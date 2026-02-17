--[[
    NOVA Framework - Módulo: Jobs
    Job callbacks (duty/spawn/change) + Sistema de Salários
    
    Registado como módulo via Nova.RegisterModule()
    Conteúdo original: server/job_callbacks.lua + server/salary.lua
]]

Nova.RegisterModule({
    name = 'jobs',
    version = '1.0.0',
    side = 'server',
    dependencies = { 'permissions' },

    Init = function(Nova)
        -- ============================================================
        -- DUTY CHANGE (entrar/sair de serviço)
        -- ============================================================

        AddEventHandler('nova:server:onDutyChange', function(source, isDuty)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return end

            local jobName = player.job.name
            local jobConfig = NovaGroups.Jobs[jobName]
            if not jobConfig then return end

            -- Reconstruir cache de permissões (duty afeta permissões onDutyOnly)
            Nova.Functions.RefreshPermissionCache(source)

            -- POLÍCIA
            if jobName == 'policia' then
                if isDuty then
                    if jobConfig.equipment then
                        if jobConfig.equipment.weapons and next(jobConfig.equipment.weapons) then
                            TriggerClientEvent('nova:client:giveJobWeapons', source, jobConfig.equipment.weapons)
                        end
                        if jobConfig.equipment.armor and jobConfig.equipment.armor > 0 then
                            TriggerClientEvent('nova:client:setArmor', source, jobConfig.equipment.armor)
                        end
                    end
                    TriggerEvent('nova:server:setCop', source, true)
                else
                    TriggerClientEvent('nova:client:removeJobWeapons', source)
                    TriggerClientEvent('nova:client:setArmor', source, 0)
                    TriggerEvent('nova:server:setCop', source, false)
                end

            -- AMBULÂNCIA
            elseif jobName == 'ambulancia' then
                if isDuty then
                    if jobConfig.equipment and jobConfig.equipment.items then
                        for _, item in ipairs(jobConfig.equipment.items) do
                            local p = Nova.Functions.GetPlayer(source)
                            if p then p:AddItem(item.name, item.amount) end
                        end
                    end
                    TriggerEvent('nova:server:setEMS', source, true)
                else
                    TriggerEvent('nova:server:setEMS', source, false)
                end

            -- MECÂNICO
            elseif jobName == 'mecanico' then
                if isDuty then
                    if jobConfig.equipment and jobConfig.equipment.items then
                        for _, item in ipairs(jobConfig.equipment.items) do
                            local p = Nova.Functions.GetPlayer(source)
                            if p then p:AddItem(item.name, item.amount) end
                        end
                    end
                end
            end
        end)

        -- ============================================================
        -- JOB CHANGE (mudar de emprego)
        -- ============================================================

        AddEventHandler('nova:server:onJobChange', function(source, newJobName, oldJobName)
            Nova.Functions.RefreshPermissionCache(source)

            -- Limpar equipamento do emprego anterior via nome
            -- Dados detalhados: usar exports['nova_core']:GetPlayer(source):GetJob()
            if oldJobName then
                if oldJobName == 'policia' then
                    TriggerClientEvent('nova:client:removeJobWeapons', source)
                    TriggerClientEvent('nova:client:setArmor', source, 0)
                    TriggerEvent('nova:server:setCop', source, false)
                elseif oldJobName == 'ambulancia' then
                    TriggerEvent('nova:server:setEMS', source, false)
                end
            end
        end)

        -- ============================================================
        -- GANG CHANGE
        -- ============================================================

        AddEventHandler('nova:server:onGangChange', function(source, newGangName, oldGangName)
            Nova.Functions.RefreshPermissionCache(source)
        end)

        -- ============================================================
        -- PLAYER LOADED (spawn com emprego activo)
        -- ============================================================

        AddEventHandler('nova:server:onPlayerLoaded', function(source, player)
            Nova.Functions.BuildPermissionCache(source)

            if player and player.job and player.job.duty then
                local jobName = player.job.name
                local jobConfig = NovaGroups.Jobs[jobName]

                SetTimeout(2000, function()
                    if jobName == 'policia' then
                        if jobConfig and jobConfig.equipment then
                            if jobConfig.equipment.weapons and next(jobConfig.equipment.weapons) then
                                TriggerClientEvent('nova:client:giveJobWeapons', source, jobConfig.equipment.weapons)
                            end
                            if jobConfig.equipment.armor and jobConfig.equipment.armor > 0 then
                                TriggerClientEvent('nova:client:setArmor', source, jobConfig.equipment.armor)
                            end
                        end
                        TriggerEvent('nova:server:setCop', source, true)
                    elseif jobName == 'ambulancia' then
                        TriggerEvent('nova:server:setEMS', source, true)
                    end
                end)
            end
        end)

        Nova.Debug('[MODULE] Jobs callbacks inicializados')
    end,

    Start = function()
        -- ============================================================
        -- SISTEMA DE SALÁRIOS
        -- ============================================================

        local function PayAllPlayers()
            local config = NovaGroups.Salary
            if not config or not config.enabled then return end

            local moneyType = config.moneyType or 'bank'
            local bonusRate = config.bonusPerGrade or 0.10
            local payOnDutyOnly = config.payOnDutyOnly
            local notifyPlayer = config.notifyPlayer
            local minSalary = config.minSalary or 50
            local paidCount = 0

            for src, player in pairs(Nova.Players) do
                local source = tonumber(src)
                if source and player and player.job then
                    if payOnDutyOnly and not player.job.duty then
                        if notifyPlayer then
                            Nova.Functions.Notify(source, 'Não recebeste salário - não estás em serviço.', 'info', 3000)
                        end
                        goto continue
                    end

                    local baseSalary = player.job.salary or 0
                    if baseSalary <= 0 then
                        baseSalary = minSalary
                    end

                    local grade = player.job.grade or 0
                    local bonus = baseSalary * (grade * bonusRate)
                    local totalSalary = math.floor(baseSalary + bonus)

                    if totalSalary <= 0 then
                        totalSalary = minSalary
                    end

                    player:AddMoney(moneyType, totalSalary, 'Salário: ' .. player.job.label)
                    paidCount = paidCount + 1

                    if notifyPlayer then
                        local gradeInfo = ''
                        if grade > 0 and bonus > 0 then
                            gradeInfo = string.format(' (+$%s bónus)', Nova.FormatMoney(math.floor(bonus)))
                        end
                        Nova.Functions.Notify(source,
                            string.format('Salário recebido: $%s%s (%s)',
                                Nova.FormatMoney(totalSalary),
                                gradeInfo,
                                player.job.label
                            ),
                            'success', 5000)
                    end
                end

                ::continue::
            end

            if paidCount > 0 then
                Nova.Debug(string.format('[Salários] Pago a %d jogador(es)', paidCount))
            end
        end

        -- Expor PayAllPlayers para uso por comandos
        Nova._PayAllPlayers = PayAllPlayers

        local config = NovaGroups.Salary
        if config and config.enabled then
            local intervalMs = (config.interval or 15) * 60 * 1000
            Nova.Print(string.format('[Salários] Sistema iniciado - Pagamento a cada %d minutos', config.interval or 15))

            CreateThread(function()
                Wait(intervalMs)
                while true do
                    PayAllPlayers()
                    Wait(intervalMs)
                end
            end)
        else
            Nova.Print('[Salários] Sistema de salários desativado.')
        end

        -- Comando admin para forçar pagamento
        Nova.Functions.RegisterCommand('paysalary', 'superadmin', function(source, args)
            PayAllPlayers()
            Nova.Functions.Notify(source, 'Salários pagos manualmente a todos os jogadores online.', 'success')
        end, {
            help = 'Força o pagamento de salários a todos os jogadores',
        })

        Nova.Debug('[MODULE] Jobs salários iniciados')
    end,
})
