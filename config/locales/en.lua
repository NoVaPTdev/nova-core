--[[
    NOVA Framework - English (International)
    
    To switch language, change NovaConfig.Locale in config/main.lua to 'en'
]]

NovaLocale.RegisterLocale('en', {
    -- General
    ['framework_started'] = 'NOVA Framework v%s started successfully!',
    ['framework_stopping'] = 'NOVA Framework shutting down...',

    -- Player
    ['player_connected'] = 'Player %s connected to the server.',
    ['player_disconnected'] = 'Player %s disconnected from the server.',
    ['player_loaded'] = 'Character loaded successfully!',
    ['player_saved'] = 'Character saved successfully.',
    ['player_banned'] = 'You are banned from this server.\nReason: %s',
    ['player_kicked'] = 'You have been kicked from the server.\nReason: %s',

    -- Money
    ['money_received'] = 'You received %s %s.',
    ['money_removed'] = 'You lost %s %s.',
    ['money_not_enough'] = 'You don\'t have enough money.',
    ['money_set'] = 'Your %s balance has been set to %s.',
    ['money_invalid_type'] = 'Invalid money type.',

    -- Job
    ['job_set'] = 'Your job has been changed to %s.',
    ['job_not_found'] = 'Job not found.',
    ['job_grade_not_found'] = 'Job grade not found.',
    ['job_on_duty'] = 'You are now on duty.',
    ['job_off_duty'] = 'You are now off duty.',

    -- Gang
    ['gang_set'] = 'Your gang has been changed to %s.',
    ['gang_not_found'] = 'Gang not found.',

    -- Inventory
    ['item_received'] = 'You received %sx %s.',
    ['item_removed'] = 'You lost %sx %s.',
    ['item_not_enough'] = 'You don\'t have enough of this item.',
    ['item_not_found'] = 'Item not found.',
    ['inventory_full'] = 'Your inventory is full.',

    -- Admin
    ['no_permission'] = 'You don\'t have permission to do this.',
    ['player_not_found'] = 'Player not found.',
    ['player_not_online'] = 'This player is not online.',
    ['invalid_id'] = 'Invalid ID.',
    ['invalid_amount'] = 'Invalid amount.',
    ['command_usage'] = 'Usage: %s',

    -- Admin Commands
    ['admin_give_money'] = 'You gave %s %s to player %s.',
    ['admin_remove_money'] = 'You removed %s %s from player %s.',
    ['admin_set_job'] = 'You set %s\'s job to %s [%s].',
    ['admin_set_gang'] = 'You set %s\'s gang to %s [%s].',
    ['admin_teleport'] = 'You teleported to %s.',
    ['admin_bring'] = 'You brought %s to your position.',
    ['admin_kick'] = 'You kicked %s from the server.',
    ['admin_ban'] = 'You banned %s from the server.',
    ['admin_revive'] = 'You revived %s.',
    ['admin_heal'] = 'You healed %s.',

    -- Admin Commands (extended)
    ['admin_panel'] = 'NOVA Administration Panel',
    ['admin_invalid_group'] = 'Invalid group: %s',
    ['admin_group_set'] = 'Group of %s set to %s',
    ['admin_give_item'] = 'Item \'%s\' x%s given to player %s',
    ['admin_give_item_error'] = 'Error giving item (inventory full or invalid item).',
    ['admin_user_not_found'] = 'User not found with that identifier.',
    ['admin_not_banned'] = 'User %s is not banned.',
    ['admin_unbanned'] = 'User %s has been unbanned successfully.',
    ['admin_addcar_usage'] = 'Usage: /addcar [model] or /addcar [id] [model]',
    ['admin_vehicle_spawned'] = 'Vehicle \'%s\' spawned and registered! Plate: %s',
    ['admin_vehicle_spawned_target'] = 'Vehicle \'%s\' spawned for player %s. Plate: %s',
    ['admin_tpcoords_usage'] = 'Usage: /tpcoords [x] [y] [z]',
    ['admin_teleported_coords'] = 'Teleported to %.1f, %.1f, %.1f',
    ['admin_players_online'] = 'Players online: %s',
    ['admin_clearinv_usage'] = 'Usage: /clearinv [id]',
    ['admin_clearinv_done'] = 'Player %s inventory cleared.',
    ['admin_hunger_set'] = 'Player %s hunger set to %s',
    ['admin_thirst_set'] = 'Player %s thirst set to %s',
    ['admin_armor_set'] = 'Player %s armor set to %s',

    -- Character
    ['char_create_success'] = 'Character created successfully!',
    ['char_delete_success'] = 'Character deleted successfully.',
    ['char_max_reached'] = 'You have reached the maximum number of characters.',
    ['char_select'] = 'Select a character to play.',

    -- Database
    ['db_connected'] = 'Database connection established.',
    ['db_error'] = 'Database error: %s',

    -- System
    ['server_restart'] = 'The server will restart in %s seconds.',
    ['auto_save'] = 'Auto-save completed.',
})

-- ============================================================
-- DEFINIR IDIOMA ATIVO
-- Este bloco corre DEPOIS de todos os locales serem registados
-- (en.lua é o último locale no fxmanifest shared_scripts)
-- ============================================================
NovaLocale.SetLocale(NovaConfig.Locale or 'pt')
