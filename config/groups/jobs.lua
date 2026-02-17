--[[
    NOVA Framework - Definição de Empregos
    Permissões com suporte a grau mínimo (minGrade) e gating de serviço (onDutyOnly)
    
    Formato de permissão:
        { node = 'police.handcuff', minGrade = 0, onDutyOnly = true }
        - node: nome da permissão
        - minGrade: grau mínimo necessário (0 = todos os graus)
        - onDutyOnly: true = só funciona em serviço (opcional, default false)
        - Prefixo '-' para permissão negativa: { node = '-police.seizable', minGrade = 0 }
]]

NovaGroups = NovaGroups or {}

NovaGroups.Jobs = {

    -- --------------------------------------------------------
    -- DESEMPREGADO (default)
    -- --------------------------------------------------------
    ['desempregado'] = {
        label = 'Desempregado',
        type = nil,
        defaultDuty = true,
        permissions = {},
        equipment = {},
        vehicles = {},
    },

    -- --------------------------------------------------------
    -- POLÍCIA
    -- --------------------------------------------------------
    ['policia'] = {
        label = 'Polícia',
        type = 'law',
        defaultDuty = false,
        permissions = {
            -- Acesso geral (todos os graus)
            { node = 'police.menu',        minGrade = 0 },
            { node = 'police.cloakroom',   minGrade = 0 },
            { node = 'police.stash',       minGrade = 0 },
            { node = 'police.dispatch',    minGrade = 0 },

            -- Ações em serviço (todos os graus, só on duty)
            { node = 'police.handcuff',    minGrade = 0, onDutyOnly = true },
            { node = 'police.drag',        minGrade = 0, onDutyOnly = true },
            { node = 'police.escort',      minGrade = 0, onDutyOnly = true },
            { node = 'police.putinveh',    minGrade = 0, onDutyOnly = true },
            { node = 'police.getoutveh',   minGrade = 0, onDutyOnly = true },
            { node = 'police.search',      minGrade = 0, onDutyOnly = true },
            { node = 'police.seize',       minGrade = 0, onDutyOnly = true },

            -- Agente+ (grau 1)
            { node = 'police.armory',      minGrade = 1 },
            { node = 'police.garage',      minGrade = 1 },
            { node = 'police.jail',        minGrade = 1, onDutyOnly = true },
            { node = 'police.fine',        minGrade = 1, onDutyOnly = true },
            { node = 'police.mdt',         minGrade = 1 },
            { node = 'police.fingerprint', minGrade = 1, onDutyOnly = true },
            { node = 'police.dna',         minGrade = 1, onDutyOnly = true },
            { node = 'police.evidence',    minGrade = 1, onDutyOnly = true },

            -- Sargento+ (grau 2)
            { node = 'police.radar',       minGrade = 2, onDutyOnly = true },
            { node = 'police.spike',       minGrade = 2, onDutyOnly = true },
            { node = 'police.barrier',     minGrade = 2, onDutyOnly = true },

            -- Subintendente+ (grau 3)
            { node = 'police.announce',    minGrade = 3 },
            { node = 'police.impound',     minGrade = 3, onDutyOnly = true },

            -- Negativas (aplicadas a todos os graus)
            { node = '-police.seizable',   minGrade = 0 },
        },
        equipment = {
            weapons = {
                ['WEAPON_STUNGUN']      = { ammo = 1000 },
                ['WEAPON_COMBATPISTOL'] = { ammo = 150 },
                ['WEAPON_NIGHTSTICK']   = { ammo = 0 },
                ['WEAPON_FLASHLIGHT']   = { ammo = 0 },
            },
            armor = 100,
            items = {},
        },
        vehicles = {
            [0] = { 'police', 'police2' },
            [1] = { 'police', 'police2', 'police3' },
            [2] = { 'police', 'police2', 'police3', 'policeb' },
            [3] = { 'police', 'police2', 'police3', 'policeb', 'fbi' },
            [4] = { 'police', 'police2', 'police3', 'policeb', 'fbi', 'fbi2', 'policet' },
        },
    },

    -- --------------------------------------------------------
    -- AMBULÂNCIA / HOSPITAL
    -- --------------------------------------------------------
    ['ambulancia'] = {
        label = 'Ambulância',
        type = 'medical',
        defaultDuty = false,
        permissions = {
            -- Acesso geral (todos os graus)
            { node = 'ambulance.menu',          minGrade = 0 },
            { node = 'ambulance.cloakroom',     minGrade = 0 },
            { node = 'ambulance.stash',         minGrade = 0 },
            { node = 'ambulance.dispatch',      minGrade = 0 },

            -- Ações em serviço (todos os graus)
            { node = 'ambulance.revive',        minGrade = 0, onDutyOnly = true },
            { node = 'ambulance.heal',          minGrade = 0, onDutyOnly = true },
            { node = 'ambulance.check',         minGrade = 0, onDutyOnly = true },
            { node = 'ambulance.stretcher',     minGrade = 0, onDutyOnly = true },
            { node = 'ambulance.defibrillator', minGrade = 0, onDutyOnly = true },

            -- Paramédico+ (grau 1)
            { node = 'ambulance.armory',        minGrade = 1 },
            { node = 'ambulance.garage',        minGrade = 1 },
            { node = 'ambulance.medicate',      minGrade = 1, onDutyOnly = true },
            { node = 'ambulance.bed',           minGrade = 1, onDutyOnly = true },
            { node = 'ambulance.report',        minGrade = 1 },

            -- Médico+ (grau 2)
            { node = 'ambulance.billing',       minGrade = 2 },

            -- Cirurgião+ (grau 3)
            { node = 'ambulance.surgery',       minGrade = 3, onDutyOnly = true },

            -- Diretor (grau 4)
            { node = 'ambulance.helicopter',    minGrade = 4 },
        },
        equipment = {
            weapons = {},
            armor = 0,
            items = {
                { name = 'medikit', amount = 5 },
                { name = 'bandage', amount = 10 },
            },
        },
        vehicles = {
            [0] = { 'ambulance' },
            [1] = { 'ambulance' },
            [2] = { 'ambulance', 'lguard' },
            [3] = { 'ambulance', 'lguard' },
            [4] = { 'ambulance', 'lguard', 'polmav' },
        },
    },

    -- --------------------------------------------------------
    -- MECÂNICO
    -- --------------------------------------------------------
    ['mecanico'] = {
        label = 'Mecânico',
        type = nil,
        defaultDuty = false,
        permissions = {
            { node = 'mechanic.menu',      minGrade = 0 },
            { node = 'mechanic.cloakroom', minGrade = 0 },
            { node = 'mechanic.stash',     minGrade = 0 },
            { node = 'mechanic.repair',    minGrade = 0, onDutyOnly = true },
            { node = 'mechanic.tow',       minGrade = 0, onDutyOnly = true },
            { node = 'mechanic.garage',    minGrade = 1 },
            { node = 'mechanic.tuning',    minGrade = 1, onDutyOnly = true },
            { node = 'mechanic.paint',     minGrade = 1, onDutyOnly = true },
            { node = 'mechanic.invoice',   minGrade = 1 },
            { node = 'mechanic.craft',     minGrade = 2 },
        },
        equipment = {
            weapons = {},
            armor = 0,
            items = {
                { name = 'repairkit', amount = 3 },
            },
        },
        vehicles = {
            [0] = { 'towtruck2', 'flatbed' },
            [1] = { 'towtruck2', 'flatbed', 'towtruck' },
            [2] = { 'towtruck2', 'flatbed', 'towtruck' },
        },
    },

    -- --------------------------------------------------------
    -- TAXISTA
    -- --------------------------------------------------------
    ['taxista'] = {
        label = 'Taxista',
        type = nil,
        defaultDuty = false,
        permissions = {
            { node = 'taxi.menu',         minGrade = 0 },
            { node = 'taxi.cloakroom',    minGrade = 0 },
            { node = 'taxi.garage',       minGrade = 0 },
            { node = 'taxi.meter',        minGrade = 0, onDutyOnly = true },
            { node = 'taxi.npc_missions', minGrade = 0, onDutyOnly = true },
        },
        equipment = {
            weapons = {},
            armor = 0,
            items = {},
        },
        vehicles = {
            [0] = { 'taxi' },
            [1] = { 'taxi', 'tourbus' },
        },
    },

    -- --------------------------------------------------------
    -- REPÓRTER
    -- --------------------------------------------------------
    ['reporter'] = {
        label = 'Repórter',
        type = nil,
        defaultDuty = false,
        permissions = {
            { node = 'reporter.menu',       minGrade = 0 },
            { node = 'reporter.cloakroom',  minGrade = 0 },
            { node = 'reporter.garage',     minGrade = 0 },
            { node = 'reporter.camera',     minGrade = 0, onDutyOnly = true },
            { node = 'reporter.microphone', minGrade = 0, onDutyOnly = true },
            { node = 'reporter.boom',       minGrade = 1, onDutyOnly = true },
            { node = 'reporter.announce',   minGrade = 2 },
        },
        equipment = {
            weapons = {},
            armor = 0,
            items = {},
        },
        vehicles = {
            [0] = { 'rumpo' },
            [1] = { 'rumpo', 'newsvan' },
            [2] = { 'rumpo', 'newsvan', 'frogger' },
        },
    },

    -- --------------------------------------------------------
    -- ADVOGADO
    -- --------------------------------------------------------
    ['advogado'] = {
        label = 'Advogado',
        type = nil,
        defaultDuty = false,
        permissions = {
            { node = 'lawyer.menu',       minGrade = 0 },
            { node = 'lawyer.cloakroom',  minGrade = 0 },
            { node = 'lawyer.visit_jail', minGrade = 0, onDutyOnly = true },
            { node = 'lawyer.documents',  minGrade = 0 },
            { node = 'lawyer.bail',       minGrade = 1, onDutyOnly = true },
            { node = 'lawyer.court',      minGrade = 1 },
            { node = 'lawyer.invoice',    minGrade = 1 },
        },
        equipment = {
            weapons = {},
            armor = 0,
            items = {},
        },
        vehicles = {},
    },

    -- --------------------------------------------------------
    -- IMOBILIÁRIA
    -- --------------------------------------------------------
    ['imobiliaria'] = {
        label = 'Imobiliária',
        type = nil,
        defaultDuty = false,
        permissions = {
            { node = 'realestate.menu',      minGrade = 0 },
            { node = 'realestate.cloakroom', minGrade = 0 },
            { node = 'realestate.tour',      minGrade = 0 },
            { node = 'realestate.sell',      minGrade = 1 },
            { node = 'realestate.keys',      minGrade = 1 },
            { node = 'realestate.invoice',   minGrade = 1 },
        },
        equipment = {
            weapons = {},
            armor = 0,
            items = {},
        },
        vehicles = {},
    },
}
