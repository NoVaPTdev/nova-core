--[[
    NOVA Framework - Weather Sync (Server)
    Controla o tempo e clima do servidor, sincronizando todos os jogadores.
    
    O servidor é a autoridade: decide a hora e o clima.
    Os clients recebem e aplicam.
]]

if not NovaConfig.Weather or not NovaConfig.Weather.enabled then return end

-- ============================================================
-- ESTADO
-- ============================================================

local CurrentWeather = NovaConfig.Weather.weatherCycle[1] or 'CLEAR'
local CurrentHour    = NovaConfig.Weather.startHour or 8
local CurrentMinute  = NovaConfig.Weather.startMinute or 0
local WeatherIndex   = 1
local frozen         = false  -- se true, tempo não avança

-- ============================================================
-- LOGGING
-- ============================================================

local function Log(msg)
    print('^6[NOVA Weather]^0 ' .. msg)
end

-- ============================================================
-- THREAD: Avançar tempo do jogo
-- ============================================================

CreateThread(function()
    Log('Weather Sync iniciado - Hora: ' .. CurrentHour .. ':' .. string.format('%02d', CurrentMinute) .. ' | Clima: ' .. CurrentWeather)

    while true do
        Wait(NovaConfig.Weather.timeSpeed)

        if not frozen then
            CurrentMinute = CurrentMinute + 1
            if CurrentMinute >= 60 then
                CurrentMinute = 0
                CurrentHour = CurrentHour + 1
                if CurrentHour >= 24 then
                    CurrentHour = 0
                end
            end
        end
    end
end)

-- ============================================================
-- THREAD: Ciclo automático de clima
-- ============================================================

CreateThread(function()
    while true do
        Wait(NovaConfig.Weather.weatherChangeInterval)

        if not frozen then
            WeatherIndex = WeatherIndex + 1
            if WeatherIndex > #NovaConfig.Weather.weatherCycle then
                WeatherIndex = 1
            end
            CurrentWeather = NovaConfig.Weather.weatherCycle[WeatherIndex]
            Log('Clima mudou para: ' .. CurrentWeather)
        end
    end
end)

-- ============================================================
-- THREAD: Sincronizar com todos os clients
-- ============================================================

CreateThread(function()
    while true do
        Wait(NovaConfig.Weather.syncInterval)

        TriggerClientEvent('nova:client:syncWeather', -1, {
            weather = CurrentWeather,
            hour    = CurrentHour,
            minute  = CurrentMinute,
        })
    end
end)

-- ============================================================
-- EVENTO: Sincronizar novo jogador ao spawnar
-- ============================================================

RegisterNetEvent('nova:server:requestWeather', function()
    local src = source
    TriggerClientEvent('nova:client:syncWeather', src, {
        weather = CurrentWeather,
        hour    = CurrentHour,
        minute  = CurrentMinute,
    })
end)

-- ============================================================
-- COMANDOS ADMIN
-- ============================================================

--- /setweather [tipo] - Forçar clima
RegisterCommand('setweather', function(source, args)
    -- Verificar permissão (source 0 = console)
    if source > 0 then
        local player = Nova.Functions.GetPlayer(source)
        if not player or not Nova.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('nova:client:notify', source, 'Sem permissão', 'error')
            return
        end
    end

    local weatherType = args[1] and string.upper(args[1]) or nil
    if not weatherType then
        if source == 0 then
            print('Uso: setweather [CLEAR|RAIN|THUNDER|CLOUDS|OVERCAST|FOGGY|EXTRASUNNY|CLEARING|SNOWLIGHT|XMAS|BLIZZARD]')
        end
        return
    end

    CurrentWeather = weatherType
    TriggerClientEvent('nova:client:syncWeather', -1, {
        weather = CurrentWeather,
        hour    = CurrentHour,
        minute  = CurrentMinute,
    })
    Log('Clima forçado para: ' .. CurrentWeather .. ' por ' .. (source == 0 and 'Console' or ('ID ' .. source)))
end, false)

--- /settime [hora] [minuto] - Forçar hora
RegisterCommand('settime', function(source, args)
    -- Verificar permissão
    if source > 0 then
        local player = Nova.Functions.GetPlayer(source)
        if not player or not Nova.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('nova:client:notify', source, 'Sem permissão', 'error')
            return
        end
    end

    local hour = tonumber(args[1])
    local minute = tonumber(args[2]) or 0

    if not hour or hour < 0 or hour > 23 then
        if source == 0 then
            print('Uso: settime [0-23] [0-59]')
        end
        return
    end

    minute = math.max(0, math.min(59, minute))
    CurrentHour = hour
    CurrentMinute = minute

    TriggerClientEvent('nova:client:syncWeather', -1, {
        weather = CurrentWeather,
        hour    = CurrentHour,
        minute  = CurrentMinute,
    })
    Log('Hora forçada para: ' .. CurrentHour .. ':' .. string.format('%02d', CurrentMinute) .. ' por ' .. (source == 0 and 'Console' or ('ID ' .. source)))
end, false)

--- /freezetime - Congelar/descongelar o tempo
RegisterCommand('freezetime', function(source)
    if source > 0 then
        local player = Nova.Functions.GetPlayer(source)
        if not player or not Nova.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('nova:client:notify', source, 'Sem permissão', 'error')
            return
        end
    end

    frozen = not frozen
    Log('Tempo ' .. (frozen and 'CONGELADO' or 'RETOMADO') .. ' por ' .. (source == 0 and 'Console' or ('ID ' .. source)))
end, false)

-- ============================================================
-- EXPORTS
-- ============================================================

exports('GetCurrentWeather', function()
    return CurrentWeather
end)

exports('GetCurrentTime', function()
    return CurrentHour, CurrentMinute
end)

exports('SetWeather', function(weatherType)
    CurrentWeather = string.upper(weatherType)
    TriggerClientEvent('nova:client:syncWeather', -1, {
        weather = CurrentWeather,
        hour    = CurrentHour,
        minute  = CurrentMinute,
    })
end)

exports('SetTime', function(hour, minute)
    CurrentHour = math.max(0, math.min(23, hour))
    CurrentMinute = math.max(0, math.min(59, minute or 0))
    TriggerClientEvent('nova:client:syncWeather', -1, {
        weather = CurrentWeather,
        hour    = CurrentHour,
        minute  = CurrentMinute,
    })
end)
