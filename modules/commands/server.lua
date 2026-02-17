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

        Nova.Debug('[MODULE] Commands sistema registado')
    end,

    Start = function()
        -- ============================================================
        -- COMANDOS DE ADMINISTRAÇÃO
        -- ============================================================

        Nova.Functions.RegisterCommand('novadmin', 'admin', function(source, args)
            Nova.Functions.Notify(source, _L('admin_panel'), 'info')
        end, {
            help = 'Abre o painel de administração',
        })

        Nova.Functions.RegisterCommand('setgroup', 'superadmin', function(source, args)
            local targetId = tonumber(args[1])
            local group = args[2]

            if not targetId or not group then
                Nova.Functions.Notify(source, _L('command_usage', '/setgroup [id] [grupo]'), 'error')
                return
            end

            if not NovaGroups.AdminGroups[group] then
                Nova.Functions.Notify(source, _L('admin_invalid_group', group), 'error')
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

            Nova.Functions.Notify(source, _L('admin_group_set', target:GetFullName(), group), 'success')
            Nova.Functions.Notify(targetId, 'O teu grupo foi alterado para: ' .. NovaGroups.AdminGroups[group].label, 'info')
        end, {
            help = 'Define o grupo de permissão de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'grupo', help = 'Nome do grupo (user, vip, mod, admin, superadmin, owner)' },
            },
        })

        Nova.Functions.RegisterCommand('givemoney', 'admin', function(source, args)
            local targetId = tonumber(args[1])
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
                { name = 'tipo', help = 'Tipo (cash, bank, black_money)' },
                { name = 'quantidade', help = 'Quantidade' },
            },
        })

        Nova.Functions.RegisterCommand('removemoney', 'admin', function(source, args)
            local targetId = tonumber(args[1])
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
                { name = 'tipo', help = 'Tipo (cash, bank, black_money)' },
                { name = 'quantidade', help = 'Quantidade' },
            },
        })

        Nova.Functions.RegisterCommand('setjob', 'admin', function(source, args)
            local targetId = tonumber(args[1])
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
            local targetId = tonumber(args[1])
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

        Nova.Functions.RegisterCommand('giveitem', 'admin', function(source, args)
            local targetId = tonumber(args[1])
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
                Nova.Functions.Notify(source, _L('admin_give_item', itemName, amount, targetId), 'success')
            elseif not ok then
                target:AddItem(itemName, amount)
            else
                Nova.Functions.Notify(source, _L('admin_give_item_error'), 'error')
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
            local targetId = tonumber(args[1])
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
            local targetId = tonumber(args[1])
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
            local targetId = tonumber(args[1])
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
            local targetId = tonumber(args[1])
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
                    Nova.Functions.Notify(source, _L('admin_user_not_found'), 'error')
                    return
                end

                if user.banned ~= 1 then
                    Nova.Functions.Notify(source, _L('admin_not_banned', user.name or identifier), 'info')
                    return
                end

                Nova.Database.UnbanUser(identifier)
                Nova.Functions.Notify(source, _L('admin_unbanned', user.name or identifier), 'success')
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
            local targetId = tonumber(args[1]) or source
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
            local targetId = tonumber(args[1]) or source
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

        Nova.Functions.RegisterCommand('duty', nil, function(source, args)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return end
            player:ToggleDuty()
        end, {
            help = 'Entra ou sai de serviço',
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

            -- Se o primeiro argumento é um número e há segundo argumento, é /addcar [id] [modelo]
            if tonumber(args[1]) and args[2] then
                targetId = tonumber(args[1])
                model = args[2]
            end

            if not model or model == '' then
                Nova.Functions.Notify(source, _L('admin_addcar_usage'), 'error')
                return
            end

            local targetPed = GetPlayerPed(targetId)
            if not targetPed or not DoesEntityExist(targetPed) then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
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
                Nova.Functions.Notify(source, _L('admin_vehicle_spawned', model, plate), 'success')
            else
                Nova.Functions.Notify(source, _L('admin_vehicle_spawned_target', model, targetId, plate), 'success')
            end
        end, {
            help = 'Gera um veículo e regista na garagem',
            params = {
                { name = 'modelo/id', help = 'Nome do modelo ou ID do jogador' },
                { name = 'modelo', help = '(Opcional) Nome do modelo se o primeiro for o ID' },
            },
        })

        Nova.Functions.RegisterCommand('dv', 'admin', function(source, args)
            TriggerClientEvent('nova:client:deleteVehicle', source)
        end, {
            help = 'Apaga o veículo atual ou mais próximo',
        })

        Nova.Functions.RegisterCommand('fix', 'admin', function(source, args)
            TriggerClientEvent('nova:client:fixVehicle', source)
        end, {
            help = 'Repara o veículo atual',
        })

        -- ============================================================
        -- COMANDOS DE TELEPORTE
        -- ============================================================

        Nova.Functions.RegisterCommand('tpm', 'admin', function(source, args)
            TriggerClientEvent('nova:client:teleportMarker', source)
        end, {
            help = 'Teleporta para o marcador no mapa',
        })

        Nova.Functions.RegisterCommand('tpcoords', 'admin', function(source, args)
            local x = tonumber(args[1])
            local y = tonumber(args[2])
            local z = tonumber(args[3])
            if not x or not y or not z then
                Nova.Functions.Notify(source, _L('admin_tpcoords_usage'), 'error')
                return
            end
            TriggerClientEvent('nova:client:teleport', source, x, y, z)
            Nova.Functions.Notify(source, _L('admin_teleported_coords', x, y, z), 'success')
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

        Nova.Functions.RegisterCommand('noclip', 'admin', function(source, args)
            TriggerClientEvent('nova:client:toggleNoclip', source)
        end, {
            help = 'Ativa/desativa noclip',
        })

        Nova.Functions.RegisterCommand('god', 'admin', function(source, args)
            TriggerClientEvent('nova:client:toggleGodmode', source)
        end, {
            help = 'Ativa/desativa modo deus',
        })

        Nova.Functions.RegisterCommand('invisible', 'admin', function(source, args)
            TriggerClientEvent('nova:client:toggleInvisible', source)
        end, {
            help = 'Ativa/desativa invisibilidade',
        })

        Nova.Functions.RegisterCommand('coords', nil, function(source, args)
            local ped = GetPlayerPed(source)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local msg = string.format('X: %.2f | Y: %.2f | Z: %.2f | H: %.2f', coords.x, coords.y, coords.z, heading)
            Nova.Functions.Notify(source, msg, 'info')
        end, {
            help = 'Mostra as tuas coordenadas atuais',
        })

        Nova.Functions.RegisterCommand('players', nil, function(source, args)
            local count = 0
            local list = {}
            for _, playerId in ipairs(GetPlayers()) do
                count = count + 1
                local name = GetPlayerName(playerId)
                list[#list + 1] = '[' .. playerId .. '] ' .. name
            end
            Nova.Functions.Notify(source, _L('admin_players_online', count), 'info')
        end, {
            help = 'Lista jogadores online',
        })

        -- ============================================================
        -- COMANDOS DE INVENTÁRIO / STATUS
        -- ============================================================

        Nova.Functions.RegisterCommand('clearinv', 'admin', function(source, args)
            local targetId = tonumber(args[1])
            if not targetId then
                Nova.Functions.Notify(source, _L('admin_clearinv_usage'), 'error')
                return
            end
            local target = Nova.Functions.GetPlayer(targetId)
            if not target then
                Nova.Functions.Notify(source, _L('player_not_found'), 'error')
                return
            end
            pcall(function()
                exports['nova_core']:SetPlayerInventory(targetId, {})
            end)
            Nova.Functions.Notify(source, _L('admin_clearinv_done', targetId), 'success')
            Nova.Functions.Notify(targetId, 'O teu inventário foi limpo por um administrador.', 'info')
        end, {
            help = 'Limpa o inventário de um jogador',
            params = { { name = 'id', help = 'ID do jogador' } },
        })

        Nova.Functions.RegisterCommand('sethunger', 'admin', function(source, args)
            local targetId = tonumber(args[1]) or source
            local value = tonumber(args[2]) or 100
            value = math.max(0, math.min(100, value))
            pcall(function()
                exports['nova_core']:SetPlayerMetadata(targetId, 'hunger', value)
            end)
            Nova.Functions.Notify(source, _L('admin_hunger_set', targetId, value), 'success')
        end, {
            help = 'Define a fome de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'valor', help = 'Valor (0-100)' },
            },
        })

        Nova.Functions.RegisterCommand('setthirst', 'admin', function(source, args)
            local targetId = tonumber(args[1]) or source
            local value = tonumber(args[2]) or 100
            value = math.max(0, math.min(100, value))
            pcall(function()
                exports['nova_core']:SetPlayerMetadata(targetId, 'thirst', value)
            end)
            Nova.Functions.Notify(source, _L('admin_thirst_set', targetId, value), 'success')
        end, {
            help = 'Define a sede de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'valor', help = 'Valor (0-100)' },
            },
        })

        Nova.Functions.RegisterCommand('setarmor', 'admin', function(source, args)
            local targetId = tonumber(args[1]) or source
            local value = tonumber(args[2]) or 100
            TriggerClientEvent('nova:client:setArmor', targetId, value)
            Nova.Functions.Notify(source, _L('admin_armor_set', targetId, value), 'success')
        end, {
            help = 'Define a armadura de um jogador',
            params = {
                { name = 'id', help = 'ID do jogador' },
                { name = 'valor', help = 'Valor (0-100)' },
            },
        })

        Nova.Debug('[MODULE] Commands iniciados')
    end,
})
