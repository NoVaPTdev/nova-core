--[[
    NOVA Framework - Módulo: Commands
    Sistema de Comandos com permissões integradas
    
    Registado como módulo via Nova.RegisterModule()
    Conteúdo original: server/commands.lua
]]

Nova.RegisterModule({
    name = 'commands',
    version = '1.0.0',
    side = 'server',
    dependencies = { 'permissions' },

    Init = function(Nova)
        Nova.RegisteredCommands = {}

        -- ============================================================
        -- SISTEMA DE REGISTO
        -- ============================================================

        function Nova.Functions.RegisterCommand(name, group, handler, suggestion)
            Nova.RegisteredCommands[name] = {
                name = name,
                group = group,
                handler = handler,
            }

            RegisterCommand(name, function(source, args, rawCommand)
                if source == 0 then
                    handler(source, args, rawCommand)
                    return
                end

                if group and not Nova.Functions.HasPermission(source, group) then
                    Nova.Functions.Notify(source, _L('no_permission'), 'error')
                    return
                end

                handler(source, args, rawCommand)
            end, false)

            if suggestion then
                TriggerEvent('chat:addSuggestion', '/' .. name, suggestion.help or '', suggestion.params or {})
            end

            Nova.Debug('Comando registado: /' .. name .. (group and (' [' .. group .. ']') or ''))
        end

        --- Converte um charId (ID persistente visível no HUD) para source
        --- Retorna source do jogador, ou nil se não encontrado
        function Nova.Functions.ResolveTargetId(idInput, fallbackSource)
            local id = tonumber(idInput)
            if not id then return fallbackSource or nil end

            -- Tentar primeiro por charId (ID persistente)
            local player = Nova.Functions.GetPlayerByCharId(id)
            if player then return player.source end

            -- Fallback: tentar por source directo (compatibilidade)
            local playerBySource = Nova.Functions.GetPlayer(id)
            if playerBySource then return id end

            return nil
        end

        --- Retorna o charId (ID persistente) de um source para exibição
        function Nova.Functions.GetDisplayId(src)
            if not src then return '?' end
            local p = Nova.Functions.GetPlayer(src)
            return p and p.charid or src
        end

        Nova.Debug('[MODULE] Commands sistema registado')
    end,

    Start = function()
        -- ============================================================
        -- COMANDOS DE ADMINISTRAÇÃO
        -- ============================================================

        --- Comandos que disparam eventos no cliente precisam de um jogador válido (não consola).
        local function requirePlayer(src, commandName)
            if not src or src == 0 then
                print(('[NOVA] O comando /%s deve ser usado em jogo (não na consola do servidor).'):format(commandName or '?'))
                return false
            end
            return true
        end

        Nova.Functions.RegisterCommand('novadmin', 'admin', function(source, args)
            Nova.Functions.Notify(source, 'Painel de administração NOVA', 'info')
        end, {
            help = 'Abre o painel de administração',
        })

        Nova.Functions.RegisterCommand('setgroup', 'superadmin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            local group = args[2]

            if not targetId or not group then
                Nova.Functions.Notify(source, _L('command_usage', '/setgroup [id] [grupo]'), 'error')
                return
            end

            if not NovaGroups.AdminGroups[group] then
                Nova.Functions.Notify(source, 'Grupo inválido: ' .. group, 'error')
                return
            end

            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            target.group = group
            Nova.Database.SetUserGroup(target.identifier, group)
            Nova.Functions.RefreshPermissionCache(targetId)

            Nova.Functions.Notify(source, 'Grupo de ' .. target:GetFullName() .. ' definido para ' .. group, 'success')
            Nova.Functions.Notify(targetId, 'O teu grupo foi alterado para: ' .. NovaGroups.AdminGroups[group].label, 'info')
        end, {
            help = 'Define o grupo de permissão de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'grupo', help = 'Nome do grupo (user, vip, mod, admin, superadmin, owner)' },
            },
        })

        Nova.Functions.RegisterCommand('givemoney', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            local moneyType = args[2]
            local amount = tonumber(args[3])

            if not targetId or not moneyType or not amount then
                Nova.Functions.Notify(source, _L('command_usage', '/givemoney [id] [tipo] [quantidade]'), 'error')
                return
            end

            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            if amount <= 0 then
                Nova.Functions.Notify(source, _L('invalid_amount'), 'error')
                return
            end

            if target:AddMoney(moneyType, amount, 'Admin command') then
                Nova.Functions.Notify(source, _L('admin_give_money', Nova.FormatMoney(amount), moneyType, target:GetFullName()), 'success')
                Nova.Functions.DiscordLog('Admin: Dar Dinheiro',
                    string.format('**Admin:** %s\n**Jogador:** %s\n**Tipo:** %s\n**Quantidade:** $%s',
                        GetPlayerName(source), target:GetFullName(), moneyType, Nova.FormatMoney(amount)),
                    3066993)
            end
        end, {
            help = 'Dá dinheiro a um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'tipo', help = 'Tipo (cash, bank, black_money, gems)' },
                { name = 'quantidade', help = 'Quantidade' },
            },
        })

        Nova.Functions.RegisterCommand('removemoney', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            local moneyType = args[2]
            local amount = tonumber(args[3])

            if not targetId or not moneyType or not amount then
                Nova.Functions.Notify(source, _L('command_usage', '/removemoney [id] [tipo] [quantidade]'), 'error')
                return
            end

            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            if amount <= 0 then
                Nova.Functions.Notify(source, _L('invalid_amount'), 'error')
                return
            end

            if target:RemoveMoney(moneyType, amount, 'Admin command') then
                Nova.Functions.Notify(source, _L('admin_remove_money', Nova.FormatMoney(amount), moneyType, target:GetFullName()), 'success')
            end
        end, {
            help = 'Remove dinheiro de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'tipo', help = 'Tipo (cash, bank, black_money, gems)' },
                { name = 'quantidade', help = 'Quantidade' },
            },
        })

        Nova.Functions.RegisterCommand('setjob', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            local jobName = args[2]
            local grade = tonumber(args[3]) or 0

            if not targetId or not jobName then
                Nova.Functions.Notify(source, _L('command_usage', '/setjob [id] [emprego] [grau]'), 'error')
                return
            end

            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            if target:SetJob(jobName, grade) then
                Nova.Functions.Notify(source, _L('admin_set_job', target:GetFullName(), jobName, grade), 'success')
            end
        end, {
            help = 'Define o emprego de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'emprego', help = 'Nome do emprego' },
                { name = 'grau', help = 'Grau (número)' },
            },
        })

        Nova.Functions.RegisterCommand('setgang', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            local gangName = args[2]
            local grade = tonumber(args[3]) or 0

            if not targetId or not gangName then
                Nova.Functions.Notify(source, _L('command_usage', '/setgang [id] [gang] [grau]'), 'error')
                return
            end

            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            if target:SetGang(gangName, grade) then
                Nova.Functions.Notify(source, _L('admin_set_gang', target:GetFullName(), gangName, grade), 'success')
            end
        end, {
            help = 'Define a gang de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'gang', help = 'Nome da gang' },
                { name = 'grau', help = 'Grau (número)' },
            },
        })

        --- /group <id> <job_ou_gang> [grau] - Comando unificado para setar job OU gang
        Nova.Functions.RegisterCommand('group', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            local groupName = args[2]

            if not targetId or not groupName then
                Nova.Functions.Notify(source, _L('command_usage', '/group [id] [job/gang] [grau]'), 'error')
                return
            end

            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            groupName = groupName:lower()

            local gradeInput = args[3]
            local grade = nil

            local jobData = Nova.Functions.GetJob(groupName)
            local gangData = Nova.Functions.GetGang(groupName)

            if jobData then
                if gradeInput then
                    grade = tonumber(gradeInput)
                    if not grade then
                        for g, gData in pairs(jobData.grades) do
                            if gData.label:lower() == gradeInput:lower() then
                                grade = g
                                break
                            end
                        end
                    end
                    if not grade then
                        local available = {}
                        for g, gData in pairs(jobData.grades) do
                            available[#available + 1] = g .. '=' .. gData.label
                        end
                        table.sort(available)
                        Nova.Functions.Notify(source, 'Grau inválido. Disponíveis: ' .. table.concat(available, ', '), 'error')
                        return
                    end
                else
                    grade = 0
                end

                if target:SetJob(groupName, grade) then
                    local gradeLabel = jobData.grades[grade] and jobData.grades[grade].label or tostring(grade)
                    Nova.Functions.Notify(source, target:GetFullName() .. ' setado como ' .. jobData.label .. ' [' .. gradeLabel .. ']', 'success')
                end

            elseif gangData then
                if gradeInput then
                    grade = tonumber(gradeInput)
                    if not grade then
                        for g, gData in pairs(gangData.grades) do
                            if gData.label:lower() == gradeInput:lower() then
                                grade = g
                                break
                            end
                        end
                    end
                    if not grade then
                        local available = {}
                        for g, gData in pairs(gangData.grades) do
                            available[#available + 1] = g .. '=' .. gData.label
                        end
                        table.sort(available)
                        Nova.Functions.Notify(source, 'Grau inválido. Disponíveis: ' .. table.concat(available, ', '), 'error')
                        return
                    end
                else
                    grade = 0
                end

                if target:SetGang(groupName, grade) then
                    local gradeLabel = gangData.grades[grade] and gangData.grades[grade].label or tostring(grade)
                    Nova.Functions.Notify(source, target:GetFullName() .. ' setado como ' .. gangData.label .. ' [' .. gradeLabel .. ']', 'success')
                end

            else
                local jobList, gangList = {}, {}
                for name, data in pairs(Nova.Jobs or {}) do
                    jobList[#jobList + 1] = name
                end
                for name, data in pairs(Nova.Gangs or {}) do
                    if name ~= 'none' then gangList[#gangList + 1] = name end
                end
                table.sort(jobList)
                table.sort(gangList)
                Nova.Functions.Notify(source, 'Grupo "' .. groupName .. '" não encontrado.', 'error')
                if #jobList > 0 then
                    Nova.Functions.Notify(source, 'Jobs: ' .. table.concat(jobList, ', '), 'info')
                end
                if #gangList > 0 then
                    Nova.Functions.Notify(source, 'Gangs: ' .. table.concat(gangList, ', '), 'info')
                end
            end
        end, {
            help = 'Setar job ou gang de um jogador (unificado)',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'grupo', help = 'Nome do job ou gang' },
                { name = 'grau', help = 'Grau (número ou nome do cargo)' },
            },
        })

        Nova.Functions.RegisterCommand('giveitem', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            local itemName = args[2]
            local amount = tonumber(args[3]) or 1

            if not targetId or not itemName then
                Nova.Functions.Notify(source, _L('command_usage', '/giveitem [id] [item] [quantidade]'), 'error')
                return
            end

            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            local ok, result = pcall(function()
                return exports['nova_inventory']:AddItem(targetId, itemName, amount)
            end)

            if ok and result then
                Nova.Functions.Notify(source, 'Item \'' .. itemName .. '\' x' .. amount .. ' dado ao jogador ' .. Nova.Functions.GetDisplayId(targetId), 'success')
            elseif not ok then
                target:AddItem(itemName, amount)
            else
                Nova.Functions.Notify(source, 'Erro ao dar item (inventário cheio ou item inválido).', 'error')
            end
        end, {
            help = 'Dá um item a um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'item', help = 'Nome do item' },
                { name = 'quantidade', help = 'Quantidade' },
            },
        })

        Nova.Functions.RegisterCommand('tp', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            if not targetId then
                Nova.Functions.Notify(source, _L('command_usage', '/tp [id]'), 'error')
                return
            end

            local targetPed = GetPlayerPed(targetId)
            if not targetPed or not DoesEntityExist(targetPed) then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end

            local coords = GetEntityCoords(targetPed)
            TriggerClientEvent('nova:client:teleport', source, coords.x, coords.y, coords.z)
            Nova.Functions.Notify(source, _L('admin_teleport', GetPlayerName(targetId)), 'success')
        end, {
            help = 'Teleporta-te para um jogador',
            params = { { name = 'id', help = 'ID do jogador' } },
        })

        Nova.Functions.RegisterCommand('bring', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            if not targetId then
                Nova.Functions.Notify(source, _L('command_usage', '/bring [id]'), 'error')
                return
            end

            local sourcePed = GetPlayerPed(source)
            if not sourcePed or not DoesEntityExist(sourcePed) then return end

            local coords = GetEntityCoords(sourcePed)
            TriggerClientEvent('nova:client:teleport', targetId, coords.x, coords.y, coords.z)
            Nova.Functions.Notify(source, _L('admin_bring', GetPlayerName(targetId)), 'success')
            Nova.Functions.Notify(targetId, 'Foste trazido por um administrador.', 'info')
        end, {
            help = 'Traz um jogador para a tua posição',
            params = { { name = 'id', help = 'ID do jogador' } },
        })

        Nova.Functions.RegisterCommand('kick', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            if not targetId then
                Nova.Functions.Notify(source, _L('command_usage', '/kick [id] [motivo]'), 'error')
                return
            end

            local reason = table.concat(args, ' ', 2) or 'Sem motivo'
            local target = Nova.Functions.GetPlayer(targetId)
            if target then
                target:Kick(reason)
                Nova.Functions.Notify(source, _L('admin_kick', target:GetFullName()), 'success')
                Nova.Functions.DiscordLog('Admin: Kick',
                    string.format('**Admin:** %s\n**Jogador:** %s\n**Motivo:** %s',
                        GetPlayerName(source), target:GetFullName(), reason),
                    15158332)
            else
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
            end
        end, {
            help = 'Expulsa um jogador do servidor',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'motivo', help = 'Motivo da expulsão' },
            },
        })

        Nova.Functions.RegisterCommand('ban', 'superadmin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            if not targetId then
                Nova.Functions.Notify(source, _L('command_usage', '/ban [id] [motivo]'), 'error')
                return
            end

            local reason = table.concat(args, ' ', 2) or 'Sem motivo'
            local target = Nova.Functions.GetPlayer(targetId)
            if target then
                target:Ban(reason)
                Nova.Functions.Notify(source, _L('admin_ban', target:GetFullName()), 'success')
                Nova.Functions.DiscordLog('Admin: Ban',
                    string.format('**Admin:** %s\n**Jogador:** %s\n**Motivo:** %s',
                        GetPlayerName(source), target:GetFullName(), reason),
                    15158332)
            else
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
            end
        end, {
            help = 'Bane um jogador do servidor',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'motivo', help = 'Motivo do ban' },
            },
        })

        Nova.Functions.RegisterCommand('unban', 'superadmin', function(source, args)
            local identifier = args[1]
            if not identifier or identifier == '' then
                Nova.Functions.Notify(source, _L('command_usage', '/unban [identifier]'), 'error')
                return
            end

            -- Verificar se o identifier existe e está banido
            MySQL.single('SELECT id, name, banned FROM nova_users WHERE identifier = ?', { identifier }, function(user)
                if not user then
                    Nova.Functions.Notify(source, 'Utilizador não encontrado com esse identifier.', 'error')
                    return
                end

                if user.banned ~= 1 then
                    Nova.Functions.Notify(source, 'O utilizador ' .. (user.name or identifier) .. ' não está banido.', 'info')
                    return
                end

                Nova.Database.UnbanUser(identifier)
                Nova.Functions.Notify(source, 'Utilizador ' .. (user.name or identifier) .. ' foi desbanido com sucesso.', 'success')
                Nova.Functions.DiscordLog('Admin: Unban',
                    string.format('**Admin:** %s\n**Identifier:** %s\n**Nome:** %s',
                        GetPlayerName(source), identifier, user.name or 'N/A'),
                    3066993)
            end)
        end, {
            help = 'Remove o ban de um jogador',
            params = {
                { name = 'identifier', help = 'Identifier do jogador (ex: license:abc123)' },
            },
        })

        Nova.Functions.RegisterCommand('revive', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1], source)
            local target = Nova.Functions.GetPlayer(targetId)
            if target then
                target:Revive()
                Nova.Functions.Notify(source, _L('admin_revive', target:GetFullName()), 'success')
            else
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
            end
        end, {
            help = 'Revive um jogador',
            params = { { name = 'id', help = 'ID do jogador (vazio = tu próprio)' } },
        })

        Nova.Functions.RegisterCommand('heal', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1], source)
            local target = Nova.Functions.GetPlayer(targetId)
            if target then
                target:Heal()
                Nova.Functions.Notify(source, _L('admin_heal', target:GetFullName()), 'success')
            else
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
            end
        end, {
            help = 'Cura um jogador completamente',
            params = { { name = 'id', help = 'ID do jogador (vazio = tu próprio)' } },
        })

        Nova.Functions.RegisterCommand('servico', nil, function(source, args)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return end

            local medicJob = HospitalConfig and HospitalConfig.MedicJob or 'hospital'
            if player.gang and player.gang.name == medicJob then
                Nova.GangDuty = Nova.GangDuty or {}
                Nova.GangDuty[source] = not Nova.GangDuty[source]
                local onDuty = Nova.GangDuty[source]
                Nova.Functions.Notify(source, onDuty and 'Entraste em serviço.' or 'Saíste de serviço.', 'success')
                TriggerClientEvent('nova:hospital:dutyChanged', source, onDuty)
                TriggerEvent('nova:server:onDutyChange', source, onDuty)
                return
            end

            player:ToggleDuty()
            TriggerClientEvent('nova:hospital:dutyChanged', source, player.job.duty)
        end, {
            help = 'Entrar/Sair de serviço',
        })

        Nova.Functions.RegisterCommand('me', nil, function(source, args)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return end

            local action = table.concat(args, ' ')
            if action == '' then return end

            local name = player:GetFullName()
            local ped = GetPlayerPed(source)
            local coords = GetEntityCoords(ped)

            local players = GetPlayers()
            for _, playerId in ipairs(players) do
                local targetPed = GetPlayerPed(playerId)
                if targetPed and DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local dist = #(coords - targetCoords)
                    if dist <= 20.0 then
                        TriggerClientEvent('chat:addMessage', tonumber(playerId), {
                            template = '<div style="padding: 0.3rem; font-weight: 500; color: #c586f7;">* {0} {1}</div>',
                            args = { name, action },
                        })
                    end
                end
            end
        end, {
            help = 'Executa uma ação de roleplay',
            params = { { name = 'ação', help = 'A ação que queres fazer' } },
        })

        -- ============================================================
        -- COMANDOS DE VEÍCULOS
        -- ============================================================

        Nova.Functions.RegisterCommand('addcar', 'admin', function(source, args)
            local targetId = source
            local model = args[1]

            -- Se o primeiro argumento é um ID e há segundo argumento, é /addcar [id] [modelo]
            if tonumber(args[1]) and args[2] then
                targetId = Nova.Functions.ResolveTargetId(args[1], source)
                model = args[2]
            end

            if not model or model == '' then
                Nova.Functions.Notify(source, 'Uso: /addcar [modelo] ou /addcar [id] [modelo]', 'error')
                return
            end

            local targetPed = GetPlayerPed(targetId)
            if not targetPed or not DoesEntityExist(targetPed) then
                Nova.Functions.Notify(source, 'Jogador não encontrado.', 'error')
                return
            end

            -- Gerar placa aleatória
            local plate = 'NOVA' .. string.char(math.random(65,90)) .. math.random(100, 999)

            -- Registar o veículo na base de dados
            local player = Nova.Functions.GetPlayer(targetId)
            if player then
                MySQL.Async.execute(
                    'INSERT INTO nova_vehicles (citizenid, vehicle, plate, state, garage, fuel, engine, body, mods) VALUES (@cid, @vehicle, @plate, 0, @garage, 100, 1000.0, 1000.0, @mods)',
                    {
                        ['@cid'] = player.citizenid,
                        ['@vehicle'] = model,
                        ['@plate'] = plate,
                        ['@garage'] = 'legion',
                        ['@mods'] = '{}',
                    }
                )
            end

            TriggerClientEvent('nova:client:spawnVehicle', targetId, model, plate)
            if targetId == source then
                Nova.Functions.Notify(source, 'Veículo \'' .. model .. '\' gerado e registado! Placa: ' .. plate, 'success')
            else
                Nova.Functions.Notify(source, 'Veículo \'' .. model .. '\' gerado para jogador ' .. Nova.Functions.GetDisplayId(targetId) .. '. Placa: ' .. plate, 'success')
            end
        end, {
            help = 'Gera um veículo e regista na garagem',
            params = {
                { name = 'modelo/id', help = 'Nome do modelo ou ID do jogador' },
                { name = 'modelo', help = '(Opcional) Nome do modelo se o primeiro for o ID' },
            },
        })

        Nova.Functions.RegisterCommand('car', 'admin', function(source, args)
            if not requirePlayer(source, 'car') then return end
            local model = args[1]
            if not model or model == '' then
                Nova.Functions.Notify(source, 'Uso: /car [modelo]', 'error')
                return
            end

            TriggerClientEvent('nova:client:spawnVehicle', source, model)
        end, {
            help = 'Spawna um veículo temporário (sem registar na garagem)',
            params = {
                { name = 'modelo', help = 'Nome do modelo do veículo' },
            },
        })

        Nova.Functions.RegisterCommand('dv', 'admin', function(source, args)
            if not requirePlayer(source, 'dv') then return end
            TriggerClientEvent('nova:client:deleteVehicle', source)
        end, {
            help = 'Apaga o veículo atual ou mais próximo',
        })

        Nova.Functions.RegisterCommand('fix', 'admin', function(source, args)
            if not requirePlayer(source, 'fix') then return end
            TriggerClientEvent('nova:client:fixVehicle', source)
        end, {
            help = 'Repara o veículo atual',
        })

        -- ============================================================
        -- COMANDOS DE TELEPORTE
        -- ============================================================

        Nova.Functions.RegisterCommand('tpm', 'admin', function(source, args)
            if not requirePlayer(source, 'tpm') then return end
            TriggerClientEvent('nova:client:teleportMarker', source)
        end, {
            help = 'Teleporta para o marcador no mapa',
        })

        Nova.Functions.RegisterCommand('tpcoords', 'admin', function(source, args)
            if not requirePlayer(source, 'tpcoords') then return end
            local x = tonumber(args[1])
            local y = tonumber(args[2])
            local z = tonumber(args[3])
            if not x or not y or not z then
                Nova.Functions.Notify(source, 'Uso: /tpcoords [x] [y] [z]', 'error')
                return
            end
            TriggerClientEvent('nova:client:teleport', source, x, y, z)
            Nova.Functions.Notify(source, string.format('Teleportado para %.1f, %.1f, %.1f', x, y, z), 'success')
        end, {
            help = 'Teleporta para coordenadas específicas',
            params = {
                { name = 'x', help = 'Coordenada X' },
                { name = 'y', help = 'Coordenada Y' },
                { name = 'z', help = 'Coordenada Z' },
            },
        })

        -- ============================================================
        -- COMANDOS DE JOGADOR
        -- ============================================================

        Nova.Functions.RegisterCommand('nc', 'admin', function(source, args)
            if not requirePlayer(source, 'nc') then return end
            TriggerClientEvent('nova:client:toggleNoclip', source)
        end, {
            help = 'Ativa/desativa noclip',
        })

        Nova.Functions.RegisterCommand('god', 'admin', function(source, args)
            local target = Nova.Functions.ResolveTargetId(args[1], source)
            if not target or target == 0 then
                if source == 0 then
                    print('[NOVA] O comando /god deve ser usado em jogo ou com um ID: /god [id]')
                else
                    Nova.Functions.Notify(source, 'Jogador não encontrado.', 'error')
                end
                return
            end
            TriggerClientEvent('nova:client:toggleGodmode', target)

            -- Limpar is_dead no server
            local player = Nova.Functions.GetPlayer(target)
            if player and player.metadata and player.metadata.is_dead then
                player:SetMetadata('is_dead', false)
                player:SetMetadata('health', 200)
            end

            -- Restaurar hunger/thirst
            if player then
                player.metadata.hunger = 100
                player.metadata.thirst = 100
                player:UpdateClient('metadata')
            end

            if target ~= source then
                local targetPlayer = Nova.Functions.GetPlayer(target)
                local displayId = targetPlayer and targetPlayer.charid or target
                Nova.Functions.Notify(source, 'Jogador ID ' .. displayId .. ' curado.', 'success')
            end
        end, {
            help = 'Cura completa (vida, armadura, comida, bebida) + revive',
            params = {
                { name = 'id', help = 'ID do jogador (opcional)', type = 'number', optional = true },
            },
        })

        Nova.Functions.RegisterCommand('invisible', 'admin', function(source, args)
            if not requirePlayer(source, 'invisible') then return end
            TriggerClientEvent('nova:client:toggleInvisible', source)
        end, {
            help = 'Ativa/desativa invisibilidade',
        })

        Nova.Functions.RegisterCommand('tpcds', 'admin', function(source, args)
            if not requirePlayer(source, 'tpcds') then return end
            TriggerClientEvent('nova:client:tpCoordsInput', source)
        end, {
            help = 'Teleportar para coordenadas (abre painel)',
        })

        Nova.Functions.RegisterCommand('coords', nil, function(source, args)
            if not requirePlayer(source, 'coords') then return end
            local ped = GetPlayerPed(source)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local coordStr = string.format('%.2f, %.2f, %.2f', coords.x, coords.y, coords.z)
            local fullMsg = string.format('X: %.2f | Y: %.2f | Z: %.2f | H: %.2f', coords.x, coords.y, coords.z, heading)
            TriggerClientEvent('nova:client:copyCoords', source, coordStr, fullMsg)
        end, {
            help = 'Copia as tuas coordenadas para o clipboard',
        })

        Nova.Functions.RegisterCommand('status', nil, function(source, args)
            local count = 0
            local list = {}
            for _, playerId in ipairs(GetPlayers()) do
                count = count + 1
                local player = Nova.Functions.GetPlayer(tonumber(playerId))
                local displayId = player and player.charid or playerId
                local name = GetPlayerName(playerId)
                list[#list + 1] = '[' .. displayId .. '] ' .. name
            end
            Nova.Functions.Notify(source, 'Jogadores online: ' .. count, 'info')
        end, {
            help = 'Lista jogadores online',
        })

        -- ============================================================
        -- COMANDOS DE INVENTÁRIO / STATUS
        -- ============================================================

        Nova.Functions.RegisterCommand('clearinv', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1])
            if not targetId then
                Nova.Functions.Notify(source, 'Uso: /clearinv [id]', 'error')
                return
            end
            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, 'Jogador não encontrado.', 'error')
                return
            end
            pcall(function()
                exports['nova_inventory']:ClearInventory(targetId)
            end)
            Nova.Functions.Notify(source, 'Inventário do jogador ' .. Nova.Functions.GetDisplayId(targetId) .. ' limpo.', 'success')
            Nova.Functions.Notify(targetId, 'O teu inventário foi limpo por um administrador.', 'info')
        end, {
            help = 'Limpa o inventário de um jogador',
            params = { { name = 'id', help = 'ID do jogador' } },
        })

        Nova.Functions.RegisterCommand('sethunger', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1], source)
            local value = tonumber(args[2]) or 100
            value = math.max(0, math.min(100, value))
            pcall(function()
                exports['nova_core']:SetPlayerMetadata(targetId, 'hunger', value)
            end)
            Nova.Functions.Notify(source, 'Fome do jogador ' .. Nova.Functions.GetDisplayId(targetId) .. ' definida para ' .. value, 'success')
        end, {
            help = 'Define a fome de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'valor', help = 'Valor (0-100)' },
            },
        })

        Nova.Functions.RegisterCommand('setthirst', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1], source)
            local value = tonumber(args[2]) or 100
            value = math.max(0, math.min(100, value))
            pcall(function()
                exports['nova_core']:SetPlayerMetadata(targetId, 'thirst', value)
            end)
            Nova.Functions.Notify(source, 'Sede do jogador ' .. Nova.Functions.GetDisplayId(targetId) .. ' definida para ' .. value, 'success')
        end, {
            help = 'Define a sede de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'valor', help = 'Valor (0-100)' },
            },
        })

        Nova.Functions.RegisterCommand('setarmor', 'admin', function(source, args)
            local targetId = Nova.Functions.ResolveTargetId(args[1], source)
            local value = tonumber(args[2]) or 100
            TriggerClientEvent('nova:client:setArmor', targetId, value)
            Nova.Functions.Notify(source, 'Armadura do jogador ' .. Nova.Functions.GetDisplayId(targetId) .. ' definida para ' .. value, 'success')
        end, {
            help = 'Define a armadura de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'valor', help = 'Valor (0-100)' },
            },
        })

        -- ============================================================
        -- COMANDO /CDS (Atalho para coordenadas)
        -- ============================================================

        Nova.Functions.RegisterCommand('cds', nil, function(source, args)
            local ped = GetPlayerPed(source)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local msg = string.format('X: %.2f | Y: %.2f | Z: %.2f | H: %.2f', coords.x, coords.y, coords.z, heading)
            Nova.Functions.Notify(source, msg, 'info')
        end, {
            help = 'Mostra as tuas coordenadas atuais',
        })

        Nova.Functions.RegisterCommand('pesoadmin', 'admin', function(source, args)
            local target = Nova.Functions.ResolveTargetId(args[1], source)
            local targetPlayer = Nova.Functions.GetPlayer(target)
            local displayId = targetPlayer and targetPlayer.charid or target
            local ok, enabled = exports['nova_inventory']:ToggleInfiniteWeight(target)
            if ok then
                if enabled then
                    Nova.Functions.Notify(source, 'Peso infinito ATIVADO para ID ' .. displayId, 'success')
                else
                    Nova.Functions.Notify(source, 'Peso infinito DESATIVADO para ID ' .. displayId, 'error')
                end
            end
        end, {
            help = 'Ativar/desativar peso infinito no inventário',
            params = {
                { name = 'id', help = 'ID do jogador (opcional, default = tu)', type = 'number', optional = true },
            },
        })

        Nova.Debug('[MODULE] Commands iniciados')
    end,
})
