--[[
    NOVA Framework - Sistema de Callbacks (Client)
    Comunicação assíncrona com o server
]]

Nova.ClientCallbacks = {}
local callbackRequestId = 0

-- ============================================================
-- TRIGGER CALLBACK
-- ============================================================

--- Dispara um callback no server e aguarda resposta
---@param name string Nome do callback
---@param callback function Função com a resposta
---@param ... any Argumentos extras
function Nova.Functions.TriggerCallback(name, callback, ...)
    callbackRequestId = callbackRequestId + 1
    local requestId = callbackRequestId

    Nova.ClientCallbacks[requestId] = callback

    TriggerServerEvent('nova:server:triggerCallback', name, requestId, ...)
end

--- Versão com promise (pode usar com Citizen.Await)
---@param name string Nome do callback
---@param ... any Argumentos
---@return any Resultado do callback
function Nova.Functions.TriggerCallbackSync(name, ...)
    local p = promise.new()

    Nova.Functions.TriggerCallback(name, function(...)
        p:resolve({ ... })
    end, ...)

    local result = Citizen.Await(p)
    return table.unpack(result)
end

-- ============================================================
-- RESPOSTA DO SERVER
-- ============================================================

RegisterNetEvent('nova:client:callbackResponse', function(requestId, ...)
    if Nova.ClientCallbacks[requestId] then
        Nova.ClientCallbacks[requestId](...)
        Nova.ClientCallbacks[requestId] = nil
    end
end)
