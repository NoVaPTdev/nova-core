--[[
    NOVA Framework - Configuração Central de Blips
    Todos os blips do mapa num só ficheiro.
    
    Sprite list: https://docs.fivem.net/docs/game-references/blips/
    Color list:  https://docs.fivem.net/docs/game-references/blips/#blip-colors
    
    Cada entrada:
        label    = Nome que aparece no mapa
        sprite   = Ícone do blip
        color    = Cor do blip
        scale    = Tamanho (0.5 - 1.2)
        coords   = { x, y, z }
        display  = (opcional) 2 = mapa normal, 4 = mapa + minimap, 8 = só minimap
        shortRange = (opcional) true = só aparece perto (default true)
        category = (opcional) grupo para organização
]]

BlipsConfig = {}

-- ============================================================
-- BANCOS
-- ============================================================

BlipsConfig.Banks = {
    sprite = 108, color = 2, scale = 0.7, category = 'bank',
    locations = {
        { label = 'Banco',         coords = { 149.03, -1042.18, 29.37 } },
        { label = 'Banco',   coords = { 314.19, -278.62, 54.17 } },
        { label = 'Banco',            coords = { -351.53, -49.53, 49.04 } },
        { label = 'Banco',          coords = { -1212.98, -330.85, 37.79 } },
        { label = 'Banco',       coords = { -2962.58, 482.63, 15.7 } },
        { label = 'Banco',      coords = { -111.37, 6462.0, 31.64 } },
        { label = 'Banco',    coords = { 1175.07, 2706.41, 38.09 } },
        { label = 'Banco',   coords = { -113.23, 6470.22, 31.63 } },
    },
}

-- ============================================================
-- GASOLINEIRAS
-- ============================================================

BlipsConfig.GasStations = {
    sprite = 361, color = 1, scale = 0.7, category = 'fuel',
    locations = {
        { label = 'Posto de Gasolina',           coords = { -70.2, -1761.8, 29.5 } },
        { label = 'Posto de Gasolina',      coords = { 265.6, -1261.3, 29.3 } },
        { label = 'Posto de Gasolina',         coords = { 819.7, -1027.7, 26.4 } },
        { label = 'Posto de Gasolina',     coords = { 1209.5, -1402.2, 35.2 } },
        { label = 'Posto de Gasolina',        coords = { 1181.4, -330.8, 69.3 } },
        { label = 'Posto de Gasolina',        coords = { 620.8, 269.0, 103.1 } },
        { label = 'Posto de Gasolina',    coords = { -531.3, -1220.5, 18.5 } },
        { label = 'Posto de Gasolina',         coords = { -2554.9, 2334.4, 33.1 } },
        { label = 'Posto de Gasolina',        coords = { 176.6, -562.6, 43.9 } },
        { label = 'Posto de Gasolina',        coords = { 2581.4, 362.0, 108.5 } },
        { label = 'Posto de Gasolina',        coords = { 2679.9, 3263.9, 55.2 } },
        { label = 'Posto de Gasolina',    coords = { 1701.8, 6416.1, 32.8 } },
        { label = 'Posto de Gasolina',      coords = { 180.6, 6603.2, 32.0 } },
        { label = 'Posto de Gasolina',       coords = { 1687.2, 4929.4, 42.1 } },
        { label = 'Posto de Gasolina',         coords = { 1039.9, 2671.4, 39.6 } },
        { label = 'Posto de Gasolina',        coords = { -1437.6, -276.7, 46.2 } },
        { label = 'Posto de Gasolina',    coords = { -1799.0, 802.2, 138.5 } },
        { label = 'Posto de Gasolina',      coords = { -2096.2, -319.3, 13.2 } },
        { label = 'Posto de Gasolina',        coords = { 1208.4, -1389.0, 35.4 } },
    },
}

-- ============================================================
-- LOJAS 24/7
-- ============================================================

BlipsConfig.Convenience = {
    sprite = 59, color = 2, scale = 0.6, category = 'shop',
    locations = {
        { label = 'Loja de Departamento',        coords = { 25.7, -1346.3, 29.5 } },
        { label = 'Loja de Departamento',    coords = { -3039.5, 584.4, 7.9 } },
        { label = 'Loja de Departamento',          coords = { -3241.0, 1001.5, 12.8 } },
        { label = 'Loja de Departamento',      coords = { 1960.0, 3740.7, 32.3 } },
        { label = 'Loja de Departamento',         coords = { 1728.7, 6414.1, 35.0 } },
        { label = 'Loja de Departamento',        coords = { 166.5, 6639.2, 31.6 } },
        { label = 'Loja de Departamento',       coords = { 1163.4, -324.3, 69.2 } },
        { label = 'Loja de Departamento',          coords = { 373.6, 325.6, 103.6 } },
        { label = 'Loja de Departamento',             coords = { -46.5, -1757.8, 29.4 } },
        { label = 'Loja de Departamento',           coords = { -3038.9, 585.9, 7.9 } },
    },
}

-- ============================================================
-- AMMU-NATION
-- ============================================================

BlipsConfig.Weapons = {
    sprite = 110, color = 1, scale = 0.7, category = 'shop',
    locations = {
        { label = 'Loja de Armas',        coords = { 252.6, -50.0, 69.9 } },
        { label = 'Loja de Armas',         coords = { 22.2, -1105.6, 29.8 } },
        { label = 'Loja de Armas',         coords = { 842.4, -1035.4, 28.2 } },
        { label = 'Loja de Armas',    coords = { -661.8, -934.6, 21.8 } },
        { label = 'Loja de Armas',          coords = { -1305.1, -394.8, 36.7 } },
        { label = 'Loja de Armas',         coords = { -3172.8, 1088.8, 20.8 } },
        { label = 'Loja de Armas',    coords = { 2567.7, 294.4, 108.7 } },
        { label = 'Loja de Armas',      coords = { -330.2, 6083.9, 31.5 } },
    },
}

-- ============================================================
-- LOJAS DE ROUPA
-- ============================================================

BlipsConfig.Clothing = {
    sprite = 73, color = 47, scale = 0.6, category = 'shop',
    locations = {
        { label = 'Loja de Roupa',      coords = { 72.3, -1399.1, 29.4 } },
        { label = 'Loja de Roupa',       coords = { -167.9, -299.0, 39.7 } },
        { label = 'Loja de Roupa',          coords = { -829.4, -1073.7, 11.3 } },
        { label = 'Loja de Roupa',         coords = { -3172.5, 1043.3, 20.9 } },
        { label = 'Loja de Roupa',         coords = { -708.7, -152.3, 37.4 } },
        { label = 'Loja de Roupa', coords = { -1447.8, -242.5, 49.8 } },
        { label = 'Loja de Roupa',    coords = { -1193.4, -772.3, 17.3 } },
        { label = 'Loja de Roupa',      coords = { 428.7, -800.1, 29.5 } },
        { label = 'Loja de Roupa',      coords = { 4.9, 6513.8, 31.9 } },
    },
}

-- ============================================================
-- TATUAGENS
-- ============================================================

BlipsConfig.Tattoos = {
    sprite = 75, color = 1, scale = 0.6, category = 'shop',
    locations = {
        { label = 'Loja de Tatuagem',    coords = { 1322.6, -1651.9, 52.3 } },
        { label = 'Loja de Tatuagem',             coords = { -1153.7, -1425.7, 4.9 } },
        { label = 'Loja de Tatuagem',        coords = { 1864.1, 3747.7, 33.0 } },
        { label = 'Loja de Tatuagem',          coords = { -293.7, 6200.0, 31.5 } },
        { label = 'Loja de Tatuagem',            coords = { -1094.2, 2708.5, 18.9 } },
        { label = 'Loja de Tatuagem',      coords = { -3170.0, 1075.0, 20.8 } },
    },
}

-- ============================================================
-- CONCESSIONÁRIOS
-- ============================================================

BlipsConfig.Dealerships = {
    sprite = 326, color = 3, scale = 0.8, category = 'vehicle',
    locations = {
        { label = 'Concessionaria',          coords = { -56.49, -1096.43, 26.42 }, color = 3 },
    },
}

-- ============================================================
-- GARAGENS
-- ============================================================

BlipsConfig.Garages = {
    sprite = 357, color = 3, scale = 0.7, category = 'vehicle',
    locations = {
        { label = 'Garagem',    coords = { 215.8, -810.0, 30.7 } },
        { label = 'Garagem',          coords = { 65.4, 13.7, 69.2 } },
        { label = 'Garagem',             coords = { -283.7, -886.8, 31.1 } },
        { label = 'Garagem',        coords = { -1184.4, -1509.6, 4.4 } },
        { label = 'Garagem',         coords = { -332.1, 275.6, 85.5 } },
        { label = 'Garagem',     coords = { 1737.6, 3710.2, 34.1 } },
        { label = 'Garagem',       coords = { 107.3, 6611.5, 32.0 } },
    },
}

-- ============================================================
-- REBOQUE / IMPOUND
-- ============================================================

BlipsConfig.Impounds = {
    sprite = 67, color = 1, scale = 0.7, category = 'vehicle',
    locations = {
        { label = 'Impound',         coords = { 409.3, -1623.7, 29.3 } },
        { label = 'Impound',       coords = { 1645.5, 3798.3, 35.0 } },
    },
}

-- ============================================================
-- FERRAMENTAS (Tool Shops)
-- ============================================================

BlipsConfig.ToolShops = {
    sprite = 402, color = 0, scale = 0.6, category = 'shop',
    locations = {
        -- Adiciona aqui lojas de ferramentas se existirem
    },
}

-- ============================================================
-- HOSPITAIS / EMS
-- ============================================================

BlipsConfig.Hospitals = {
    sprite = 61, color = 1, scale = 0.8, category = 'service',
    locations = {
        { label = 'Hospital',   coords = { 311.0, -590.0, 43.3 } },
    },
}
