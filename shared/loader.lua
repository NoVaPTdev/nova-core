--[[
    NOVA Framework - Module Loader
    Sistema modular para carregar/descarregar funcionalidades do framework.
    
    Cada módulo segue o padrão:
    {
        name = 'inventory',     -- Identificador único
        version = '1.0.0',      -- Versão do módulo
        side = 'server',        -- 'server', 'client', ou 'shared'
        dependencies = {},      -- Lista de módulos dos quais depende
        Init = function(Nova)   -- Inicialização (registar callbacks, preparar dados)
        end,
        Start = function()      -- Arranque (loops, threads, etc.)
        end,
    }
    
    Fase atual: Dev (todos os módulos são carregados)
    Fase futura: Carregamento condicional baseado em Auth:HasModule()
]]

-- ============================================================
-- REGISTRY
-- ============================================================

Nova.Modules = {}
Nova.ModuleOrder = {}  -- Ordem de registo (para Init/Start sequencial)

-- ============================================================
-- REGISTO DE MÓDULOS
-- ============================================================

--- Regista um módulo no framework
---@param module table Definição do módulo
---@return boolean Sucesso do registo
function Nova.RegisterModule(module)
    if not module or not module.name then
        Nova.Error('[LOADER] Tentativa de registar módulo sem nome')
        return false
    end

    local name = module.name

    -- Verificar se o módulo já foi registado
    if Nova.Modules[name] then
        Nova.Warn('[LOADER] Módulo já registado: ' .. name .. ' (a ignorar duplicado)')
        return false
    end

    -- Verificar autorização via Auth
    if not Nova.Auth:HasModule(name) then
        Nova.Error('[LOADER] Módulo não autorizado: ' .. name)
        return false
    end

    -- Registar
    Nova.Modules[name] = {
        name = name,
        version = module.version or '1.0.0',
        side = module.side or 'shared',
        dependencies = module.dependencies or {},
        Init = module.Init,
        Start = module.Start,
        state = 'registered',  -- registered -> initialized -> started -> error
    }

    Nova.ModuleOrder[#Nova.ModuleOrder + 1] = name

    Nova.Debug('[LOADER] Módulo registado: ' .. name .. ' v' .. (module.version or '1.0.0'))
    return true
end

-- ============================================================
-- VERIFICAÇÃO DE DEPENDÊNCIAS
-- ============================================================

--- Verifica se todas as dependências de um módulo estão satisfeitas
---@param moduleName string Nome do módulo
---@return boolean
---@return string|nil Dependência em falta
local function CheckDependencies(moduleName)
    local mod = Nova.Modules[moduleName]
    if not mod then return false, moduleName end

    for _, dep in ipairs(mod.dependencies) do
        if not Nova.Modules[dep] then
            return false, dep
        end
        -- Verificar se a dependência já foi inicializada
        if Nova.Modules[dep].state == 'registered' then
            return false, dep .. ' (nao inicializado)'
        end
    end

    return true
end

-- ============================================================
-- CARREGAMENTO
-- ============================================================

--- Inicializa todos os módulos registados (fase Init)
---@return number Número de módulos inicializados
function Nova.InitModules()
    local count = 0

    for _, name in ipairs(Nova.ModuleOrder) do
        local mod = Nova.Modules[name]

        if mod and mod.state == 'registered' then
            -- Verificar dependências
            local depsOk, missingDep = CheckDependencies(name)
            if not depsOk then
                Nova.Error('[LOADER] Módulo ' .. name .. ' - dependência em falta: ' .. tostring(missingDep))
                mod.state = 'error'
            else
                -- Executar Init
                if mod.Init then
                    local ok, err = pcall(mod.Init, Nova)
                    if ok then
                        mod.state = 'initialized'
                        count = count + 1
                        Nova.Debug('[LOADER] Módulo inicializado: ' .. name)
                    else
                        mod.state = 'error'
                        Nova.Error('[LOADER] Erro ao inicializar módulo ' .. name .. ': ' .. tostring(err))
                    end
                else
                    mod.state = 'initialized'
                    count = count + 1
                end
            end
        end
    end

    return count
end

--- Arranca todos os módulos inicializados (fase Start)
---@return number Número de módulos arrancados
function Nova.StartModules()
    local count = 0

    for _, name in ipairs(Nova.ModuleOrder) do
        local mod = Nova.Modules[name]

        if mod and mod.state == 'initialized' then
            if mod.Start then
                local ok, err = pcall(mod.Start)
                if ok then
                    mod.state = 'started'
                    count = count + 1
                    Nova.Debug('[LOADER] Módulo arrancado: ' .. name)
                else
                    mod.state = 'error'
                    Nova.Error('[LOADER] Erro ao arrancar módulo ' .. name .. ': ' .. tostring(err))
                end
            else
                mod.state = 'started'
                count = count + 1
            end
        end
    end

    return count
end

--- Carrega todos os módulos (Init + Start)
---@return number initCount, number startCount
function Nova.LoadModules()
    Nova.Debug('[LOADER] A inicializar módulos...')
    local initCount = Nova.InitModules()
    Nova.Debug('[LOADER] ' .. initCount .. ' módulos inicializados')

    Nova.Debug('[LOADER] A arrancar módulos...')
    local startCount = Nova.StartModules()
    Nova.Debug('[LOADER] ' .. startCount .. ' módulos arrancados')

    return initCount, startCount
end

-- ============================================================
-- CONSULTA
-- ============================================================

--- Verifica se um módulo está carregado e a funcionar
---@param moduleName string Nome do módulo
---@return boolean
function Nova.IsModuleLoaded(moduleName)
    local mod = Nova.Modules[moduleName]
    return mod ~= nil and (mod.state == 'initialized' or mod.state == 'started')
end

--- Obtém o estado de um módulo
---@param moduleName string Nome do módulo
---@return string|nil Estado ('registered', 'initialized', 'started', 'error')
function Nova.GetModuleState(moduleName)
    local mod = Nova.Modules[moduleName]
    return mod and mod.state or nil
end

--- Lista todos os módulos e seus estados
---@return table
function Nova.GetModuleList()
    local list = {}
    for _, name in ipairs(Nova.ModuleOrder) do
        local mod = Nova.Modules[name]
        if mod then
            list[#list + 1] = {
                name = mod.name,
                version = mod.version,
                state = mod.state,
                side = mod.side,
            }
        end
    end
    return list
end

Nova.Debug('[LOADER] Module loader inicializado')
