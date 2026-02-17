--[[
    NOVA Framework - Português (Portugal/Brasil)
]]

NovaLocale.RegisterLocale('pt', {
    -- Geral
    ['framework_started'] = 'NOVA Framework v%s iniciado com sucesso!',
    ['framework_stopping'] = 'NOVA Framework a encerrar...',

    -- Jogador
    ['player_connected'] = 'Jogador %s conectou-se ao servidor.',
    ['player_disconnected'] = 'Jogador %s desconectou-se do servidor.',
    ['player_loaded'] = 'Personagem carregado com sucesso!',
    ['player_saved'] = 'Personagem guardado com sucesso.',
    ['player_banned'] = 'Estás banido deste servidor.\nMotivo: %s',
    ['player_kicked'] = 'Foste expulso do servidor.\nMotivo: %s',

    -- Dinheiro
    ['money_received'] = 'Recebeste %s %s.',
    ['money_removed'] = 'Perdeste %s %s.',
    ['money_not_enough'] = 'Não tens dinheiro suficiente.',
    ['money_set'] = 'O teu saldo de %s foi definido para %s.',
    ['money_invalid_type'] = 'Tipo de dinheiro inválido.',

    -- Emprego
    ['job_set'] = 'O teu emprego foi alterado para %s.',
    ['job_not_found'] = 'Emprego não encontrado.',
    ['job_grade_not_found'] = 'Grau de emprego não encontrado.',
    ['job_on_duty'] = 'Entraste em serviço.',
    ['job_off_duty'] = 'Saíste de serviço.',

    -- Gang
    ['gang_set'] = 'A tua gang foi alterada para %s.',
    ['gang_not_found'] = 'Gang não encontrada.',

    -- Inventário
    ['item_received'] = 'Recebeste %sx %s.',
    ['item_removed'] = 'Perdeste %sx %s.',
    ['item_not_enough'] = 'Não tens este item suficiente.',
    ['item_not_found'] = 'Item não encontrado.',
    ['inventory_full'] = 'O teu inventário está cheio.',

    -- Admin
    ['no_permission'] = 'Não tens permissão para fazer isto.',
    ['player_not_found'] = 'Jogador não encontrado.',
    ['player_not_online'] = 'Este jogador não está online.',
    ['invalid_id'] = 'ID inválido.',
    ['invalid_amount'] = 'Quantidade inválida.',
    ['command_usage'] = 'Uso: %s',

    -- Admin Commands
    ['admin_give_money'] = 'Deste %s %s ao jogador %s.',
    ['admin_remove_money'] = 'Removeste %s %s do jogador %s.',
    ['admin_set_job'] = 'Definiste o emprego de %s para %s [%s].',
    ['admin_set_gang'] = 'Definiste a gang de %s para %s [%s].',
    ['admin_teleport'] = 'Teleportaste-te para %s.',
    ['admin_bring'] = 'Trouxeste %s para a tua posição.',
    ['admin_kick'] = 'Expulsaste %s do servidor.',
    ['admin_ban'] = 'Baniste %s do servidor.',
    ['admin_revive'] = 'Reviveste %s.',
    ['admin_heal'] = 'Curaste %s.',

    -- Comandos Admin (extended)
    ['admin_panel'] = 'Painel de administração NOVA',
    ['admin_invalid_group'] = 'Grupo inválido: %s',
    ['admin_group_set'] = 'Grupo de %s definido para %s',
    ['admin_give_item'] = 'Item \'%s\' x%s dado ao jogador %s',
    ['admin_give_item_error'] = 'Erro ao dar item (inventário cheio ou item inválido).',
    ['admin_user_not_found'] = 'Utilizador não encontrado com esse identifier.',
    ['admin_not_banned'] = 'O utilizador %s não está banido.',
    ['admin_unbanned'] = 'Utilizador %s foi desbanido com sucesso.',
    ['admin_addcar_usage'] = 'Uso: /addcar [modelo] ou /addcar [id] [modelo]',
    ['admin_vehicle_spawned'] = 'Veículo \'%s\' gerado e registado! Placa: %s',
    ['admin_vehicle_spawned_target'] = 'Veículo \'%s\' gerado para jogador %s. Placa: %s',
    ['admin_tpcoords_usage'] = 'Uso: /tpcoords [x] [y] [z]',
    ['admin_teleported_coords'] = 'Teleportado para %.1f, %.1f, %.1f',
    ['admin_players_online'] = 'Jogadores online: %s',
    ['admin_clearinv_usage'] = 'Uso: /clearinv [id]',
    ['admin_clearinv_done'] = 'Inventário do jogador %s limpo.',
    ['admin_hunger_set'] = 'Fome do jogador %s definida para %s',
    ['admin_thirst_set'] = 'Sede do jogador %s definida para %s',
    ['admin_armor_set'] = 'Armadura do jogador %s definida para %s',

    -- Personagem
    ['char_create_success'] = 'Personagem criado com sucesso!',
    ['char_delete_success'] = 'Personagem eliminado com sucesso.',
    ['char_max_reached'] = 'Atingiste o limite máximo de personagens.',
    ['char_select'] = 'Seleciona um personagem para jogar.',

    -- Base de Dados
    ['db_connected'] = 'Ligação à base de dados estabelecida.',
    ['db_error'] = 'Erro na base de dados: %s',

    -- Sistema
    ['server_restart'] = 'O servidor vai reiniciar em %s segundos.',
    ['auto_save'] = 'Salvamento automático realizado.',
})
