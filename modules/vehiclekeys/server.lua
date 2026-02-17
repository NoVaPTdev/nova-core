--[[
    NOVA Framework - Vehicle Keys System (Server)
    Sistema de chaves de veículos: trancar/destrancar, gestão de chaves
    
    Chaves são guardadas em memória por sessão.
    Quando o jogador compra um carro ou retira da garagem, recebe as chaves.
    Chaves temporárias (empréstimo) expiram ao desconectar.
]]

-- Chaves por jogador: PlayerKeys[citizenid] = { ['PLATE'] = true, ... }
local PlayerKeys = {}

-- ============================================================
-- HELPERS
-- ============================================================

local function GetPlayer(src)
    return Nova.Functions.GetPlayer(src)
end

local function Log(msg)
    print('^5[NOVA Keys]^0 ' .. msg)
end

-- ============================================================
-- GESTÃO DE CHAVES
-- ============================================================

--- Dar chave de um veículo ao jogador
local function GiveKeys(src, plate)
    if not plate or plate == '' then return false end
    local player = GetPlayer(src)
    if not player then return false end
    
    local cid = player.citizenid
    if not PlayerKeys[cid] then PlayerKeys[cid] = {} end
    
    plate = tostring(plate):upper():gsub('%s+', '')
    PlayerKeys[cid][plate] = true
    
    -- Sincronizar com o client
    TriggerClientEvent('nova:keys:receiveKeys', src, PlayerKeys[cid])
    return true
end

--- Remover chave de um veículo do jogador
local function RemoveKeys(src, plate)
    if not plate or plate == '' then return false end
    local player = GetPlayer(src)
    if not player then return false end
    
    local cid = player.citizenid
    if not PlayerKeys[cid] then return false end
    
    plate = tostring(plate):upper():gsub('%s+', '')
    PlayerKeys[cid][plate] = nil
    
    TriggerClientEvent('nova:keys:receiveKeys', src, PlayerKeys[cid])
    return true
end

--- Verificar se o jogador tem chave
local function HasKeys(src, plate)
    if not plate or plate == '' then return false end
    local player = GetPlayer(src)
    if not player then return false end
    
    local cid = player.citizenid
    if not PlayerKeys[cid] then return false end
    
    plate = tostring(plate):upper():gsub('%s+', '')
    return PlayerKeys[cid][plate] == true
end

--- Carregar chaves de todos os veículos do jogador (ao fazer login/spawn)
local function LoadPlayerKeys(src)
    local player = GetPlayer(src)
    if not player then return end
    
    local cid = player.citizenid
    PlayerKeys[cid] = {}
    
    -- Dar chaves de todos os veículos que o jogador possui
    local vehicles = MySQL.query.await('SELECT plate FROM nova_vehicles WHERE citizenid = ?', { cid })
    if vehicles then
        for _, v in ipairs(vehicles) do
            local plate = tostring(v.plate):upper():gsub('%s+', '')
            PlayerKeys[cid][plate] = true
        end
    end
    
    TriggerClientEvent('nova:keys:receiveKeys', src, PlayerKeys[cid])
    Log('Chaves carregadas para ' .. cid .. ' (' .. (vehicles and #vehicles or 0) .. ' veículos)')
end

-- ============================================================
-- EVENTOS
-- ============================================================

--- Jogador pede para trancar/destrancar
RegisterNetEvent('nova:keys:toggleLock', function(plate, netId)
    local src = source
    if not plate or plate == '' then return end
    
    plate = tostring(plate):upper():gsub('%s+', '')
    
    if not HasKeys(src, plate) then
        Nova.Functions.Notify(src, 'Não tens a chave deste veículo!', 'error', 3000)
        return
    end
    
    -- Broadcast para todos os clients perto
    TriggerClientEvent('nova:keys:toggleLockResult', -1, netId, src)
end)

--- Jogador carregou - dar chaves
RegisterNetEvent('nova:keys:requestKeys', function()
    local src = source
    LoadPlayerKeys(src)
end)

--- Jogador desconectou - limpar chaves temporárias (manter as permanentes na próxima sessão)
AddEventHandler('playerDropped', function()
    -- As chaves são recarregadas na próxima sessão via LoadPlayerKeys
    -- Não precisamos limpar aqui, apenas se quisermos libertar memória
end)

--- Quando o jogador faz login no framework
AddEventHandler('nova:server:onPlayerLoaded', function(src)
    -- Dar um pequeno delay para garantir que o player está pronto
    SetTimeout(2000, function()
        LoadPlayerKeys(src)
    end)
end)

-- ============================================================
-- EXPORTS (para outros scripts)
-- ============================================================

--- Dar chave ao jogador (usado por dealership, garage, admin, etc.)
exports('GiveKeys', function(src, plate)
    return GiveKeys(src, plate)
end)

--- Remover chave do jogador
exports('RemoveKeys', function(src, plate)
    return RemoveKeys(src, plate)
end)

--- Verificar se o jogador tem chave
exports('HasKeys', function(src, plate)
    return HasKeys(src, plate)
end)

--- Carregar todas as chaves do jogador
exports('LoadPlayerKeys', function(src)
    LoadPlayerKeys(src)
end)

Log('Modulo de chaves iniciado.')
