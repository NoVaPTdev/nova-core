--[[
    NOVA Framework - Definição de Items
    Registra todos os items disponíveis no servidor
]]

NovaItems = {}

--- Registra um novo item
---@param name string Nome único do item
---@param data table Dados do item
function NovaItems.Register(name, data)
    NovaItems[name] = {
        name = name,
        label = data.label or name,
        weight = data.weight or 0,
        type = data.type or 'item',          -- item, weapon, food, drink, misc
        useable = data.useable or false,
        unique = data.unique or false,
        shouldClose = data.shouldClose or false,
        description = data.description or '',
        image = data.image or (name .. '.png'),
    }
end

-- ============================================================
-- ITEMS PADRÃO
-- ============================================================

-- Dinheiro
NovaItems.Register('money', {
    label = 'Dinheiro',
    weight = 0,
    type = 'item',
    useable = false,
    unique = false,
    description = 'Dinheiro em notas.',
    image = 'money.png',
})

-- Documentos
NovaItems.Register('id_card', {
    label = 'Cartão de Cidadão',
    weight = 0,
    type = 'item',
    useable = true,
    unique = true,
    description = 'O teu cartão de identificação.',
})

NovaItems.Register('driver_license', {
    label = 'Carta de Condução',
    weight = 0,
    type = 'item',
    useable = true,
    unique = true,
    description = 'A tua carta de condução.',
})

NovaItems.Register('weapon_license', {
    label = 'Licença de Arma',
    weight = 0,
    type = 'item',
    useable = true,
    unique = true,
    description = 'A tua licença para portar arma.',
})

-- Comida e Bebida
NovaItems.Register('burger', {
    label = 'Hambúrguer',
    weight = 350,
    type = 'food',
    useable = true,
    shouldClose = true,
    description = 'Um hambúrguer suculento.',
})

NovaItems.Register('bread', {
    label = 'Pão',
    weight = 200,
    type = 'food',
    useable = true,
    shouldClose = true,
    description = 'Um pão fresquinho.',
})

NovaItems.Register('water', {
    label = 'Água',
    weight = 500,
    type = 'drink',
    useable = true,
    shouldClose = true,
    description = 'Uma garrafa de água.',
})

NovaItems.Register('sandwich', {
    label = 'Sandes',
    weight = 300,
    type = 'food',
    useable = true,
    shouldClose = true,
    description = 'Uma sandes deliciosa.',
})

NovaItems.Register('coffee', {
    label = 'Café',
    weight = 250,
    type = 'drink',
    useable = true,
    shouldClose = true,
    description = 'Um café quente.',
})

NovaItems.Register('energy_drink', {
    label = 'Bebida Energética',
    weight = 350,
    type = 'drink',
    useable = true,
    shouldClose = true,
    description = 'Uma bebida energética.',
})

-- Utilidades
NovaItems.Register('phone', {
    label = 'Telemóvel',
    weight = 200,
    type = 'item',
    useable = true,
    unique = true,
    description = 'O teu telemóvel.',
})

NovaItems.Register('radio', {
    label = 'Rádio',
    weight = 500,
    type = 'item',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Um rádio portátil.',
})

NovaItems.Register('lockpick', {
    label = 'Lockpick',
    weight = 300,
    type = 'item',
    useable = true,
    description = 'Ferramenta para abrir fechaduras.',
})

NovaItems.Register('repairkit', {
    label = 'Kit de Reparação',
    weight = 2500,
    type = 'item',
    useable = true,
    description = 'Kit para reparar veículos.',
})

NovaItems.Register('medikit', {
    label = 'Kit Médico',
    weight = 1000,
    type = 'item',
    useable = true,
    shouldClose = true,
    description = 'Um kit de primeiros socorros.',
})

NovaItems.Register('bandage', {
    label = 'Ligadura',
    weight = 200,
    type = 'item',
    useable = true,
    shouldClose = true,
    description = 'Uma ligadura para ferimentos leves.',
})

NovaItems.Register('jerrycan', {
    label = 'Jerrycan',
    weight = 5000,
    type = 'item',
    useable = true,
    shouldClose = true,
    description = 'Um jerrycan para abastecer veículos.',
})

-- Materiais
NovaItems.Register('iron', {
    label = 'Ferro',
    weight = 500,
    type = 'misc',
    description = 'Uma barra de ferro.',
})

NovaItems.Register('steel', {
    label = 'Aço',
    weight = 700,
    type = 'misc',
    description = 'Uma barra de aço.',
})

NovaItems.Register('plastic', {
    label = 'Plástico',
    weight = 200,
    type = 'misc',
    description = 'Plástico reciclável.',
})

NovaItems.Register('rubber', {
    label = 'Borracha',
    weight = 300,
    type = 'misc',
    description = 'Um pedaço de borracha.',
})

NovaItems.Register('glass', {
    label = 'Vidro',
    weight = 400,
    type = 'misc',
    description = 'Um pedaço de vidro.',
})

-- ============================================================
-- ARMAS E MUNIÇÕES (nova_shops)
-- ============================================================

-- Pistolas
NovaItems.Register('weapon_pistol', {
    label = 'Pistola',
    weight = 1500,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma pistola semi-automática padrão.',
    image = 'weapon_pistol.png',
})

NovaItems.Register('weapon_combatpistol', {
    label = 'Pistola de Combate',
    weight = 1600,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma pistola compacta e leve.',
    image = 'weapon_combatpistol.png',
})

NovaItems.Register('weapon_heavypistol', {
    label = 'Pistola Pesada',
    weight = 1800,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma pistola de alto calibre.',
    image = 'weapon_heavypistol.png',
})

NovaItems.Register('weapon_snspistol', {
    label = 'Pistola SNS',
    weight = 900,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma pistola pequena e discreta.',
    image = 'weapon_snspistol.png',
})

-- SMGs
NovaItems.Register('weapon_microsmg', {
    label = 'Micro SMG',
    weight = 2500,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma submetralhadora compacta.',
    image = 'weapon_microsmg.png',
})

NovaItems.Register('weapon_smg', {
    label = 'SMG',
    weight = 2800,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma submetralhadora versátil.',
    image = 'weapon_smg.png',
})

-- Shotguns
NovaItems.Register('weapon_pumpshotgun', {
    label = 'Shotgun Pump',
    weight = 3500,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma shotgun de acção por bomba.',
    image = 'weapon_pumpshotgun.png',
})

NovaItems.Register('weapon_sawnoffshotgun', {
    label = 'Shotgun Serrada',
    weight = 2800,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma shotgun com cano serrado.',
    image = 'weapon_sawnoffshotgun.png',
})

-- Rifles
NovaItems.Register('weapon_carbinerifle', {
    label = 'Rifle Carbine',
    weight = 3500,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Um rifle de assalto carbine.',
    image = 'weapon_carbinerifle.png',
})

NovaItems.Register('weapon_assaultrifle', {
    label = 'Rifle de Assalto',
    weight = 3800,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Um rifle de assalto clássico.',
    image = 'weapon_assaultrifle.png',
})

-- Corpo a corpo
NovaItems.Register('weapon_bat', {
    label = 'Taco de Basebol',
    weight = 1500,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Um taco de basebol.',
    image = 'weapon_bat.png',
})

NovaItems.Register('weapon_knife', {
    label = 'Faca',
    weight = 500,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma faca afiada.',
    image = 'weapon_knife.png',
})

NovaItems.Register('weapon_flashlight', {
    label = 'Lanterna',
    weight = 800,
    type = 'weapon',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Uma lanterna resistente.',
    image = 'weapon_flashlight.png',
})

-- Munições
NovaItems.Register('ammo_pistol', {
    label = 'Munição Pistola',
    weight = 200,
    type = 'ammo',
    useable = true,
    shouldClose = true,
    description = 'Caixa de munição para pistola (24 balas).',
    image = 'pistol_ammo.png',
})

NovaItems.Register('ammo_smg', {
    label = 'Munição SMG',
    weight = 300,
    type = 'ammo',
    useable = true,
    shouldClose = true,
    description = 'Caixa de munição para submetralhadora (30 balas).',
    image = 'smg_ammo.png',
})

NovaItems.Register('ammo_shotgun', {
    label = 'Munição Shotgun',
    weight = 400,
    type = 'ammo',
    useable = true,
    shouldClose = true,
    description = 'Caixa de cartuchos para shotgun (12 cartuchos).',
    image = 'shotgun_ammo.png',
})

NovaItems.Register('ammo_rifle', {
    label = 'Munição Rifle',
    weight = 350,
    type = 'ammo',
    useable = true,
    shouldClose = true,
    description = 'Caixa de munição para rifle (30 balas).',
    image = 'rifle_ammo.png',
})

-- Protecção
NovaItems.Register('armor', {
    label = 'Colete à Prova de Bala',
    weight = 3000,
    type = 'item',
    useable = true,
    shouldClose = true,
    description = 'Um colete de protecção balística.',
    image = 'armor.png',
})

-- ============================================================
-- ITEMS DE RÁDIO (nova_radio)
-- ============================================================
NovaItems.Register('jammer', {
    label = 'Jammer de Rádio',
    weight = 5000,
    type = 'item',
    useable = true,
    unique = true,
    shouldClose = true,
    description = 'Um dispositivo que bloqueia sinais de rádio numa área.',
})

NovaItems.Register('radiocell', {
    label = 'Bateria de Rádio',
    weight = 200,
    type = 'item',
    useable = true,
    description = 'Uma bateria para recarregar o rádio portátil.',
})
