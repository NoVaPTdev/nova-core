--[[
    NOVA Framework - Sistema de Callbacks (Server)
    Permite comunicação assíncrona eficiente entre client e server
]]

Nova.ServerCallbacks = {}

-- ============================================================
-- REGISTO DE CALLBACKS
-- ============================================================

--- Regista um callback no server
---@param name string Nome único do callback
---@param handler function Função handler (source, callback, ...)
function Nova.Functions.CreateCallback(name, handler)
    Nova.ServerCallbacks[name] = handler
    Nova.Debug('Callback registado: ' .. name)
end

-- ============================================================
-- EVENTOS DO SISTEMA DE CALLBACKS
-- ============================================================

--- Evento chamado pelo client para disparar um callback
RegisterNetEvent('nova:server:triggerCallback', function(name, requestId, ...)
    local source = source

    if not Nova.ServerCallbacks[name] then
        Nova.Error('Callback não encontrado: ' .. name)
        TriggerClientEvent('nova:client:callbackResponse', source, requestId, nil)
        return
    end

    -- Executar o callback com uma função que envia a resposta de volta
    Nova.ServerCallbacks[name](source, function(...)
        TriggerClientEvent('nova:client:callbackResponse', source, requestId, ...)
    end, ...)
end)

-- ============================================================
-- CALLBACKS PADRÃO
-- ============================================================

-- Callback para obter dados do jogador
Nova.Functions.CreateCallback('nova:server:getPlayerData', function(source, cb)
    local player = Nova.Functions.GetPlayer(source)
    if player then
        cb(player:GetData())
    else
        cb(nil)
    end
end)

-- Callback para obter personagens do jogador
Nova.Functions.CreateCallback('nova:server:getCharacters', function(source, cb)
    local identifier = Nova.Functions.GetIdentifier(source, NovaConfig.IdentifierType)
    if not identifier then
        cb({})
        return
    end

    Nova.Database.GetOrCreateUser(identifier, GetPlayerName(source), Nova.Functions.GetAllIdentifiers(source), function(user)
        if not user then
            cb({})
            return
        end

        Nova.Database.GetCharacters(user.id, function(characters)
            local charList = {}
            for _, char in ipairs(characters) do
                table.insert(charList, {
                    citizenid = char.citizenid,
                    firstname = char.firstname,
                    lastname = char.lastname,
                    dateofbirth = char.dateofbirth,
                    gender = char.gender,
                    nationality = char.nationality,
                    cash = char.cash,
                    bank = char.bank,
                    job = char.job,
                    job_grade = char.job_grade,
                })
            end
            cb(charList)
        end)
    end)
end)

-- Callback para obter empregos
Nova.Functions.CreateCallback('nova:server:getJobs', function(source, cb)
    Nova.Database.GetAllJobs(function(jobs)
        cb(jobs)
    end)
end)

-- Callback para obter gangs
Nova.Functions.CreateCallback('nova:server:getGangs', function(source, cb)
    Nova.Database.GetAllGangs(function(gangs)
        cb(gangs)
    end)
end)
