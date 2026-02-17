--[[
    NOVA Framework - Módulo: Permissions
    Sistema de Permissões com Cache O(1)
    
    Registado como módulo via Nova.RegisterModule()
    Conteúdo original: server/permissions.lua
]]

-- ============================================================
-- REGISTO DO MÓDULO
-- ============================================================

Nova.RegisterModule({
    name = 'permissions',
    version = '1.0.0',
    side = 'server',
    dependencies = {},

    Init = function(Nova)
        Nova.PermissionCache = {}

        -- ============================================================
        -- ACE BRIDGE (txAdmin / server.cfg integration)
        -- ============================================================

        local function GetEffectiveAdminLevel(source, dbGroup)
            local adminGroups = NovaGroups.AdminGroups
            local dbLevel = adminGroups[dbGroup] and adminGroups[dbGroup].level or 0
            local effectiveLevel = dbLevel
            local effectiveGroup = dbGroup

            if source > 0 then
                local aceMap = {
                    { ace = 'nova.owner',      level = 4, group = 'owner' },
                    { ace = 'nova.superadmin', level = 3, group = 'superadmin' },
                    { ace = 'nova.admin',      level = 2, group = 'admin' },
                    { ace = 'nova.mod',        level = 1, group = 'mod' },
                }

                for _, entry in ipairs(aceMap) do
                    if IsPlayerAceAllowed(source, entry.ace) then
                        if entry.level > effectiveLevel then
                            effectiveLevel = entry.level
                            effectiveGroup = entry.group
                        end
                        break
                    end
                end
            end

            return effectiveLevel, effectiveGroup
        end

        -- ============================================================
        -- CONSTRUÇÃO DA CACHE
        -- ============================================================

        function Nova.Functions.BuildPermissionCache(source)
            local player = Nova.Functions.GetPlayer(source)
            if not player then
                Nova.PermissionCache[source] = nil
                return
            end

            local cache = {}
            local negatives = {}

            local adminGroup = player.group or 'user'
            local effectiveLevel, effectiveGroup = GetEffectiveAdminLevel(source, adminGroup)

            if effectiveGroup ~= adminGroup then
                player._effectiveGroup = effectiveGroup
                player._effectiveLevel = effectiveLevel
            else
                player._effectiveGroup = nil
                player._effectiveLevel = nil
            end

            for _, group in pairs(NovaGroups.AdminGroups) do
                if group.level <= effectiveLevel then
                    for _, perm in ipairs(group.permissions) do
                        cache[perm] = true
                    end
                end
            end

            local jobName = player.job and player.job.name or 'desempregado'
            local jobGrade = player.job and player.job.grade or 0
            local isOnDuty = player.job and player.job.duty or false
            local jobConfig = NovaGroups.Jobs[jobName]

            if jobConfig and jobConfig.permissions then
                for _, perm in ipairs(jobConfig.permissions) do
                    local node = perm.node or perm
                    local minGrade = perm.minGrade or 0
                    local onDutyOnly = perm.onDutyOnly or false

                    if jobGrade >= minGrade then
                        if not onDutyOnly or isOnDuty then
                            if type(node) == 'string' and string.sub(node, 1, 1) == '-' then
                                negatives[string.sub(node, 2)] = true
                            else
                                cache[node] = true
                            end
                        end
                    end
                end
            end

            local gangName = player.gang and player.gang.name or 'none'
            if gangName ~= 'none' and NovaGroups.GetGangPermissions then
                local gangPerms = NovaGroups.GetGangPermissions(gangName)
                for _, perm in ipairs(gangPerms) do
                    cache[perm] = true
                end
            end

            cache._wildcards = {}
            for perm, _ in pairs(cache) do
                if type(perm) == 'string' and string.sub(perm, -1) == '*' then
                    cache._wildcards[#cache._wildcards + 1] = string.sub(perm, 1, -2)
                end
            end

            for neg, _ in pairs(negatives) do
                cache[neg] = nil
            end

            cache._level = effectiveLevel
            cache._group = effectiveGroup
            cache._jobName = jobName
            cache._jobGrade = jobGrade
            cache._isOnDuty = isOnDuty
            cache._gangName = gangName

            Nova.PermissionCache[source] = cache
        end

        function Nova.Functions.InvalidatePermissionCache(source)
            Nova.PermissionCache[source] = nil
        end

        function Nova.Functions.RefreshPermissionCache(source)
            Nova.Functions.BuildPermissionCache(source)
        end

        -- ============================================================
        -- VERIFICAÇÃO DE PERMISSÕES (O(1) com cache)
        -- ============================================================

        function Nova.Functions.HasPermission(source, group)
            local cache = Nova.PermissionCache[source]
            if cache then
                local playerLevel = cache._level or 0
                if type(group) == 'table' then
                    for _, g in ipairs(group) do
                        local reqLevel = NovaGroups.AdminGroups[g] and NovaGroups.AdminGroups[g].level or 0
                        if playerLevel >= reqLevel then return true end
                    end
                    return false
                else
                    local reqLevel = NovaGroups.AdminGroups[group] and NovaGroups.AdminGroups[group].level or 0
                    return playerLevel >= reqLevel
                end
            end

            local player = Nova.Functions.GetPlayer(source)
            if not player then return false end

            local adminGroup = player.group or 'user'
            local effectiveLevel = GetEffectiveAdminLevel(source, adminGroup)

            if type(group) == 'table' then
                for _, g in ipairs(group) do
                    local reqLevel = NovaGroups.AdminGroups[g] and NovaGroups.AdminGroups[g].level or 0
                    if effectiveLevel >= reqLevel then return true end
                end
                return false
            else
                local reqLevel = NovaGroups.AdminGroups[group] and NovaGroups.AdminGroups[group].level or 0
                return effectiveLevel >= reqLevel
            end
        end

        function Nova.Functions.IsAdmin(source)
            return Nova.Functions.HasPermission(source, 'admin')
        end

        function Nova.Functions.HasPermissionNode(source, permission)
            local cache = Nova.PermissionCache[source]
            if not cache then
                Nova.Functions.BuildPermissionCache(source)
                cache = Nova.PermissionCache[source]
                if not cache then return false end
            end

            if cache[permission] then return true end

            if cache._wildcards then
                for _, prefix in ipairs(cache._wildcards) do
                    if string.sub(permission, 1, #prefix) == prefix then
                        return true
                    end
                end
            end

            return false
        end

        -- ============================================================
        -- HELPER FUNCTIONS
        -- ============================================================

        function Nova.Functions.GetPlayerJobConfig(source)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return nil end
            return NovaGroups.Jobs[player.job.name]
        end

        function Nova.Functions.GetPlayerGangConfig(source)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return nil end
            return NovaGroups.Gangs[player.gang.name]
        end

        function Nova.Functions.GetPlayerJobVehicles(source)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return {} end

            local jobConfig = NovaGroups.Jobs[player.job.name]
            if not jobConfig or not jobConfig.vehicles then return {} end

            return jobConfig.vehicles[player.job.grade] or {}
        end

        function Nova.Functions.GetEffectiveAdminLevel(source)
            local player = Nova.Functions.GetPlayer(source)
            if not player then return 0, 'user' end
            return GetEffectiveAdminLevel(source, player.group or 'user')
        end

        -- ============================================================
        -- AUTO-INVALIDAÇÃO
        -- ============================================================

        AddEventHandler('nova:server:onPlayerLogout', function(source)
            Nova.PermissionCache[source] = nil
        end)

        AddEventHandler('playerDropped', function()
            local src = source
            Nova.PermissionCache[src] = nil
        end)

        Nova.Debug('[MODULE] Permissions inicializado')
    end,
})
