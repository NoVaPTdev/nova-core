--[[
    NOVA Framework - Localizações de Emprego
    Seletores, pontos de duty, blips de emprego
]]

NovaGroups = NovaGroups or {}

-- ============================================================
-- SELETORES DE EMPREGO
-- Locais onde os jogadores podem escolher/mudar de emprego
-- ============================================================

NovaGroups.JobSelectors = {
    ['centro_emprego'] = {
        label = 'Centro de Emprego',
        coords = vector3(-268.36, -957.26, 31.22),
        blip = { sprite = 351, color = 47, scale = 0.8 },
        marker = { type = 21, color = { r = 0, g = 248, b = 185, a = 200 }, scale = vector3(0.6, 0.6, 0.6) },
        jobs = {
            'taxista',
            'mecanico',
            'reporter',
            'desempregado',
        },
        permission = nil, -- nil = acessível por todos
    },

    ['policia_recrutamento'] = {
        label = 'Recrutamento Policial',
        coords = vector3(437.92, -987.97, 30.69),
        blip = { sprite = 60, color = 29, scale = 0.6 },
        marker = { type = 21, color = { r = 0, g = 100, b = 255, a = 200 }, scale = vector3(0.6, 0.6, 0.6) },
        jobs = {
            'policia',
            'desempregado',
        },
        permission = 'admin.setjob',
    },

    ['hospital_recrutamento'] = {
        label = 'Recrutamento Hospital',
        coords = vector3(-498.96, -335.72, 34.50),
        blip = { sprite = 61, color = 1, scale = 0.6 },
        marker = { type = 21, color = { r = 255, g = 0, b = 0, a = 200 }, scale = vector3(0.6, 0.6, 0.6) },
        jobs = {
            'ambulancia',
            'desempregado',
        },
        permission = 'admin.setjob',
    },
}

-- ============================================================
-- LOCAIS DE SERVIÇO (ON DUTY / OFF DUTY)
-- ============================================================

NovaGroups.DutyLocations = {
    ['policia'] = {
        { coords = vector3(440.08, -981.14, 30.69), radius = 2.0 },
    },
    ['ambulancia'] = {
        { coords = vector3(311.25, -592.07, 43.28), radius = 2.0 },
    },
    ['mecanico'] = {
        { coords = vector3(-339.76, -134.63, 39.01), radius = 2.0 },
    },
    ['taxista'] = {
        { coords = vector3(895.42, -179.21, 74.70), radius = 2.0 },
    },
    ['reporter'] = {
        { coords = vector3(-598.97, -930.54, 23.86), radius = 2.0 },
    },
    ['advogado'] = {
        { coords = vector3(-1581.76, -565.07, 25.83), radius = 2.0 },
    },
    ['imobiliaria'] = {
        { coords = vector3(-706.68, 260.36, 80.19), radius = 2.0 },
    },
}

-- ============================================================
-- BLIPS DE EMPREGO
-- Blips mostrados no mapa para todos os jogadores
-- ============================================================

NovaGroups.JobBlips = {
    ['policia'] = {
        { name = 'Esquadra da Polícia', coords = vector3(428.23, -984.28, 30.71), sprite = 60, color = 29, scale = 0.8 },
    },
    ['ambulancia'] = {
        { name = 'Hospital Central', coords = vector3(311.81, -590.93, 43.28), sprite = 61, color = 1, scale = 0.8 },
        { name = 'Hospital Sandy', coords = vector3(1839.62, 3672.93, 34.28), sprite = 61, color = 1, scale = 0.6 },
        { name = 'Hospital Paleto', coords = vector3(-247.76, 6331.23, 32.43), sprite = 61, color = 1, scale = 0.6 },
    },
    ['mecanico'] = {
        { name = 'Los Santos Customs', coords = vector3(-337.39, -134.86, 39.01), sprite = 446, color = 47, scale = 0.7 },
    },
    ['taxista'] = {
        { name = 'Central de Táxis', coords = vector3(895.42, -179.21, 74.70), sprite = 198, color = 46, scale = 0.7 },
    },
    ['reporter'] = {
        { name = 'Weazel News', coords = vector3(-598.97, -930.54, 23.86), sprite = 459, color = 1, scale = 0.7 },
    },
    ['advogado'] = {
        { name = 'Escritório de Advogados', coords = vector3(-1581.76, -565.07, 25.83), sprite = 408, color = 0, scale = 0.7 },
    },
    ['imobiliaria'] = {
        { name = 'Imobiliária Dynasty 8', coords = vector3(-706.68, 260.36, 80.19), sprite = 374, color = 2, scale = 0.7 },
    },
}
