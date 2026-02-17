--[[
    NOVA Framework - Configuração Principal
    Todas as configurações globais do framework
]]

NovaConfig = {}

-- ============================================================
-- GERAL
-- ============================================================
NovaConfig.ServerName = 'NOVA RP'
NovaConfig.Debug = false
NovaConfig.Locale = 'pt'

-- Identificador principal (license, steam, discord, fivem)
NovaConfig.IdentifierType = 'license'

-- ============================================================
-- PERSONAGENS (Multichar)
-- ============================================================
NovaConfig.MaxCharacters = 3
NovaConfig.DefaultSpawn = vector4(-269.4, -955.3, 31.2, 205.8) -- Legion Square

-- ============================================================
-- DINHEIRO
-- ============================================================
NovaConfig.MoneyTypes = {
    cash = { label = 'Dinheiro', default = 5000 },
    bank = { label = 'Banco', default = 10000 },
    black_money = { label = 'Dinheiro Sujo', default = 0 },
}

-- ============================================================
-- EMPREGO PADRÃO
-- ============================================================
NovaConfig.DefaultJob = {
    name = 'desempregado',
    label = 'Desempregado',
    grade = 0,
    grade_label = 'Desempregado',
    salary = 100,
    type = nil,
    duty = true,
}

-- ============================================================
-- GANG PADRÃO
-- ============================================================
NovaConfig.DefaultGang = {
    name = 'none',
    label = 'Nenhuma',
    grade = 0,
    grade_label = 'Membro',
    is_boss = false,
}

-- ============================================================
-- PERSONAGEM PADRÃO
-- ============================================================
NovaConfig.DefaultCharInfo = {
    firstname = '',
    lastname = '',
    dateofbirth = '01/01/2000',
    gender = 0,       -- 0 = masculino, 1 = feminino
    nationality = 'Português',
    phone = nil,
}

-- ============================================================
-- METADATA PADRÃO
-- ============================================================
NovaConfig.DefaultMetadata = {
    hunger = 100,
    thirst = 100,
    stress = 0,
    armor = 0,
    health = 200,
    is_dead = false,
    in_jail = false,
    jail_time = 0,
    tracker = false,
    bloodtype = 'O+',
    licenses = {
        driver = false,
        weapon = false,
        fishing = false,
        hunting = false,
    },
}

-- ============================================================
-- NECESSIDADES (Hunger/Thirst)
-- ============================================================
NovaConfig.Needs = {
    enabled = true,
    interval = 60000,       -- ms entre cada redução
    hunger_rate = 0.8,      -- quanto reduz por tick
    thirst_rate = 1.0,      -- quanto reduz por tick
}

-- ============================================================
-- WEATHER SYNC (Ciclo automático de tempo e clima)
-- ============================================================
NovaConfig.Weather = {
    enabled = true,

    -- Hora inicial do servidor (quando inicia)
    startHour   = 8,
    startMinute = 0,

    -- Velocidade do tempo: a cada X ms reais, avança 1 minuto in-game
    -- 10000 = 10s reais por 1 min in-game (1 dia in-game = 4h reais)
    -- 30000 = 30s reais por 1 min in-game (1 dia in-game = 12h reais)
    timeSpeed = 10000,

    -- Intervalo de mudança de clima (ms) - muda a cada 10 minutos reais
    weatherChangeInterval = 600000,

    -- Ciclo de climas (o sistema roda por esta lista)
    weatherCycle = {
        'EXTRASUNNY',   -- Sol forte
        'CLEAR',        -- Limpo
        'CLOUDS',       -- Nublado leve
        'OVERCAST',     -- Nublado
        'CLEARING',     -- A limpar
        'CLEAR',        -- Limpo
        'EXTRASUNNY',   -- Sol forte
        'CLOUDS',       -- Nublado leve
        'RAIN',         -- Chuva
        'THUNDER',      -- Trovoada
        'CLEARING',     -- A limpar
        'FOGGY',        -- Nevoeiro
        'CLEAR',        -- Limpo
    },

    -- Intervalo de sync com clients (ms) - a cada 5 segundos
    syncInterval = 5000,
}

-- ============================================================
-- SALVAMENTO AUTOMÁTICO
-- ============================================================
NovaConfig.AutoSave = {
    enabled = true,
    interval = 300000,      -- 5 minutos em ms
}

-- ============================================================
-- LOGS
-- ============================================================
NovaConfig.DiscordWebhook = ''  -- URL do webhook para logs

-- ============================================================
-- GRUPOS DE PERMISSÃO
-- Definição completa em config/groups/admin.lua (NovaGroups.AdminGroups)
-- ============================================================
