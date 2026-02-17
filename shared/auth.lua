--[[
    NOVA Framework - Auth Layer
    Skeleton de autenticação para gating de exports e módulos.
    
    Fase atual: Dev (verified = true, sem licença real)
    Fase futura: Token via license server, HWID bind, heartbeat
]]

-- ============================================================
-- AUTH STATE
-- ============================================================

Nova.Auth = {
    state = {
        verified = true,        -- Dev: sempre true | Prod: validado pelo license server
        sessionToken = nil,     -- Futuro: token JWT/opaco do license server
        serverId = nil,         -- Futuro: ID do server na plataforma
        modules = {},           -- Futuro: { inventory = true, jobs = true, ... }
        startedAt = (os and os.time) and os.time() or GetGameTimer(),  -- os.time server, GetGameTimer client
    },

    -- Contadores de tentativas de acesso negado (anti-tamper metrics)
    _metrics = {
        gateChecks = 0,
        gateDenied = 0,
    }
}

-- ============================================================
-- VERIFICAÇÃO
-- ============================================================

--- Verifica se o framework está autenticado
---@return boolean
function Nova.Auth:IsVerified()
    return self.state.verified == true
end

--- Obtém o token de sessão
---@return string|nil
function Nova.Auth:GetToken()
    return self.state.sessionToken
end

--- Obtém o ID do server
---@return string|nil
function Nova.Auth:GetServerId()
    return self.state.serverId
end

-- ============================================================
-- MÓDULOS
-- ============================================================

--- Verifica se um módulo está autorizado
---@param moduleName string Nome do módulo
---@return boolean
function Nova.Auth:HasModule(moduleName)
    -- Dev phase: se não há módulos definidos, tudo está autorizado
    if not self.state.modules or next(self.state.modules) == nil then
        return true
    end
    return self.state.modules[moduleName] == true
end

-- ============================================================
-- GATING
-- ============================================================

--- Gate principal: verifica auth antes de executar um export
--- Retorna true se o acesso é permitido, false se negado
---@param exportName string Nome do export para logging
---@return boolean
function Nova.Auth:Gate(exportName)
    self._metrics.gateChecks = self._metrics.gateChecks + 1

    if not self:IsVerified() then
        self._metrics.gateDenied = self._metrics.gateDenied + 1
        Nova.Error('[AUTH] Acesso negado ao export: ' .. tostring(exportName) .. ' (framework nao verificado)')
        return false
    end

    return true
end

--- Gate com verificação de módulo
---@param exportName string Nome do export
---@param moduleName string Nome do módulo necessário
---@return boolean
function Nova.Auth:GateModule(exportName, moduleName)
    if not self:Gate(exportName) then
        return false
    end

    if not self:HasModule(moduleName) then
        Nova.Error('[AUTH] Módulo nao autorizado: ' .. tostring(moduleName) .. ' (export: ' .. tostring(exportName) .. ')')
        return false
    end

    return true
end

-- ============================================================
-- MÉTRICAS (para diagnóstico futuro)
-- ============================================================

--- Obtém as métricas do auth
---@return table
function Nova.Auth:GetMetrics()
    return {
        gateChecks = self._metrics.gateChecks,
        gateDenied = self._metrics.gateDenied,
        verified = self.state.verified,
        uptime = ((os and os.time) and os.time() or GetGameTimer()) - self.state.startedAt,
    }
end

-- ============================================================
-- FUTURO: Funções placeholder para license server
-- ============================================================

--- Placeholder: Verificar licença com server externo
--- Na fase dev, retorna sempre true
---@param licenseKey string|nil Chave de licença
---@return boolean
function Nova.Auth:Verify(licenseKey)
    -- TODO: Implementar verificação real quando for vender
    -- 1. HTTP request para o license server
    -- 2. Validar token
    -- 3. Receber lista de módulos autorizados
    -- 4. Definir sessionToken
    -- 5. Iniciar heartbeat

    self.state.verified = true
    Nova.Debug('[AUTH] Verificação concluída (modo dev - sempre aprovado)')
    return true
end

--- Placeholder: Invalidar sessão
function Nova.Auth:Invalidate()
    -- TODO: Implementar quando for vender
    -- self.state.verified = false
    -- self.state.sessionToken = nil
    -- self.state.modules = {}
    Nova.Debug('[AUTH] Sessão invalidada (modo dev - sem efeito)')
end

Nova.Debug('[AUTH] Auth layer inicializado (modo dev)')
