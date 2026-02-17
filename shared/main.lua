--[[
    NOVA Framework - Objeto Principal (Shared)
    Inicializa o objeto global Nova e funções compartilhadas
]]

Nova = {}
Nova.Config = NovaConfig
Nova.Locale = NovaLocale
Nova.Items = NovaItems
Nova.Functions = {}
Nova.Players = {}           -- Apenas server-side
Nova.Callbacks = {}         -- Sistema de callbacks

-- Versão do framework
Nova.Version = '1.0.0'

-- ============================================================
-- FUNÇÕES COMPARTILHADAS
-- ============================================================

--- Imprime mensagem de debug (apenas se debug estiver ativo)
---@param ... any Mensagens para imprimir
function Nova.Debug(...)
    if not NovaConfig.Debug then return end
    local args = { ... }
    local msg = ''
    for i = 1, #args do
        msg = msg .. tostring(args[i]) .. ' '
    end
    print('^3[NOVA Debug] ^0' .. msg)
end

--- Imprime mensagem do framework
---@param msg string Mensagem
function Nova.Print(msg)
    print('^2[NOVA] ^0' .. tostring(msg))
end

--- Imprime mensagem de erro
---@param msg string Mensagem de erro
function Nova.Error(msg)
    print('^1[NOVA ERROR] ^0' .. tostring(msg))
end

--- Imprime mensagem de aviso
---@param msg string Mensagem de aviso
function Nova.Warn(msg)
    print('^3[NOVA WARN] ^0' .. tostring(msg))
end

--- Obtém tradução (atalho)
---@param key string Chave de tradução
---@param ... any Argumentos
---@return string
function Nova.Lang(key, ...)
    return _L(key, ...)
end

--- Clona uma tabela (deep copy)
---@param orig table Tabela original
---@return table
function Nova.DeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for key, value in next, orig, nil do
            copy[Nova.DeepCopy(key)] = Nova.DeepCopy(value)
        end
        setmetatable(copy, Nova.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

--- Verifica se uma tabela contém um valor
---@param tbl table Tabela para procurar
---@param value any Valor a procurar
---@return boolean
function Nova.TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

--- Conta os elementos de uma tabela
---@param tbl table Tabela
---@return integer
function Nova.TableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

--- Merge de duas tabelas
---@param t1 table Tabela destino
---@param t2 table Tabela fonte
---@return table
function Nova.TableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == 'table' and type(t1[k]) == 'table' then
            Nova.TableMerge(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

--- Gera um ID aleatório
---@param length number Tamanho do ID (padrão: 8)
---@return string
function Nova.GenerateId(length)
    length = length or 8
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local id = ''
    for _ = 1, length do
        local idx = math.random(1, #chars)
        id = id .. string.sub(chars, idx, idx)
    end
    return id
end

--- Gera um CitizenID único (formato: ABC12345)
---@return string
function Nova.GenerateCitizenId()
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local id = ''
    for _ = 1, 3 do
        local idx = math.random(1, #letters)
        id = id .. string.sub(letters, idx, idx)
    end
    for _ = 1, 5 do
        id = id .. tostring(math.random(0, 9))
    end
    return id
end

--- Formata um número com separador de milhares
---@param amount number Número a formatar
---@return string
function Nova.FormatMoney(amount)
    local formatted = tostring(math.floor(amount))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return formatted
end

--- Formata segundos em formato legível
---@param seconds number Segundos
---@return string
function Nova.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format('%dh %dm %ds', hours, mins, secs)
    elseif mins > 0 then
        return string.format('%dm %ds', mins, secs)
    else
        return string.format('%ds', secs)
    end
end

--- Obtém um item pela key
---@param itemName string Nome do item
---@return table|nil
function Nova.GetItem(itemName)
    return NovaItems[itemName] or nil
end

--- Verifica se um item existe
---@param itemName string Nome do item
---@return boolean
function Nova.ItemExists(itemName)
    return NovaItems[itemName] ~= nil
end

-- ============================================================
-- EXPORT DO OBJETO NOVA
-- ============================================================

--- CRÍTICO: Dá acesso ao objeto Nova inteiro
--- Futuro: retornar proxy em vez do objeto real
exports('GetObject', function()
    if not Nova.Auth or not Nova.Auth:Gate('GetObject') then return nil end
    return Nova
end)

--- PÚBLICO: Config não contém dados sensíveis
exports('GetConfig', function()
    return NovaConfig
end)

--- PÚBLICO: Items são dados estáticos
exports('GetItems', function()
    return NovaItems
end)

--- PÚBLICO: Verificação básica de estado (apenas client-side)
--- O server tem a sua própria versão em server/main.lua com flag mais precisa
if not IsDuplicityVersion() then
    exports('IsFrameworkReady', function()
        return Nova ~= nil and Nova.Config ~= nil
    end)
end

Nova.Print(string.format('Módulo compartilhado carregado (v%s)', Nova.Version))
