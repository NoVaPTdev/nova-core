--[[
    NOVA Framework - Funções do Client
    Funções utilitárias client-side
]]

-- ============================================================
-- NOTIFICAÇÕES (via nova_notify)
-- ============================================================

--- Envia uma notificação usando nova_notify
---@param message string Mensagem
---@param type string Tipo (success, error, info, warning)
---@param duration number|nil Duração em ms
function Nova.Functions.Notify(message, type, duration)
    if GetResourceState('nova_notify') == 'started' then
        exports['nova_notify']:SendNotification(type or 'info', message, duration or 5000)
    else
        -- Fallback: print no chat se nova_notify não estiver disponível
        print('[NOVA Notify] ' .. tostring(type) .. ': ' .. tostring(message))
    end
end

-- NOTA: O evento 'nova:client:notify' é escutado directamente pelo nova_notify
-- Não registar aqui para evitar notificações duplicadas

-- ============================================================
-- UTILIDADES DE PED
-- ============================================================

--- Obtém o ped do jogador
---@return number
function Nova.Functions.GetPlayerPed()
    return PlayerPedId()
end

--- Obtém as coordenadas do jogador
---@return vector3
function Nova.Functions.GetPlayerCoords()
    return GetEntityCoords(PlayerPedId())
end

--- Obtém o heading do jogador
---@return number
function Nova.Functions.GetPlayerHeading()
    return GetEntityHeading(PlayerPedId())
end

--- Obtém coordenadas com heading (vector4)
---@return vector4
function Nova.Functions.GetPlayerPosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    return vector4(coords.x, coords.y, coords.z, heading)
end

--- Verifica se o jogador está num veículo
---@return boolean
function Nova.Functions.IsInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

--- Obtém o veículo atual do jogador
---@return number|nil
function Nova.Functions.GetCurrentVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

--- Verifica se o jogador é o condutor
---@return boolean
function Nova.Functions.IsDriver()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then
        return GetPedInVehicleSeat(vehicle, -1) == ped
    end
    return false
end

-- ============================================================
-- TELEPORTE
-- ============================================================

--- Teleporta o jogador para coordenadas
---@param x number
---@param y number
---@param z number
---@param heading number|nil
function Nova.Functions.Teleport(x, y, z, heading)
    local ped = PlayerPedId()

    SetPedCoordsKeepVehicle(ped, x, y, z)

    if heading then
        SetEntityHeading(ped, heading)
    end
end

-- Evento de teleporte do server
RegisterNetEvent('nova:client:teleport', function(x, y, z, heading)
    Nova.Functions.Teleport(x, y, z, heading)
end)

-- ============================================================
-- DESENHO DE TEXTO
-- ============================================================

--- Desenha texto 3D no mundo
---@param coords vector3 Posição
---@param text string Texto
---@param scale number|nil Escala (padrão: 0.35)
function Nova.Functions.DrawText3D(coords, text, scale)
    scale = scale or 0.35
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

--- Desenha texto 2D na tela
---@param x number Posição X (0.0 - 1.0)
---@param y number Posição Y (0.0 - 1.0)
---@param text string Texto
---@param scale number|nil Escala
---@param color table|nil Cor {r, g, b, a}
function Nova.Functions.DrawText2D(x, y, text, scale, color)
    scale = scale or 0.4
    color = color or { 255, 255, 255, 255 }

    SetTextFont(4)
    SetTextProportional(false)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

-- ============================================================
-- CARREGAMENTO DE ASSETS
-- ============================================================

--- Carrega um modelo de forma assíncrona
---@param model string|number Hash ou nome do modelo
---@return boolean
function Nova.Functions.LoadModel(model)
    if type(model) == 'string' then
        model = GetHashKey(model)
    end

    if HasModelLoaded(model) then return true end

    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) do
        Wait(10)
        timeout = timeout + 10
        if timeout > 10000 then
            Nova.Error('Timeout ao carregar modelo: ' .. model)
            return false
        end
    end

    return true
end

--- Carrega um dicionário de animações
---@param dict string Nome do dicionário
---@return boolean
function Nova.Functions.LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end

    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) do
        Wait(10)
        timeout = timeout + 10
        if timeout > 10000 then
            Nova.Error('Timeout ao carregar animação: ' .. dict)
            return false
        end
    end

    return true
end

--- Carrega uma textura de particles
---@param dict string Nome do dicionário
---@return boolean
function Nova.Functions.LoadParticleDict(dict)
    if HasNamedPtfxAssetLoaded(dict) then return true end

    RequestNamedPtfxAsset(dict)
    local timeout = 0
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(10)
        timeout = timeout + 10
        if timeout > 10000 then
            Nova.Error('Timeout ao carregar partículas: ' .. dict)
            return false
        end
    end

    return true
end

-- ============================================================
-- PROGRESSBAR SIMPLES (via NUI)
-- ============================================================

--- Mostra uma barra de progresso
---@param label string Texto da barra
---@param duration number Duração em ms
---@param options table|nil Opções (canCancel, anim, prop)
---@param onComplete function|nil Callback ao completar
---@param onCancel function|nil Callback ao cancelar
function Nova.Functions.Progressbar(label, duration, options, onComplete, onCancel)
    options = options or {}

    SendNUIMessage({
        action = 'progressbar',
        label = label,
        duration = duration,
    })

    -- Desativar controles durante a progressbar (a menos que allowMovement esteja ativo)
    if not options.canCancel and not options.allowMovement then
        CreateThread(function()
            local startTime = GetGameTimer()
            while GetGameTimer() - startTime < duration do
                DisableAllControlActions(0)
                Wait(5)
            end
        end)
    end

    SetTimeout(duration, function()
        if onComplete then
            onComplete()
        end
    end)
end

-- ============================================================
-- DISTÂNCIA E RAYCASTING
-- ============================================================

--- Obtém entidades próximas
---@param coords vector3 Centro da procura
---@param radius number Raio
---@return table Jogadores próximos
function Nova.Functions.GetNearbyPlayers(coords, radius)
    coords = coords or Nova.Functions.GetPlayerCoords()
    radius = radius or 5.0

    local players = {}
    local activePlayers = GetActivePlayers()

    for _, playerId in ipairs(activePlayers) do
        local ped = GetPlayerPed(playerId)
        if ped ~= PlayerPedId() then
            local playerCoords = GetEntityCoords(ped)
            local dist = #(coords - playerCoords)
            if dist <= radius then
                table.insert(players, {
                    id = playerId,
                    ped = ped,
                    coords = playerCoords,
                    distance = dist,
                })
            end
        end
    end

    return players
end

--- Obtém o jogador mais próximo
---@param coords vector3|nil Centro
---@param radius number|nil Raio
---@return number|nil playerId
---@return number|nil distance
function Nova.Functions.GetClosestPlayer(coords, radius)
    local nearby = Nova.Functions.GetNearbyPlayers(coords, radius)

    local closestId = nil
    local closestDist = math.huge

    for _, data in ipairs(nearby) do
        if data.distance < closestDist then
            closestId = data.id
            closestDist = data.distance
        end
    end

    return closestId, closestDist
end

-- ============================================================
-- EXPORTS CLIENT
-- ============================================================

exports('TriggerCallback', function(name, cb, ...)
    Nova.Functions.TriggerCallback(name, cb, ...)
end)

exports('ClientNotify', function(message, type, duration)
    Nova.Functions.Notify(message, type, duration)
end)

exports('GetPlayerData', function()
    return Nova.PlayerData
end)

exports('IsPlayerLoaded', function()
    return Nova.IsPlayerLoaded
end)

-- ============================================================
-- HANDLERS DE COMANDOS ADMIN (client-side)
-- ============================================================

-- Spawn de veículo
RegisterNetEvent('nova:client:spawnVehicle', function(model, plate)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        Nova.Functions.Notify('Modelo de veículo inválido: ' .. model, 'error')
        return
    end

    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    if not HasModelLoaded(hash) then
        Nova.Functions.Notify('Erro ao carregar modelo.', 'error')
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleNumberPlateText(vehicle, plate or 'NOVA')
    SetVehicleEngineOn(vehicle, true, true, false)
    Nova.Functions.Notify('Veículo \'' .. model .. '\' gerado!', 'success')
end)

-- Apagar veículo
RegisterNetEvent('nova:client:deleteVehicle', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        local coords = GetEntityCoords(ped)
        local closestVeh = 0
        local closestDist = 10.0
        local vehicles = GetGamePool('CVehicle')
        for _, veh in ipairs(vehicles) do
            local vCoords = GetEntityCoords(veh)
            local dist = #(coords - vCoords)
            if dist < closestDist then
                closestVeh = veh
                closestDist = dist
            end
        end
        vehicle = closestVeh
    end

    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
        Nova.Functions.Notify('Veículo apagado.', 'success')
    else
        Nova.Functions.Notify('Nenhum veículo encontrado por perto.', 'error')
    end
end)

-- Reparar veículo
RegisterNetEvent('nova:client:fixVehicle', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleDirtLevel(vehicle, 0.0)
        Nova.Functions.Notify('Veículo reparado!', 'success')
    else
        Nova.Functions.Notify('Precisas estar num veículo.', 'error')
    end
end)

-- Teleport para marcador no mapa
RegisterNetEvent('nova:client:teleportMarker', function()
    local blip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blip) then
        Nova.Functions.Notify('Coloca um marcador no mapa primeiro.', 'error')
        return
    end

    local coords = GetBlipInfoIdCoord(blip)
    local groundFound = false
    local z = 0.0

    for i = 1, 1000 do
        local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, tonumber(i) + 0.0, false)
        if found then
            z = groundZ + 1.0
            groundFound = true
            break
        end
    end

    if not groundFound then
        z = 300.0
    end

    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, coords.x, coords.y, z)
    Nova.Functions.Notify('Teleportado para o marcador!', 'success')
end)

-- Noclip
local noclipEnabled = false
local noclipCam = nil

RegisterNetEvent('nova:client:toggleNoclip', function()
    noclipEnabled = not noclipEnabled
    local ped = PlayerPedId()

    if noclipEnabled then
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        Nova.Functions.Notify('Noclip ATIVADO. WASD + Shift/Ctrl para mover.', 'success')

        CreateThread(function()
            while noclipEnabled do
                local heading = GetGameplayCamRelativeHeading()
                local pitch = GetGameplayCamRelativePitch()
                local camRot = GetGameplayCamRot(2)

                local speed = 1.0
                if IsControlPressed(0, 21) then speed = 3.0 end -- Shift

                local fwd = vector3(
                    -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                    math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                    math.sin(math.rad(camRot.x))
                )

                local pos = GetEntityCoords(ped)
                local newPos = pos

                if IsControlPressed(0, 32) then newPos = newPos + fwd * speed end -- W
                if IsControlPressed(0, 33) then newPos = newPos - fwd * speed end -- S
                if IsControlPressed(0, 34) then -- A
                    newPos = newPos + vector3(fwd.y, -fwd.x, 0.0) * speed
                end
                if IsControlPressed(0, 35) then -- D
                    newPos = newPos - vector3(fwd.y, -fwd.x, 0.0) * speed
                end
                if IsControlPressed(0, 44) then newPos = newPos + vector3(0, 0, speed) end -- Q (up)
                if IsControlPressed(0, 20) then newPos = newPos - vector3(0, 0, speed) end -- Z (down)

                SetEntityCoordsNoOffset(ped, newPos.x, newPos.y, newPos.z, false, false, false)
                SetEntityHeading(ped, camRot.z)

                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 47, true)

                Wait(1)
            end
        end)
    else
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)
        Nova.Functions.Notify('Noclip DESATIVADO.', 'info')
    end
end)

-- TP Coords Input (NUI panel)
RegisterNetEvent('nova:client:tpCoordsInput', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openTpcds' })
end)

RegisterNUICallback('tpcds_result', function(data, cb)
    SetNuiFocus(false, false)

    if data.cancelled then
        Nova.Functions.Notify('Coordenadas canceladas.', 'error')
        cb('ok')
        return
    end

    local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
    if not x or not y or not z then
        Nova.Functions.Notify('Formato inválido! Usa: x, y, z', 'error')
        cb('ok')
        return
    end

    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, x, y, z)
    Nova.Functions.Notify(string.format('Teleportado para %.2f, %.2f, %.2f', x, y, z), 'success')
    cb('ok')
end)

-- Copiar coordenadas para clipboard
RegisterNetEvent('nova:client:copyCoords', function(coordStr, fullMsg)
    SendNUIMessage({ action = 'copyToClipboard', text = coordStr })
    Nova.Functions.Notify(fullMsg .. ' (copiado!)', 'success')
end)

-- God (heal completo + revive)
RegisterNetEvent('nova:client:toggleGodmode', function()
    local ped = PlayerPedId()

    -- Forçar respawn do deathscreen se estiver morto
    if GetResourceState('nova_deathscreen') == 'started' then
        local ok, dead = pcall(exports['nova_deathscreen'].IsDead, exports['nova_deathscreen'])
        if ok and dead then
            TriggerEvent('nova:death:forceRespawn')
            Wait(300)
            ped = PlayerPedId()
        end
    end

    -- Ressuscitar se o ped estiver morto nativamente
    if IsEntityDead(ped) then
        local coords = GetEntityCoords(ped)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
        Wait(200)
        ped = PlayerPedId()
    end

    -- Garantir que o jogador tem controlo total
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetPlayerControl(PlayerId(), true, 0)
    ClearPedTasksImmediately(ped)
    ClearPedTasks(ped)
    SetPedCanRagdoll(ped, true)

    -- Aplicar cura completa
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)

    -- Limpar is_dead localmente
    if Nova.PlayerData and Nova.PlayerData.metadata then
        Nova.PlayerData.metadata.is_dead = false
    end

    -- Notificar HUD que reviveu
    TriggerEvent('nova:client:onRevive')
    pcall(function() exports['nova_hud']:toggleHud(true) end)

    Nova.Functions.Notify('Vida, armadura, comida e bebida restaurados.', 'success')
end)

-- Invisibilidade
local invisibleEnabled = false

RegisterNetEvent('nova:client:toggleInvisible', function()
    invisibleEnabled = not invisibleEnabled
    local ped = PlayerPedId()
    SetEntityVisible(ped, not invisibleEnabled, false)
    if invisibleEnabled then
        Nova.Functions.Notify('Invisibilidade ATIVADA.', 'success')
    else
        Nova.Functions.Notify('Invisibilidade DESATIVADA.', 'info')
    end
end)

-- Set Armor
RegisterNetEvent('nova:client:setArmor', function(value)
    local ped = PlayerPedId()
    SetPedArmour(ped, tonumber(value) or 100)
end)
