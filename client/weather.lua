--[[
    NOVA Framework - Weather Sync (Client)
    Recebe o estado de tempo/clima do servidor e aplica localmente.
    Desativa o weather nativo do GTA para evitar conflitos.
]]

if not NovaConfig.Weather or not NovaConfig.Weather.enabled then return end

-- ============================================================
-- ESTADO LOCAL
-- ============================================================

local currentWeather  = 'CLEAR'
local targetWeather   = 'CLEAR'
local currentHour     = 8
local currentMinute   = 0
local weatherReady    = false
local transitionTimer = 0.0

-- ============================================================
-- EVENTO: Receber sync do servidor
-- ============================================================

RegisterNetEvent('nova:client:syncWeather', function(data)
    if not data then return end

    currentHour   = data.hour or currentHour
    currentMinute = data.minute or currentMinute

    if data.weather and data.weather ~= currentWeather then
        targetWeather  = data.weather
        transitionTimer = 0.0
    end

    weatherReady = true
end)

-- ============================================================
-- PEDIR ESTADO AO ENTRAR
-- ============================================================

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('nova:server:requestWeather')
end)

-- ============================================================
-- THREAD PRINCIPAL: Aplicar clima e hora
-- ============================================================

CreateThread(function()
    -- Pedir estado inicial
    Wait(2000)
    TriggerServerEvent('nova:server:requestWeather')

    while true do
        Wait(100)

        if weatherReady then
            -- ==== DESATIVAR WEATHER NATIVO ====
            -- Impedir o jogo de mudar o clima sozinho
            SetArtificialLightsState(false)
            
            -- ==== APLICAR HORA ====
            NetworkOverrideClockTime(currentHour, currentMinute, 0)

            -- ==== TRANSIÇÃO SUAVE DE CLIMA ====
            if targetWeather ~= currentWeather then
                transitionTimer = transitionTimer + 0.01
                if transitionTimer >= 1.0 then
                    currentWeather = targetWeather
                    transitionTimer = 0.0
                    SetWeatherTypeNowPersist(currentWeather)
                    SetWeatherTypeNow(currentWeather)
                else
                    SetWeatherTypeOvertimePersist(targetWeather, 15.0)
                end
            else
                SetWeatherTypeNowPersist(currentWeather)
            end

            -- Forçar override para impedir mudanças nativas
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypePersist(currentWeather)
            SetWeatherTypeNow(currentWeather)
            SetOverrideWeather(currentWeather)
        end
    end
end)

-- ============================================================
-- THREAD: Impedir relógio nativo de avançar
-- ============================================================

CreateThread(function()
    while true do
        Wait(0)
        -- Não deixar o relógio nativo avançar
        if weatherReady then
            NetworkOverrideClockTime(currentHour, currentMinute, 0)
        end
    end
end)

-- ============================================================
-- WIND (efeitos visuais melhorados para chuva/trovoada)
-- ============================================================

CreateThread(function()
    while true do
        Wait(1000)

        if weatherReady then
            if currentWeather == 'RAIN' or currentWeather == 'THUNDER' then
                SetWind(0.5)
                SetWindSpeed(8.0)
                SetWindDirection(math.random() * 360.0)
            elseif currentWeather == 'FOGGY' then
                SetWind(0.1)
                SetWindSpeed(2.0)
            else
                SetWind(0.0)
                SetWindSpeed(0.0)
            end
        end
    end
end)
