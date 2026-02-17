--[[
    NOVA Framework - Sistema de Localização
    Suporta múltiplos idiomas com formatação de strings
]]

NovaLocale = {}
NovaLocale.Strings = {}
NovaLocale.CurrentLocale = nil

--- Registra strings de um idioma
---@param locale string Código do idioma (ex: 'pt')
---@param strings table Tabela com as traduções
function NovaLocale.RegisterLocale(locale, strings)
    if not NovaLocale.Strings[locale] then
        NovaLocale.Strings[locale] = {}
    end

    for key, value in pairs(strings) do
        NovaLocale.Strings[locale][key] = value
    end
end

--- Define o idioma ativo
---@param locale string Código do idioma
function NovaLocale.SetLocale(locale)
    if NovaLocale.Strings[locale] then
        NovaLocale.CurrentLocale = locale
    else
        print('^1[NOVA] ^0Idioma não encontrado: ' .. locale)
    end
end

--- Obtém uma string traduzida
---@param key string Chave da tradução
---@param ... any Argumentos para formatação
---@return string
function NovaLocale.Get(key, ...)
    local locale = NovaLocale.CurrentLocale or 'pt'
    local strings = NovaLocale.Strings[locale]

    if not strings then
        return key
    end

    local str = strings[key]

    if not str then
        if NovaConfig.Debug then
            print('^3[NOVA] ^0Tradução não encontrada: ' .. key)
        end
        return key
    end

    local args = { ... }
    if #args > 0 then
        return string.format(str, ...)
    end

    return str
end

--- Atalho global para obter traduções
---@param key string Chave da tradução
---@param ... any Argumentos para formatação
---@return string
function _L(key, ...)
    return NovaLocale.Get(key, ...)
end
