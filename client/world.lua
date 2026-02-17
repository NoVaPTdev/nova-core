--[[
    NOVA Framework - World Control
    Controlo de NPCs, tráfego, polícia e wanted level
    
    - Remove todos os veículos NPC (tráfego)
    - Remove carros estacionados NPC
    - Remove polícia NPC
    - Remove wanted level permanentemente
    - Mantém apenas pedestres a caminhar
]]

-- ============================================================
-- CONFIGURAÇÃO
-- ============================================================

local WorldConfig = {
    -- Tráfego de veículos (0.0 = nenhum, 1.0 = normal)
    vehicleDensity     = 0.0,
    parkedDensity      = 0.0,
    randomVehicles     = false,

    -- Pedestres a pé (0.0 = nenhum, 1.0 = normal)
    pedDensity         = 0.6,      -- Manter alguns pedestres a andar

    -- Polícia / Wanted
    disablePolice      = true,     -- Desactivar polícia completamente
    disableWanted      = true,     -- Remover wanted level sempre
    disableDispatch    = true,     -- Desactivar dispatch (polícia, bombeiros, ambulância NPC)

    -- Limpeza de veículos existentes
    cleanupRadius      = 300.0,    -- Raio para limpar veículos NPC ao redor do jogador
    cleanupInterval    = 10000,    -- Intervalo de limpeza em ms (10 segundos)
}

-- ============================================================
-- DESACTIVAR SERVIÇOS DE DISPATCH (polícia, bombeiros, etc)
-- ============================================================

local dispatchServices = {
    1,  -- PoliceAutomobile
    2,  -- PoliceHelicopter
    3,  -- FireDepartment
    4,  -- SwatAutomobile
    5,  -- AmbulanceDepartment
    6,  -- PoliceRiders (motos)
    7,  -- PoliceVehicleRequest
    8,  -- PoliceRoadBlock
    9,  -- PoliceAutomobileWaitPulledOver
    10, -- PoliceAutomobileWaitCruising
    11, -- Gangs
    12, -- SwatHelicopter
    15, -- PoliceBoat
}

-- ============================================================
-- THREAD PRINCIPAL: Densidades + Wanted + Dispatch
-- ============================================================

CreateThread(function()
    -- Aplicar configurações iniciais de densidade
    SetVehicleDensityMultiplierThisFrame(WorldConfig.vehicleDensity)
    SetParkedVehicleDensityMultiplierThisFrame(WorldConfig.parkedDensity)
    SetPedDensityMultiplierThisFrame(WorldConfig.pedDensity)

    if WorldConfig.randomVehicles == false then
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
    end

    while true do
        -- ── Densidades (precisam ser aplicadas a cada frame) ──
        SetVehicleDensityMultiplierThisFrame(WorldConfig.vehicleDensity)
        SetParkedVehicleDensityMultiplierThisFrame(WorldConfig.parkedDensity)
        SetPedDensityMultiplierThisFrame(WorldConfig.pedDensity)
        SetRandomVehicleDensityMultiplierThisFrame(WorldConfig.vehicleDensity)

        -- ── Remover Wanted Level ──
        if WorldConfig.disableWanted then
            local ped = PlayerPedId()
            if GetPlayerWantedLevel(PlayerId()) > 0 then
                SetPlayerWantedLevel(PlayerId(), 0, false)
                SetPlayerWantedLevelNow(PlayerId(), false)
            end
            -- Impedir que o wanted level suba
            SetMaxWantedLevel(0)
        end

        -- ── Desactivar Dispatch Services ──
        if WorldConfig.disableDispatch then
            for _, serviceId in ipairs(dispatchServices) do
                EnableDispatchService(serviceId, false)
            end
        end

        -- ── Desactivar polícia ──
        if WorldConfig.disablePolice then
            -- Remover blips de polícia do mapa
            SetGarbageTrucks(false)
            SetRandomBoats(false)
            SetRandomTrains(false)

            -- Impedir que a polícia NPC apareça
            for i = 1, 15 do
                EnableDispatchService(i, false)
            end
        end

        Wait(0)
    end
end)

-- ============================================================
-- THREAD: Limpar veículos NPC periodicamente
-- ============================================================

CreateThread(function()
    -- Esperar o jogo carregar completamente
    Wait(5000)

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Obter todos os veículos na área
        local vehicles = GetGamePool('CVehicle')

        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) then
                -- Verificar se NÃO é um veículo de jogador
                local driver = GetPedInVehicleSeat(vehicle, -1)
                local isPlayerVehicle = false

                -- Verificar se o veículo pertence a algum jogador
                if driver ~= 0 and IsPedAPlayer(driver) then
                    isPlayerVehicle = true
                end

                -- Verificar se algum jogador está dentro do veículo
                if not isPlayerVehicle then
                    for seat = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                        local seatPed = GetPedInVehicleSeat(vehicle, seat)
                        if seatPed ~= 0 and IsPedAPlayer(seatPed) then
                            isPlayerVehicle = true
                            break
                        end
                    end
                end

                -- Verificar se é um veículo da rede (criado por script/outro jogador)
                if not isPlayerVehicle and NetworkGetEntityIsNetworked(vehicle) then
                    local owner = NetworkGetEntityOwner(vehicle)
                    if owner and owner > 0 then
                        -- Pode ser veículo de script, manter
                        local netId = NetworkGetNetworkIdFromEntity(vehicle)
                        if netId and netId > 0 then
                            isPlayerVehicle = true
                        end
                    end
                end

                -- Se é um veículo NPC puro (sem rede, sem jogador), eliminar
                if not isPlayerVehicle then
                    local dist = #(playerCoords - GetEntityCoords(vehicle))
                    if dist < WorldConfig.cleanupRadius then
                        -- Verificar se não é um veículo de missão/script
                        if not IsEntityAMissionEntity(vehicle) and not DecorExistOn(vehicle, 'Player_Vehicle') then
                            SetEntityAsMissionEntity(vehicle, true, true)
                            DeleteEntity(vehicle)
                        end
                    end
                end
            end
        end

        Wait(WorldConfig.cleanupInterval)
    end
end)

-- ============================================================
-- THREAD: Remover peds de polícia que apareçam
-- ============================================================

CreateThread(function()
    Wait(3000)

    while true do
        if WorldConfig.disablePolice then
            local peds = GetGamePool('CPed')

            for _, ped in ipairs(peds) do
                if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                    -- Verificar se é polícia
                    local pedType = GetPedType(ped)
                    -- Tipo 6 = Cop/Police
                    if pedType == 6 then
                        -- Verificar se não está num veículo de jogador
                        local veh = GetVehiclePedIsIn(ped, false)
                        local isInPlayerVeh = false
                        if veh ~= 0 then
                            for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
                                local seatPed = GetPedInVehicleSeat(veh, seat)
                                if seatPed ~= 0 and IsPedAPlayer(seatPed) then
                                    isInPlayerVeh = true
                                    break
                                end
                            end
                        end

                        if not isInPlayerVeh then
                            -- Eliminar ped de polícia e seu veículo
                            if veh ~= 0 and DoesEntityExist(veh) then
                                SetEntityAsMissionEntity(veh, true, true)
                                DeleteEntity(veh)
                            end
                            SetEntityAsMissionEntity(ped, true, true)
                            DeleteEntity(ped)
                        end
                    end
                end
            end
        end

        Wait(5000)
    end
end)

-- ============================================================
-- THREAD: Remover veículos NPC que peds estejam a conduzir
-- (Mantém apenas peds a pé)
-- ============================================================

CreateThread(function()
    Wait(4000)

    while true do
        local peds = GetGamePool('CPed')

        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and DoesEntityExist(veh) then
                    -- Este ped NPC está num veículo - verificar se não tem jogadores
                    local hasPlayer = false
                    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
                        local seatPed = GetPedInVehicleSeat(veh, seat)
                        if seatPed ~= 0 and IsPedAPlayer(seatPed) then
                            hasPlayer = true
                            break
                        end
                    end

                    -- Se nenhum jogador está no veículo, remover o NPC e o veículo
                    if not hasPlayer and not IsEntityAMissionEntity(veh) then
                        -- Remover todos os NPCs do veículo primeiro
                        for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
                            local seatPed = GetPedInVehicleSeat(veh, seat)
                            if seatPed ~= 0 and DoesEntityExist(seatPed) and not IsPedAPlayer(seatPed) then
                                SetEntityAsMissionEntity(seatPed, true, true)
                                DeleteEntity(seatPed)
                            end
                        end
                        -- Remover o veículo
                        SetEntityAsMissionEntity(veh, true, true)
                        DeleteEntity(veh)
                    end
                end
            end
        end

        Wait(8000)
    end
end)

-- ============================================================
-- EVENTO: Limpar ao iniciar/resource restart
-- ============================================================

AddEventHandler('playerSpawned', function()
    -- Aplicar configurações quando o jogador spawna
    SetMaxWantedLevel(0)
    SetPlayerWantedLevel(PlayerId(), 0, false)
    SetPlayerWantedLevelNow(PlayerId(), false)

    -- Desactivar geração automática de polícia
    if WorldConfig.disableDispatch then
        for _, serviceId in ipairs(dispatchServices) do
            EnableDispatchService(serviceId, false)
        end
    end
end)

-- ============================================================
-- LIMPEZA AO PARAR O RESOURCE
-- ============================================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    -- Restaurar densidades ao normal
    SetVehicleDensityMultiplierThisFrame(1.0)
    SetParkedVehicleDensityMultiplierThisFrame(1.0)
    SetPedDensityMultiplierThisFrame(1.0)
    SetRandomVehicleDensityMultiplierThisFrame(1.0)
    SetMaxWantedLevel(5)
end)
