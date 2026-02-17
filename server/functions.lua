--[[
    NOVA Framework - Funções do Server
    Funções utilitárias e de gestão de jogadores (server-side)
]]

-- Cache de empregos e gangs
Nova.Jobs = {}
Nova.Gangs = {}

-- ============================================================
-- IDENTIFICADORES
-- ============================================================

--- Obtém um identificador específico do jogador
---@param source number ID do jogador
---@param idType string Tipo de identificador (license, steam, discord, fivem)
---@return string|nil
function Nova.Functions.GetIdentifier(source, idType)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, idType .. ':') then
            return identifier
        end
    end
    return nil
end

--- Obtém todos os identificadores do jogador
---@param source number ID do jogador
---@return table
function Nova.Functions.GetAllIdentifiers(source)
    local identifiers = GetPlayerIdentifiers(source)
    local result = {}

    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, 'license:') then
            result.license = identifier
        elseif string.find(identifier, 'steam:') then
            result.steam = identifier
        elseif string.find(identifier, 'discord:') then
            result.discord = identifier
        elseif string.find(identifier, 'fivem:') then
            result.fivem = identifier
        end
    end

    return result
end

-- ============================================================
-- GESTÃO DE JOGADORES
-- ============================================================

--- Obtém um jogador pelo source
---@param source number ID do jogador
---@return table|nil Player object
function Nova.Functions.GetPlayer(source)
    return Nova.Players[tostring(source)]
end

--- Obtém um jogador pelo CitizenID
---@param citizenId string CitizenID do jogador
---@return table|nil Player object
function Nova.Functions.GetPlayerByCitizenId(citizenId)
    for _, player in pairs(Nova.Players) do
        if player.citizenid == citizenId then
            return player
        end
    end
    return nil
end

--- Obtém todos os jogadores carregados
---@return table
function Nova.Functions.GetPlayers()
    local players = {}
    for src, player in pairs(Nova.Players) do
        players[#players + 1] = {
            source = tonumber(src),
            player = player,
        }
    end
    return players
end

--- Obtém a contagem de jogadores online
---@return number
function Nova.Functions.GetPlayerCount()
    return Nova.TableCount(Nova.Players)
end

--- Gera um CitizenID único que não existe na base de dados
---@param callback function Callback com o CitizenID gerado
function Nova.Functions.GenerateUniqueCitizenId(callback)
    local citizenId = Nova.GenerateCitizenId()

    MySQL.single('SELECT citizenid FROM nova_characters WHERE citizenid = ?', { citizenId }, function(result)
        if result then
            -- Se já existe, tentar novamente
            Nova.Functions.GenerateUniqueCitizenId(callback)
        else
            callback(citizenId)
        end
    end)
end

--- Gera um número de telefone único
---@param callback function Callback com o número gerado
function Nova.Functions.GeneratePhoneNumber(callback)
    local phone = '9' .. tostring(math.random(10000000, 99999999))

    MySQL.single('SELECT phone FROM nova_characters WHERE phone = ?', { phone }, function(result)
        if result then
            Nova.Functions.GeneratePhoneNumber(callback)
        else
            callback(phone)
        end
    end)
end

-- ============================================================
-- EMPREGOS E GANGS
-- ============================================================

--- Carrega todos os empregos da base de dados para cache
function Nova.Functions.LoadJobs()
    Nova.Database.GetAllJobs(function(jobs)
        Nova.Jobs = jobs
        Nova.Print('Empregos carregados: ' .. Nova.TableCount(jobs))
    end)
end

--- Carrega todas as gangs da base de dados para cache
function Nova.Functions.LoadGangs()
    Nova.Database.GetAllGangs(function(gangs)
        Nova.Gangs = gangs
        Nova.Print('Gangs carregadas: ' .. Nova.TableCount(gangs))
    end)
end

--- Obtém dados de um emprego do cache
---@param jobName string Nome do emprego
---@return table|nil
function Nova.Functions.GetJob(jobName)
    return Nova.Jobs[jobName]
end

--- Obtém dados de uma gang do cache
---@param gangName string Nome da gang
---@return table|nil
function Nova.Functions.GetGang(gangName)
    return Nova.Gangs[gangName]
end

-- ============================================================
-- NOTIFICAÇÕES
-- ============================================================

--- Envia uma notificação para um jogador
---@param source number ID do jogador
---@param message string Mensagem
---@param type string Tipo (success, error, info, warning)
---@param duration number Duração em ms (padrão: 5000)
function Nova.Functions.Notify(source, message, type, duration)
    if not source or source == 0 then
        -- Consola do servidor - apenas print
        print('[NOVA] [' .. (type or 'info') .. '] ' .. tostring(message))
        return
    end
    TriggerClientEvent('nova:client:notify', source, {
        message = message,
        type = type or 'info',
        duration = duration or 5000,
    })
end

--- Envia uma notificação para todos os jogadores
---@param message string Mensagem
---@param type string Tipo
---@param duration number Duração em ms
function Nova.Functions.NotifyAll(message, type, duration)
    TriggerClientEvent('nova:client:notify', -1, {
        message = message,
        type = type or 'info',
        duration = duration or 5000,
    })
end

-- ============================================================
-- VERIFICAÇÃO DE PERMISSÕES
-- Implementação completa em server/permissions.lua (cache O(1) + ACE bridge)
-- As funções HasPermission, HasPermissionNode, IsAdmin, etc. são definidas lá
-- ============================================================

-- ============================================================
-- UTILIDADES
-- ============================================================

--- Envia um log para o Discord (via webhook)
---@param title string Título do embed
---@param message string Mensagem
---@param color number Cor do embed (decimal)
function Nova.Functions.DiscordLog(title, message, color)
    if NovaConfig.DiscordWebhook == '' then return end

    PerformHttpRequest(NovaConfig.DiscordWebhook, function() end, 'POST',
        json.encode({
            embeds = {{
                title = title,
                description = message,
                color = color or 3447003,
                footer = {
                    text = NovaConfig.ServerName .. ' | NOVA Framework'
                },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            }}
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

-- ============================================================
-- EXPORTS (com Auth Gating)
-- ============================================================

-- ============================================================
-- WRAP PLAYER PARA EXPORTS
-- Metatables são perdidas ao cruzar a fronteira de exports.
-- Esta função liga todos os métodos da classe Player directamente
-- ao objecto retornado, apontando para o player REAL (referência partilhada).
-- ============================================================

function Nova.WrapPlayerForExport(player)
    if not player then return nil end

    local wrapped = {}

    -- Copiar todas as propriedades (mesmas referências de tabela)
    for k, v in pairs(player) do
        wrapped[k] = v
    end

    -- Ligar todos os métodos da classe Player directamente
    for k, v in pairs(Nova.Player) do
        if type(v) == 'function' and k ~= '__index' and k ~= 'New' then
            wrapped[k] = function(_, ...)
                return v(player, ...)
            end
        end
    end

    return wrapped
end

-- CRÍTICOS: Gating obrigatório
exports('GetPlayer', function(source)
    if not Nova.Auth:Gate('GetPlayer') then return nil end
    return Nova.WrapPlayerForExport(Nova.Functions.GetPlayer(source))
end)

exports('GetPlayerByCitizenId', function(citizenId)
    if not Nova.Auth:Gate('GetPlayerByCitizenId') then return nil end
    return Nova.WrapPlayerForExport(Nova.Functions.GetPlayerByCitizenId(citizenId))
end)

exports('GetPlayers', function()
    if not Nova.Auth:Gate('GetPlayers') then return {} end
    local players = {}
    for src, player in pairs(Nova.Players) do
        players[#players + 1] = {
            source = tonumber(src),
            player = Nova.WrapPlayerForExport(player),
        }
    end
    return players
end)

exports('SetPlayerMetadata', function(source, key, value)
    if not Nova.Auth:Gate('SetPlayerMetadata') then return false end
    local Player = Nova.Functions.GetPlayer(source)
    if Player then
        Player:SetMetadata(key, value)
        return true
    end
    return false
end)

exports('CreateCallback', function(name, handler)
    if not Nova.Auth:Gate('CreateCallback') then return end
    Nova.Functions.CreateCallback(name, handler)
end)

exports('LoginPlayer', function(source, userData, charData)
    if not Nova.Auth:Gate('LoginPlayer') then return nil end
    local player = Nova.Player.New(source, userData, charData)
    if not player then return nil end
    Nova.Players[tostring(source)] = player
    TriggerClientEvent('nova:client:onPlayerLoaded', source, player:GetData())
    TriggerEvent('nova:server:onPlayerLoaded', source, Nova.WrapPlayerForExport(player))
    return player:GetData()
end)

exports('LogoutPlayer', function(source)
    if not Nova.Auth:Gate('LogoutPlayer') then return end
    local player = Nova.Functions.GetPlayer(source)
    if player then
        player:Logout()
    end
end)

exports('AddPlayerMoney', function(source, moneyType, amount)
    if not Nova.Auth:Gate('AddPlayerMoney') then return false end
    local player = Nova.Functions.GetPlayer(source)
    if player then
        return player:AddMoney(moneyType, amount)
    end
    return false
end)

exports('RemovePlayerMoney', function(source, moneyType, amount, silent)
    if not Nova.Auth:Gate('RemovePlayerMoney') then return false end
    local player = Nova.Functions.GetPlayer(source)
    if player then
        return player:RemoveMoney(moneyType, amount, nil, silent)
    end
    return false
end)

exports('SetPlayerInventory', function(source, inventory)
    if not Nova.Auth:Gate('SetPlayerInventory') then return false end
    local player = Nova.Functions.GetPlayer(source)
    if player then
        player.inventory = inventory
        return true
    end
    return false
end)

exports('SetPlayerSkin', function(source, skinData)
    if not Nova.Auth:Gate('SetPlayerSkin') then return false end
    local player = Nova.Functions.GetPlayer(source)
    if player then
        player.skin = skinData
        return true
    end
    return false
end)

exports('SavePlayer', function(source)
    if not Nova.Auth:Gate('SavePlayer') then return false end
    local player = Nova.Functions.GetPlayer(source)
    if player then
        player:Save()
        return true
    end
    return false
end)

-- SENSÍVEIS: Gating recomendado
exports('Notify', function(source, message, type, duration)
    if not Nova.Auth:Gate('Notify') then return end
    Nova.Functions.Notify(source, message, type, duration)
end)

exports('HasPermission', function(source, group)
    if not Nova.Auth:Gate('HasPermission') then return false end
    return Nova.Functions.HasPermission(source, group)
end)

exports('HasPermissionNode', function(source, permission)
    if not Nova.Auth:Gate('HasPermissionNode') then return false end
    return Nova.Functions.HasPermissionNode(source, permission)
end)

exports('IsAdmin', function(source)
    if not Nova.Auth:Gate('IsAdmin') then return false end
    return Nova.Functions.IsAdmin(source)
end)

exports('GetPlayerJobConfig', function(source)
    if not Nova.Auth:Gate('GetPlayerJobConfig') then return nil end
    return Nova.Functions.GetPlayerJobConfig(source)
end)

exports('GetPlayerGangConfig', function(source)
    if not Nova.Auth:Gate('GetPlayerGangConfig') then return nil end
    return Nova.Functions.GetPlayerGangConfig(source)
end)

exports('GetPlayerJobVehicles', function(source)
    if not Nova.Auth:Gate('GetPlayerJobVehicles') then return {} end
    return Nova.Functions.GetPlayerJobVehicles(source)
end)

exports('GetJobConfig', function(jobName)
    if not Nova.Auth:Gate('GetJobConfig') then return nil end
    return NovaGroups.Jobs[jobName]
end)

exports('GetGangConfig', function(gangName)
    if not Nova.Auth:Gate('GetGangConfig') then return nil end
    return NovaGroups.Gangs[gangName]
end)

-- SENSÍVEL: Informação de estado
exports('IsPlayerLoaded', function(source)
    if not Nova.Auth:Gate('IsPlayerLoaded') then return false end
    return Nova.Functions.GetPlayer(source) ~= nil
end)
