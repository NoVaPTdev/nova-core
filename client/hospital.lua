local isLayingDown = false
local bedEntity = nil
local isMedicOnDuty = false

local function GetUp()
    if not isLayingDown then return end
    isLayingDown = false

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)

    bedEntity = nil
    TriggerServerEvent('nova:hospital:standUp')
end

local function LayDown(entity)
    if isLayingDown then return end
    isLayingDown = true
    bedEntity = entity

    local ped = PlayerPedId()
    local bedCoords = GetEntityCoords(entity)
    local bedHeading = GetEntityHeading(entity)

    SetEntityCoords(ped, bedCoords.x, bedCoords.y, bedCoords.z + 0.3, false, false, false, false)
    SetEntityHeading(ped, bedHeading)
    Wait(200)

    RequestAnimDict(HospitalConfig.LayAnim.dict)
    local t = 0
    while not HasAnimDictLoaded(HospitalConfig.LayAnim.dict) and t < 50 do
        Wait(10)
        t = t + 1
    end

    TaskPlayAnim(ped, HospitalConfig.LayAnim.dict, HospitalConfig.LayAnim.name, 8.0, 1.0, -1, 1, 0, false, false, false)
    Wait(500)
    FreezeEntityPosition(ped, true)

    TriggerServerEvent('nova:hospital:layDown')

    if Nova and Nova.Functions and Nova.Functions.Notify then
        Nova.Functions.Notify('Estás deitado na cama. Aguarda um médico ou pressiona E para levantar.', 'info', 5000)
    end
end

local function SelfHeal()
    Nova.Functions.TriggerCallback('nova:hospital:selfHeal', function(result)
        if not result then return end

        if result.blocked then
            Nova.Functions.Notify('Há médicos em serviço! Chama um médico para te tratar.', 'error', 4000)
            return
        end

        if result.noMoney then
            Nova.Functions.Notify('Não tens dinheiro suficiente ($' .. HospitalConfig.SelfHealCost .. ').', 'error', 3000)
            return
        end

        if result.success then
            local ped = PlayerPedId()
            SetEntityHealth(ped, HospitalConfig.HealAmount)
            ClearPedBloodDamage(ped)

            if Nova.PlayerData and Nova.PlayerData.metadata then
                Nova.PlayerData.metadata.is_dead = false
            end

            TriggerEvent('nova:client:onRevive')
            Nova.Functions.Notify('Foste tratado no hospital. Custo: $' .. HospitalConfig.SelfHealCost, 'success', 4000)
        end
    end)
end

CreateThread(function()
    while not Nova or not Nova.IsPlayerLoaded do Wait(500) end
    Wait(2000)

    Nova.Functions.TriggerCallback('nova:hospital:checkMedic', function(onDuty)
        isMedicOnDuty = onDuty or false
    end)

    local models = {}
    for _, m in ipairs(HospitalConfig.BedModels) do
        models[#models + 1] = m
    end

    pcall(function()
        exports['nova_target']:addModel(models, {
            {
                name = 'hospital_selfheal',
                label = 'Auto-Tratamento ($' .. HospitalConfig.SelfHealCost .. ')',
                icon = 'heart',
                distance = 2.0,
                canInteract = function()
                    return not isLayingDown
                end,
                onSelect = function()
                    SelfHeal()
                end,
            },
            {
                name = 'hospital_laydown',
                label = 'Deitar na Cama',
                icon = 'bed',
                distance = 2.0,
                canInteract = function()
                    return not isLayingDown
                end,
                onSelect = function(data)
                    LayDown(data.entity)
                end,
            },
        })
    end)

    pcall(function()
        exports['nova_target']:addGlobalPlayer({
            {
                name = 'hospital_treat_player',
                label = 'Tratar Paciente ($' .. HospitalConfig.MedicPayment .. ')',
                icon = 'briefcase-medical',
                distance = 3.0,
                canInteract = function(entity)
                    if not isMedicOnDuty then return false end
                    local targetSrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    if targetSrc <= 0 then return false end
                    return true
                end,
                onSelect = function(data)
                    local targetPed = data.entity
                    local targetPlayer = NetworkGetPlayerIndexFromPed(targetPed)
                    if not targetPlayer then return end
                    local targetSrc = GetPlayerServerId(targetPlayer)
                    if targetSrc <= 0 then return end
                    TriggerServerEvent('nova:hospital:treatPlayer', targetSrc)
                end,
            },
        })
    end)

end)

RegisterNetEvent('nova:hospital:dutyChanged', function(onDuty)
    isMedicOnDuty = onDuty
end)

RegisterNetEvent('nova:hospital:healed', function()
    local ped = PlayerPedId()

    if isLayingDown then
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)
        isLayingDown = false
        bedEntity = nil
    end

    SetEntityHealth(ped, HospitalConfig.HealAmount)
    ClearPedBloodDamage(ped)

    if Nova.PlayerData and Nova.PlayerData.metadata then
        Nova.PlayerData.metadata.is_dead = false
    end

    TriggerEvent('nova:client:onRevive')
    Nova.Functions.Notify('Um médico tratou-te!', 'success', 4000)
end)

CreateThread(function()
    while true do
        if isLayingDown then
            if IsControlJustPressed(0, 38) then -- E
                GetUp()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    if isLayingDown then
        local ped = PlayerPedId()
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)
    end
end)
