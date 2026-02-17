--[[
    NOVA Framework - Core
    Um framework moderno e otimizado para FiveM RP
    
    Desenvolvido com foco em:
    - Performance
    - Segurança (validações server-side)
    - Modularidade
    - Facilidade de uso
]]

fx_version 'cerulean'
game 'gta5'

name 'nova_core'
description 'NOVA Framework - Core Resource'
author 'NOVA Development'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'config/main.lua',
    'config/groups/admin.lua',
    'config/groups/jobs.lua',
    'config/groups/gangs.lua',
    'config/groups/salary.lua',
    'config/groups/locations.lua',
    'config/items.lua',
    'shared/locale.lua',
    'config/locales/pt.lua',
    'config/locales/en.lua',
    'shared/main.lua',
    'shared/auth.lua',
    'shared/loader.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/callbacks.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/main.lua',
    'server/weather.lua',
    -- Módulos (carregados pelo loader)
    'modules/permissions/server.lua',
    'modules/commands/server.lua',
    'modules/jobs/server.lua',
    'modules/vehiclekeys/server.lua',
}

client_scripts {
    'client/callbacks.lua',
    'client/functions.lua',
    'client/main.lua',
    'client/ipl.lua',
    'client/world.lua',
    'client/weather.lua',
    'modules/vehiclekeys/client.lua',
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
}

-- ============================================================
-- EXPORTS DECLARADOS (para discovery por outros devs/resources)
-- ============================================================

-- Shared (disponíveis em client E server)
exports {
    'GetObject',            -- Retorna o objeto Nova completo
    'GetConfig',            -- Retorna NovaConfig
    'GetItems',             -- Retorna NovaItems
}

-- Server-only
server_exports {
    'IsFrameworkReady',     -- bool: framework pronto?
    'GetPlayer',            -- Player obj por source
    'GetPlayerByCitizenId', -- Player obj por citizenid
    'GetPlayers',           -- Lista de todos os players
    'IsPlayerLoaded',       -- bool: player carregado? (source)
    'AddPlayerMoney',       -- Adicionar dinheiro
    'RemovePlayerMoney',    -- Remover dinheiro
    'SetPlayerInventory',   -- Definir inventário do player real
    'SetPlayerSkin',        -- Definir skin do player real
    'SavePlayer',           -- Forçar save do player
    'SetPlayerMetadata',    -- Definir metadata
    'LoginPlayer',          -- Login de player
    'LogoutPlayer',         -- Logout de player
    'CreateCallback',       -- Registar callback
    'Notify',               -- Enviar notificação
    'HasPermission',        -- Verificar grupo
    'HasPermissionNode',    -- Verificar permissão específica
    'IsAdmin',              -- Verificar admin
    'GetJobs',              -- Todos os empregos
    'GetGangs',             -- Todas as gangs
    'GetJobConfig',         -- Config de um emprego
    'GetGangConfig',        -- Config de uma gang
    'GetPlayerJobConfig',   -- Config do emprego do player
    'GetPlayerGangConfig',  -- Config da gang do player
    'GetPlayerJobVehicles', -- Veículos do emprego
    -- Weather
    'GetCurrentWeather',    -- Clima atual
    'GetCurrentTime',       -- Hora atual (hour, minute)
    'SetWeather',           -- Forçar clima
    'SetTime',              -- Forçar hora
    -- Vehicle Keys
    'GiveKeys',             -- Dar chaves
    'RemoveKeys',           -- Remover chaves
    'HasKeys',              -- Verificar chaves (server)
    'LoadPlayerKeys',       -- Carregar chaves do player
}

-- Client-only
client_exports {
    'IsFrameworkReady',     -- bool: framework pronto? (client)
    'IsPlayerLoaded',       -- bool: player carregado?
    'GetPlayerData',        -- Dados do player
    'TriggerCallback',      -- Disparar callback no server
    'ClientNotify',         -- Enviar notificação local
    -- Vehicle Keys
    'HasKey',               -- Verificar chave (client)
    'GetMyKeys',            -- Todas as chaves do player
}

dependencies {
    'oxmysql',
}
