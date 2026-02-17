--[[
    NOVA Framework - Vehicle Keys System (Client)
    Trancar/destrancar veículos com tecla L
    Animação + som ao trancar/destrancar
]]

local MyKeys = {}           -- Chaves do jogador: { ['PLATE'] = true }
local LockCooldown = false  -- Anti-spam

-- ============================================================
-- RECEBER CHAVES DO SERVIDOR
-- ============================================================

RegisterNetEvent('nova:keys:receiveKeys', function(keys)
    MyKeys = keys or {}
end)

-- ============================================================
-- UTILIDADES
-- ============================================================

local function CleanPlate(plate)
    if not plate then return '' end
    return tostring(plate):upper():gsub('%s+', '')
end

local function HasKey(plate)
    return MyKeys[CleanPlate(plate)] == true
end

local function GetClosestVehicle(maxDist)
    maxDist = maxDist or 10.0
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local closest = nil
    local closestDist = maxDist
    
    local vehs = GetGamePool('CVehicle')
    for _, veh in ipairs(vehs) do
        local dist = #(pCoords - GetEntityCoords(veh))
        if dist < closestDist then
            closestDist = dist
            closest = veh
        end
    end
    
    return closest, closestDist
end

-- ============================================================
-- TRANCAR / DESTRANCAR
-- ============================================================

local function ToggleLock()
    if LockCooldown then return end
    LockCooldown = true
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    -- Se não está num veículo, procurar o mais próximo
    if vehicle == 0 then
        vehicle = GetClosestVehicle(10.0)
    end
    
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        LockCooldown = false
        return
    end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate then LockCooldown = false; return end
    
    plate = CleanPlate(plate)
    
    -- Verificar se tem chave localmente (resposta rápida)
    if not HasKey(plate) then
        Nova.Functions.Notify('Não tens a chave deste veículo!', 'error', 2000)
        LockCooldown = false
        return
    end
    
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    
    -- Pedir ao servidor para validar e broadcast
    TriggerServerEvent('nova:keys:toggleLock', plate, netId)
    
    -- Cooldown de 1 segundo
    SetTimeout(1000, function()
        LockCooldown = false
    end)
end

-- ============================================================
-- RESULTADO DO TOGGLE (recebido por TODOS os clients)
-- ============================================================

RegisterNetEvent('nova:keys:toggleLockResult', function(netId, ownerSrc)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    local currentLockState = GetVehicleDoorLockStatus(vehicle)
    local isLocked = (currentLockState == 2 or currentLockState == 10)
    local newLockState = isLocked and 1 or 2  -- 1 = destrancado, 2 = trancado
    
    SetVehicleDoorsLocked(vehicle, newLockState)
    
    -- Efeitos visuais e sonoros
    if newLockState == 2 then
        -- Trancado: piscar luzes + som de trancar
        SetVehicleLights(vehicle, 2)
        Wait(150)
        SetVehicleLights(vehicle, 0)
        Wait(100)
        SetVehicleLights(vehicle, 2)
        Wait(150)
        SetVehicleLights(vehicle, 0)
    else
        -- Destrancado: piscar luzes uma vez
        SetVehicleLights(vehicle, 2)
        Wait(200)
        SetVehicleLights(vehicle, 0)
    end
    
    -- Notificação apenas para o dono
    if GetPlayerServerId(PlayerId()) == ownerSrc then
        if newLockState == 2 then
            Nova.Functions.Notify('Veículo trancado 🔒', 'info', 2000)
        else
            Nova.Functions.Notify('Veículo destrancado 🔓', 'success', 2000)
        end
    end
end)

-- ============================================================
-- IMPEDIR ENTRAR EM VEÍCULOS TRANCADOS
-- ============================================================

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        
        if IsPedTryingToEnterALockedVehicle(ped) then
            sleep = 0
            local vehicle = GetVehiclePedIsTryingToEnter(ped)
            if vehicle and DoesEntityExist(vehicle) then
                -- Ignorar veículos de showroom da garagem
                local isShowroom = false
                pcall(function()
                    isShowroom = exports['nova_garage']:IsShowroomVehicle(vehicle)
                end)
                if not isShowroom then
                    local lockState = GetVehicleDoorLockStatus(vehicle)
                    if lockState == 2 or lockState == 10 then
                        local plate = GetVehicleNumberPlateText(vehicle)
                        if plate and not HasKey(CleanPlate(plate)) then
                            -- Não tem chave: cancelar entrada
                            ClearPedTasks(ped)
                            Nova.Functions.Notify('Este veículo está trancado!', 'error', 2000)
                            Wait(1000)
                        end
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- ============================================================
-- TECLA L PARA TRANCAR/DESTRANCAR
-- ============================================================

CreateThread(function()
    while true do
        Wait(0)
        -- L key = 182
        if IsControlJustPressed(0, 182) then
            ToggleLock()
        end
    end
end)

-- ============================================================
-- PEDIR CHAVES AO CARREGAR
-- ============================================================

CreateThread(function()
    while not Nova.IsPlayerLoaded do Wait(500) end
    Wait(2000)
    TriggerServerEvent('nova:keys:requestKeys')
end)

-- ============================================================
-- EXPORTS (para outros scripts client-side)
-- ============================================================

exports('HasKey', function(plate)
    return HasKey(plate)
end)

exports('GetMyKeys', function()
    return MyKeys
end)
