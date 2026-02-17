--[[
    NOVA Framework - Definição de Gangs
    Sistema de template: permissões base são herdadas por todas as gangs
    Cada gang só define extras e território
]]

NovaGroups = NovaGroups or {}

-- Permissões base herdadas por TODAS as gangs (exceto 'none')
NovaGroups.GangBasePermissions = {
    'gang.territory',      -- Controlar território
    'gang.stash',          -- Cofre da gang
    'gang.craft',          -- Craftar items ilegais
    'gang.spray',          -- Grafitar paredes
    'gang.rob',            -- Roubar lojas
    'gang.drug_sell',      -- Vender droga
}

NovaGroups.Gangs = {
    ['none'] = {
        label = 'Nenhuma',
        extraPermissions = {},
        territory = nil,
    },

    ['ballas'] = {
        label = 'Ballas',
        extraPermissions = {},
        territory = {
            center = vector3(89.94, -1958.84, 20.74),
            radius = 200.0,
            blip = { sprite = 310, color = 27 },
        },
    },

    ['vagos'] = {
        label = 'Vagos',
        extraPermissions = {},
        territory = {
            center = vector3(335.26, -2036.58, 20.98),
            radius = 200.0,
            blip = { sprite = 310, color = 46 },
        },
    },

    ['families'] = {
        label = 'Families',
        extraPermissions = {},
        territory = {
            center = vector3(-164.16, -1636.82, 33.63),
            radius = 200.0,
            blip = { sprite = 310, color = 2 },
        },
    },

    ['marabunta'] = {
        label = 'Marabunta Grande',
        extraPermissions = {},
        territory = {
            center = vector3(1377.46, -1510.02, 57.56),
            radius = 200.0,
            blip = { sprite = 310, color = 3 },
        },
    },

    ['lost'] = {
        label = 'The Lost MC',
        extraPermissions = { 'gang.mc_missions' },
        territory = {
            center = vector3(982.28, -96.78, 74.85),
            radius = 150.0,
            blip = { sprite = 310, color = 40 },
        },
    },
}

--- Obtém todas as permissões de uma gang (base + extras)
---@param gangName string
---@return table
function NovaGroups.GetGangPermissions(gangName)
    local gang = NovaGroups.Gangs[gangName]
    if not gang then return {} end
    if gangName == 'none' then return {} end

    local perms = {}
    -- Base
    for _, p in ipairs(NovaGroups.GangBasePermissions) do
        perms[#perms + 1] = p
    end
    -- Extras
    if gang.extraPermissions then
        for _, p in ipairs(gang.extraPermissions) do
            perms[#perms + 1] = p
        end
    end
    return perms
end
