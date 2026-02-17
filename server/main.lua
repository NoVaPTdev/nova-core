--[[
    NOVA Framework - Main Server
    Ponto de entrada principal do servidor
    Gestão de conexões, carregamento de personagens e loops
]]

local isFrameworkReady = false

-- ============================================================
-- INICIALIZAÇÃO
-- ============================================================

CreateThread(function()
    -- Inicializar base de dados
    Nova.Database.Initialize()

    -- Aguardar a base de dados estar pronta
    Wait(1000)

    -- Carregar empregos e gangs para cache
    Nova.Functions.LoadJobs()
    Nova.Functions.LoadGangs()

    -- Aguardar cache carregar
    Wait(1000)

    -- Carregar módulos (permissions, commands, jobs)
    local initCount, startCount = Nova.LoadModules()
    Nova.Print(string.format('Módulos carregados: %d inicializados, %d arrancados', initCount, startCount))

    isFrameworkReady = true
    Nova.Print(_L('framework_started', Nova.Version))
    Nova.Print(string.format('Servidor: %s', NovaConfig.ServerName))

    TriggerEvent('nova:server:onFrameworkReady')
end)

-- ============================================================
-- CONEXÃO DO JOGADOR
-- ============================================================

--- Evento quando um jogador tenta conectar
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    Wait(0)

    deferrals.update(string.format('Bem-vindo ao %s!\nA verificar os teus dados...', NovaConfig.ServerName))

    -- Aguardar framework estar pronto
    while not isFrameworkReady do
        Wait(100)
    end

    -- Obter identificador principal
    local identifier = Nova.Functions.GetIdentifier(source, NovaConfig.IdentifierType)

    if not identifier then
        deferrals.done('Não foi possível identificar-te. Certifica-te que tens o ' .. NovaConfig.IdentifierType .. ' ativo.')
        return
    end

    Wait(500)
    deferrals.update('A verificar se estás banido...')

    -- Verificar ban
    Nova.Database.IsUserBanned(identifier, function(banned, reason)
        if banned then
            deferrals.done(_L('player_banned', reason))
            return
        end

        deferrals.update('A preparar a tua sessão...')

        -- Obter ou criar utilizador
        local identifiers = Nova.Functions.GetAllIdentifiers(source)
        Nova.Database.GetOrCreateUser(identifier, name, identifiers, function(user)
            if not user then
                deferrals.done('Ocorreu um erro ao carregar o teu perfil. Tenta novamente.')
                return
            end

            Wait(500)
            deferrals.done()

            Nova.Print(_L('player_connected', name .. ' [' .. source .. ']'))
        end)
    end)
end)

-- ============================================================
-- CARREGAMENTO DE PERSONAGEM
-- ============================================================

--- Evento para carregar um personagem (chamado após seleção)
RegisterNetEvent('nova:server:loadCharacter', function(citizenId)
    local source = source
    local identifier = Nova.Functions.GetIdentifier(source, NovaConfig.IdentifierType)

    if not identifier then
        DropPlayer(source, 'Identificador não encontrado.')
        return
    end

    -- Verificar se o jogador já está carregado
    if Nova.Functions.GetPlayer(source) then
        Nova.Warn('Jogador ' .. source .. ' já tem um personagem carregado.')
        return
    end

    -- Obter dados do utilizador
    Nova.Database.GetOrCreateUser(identifier, GetPlayerName(source), Nova.Functions.GetAllIdentifiers(source), function(user)
        if not user then
            Nova.Error('Erro ao obter utilizador para source: ' .. source)
            return
        end

        -- Obter dados do personagem
        Nova.Database.GetCharacter(citizenId, function(charData)
            if not charData then
                Nova.Error('Personagem não encontrado: ' .. citizenId)
                return
            end

            -- Verificar se o personagem pertence ao utilizador
            if charData.user_id ~= user.id then
                Nova.Error('Tentativa de carregar personagem de outro utilizador!')
                DropPlayer(source, 'Erro de segurança.')
                return
            end

            -- Criar objeto Player
            local player = Nova.Player.New(source, user, charData)

            -- Registar no sistema
            Nova.Players[tostring(source)] = player

            -- Enviar dados para o client
            TriggerClientEvent('nova:client:onPlayerLoaded', source, player:GetData())

            -- Definir routing bucket (se necessário)
            SetPlayerRoutingBucket(source, 0)

            Nova.Print(string.format('Personagem carregado: %s (%s) - Source: %s',
                player:GetFullName(), player.citizenid, source))

            -- Trigger evento para outros resources (wrapped para preservar métodos cross-resource)
            TriggerEvent('nova:server:onPlayerLoaded', source, Nova.WrapPlayerForExport(player))
        end)
    end)
end)

-- ============================================================
-- CRIAÇÃO DE PERSONAGEM (com rate-limiting)
-- ============================================================

local createCharCooldowns = {} -- [source] = timestamp

RegisterNetEvent('nova:server:createCharacter', function(charData)
    local source = source
    local now = os.time()

    -- Rate-limiting: 1 criação a cada 10 segundos por source
    if createCharCooldowns[source] and (now - createCharCooldowns[source]) < 10 then
        Nova.Functions.Notify(source, 'Aguarda antes de criar outro personagem.', 'error')
        return
    end
    createCharCooldowns[source] = now

    local identifier = Nova.Functions.GetIdentifier(source, NovaConfig.IdentifierType)

    if not identifier then return end

    -- Validar dados básicos do personagem
    if not charData or type(charData) ~= 'table' then return end
    if not charData.firstname or type(charData.firstname) ~= 'string' or #charData.firstname < 2 then
        Nova.Functions.Notify(source, 'Nome inválido.', 'error')
        return
    end
    if not charData.lastname or type(charData.lastname) ~= 'string' or #charData.lastname < 2 then
        Nova.Functions.Notify(source, 'Apelido inválido.', 'error')
        return
    end

    Nova.Database.GetOrCreateUser(identifier, GetPlayerName(source), Nova.Functions.GetAllIdentifiers(source), function(user)
        if not user then return end

        -- Verificar limite de personagens
        Nova.Database.GetCharacters(user.id, function(characters)
            if #characters >= NovaConfig.MaxCharacters then
                Nova.Functions.Notify(source, _L('char_max_reached'), 'error')
                return
            end

            -- Gerar CitizenID e telefone únicos
            Nova.Functions.GenerateUniqueCitizenId(function(citizenId)
                Nova.Functions.GeneratePhoneNumber(function(phone)
                    charData.phone = phone

                    Nova.Database.CreateCharacter(user.id, citizenId, charData, function(success, charId)
                        if success then
                            Nova.Functions.Notify(source, _L('char_create_success'), 'success')
                            TriggerClientEvent('nova:client:characterCreated', source, citizenId)
                            Nova.Debug('Personagem criado: ' .. citizenId .. ' para user ' .. user.id)
                        else
                            Nova.Functions.Notify(source, 'Erro ao criar personagem.', 'error')
                        end
                    end)
                end)
            end)
        end)
    end)
end)

-- Limpar cooldown ao desconectar
AddEventHandler('playerDropped', function()
    createCharCooldowns[source] = nil
end)

-- ============================================================
-- ELIMINAÇÃO DE PERSONAGEM
-- ============================================================

RegisterNetEvent('nova:server:deleteCharacter', function(citizenId)
    local source = source
    local identifier = Nova.Functions.GetIdentifier(source, NovaConfig.IdentifierType)

    if not identifier then return end

    Nova.Database.GetOrCreateUser(identifier, GetPlayerName(source), Nova.Functions.GetAllIdentifiers(source), function(user)
        if not user then return end

        -- Verificar se o personagem pertence ao utilizador
        Nova.Database.GetCharacter(citizenId, function(charData)
            if not charData or charData.user_id ~= user.id then
                Nova.Error('Tentativa de eliminar personagem de outro utilizador!')
                return
            end

            Nova.Database.DeleteCharacter(citizenId, function(success)
                if success then
                    Nova.Functions.Notify(source, _L('char_delete_success'), 'success')
                    TriggerClientEvent('nova:client:characterDeleted', source, citizenId)
                else
                    Nova.Functions.Notify(source, 'Erro ao eliminar personagem.', 'error')
                end
            end)
        end)
    end)
end)

-- ============================================================
-- DESCONEXÃO DO JOGADOR
-- ============================================================

AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = Nova.Functions.GetPlayer(source)

    if player then
        player:Save()
        Nova.Players[tostring(source)] = nil
        Nova.Print(_L('player_disconnected', player:GetFullName() .. ' [' .. source .. ']') .. ' - Motivo: ' .. reason)
        TriggerEvent('nova:server:onPlayerDropped', source, player.citizenid, reason)
    end
end)

-- ============================================================
-- ATUALIZAÇÃO DE POSIÇÃO (com validação de coordenadas)
-- ============================================================

RegisterNetEvent('nova:server:updatePosition', function(coords)
    local source = source
    local player = Nova.Functions.GetPlayer(source)

    if not player or not coords then return end
    if type(coords) ~= 'table' then return end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)
    local w = tonumber(coords.w) or 0.0

    if not x or not y or not z then return end

    -- Validar limites do mapa GTA V (prevenir teleport exploits)
    if x < -4500 or x > 6500 or y < -5000 or y > 9500 or z < -200 or z > 2000 then
        Nova.Warn(string.format('Coordenadas suspeitas de source %d: %.1f, %.1f, %.1f', source, x, y, z))
        return
    end

    player:SetPosition(vector4(x, y, z, w))
end)

-- ============================================================
-- ATUALIZAÇÃO DE METADATA (Hunger/Thirst do client)
-- ============================================================

RegisterNetEvent('nova:server:updateMetadata', function(data)
    local source = source
    local player = Nova.Functions.GetPlayer(source)

    if not player or not data or type(data) ~= 'table' then return end

    -- Atualizar apenas campos permitidos pelo client (hunger, thirst)
    if data.hunger ~= nil then
        local hunger = tonumber(data.hunger)
        if hunger and hunger >= 0 and hunger <= 100 then
            player.metadata.hunger = hunger
        end
    end

    if data.thirst ~= nil then
        local thirst = tonumber(data.thirst)
        if thirst and thirst >= 0 and thirst <= 100 then
            player.metadata.thirst = thirst
        end
    end
end)

-- ============================================================
-- VALIDAÇÃO DE MORTE (server-side)
-- ============================================================

RegisterNetEvent('nova:server:onPlayerDeath', function()
    local source = source
    local player = Nova.Functions.GetPlayer(source)
    if not player then return end

    -- Verificar que o jogador realmente morreu (server-side)
    local ped = GetPlayerPed(source)
    if ped and DoesEntityExist(ped) then
        local health = GetEntityHealth(ped)
        if health > 0 then
            Nova.Warn(string.format('Morte reportada por source %d mas saúde = %d (ignorado)', source, health))
            return
        end
    end

    if player.metadata and not player.metadata.is_dead then
        player:SetMetadata('is_dead', true)
        TriggerEvent('nova:server:onPlayerDeath', source)
        Nova.Debug('Jogador morreu (validado server): ' .. player:GetFullName())
    end
end)

-- ============================================================
-- SALVAMENTO AUTOMÁTICO
-- ============================================================

if NovaConfig.AutoSave.enabled then
    CreateThread(function()
        while true do
            Wait(NovaConfig.AutoSave.interval)

            local count = 0
            for _, player in pairs(Nova.Players) do
                player:Save()
                count = count + 1
            end

            if count > 0 then
                Nova.Debug(_L('auto_save') .. ' (' .. count .. ' jogadores)')
            end
        end
    end)
end

-- ============================================================
-- EVENTO DE PARAGEM DO RESOURCE
-- ============================================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    Nova.Print(_L('framework_stopping'))

    -- Salvar todos os jogadores
    for _, player in pairs(Nova.Players) do
        player:Save()
    end

    Nova.Print('Todos os jogadores foram guardados.')
end)

-- ============================================================
-- EXPORTS ADICIONAIS (com Auth Gating)
-- ============================================================

--- PÚBLICO: Verificação básica de estado
exports('IsFrameworkReady', function()
    return isFrameworkReady
end)

--- SENSÍVEL: Dados de configuração de empregos
exports('GetJobs', function()
    if not Nova.Auth:Gate('GetJobs') then return {} end
    return Nova.Jobs
end)

--- SENSÍVEL: Dados de configuração de gangs
exports('GetGangs', function()
    if not Nova.Auth:Gate('GetGangs') then return {} end
    return Nova.Gangs
end)
