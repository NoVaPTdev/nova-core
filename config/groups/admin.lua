--[[
    NOVA Framework - Grupos de Administração
    Hierarquia baseada em níveis: quanto maior o nível, mais poder
    Cada grupo acumula as permissões dos grupos inferiores automaticamente
]]

NovaGroups = NovaGroups or {}

NovaGroups.AdminGroups = {
    ['user'] = {
        level = 0,
        label = 'Utilizador',
        permissions = {
            'player.characters',       -- Menu de personagens
            'player.phone',            -- Usar telemóvel
            'player.inventory',        -- Abrir inventário
            'player.emotes',           -- Usar emotes
            'player.report',           -- Reportar ao admin
            'player.me',              -- Comando /me
            'player.do',              -- Comando /do
            'player.ooc',             -- Chat OOC
            'police.seizable',        -- Pode ser revistado pela polícia
        },
    },

    ['vip'] = {
        level = 0,
        label = 'VIP',
        permissions = {
            'vip.queue_priority',      -- Prioridade na fila
            'vip.custom_plate',        -- Matrículas personalizadas
            'vip.extra_characters',    -- +2 personagens extra
            'vip.extra_garages',       -- Garagens adicionais
        },
    },

    ['mod'] = {
        level = 1,
        label = 'Moderador',
        permissions = {
            'admin.tickets',           -- Ver e responder tickets
            'admin.spectate',          -- Modo espectador
            'admin.noclip',            -- Noclip
            'admin.kick',              -- Expulsar jogadores
            'admin.freeze',            -- Congelar jogadores
            'admin.warn',              -- Avisar jogadores
            'player.list',             -- Ver lista de jogadores
            'player.coords',           -- Ver coordenadas
        },
    },

    ['admin'] = {
        level = 2,
        label = 'Administrador',
        permissions = {
            'admin.ban',               -- Banir (temporário)
            'admin.tp',                -- Teleportar
            'admin.bring',             -- Trazer jogador
            'admin.revive',            -- Reviver
            'admin.heal',              -- Curar
            'admin.giveitem',          -- Dar items
            'admin.givemoney',         -- Dar dinheiro
            'admin.removemoney',       -- Remover dinheiro
            'admin.setjob',            -- Definir emprego
            'admin.setgang',           -- Definir gang
            'admin.vehicle',           -- Spawnar veículos
            'admin.delvehicle',        -- Apagar veículos
            'admin.announce',          -- Anúncios no servidor
            'admin.godmode',           -- Modo deus
            'admin.invisible',         -- Invisível
        },
    },

    ['superadmin'] = {
        level = 3,
        label = 'Super Admin',
        permissions = {
            'admin.setgroup',          -- Alterar grupos de jogadores
            'admin.unban',             -- Desbanir
            'admin.permban',           -- Ban permanente
            'admin.whitelist',         -- Gerir whitelist
            'admin.resources',         -- Gerir resources
            'admin.server_config',     -- Configurações do servidor
            'admin.give_weapon',       -- Dar armas
        },
    },

    ['owner'] = {
        level = 4,
        label = 'Dono',
        permissions = {
            'admin.*',                 -- Wildcard: todas as permissões admin
            'player.*',                -- Wildcard: todas as permissões player
            'server.*',                -- Wildcard: todas as permissões server
        },
    },
}

-- Grupos atribuídos automaticamente a todos os jogadores
NovaGroups.DefaultGroups = {
    'user',
}
