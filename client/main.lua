--[[
    NOVA Framework - Main Client
    Ponto de entrada principal do cliente
    Gestão do estado do jogador, necessidades e eventos
]]

-- Estado do jogador
Nova.PlayerData = {}
Nova.IsPlayerLoaded = false

-- ============================================================
-- CARREGAMENTO DO PERSONAGEM
-- ============================================================

--- Evento quando o personagem é carregado pelo server
RegisterNetEvent('nova:client:onPlayerLoaded', function(playerData)
    if not playerData then
        Nova.Debug('Aviso: onPlayerLoaded chamado sem dados - ignorado.')
        return
    end

    Nova.PlayerData = playerData
    Nova.IsPlayerLoaded = true

    -- Determine the correct freemode model from skin data or gender
    local targetModel = `mp_m_freemode_01` -- default male
    if playerData.skin and playerData.skin.model then
        targetModel = playerData.skin.model
    elseif playerData.charinfo and playerData.charinfo.gender == 1 then
        targetModel = `mp_f_freemode_01`
    end

    -- Change player ped model to the correct freemode model
    RequestModel(targetModel)
    while not HasModelLoaded(targetModel) do Wait(0) end
    SetPlayerModel(PlayerId(), targetModel)
    local ped = PlayerPedId()
    SetPedDefaultComponentVariation(ped)
    SetModelAsNoLongerNeeded(targetModel)

    -- Teleportar para a posição guardada
    local pos = playerData.position or NovaConfig.DefaultSpawn
    if pos then
        SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false)
        SetEntityHeading(ped, pos.w or 0.0)
    end

    -- Aplicar skin/aparência do personagem (agora no ped freemode correcto)
    if playerData.skin then
        local skinSuccess, err = pcall(function()
            exports['nova_creator']:ApplySkin(ped, playerData.skin)
        end)
        if not skinSuccess then
            Nova.Debug('Aviso: nova_creator não disponível para aplicar skin: ' .. tostring(err))
        end
    end

    -- Definir saúde e armadura
    local health = playerData.metadata and playerData.metadata.health or 200
    local armor = playerData.metadata and playerData.metadata.armor or 0
    SetEntityHealth(ped, health)
    SetPedArmour(ped, armor)

    -- Se está morto, manter morto
    if playerData.metadata and playerData.metadata.is_dead then
        SetEntityHealth(ped, 0)
    end

    -- Desbloquear mapa completo
    SetMinimapClipType(0)

    -- Notificar
    Nova.Functions.Notify(_L('player_loaded'), 'success')

    -- Trigger para outros resources (use different event name to avoid recursion)
    TriggerEvent('nova:client:playerLoaded', playerData)

    Nova.Debug('Personagem carregado no client: ' .. (playerData.charinfo.firstname or '') .. ' ' .. (playerData.charinfo.lastname or ''))
end)

-- ============================================================
-- LOGOUT
-- ============================================================

RegisterNetEvent('nova:client:onLogout', function()
    Nova.PlayerData = {}
    Nova.IsPlayerLoaded = false
    TriggerEvent('nova:client:onLogout')
    Nova.Debug('Jogador descarregado do client.')
end)

-- ============================================================
-- ATUALIZAÇÃO DE DADOS
-- ============================================================

--- Evento para atualizar dados parciais do jogador
RegisterNetEvent('nova:client:updatePlayerData', function(data)
    -- Guard: data deve ser uma tabela
    if type(data) ~= 'table' then
        Nova.Warn('updatePlayerData recebeu tipo inválido: ' .. type(data))
        return
    end

    if data.type then
        -- Atualização parcial - garantir que PlayerData é uma tabela
        if type(Nova.PlayerData) ~= 'table' then
            Nova.PlayerData = {}
        end
        Nova.PlayerData[data.type] = data.data
        TriggerEvent('nova:client:onPlayerDataUpdate', data.type, data.data)
    else
        -- Atualização completa
        Nova.PlayerData = data
        TriggerEvent('nova:client:onPlayerDataUpdate', 'all', data)
    end
end)

-- ============================================================
-- REVIVE / HEAL
-- ============================================================

RegisterNetEvent('nova:client:revive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 0)
    ClearPedBloodDamage(ped)

    if Nova.PlayerData.metadata then
        Nova.PlayerData.metadata.is_dead = false
        Nova.PlayerData.metadata.health = 200
    end

    Nova.Functions.Notify('Foste revivido!', 'success')
    TriggerEvent('nova:client:onRevive')
end)

RegisterNetEvent('nova:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 0)
    ClearPedBloodDamage(ped)

    if Nova.PlayerData.metadata then
        Nova.PlayerData.metadata.health = 200
        Nova.PlayerData.metadata.armor = 0
        Nova.PlayerData.metadata.hunger = 100
        Nova.PlayerData.metadata.thirst = 100
        Nova.PlayerData.metadata.stress = 0
    end

    Nova.Functions.Notify('Foste curado!', 'success')
end)

-- ============================================================
-- SISTEMA DE NECESSIDADES (Hunger/Thirst)
-- ============================================================

if NovaConfig.Needs.enabled then
    -- Thread principal: reduzir fome/sede periodicamente
    CreateThread(function()
        while true do
            Wait(NovaConfig.Needs.interval)

            if Nova.IsPlayerLoaded and Nova.PlayerData.metadata then
                local meta = Nova.PlayerData.metadata

                -- Reduzir fome
                if meta.hunger and meta.hunger > 0 then
                    meta.hunger = math.max(0, meta.hunger - NovaConfig.Needs.hunger_rate)
                end

                -- Reduzir sede
                if meta.thirst and meta.thirst > 0 then
                    meta.thirst = math.max(0, meta.thirst - NovaConfig.Needs.thirst_rate)
                end

                -- Dano por fome/sede
                if meta.hunger <= 0 or meta.thirst <= 0 then
                    local ped = PlayerPedId()
                    local health = GetEntityHealth(ped)
                    if health > 101 then
                        SetEntityHealth(ped, health - 1)
                    end
                end

                -- Sincronizar com server
                TriggerServerEvent('nova:server:updateMetadata', {
                    hunger = meta.hunger,
                    thirst = meta.thirst,
                })
            end
        end
    end)

end

-- ============================================================
-- ATUALIZAÇÃO DE POSIÇÃO
-- ============================================================

CreateThread(function()
    while true do
        Wait(30000) -- A cada 30 segundos

        if Nova.IsPlayerLoaded then
            local pos = Nova.Functions.GetPlayerPosition()
            TriggerServerEvent('nova:server:updatePosition', {
                x = pos.x,
                y = pos.y,
                z = pos.z,
                w = pos.w,
            })
        end
    end
end)

-- ============================================================
-- DETECÇÃO DE MORTE
-- ============================================================

CreateThread(function()
    while true do
        Wait(1000)

        if Nova.IsPlayerLoaded then
            local ped = PlayerPedId()
            local isDead = IsEntityDead(ped)

            if isDead and Nova.PlayerData.metadata and not Nova.PlayerData.metadata.is_dead then
                Nova.PlayerData.metadata.is_dead = true
                TriggerServerEvent('nova:server:onPlayerDeath')
                TriggerEvent('nova:client:onPlayerDeath')
                Nova.Debug('Jogador morreu!')
            end
        end
    end
end)

-- ============================================================
-- PREVENÇÃO DE DANO EM MODO PASSIVO (exemplo)
-- ============================================================

-- Anti combat-log: Salvar ao fechar jogo
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if Nova.IsPlayerLoaded then
        local pos = Nova.Functions.GetPlayerPosition()
        TriggerServerEvent('nova:server:updatePosition', {
            x = pos.x,
            y = pos.y,
            z = pos.z,
            w = pos.w,
        })
    end
end)

-- ============================================================
-- NUI CALLBACKS
-- ============================================================

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    if data.citizenid then
        TriggerServerEvent('nova:server:loadCharacter', data.citizenid)
        SetNuiFocus(false, false)
    end
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    if data then
        TriggerServerEvent('nova:server:createCharacter', data)
    end
    cb('ok')
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    if data.citizenid then
        TriggerServerEvent('nova:server:deleteCharacter', data.citizenid)
    end
    cb('ok')
end)

-- ============================================================
-- JOB WEAPONS (armas de serviço)
-- ============================================================

local jobWeapons = {}

RegisterNetEvent('nova:client:giveJobWeapons', function(weapons)
    if not weapons then return end
    local ped = PlayerPedId()

    -- Remover armas de serviço antigas
    for hash, _ in pairs(jobWeapons) do
        RemoveWeaponFromPed(ped, hash)
    end
    jobWeapons = {}

    -- Dar armas novas de serviço
    for weaponName, data in pairs(weapons) do
        local hash = GetHashKey(weaponName)
        local ammo = data.ammo or 100
        GiveWeaponToPed(ped, hash, ammo, false, false)
        jobWeapons[hash] = true
    end
end)

RegisterNetEvent('nova:client:removeJobWeapons', function()
    local ped = PlayerPedId()
    for hash, _ in pairs(jobWeapons) do
        RemoveWeaponFromPed(ped, hash)
    end
    jobWeapons = {}
end)

RegisterNetEvent('nova:client:setArmor', function(amount)
    SetPedArmour(PlayerPedId(), amount or 0)
end)

-- ============================================================
-- NOTIFICAÇÕES (fallback para quando nova_notify não está ativo)
-- Evento disparado pelo server via Nova.Functions.Notify()
-- ============================================================

RegisterNetEvent('nova:client:notify', function(data)
    if type(data) ~= 'table' then return end
    local msg = data.message or ''
    local nType = data.type or 'info'
    local duration = data.duration or 5000

    -- Tentar usar nova_notify primeiro
    if GetResourceState('nova_notify') == 'started' then
        local ok = pcall(function()
            exports['nova_notify']:SendNotification(nType, msg, duration)
        end)
        if ok then return end
    end

    -- Fallback: usar Nova.Functions.Notify (que já tem fallback para print)
    Nova.Functions.Notify(msg, nType, duration)
end)

-- ============================================================
-- BLOQUEAR WEAPON WHEEL (TAB) - usar apenas hotbar do inventário
-- ============================================================

CreateThread(function()
    while true do
        -- 37 = INPUT_SELECT_WEAPON (Tab / Weapon Wheel)
        DisableControlAction(0, 37, true)
        -- Bloquear também os selectors individuais de arma
        DisableControlAction(0, 157, true) -- INPUT_SELECT_WEAPON_UNARMED
        DisableControlAction(0, 158, true) -- INPUT_SELECT_WEAPON_MELEE
        DisableControlAction(0, 159, true) -- INPUT_SELECT_WEAPON_HANDGUN
        DisableControlAction(0, 160, true) -- INPUT_SELECT_WEAPON_SHOTGUN
        DisableControlAction(0, 161, true) -- INPUT_SELECT_WEAPON_SMG
        DisableControlAction(0, 162, true) -- INPUT_SELECT_WEAPON_AUTO_RIFLE
        DisableControlAction(0, 163, true) -- INPUT_SELECT_WEAPON_SNIPER
        DisableControlAction(0, 164, true) -- INPUT_SELECT_WEAPON_HEAVY
        DisableControlAction(0, 165, true) -- INPUT_SELECT_WEAPON_SPECIAL
        Wait(0)
    end
end)
