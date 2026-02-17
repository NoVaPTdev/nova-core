--[[
    NOVA Framework - Player Class (Server)
    Classe que representa um jogador carregado no servidor
]]

Nova.Player = {}
Nova.Player.__index = Nova.Player

-- ============================================================
-- CONSTRUTOR
-- ============================================================

--- Cria um novo objeto Player
---@param source number ID do jogador
---@param userData table Dados do utilizador (nova_users)
---@param charData table Dados do personagem (nova_characters)
---@return table Player
function Nova.Player.New(source, userData, charData)
    local self = setmetatable({}, Nova.Player)

    -- Dados base
    self.source = source
    self.identifier = userData.identifier
    self.name = userData.name
    self.group = userData.group or 'user'
    self.userId = userData.id

    -- Dados do personagem
    self.citizenid = charData.citizenid

    self.charinfo = {
        firstname = charData.firstname or '',
        lastname = charData.lastname or '',
        dateofbirth = charData.dateofbirth or '01/01/2000',
        gender = charData.gender or 0,
        nationality = charData.nationality or 'Português',
        phone = charData.phone,
    }

    -- Dinheiro
    self.money = {
        cash = charData.cash or NovaConfig.MoneyTypes.cash.default,
        bank = charData.bank or NovaConfig.MoneyTypes.bank.default,
        black_money = charData.black_money or NovaConfig.MoneyTypes.black_money.default,
    }

    -- Emprego
    local jobData = Nova.Functions.GetJob(charData.job or 'desempregado')
    if jobData then
        local gradeData = jobData.grades[charData.job_grade or 0]
        self.job = {
            name = jobData.name,
            label = jobData.label,
            type = jobData.type,
            grade = charData.job_grade or 0,
            grade_label = gradeData and gradeData.label or 'Unknown',
            salary = gradeData and gradeData.salary or 0,
            is_boss = gradeData and gradeData.is_boss or false,
            duty = charData.job_duty == 1 or jobData.default_duty,
        }
    else
        self.job = Nova.DeepCopy(NovaConfig.DefaultJob)
    end

    -- Gang
    local gangData = Nova.Functions.GetGang(charData.gang or 'none')
    if gangData then
        local gradeData = gangData.grades[charData.gang_grade or 0]
        self.gang = {
            name = gangData.name,
            label = gangData.label,
            grade = charData.gang_grade or 0,
            grade_label = gradeData and gradeData.label or 'Membro',
            is_boss = gradeData and gradeData.is_boss or false,
        }
    else
        self.gang = Nova.DeepCopy(NovaConfig.DefaultGang)
    end

    -- Posição
    if charData.position then
        local pos = type(charData.position) == 'string' and json.decode(charData.position) or charData.position
        self.position = vector4(pos.x, pos.y, pos.z, pos.w or 0.0)
    else
        self.position = NovaConfig.DefaultSpawn
    end

    -- Inventário
    if charData.inventory then
        self.inventory = type(charData.inventory) == 'string' and json.decode(charData.inventory) or charData.inventory
    else
        self.inventory = {}
    end

    -- Metadata
    if charData.metadata then
        local meta = type(charData.metadata) == 'string' and json.decode(charData.metadata) or charData.metadata
        self.metadata = Nova.TableMerge(Nova.DeepCopy(NovaConfig.DefaultMetadata), meta)
    else
        self.metadata = Nova.DeepCopy(NovaConfig.DefaultMetadata)
    end

    -- Skin
    if charData.skin then
        self.skin = type(charData.skin) == 'string' and json.decode(charData.skin) or charData.skin
    else
        self.skin = nil
    end

    return self
end

-- ============================================================
-- GETTERS
-- ============================================================

--- Obtém todos os dados do jogador (para enviar ao client)
---@return table
function Nova.Player:GetData()
    return {
        source = self.source,
        identifier = self.identifier,
        name = self.name,
        group = self.group,
        citizenid = self.citizenid,
        charinfo = self.charinfo,
        money = self.money,
        job = self.job,
        gang = self.gang,
        position = self.position,
        metadata = self.metadata,
        skin = self.skin,
    }
end

--- Obtém o nome completo do personagem
---@return string
function Nova.Player:GetFullName()
    return self.charinfo.firstname .. ' ' .. self.charinfo.lastname
end

--- Obtém o source do jogador
---@return number
function Nova.Player:GetSource()
    return self.source
end

--- Obtém o CitizenID
---@return string
function Nova.Player:GetCitizenId()
    return self.citizenid
end

-- ============================================================
-- DINHEIRO
-- ============================================================

--- Obtém o dinheiro de um tipo
---@param moneyType string Tipo de dinheiro (cash, bank, black_money)
---@return number
function Nova.Player:GetMoney(moneyType)
    if not self.money[moneyType] then return 0 end
    return self.money[moneyType]
end

--- Adiciona dinheiro
---@param moneyType string Tipo de dinheiro
---@param amount number Quantidade
---@param reason string|nil Motivo
---@return boolean
function Nova.Player:AddMoney(moneyType, amount, reason)
    if not Nova.Auth:IsVerified() then return false end
    if not self.money[moneyType] then
        Nova.Functions.Notify(self.source, _L('money_invalid_type'), 'error')
        return false
    end

    if amount <= 0 then return false end

    self.money[moneyType] = self.money[moneyType] + amount

    -- Notificar o jogador
    local label = NovaConfig.MoneyTypes[moneyType] and NovaConfig.MoneyTypes[moneyType].label or moneyType
    Nova.Functions.Notify(self.source, _L('money_received', Nova.FormatMoney(amount), label), 'success')

    -- Atualizar o client
    self:UpdateClient('money')

    -- Log
    Nova.Debug(string.format('Jogador %s recebeu $%s (%s) - Motivo: %s',
        self:GetFullName(), Nova.FormatMoney(amount), moneyType, reason or 'N/A'))

    -- Evento seguro: apenas source, tipo e ação (sem amount/saldo)
    -- Quem precisar do valor, use exports['nova_core']:GetPlayer(source):GetMoney(type)
    TriggerEvent('nova:server:onMoneyChange', self.source, moneyType, 'add')

    return true
end

--- Remove dinheiro
---@param moneyType string Tipo de dinheiro
---@param amount number Quantidade
---@param reason string|nil Motivo
---@param silent boolean|nil Se true, não envia notificação
---@return boolean
function Nova.Player:RemoveMoney(moneyType, amount, reason, silent)
    if not Nova.Auth:IsVerified() then return false end
    if not self.money[moneyType] then
        Nova.Functions.Notify(self.source, _L('money_invalid_type'), 'error')
        return false
    end

    if amount <= 0 then return false end

    if self.money[moneyType] < amount then
        Nova.Functions.Notify(self.source, _L('money_not_enough'), 'error')
        return false
    end

    self.money[moneyType] = self.money[moneyType] - amount

    if not silent then
        local label = NovaConfig.MoneyTypes[moneyType] and NovaConfig.MoneyTypes[moneyType].label or moneyType
        Nova.Functions.Notify(self.source, _L('money_removed', Nova.FormatMoney(amount), label), 'info')
    end

    self:UpdateClient('money')

    Nova.Debug(string.format('Jogador %s perdeu $%s (%s) - Motivo: %s',
        self:GetFullName(), Nova.FormatMoney(amount), moneyType, reason or 'N/A'))

    -- Evento seguro: apenas source, tipo e ação (sem amount/saldo)
    TriggerEvent('nova:server:onMoneyChange', self.source, moneyType, 'remove')

    return true
end

--- Define o dinheiro de um tipo
---@param moneyType string Tipo de dinheiro
---@param amount number Quantidade
---@return boolean
function Nova.Player:SetMoney(moneyType, amount)
    if not Nova.Auth:IsVerified() then return false end
    if not self.money[moneyType] then return false end
    if amount < 0 then return false end

    self.money[moneyType] = amount
    self:UpdateClient('money')

    return true
end

-- ============================================================
-- EMPREGO
-- ============================================================

--- Obtém dados do emprego
---@return table
function Nova.Player:GetJob()
    return self.job
end

--- Define o emprego do jogador
---@param jobName string Nome do emprego
---@param grade number Grau
---@return boolean
function Nova.Player:SetJob(jobName, grade)
    if not Nova.Auth:IsVerified() then return false end
    grade = grade or 0
    local jobData = Nova.Functions.GetJob(jobName)

    if not jobData then
        Nova.Functions.Notify(self.source, _L('job_not_found'), 'error')
        return false
    end

    local gradeData = jobData.grades[grade]
    if not gradeData then
        Nova.Functions.Notify(self.source, _L('job_grade_not_found'), 'error')
        return false
    end

    local oldJob = self.job

    self.job = {
        name = jobData.name,
        label = jobData.label,
        type = jobData.type,
        grade = grade,
        grade_label = gradeData.label,
        salary = gradeData.salary,
        is_boss = gradeData.is_boss,
        duty = jobData.default_duty,
    }

    Nova.Functions.Notify(self.source, _L('job_set', jobData.label), 'success')
    self:UpdateClient('job')

    -- Evento seguro: source + nome do novo job (sem grade details/oldJob completo)
    -- Quem precisar dos detalhes, use exports['nova_core']:GetPlayer(source):GetJob()
    TriggerEvent('nova:server:onJobChange', self.source, self.job.name, oldJob and oldJob.name or nil)

    return true
end

--- Alterna o estado de serviço
function Nova.Player:ToggleDuty()
    self.job.duty = not self.job.duty
    if self.job.duty then
        Nova.Functions.Notify(self.source, _L('job_on_duty'), 'success')
    else
        Nova.Functions.Notify(self.source, _L('job_off_duty'), 'info')
    end
    self:UpdateClient('job')
    -- Trigger event (job_callbacks.lua handles equipment + permissions.lua refreshes cache)
    TriggerEvent('nova:server:onDutyChange', self.source, self.job.duty)
end

-- ============================================================
-- GANG
-- ============================================================

--- Obtém dados da gang
---@return table
function Nova.Player:GetGang()
    return self.gang
end

--- Define a gang do jogador
---@param gangName string Nome da gang
---@param grade number Grau
---@return boolean
function Nova.Player:SetGang(gangName, grade)
    if not Nova.Auth:IsVerified() then return false end
    grade = grade or 0
    local gangData = Nova.Functions.GetGang(gangName)

    if not gangData then
        Nova.Functions.Notify(self.source, _L('gang_not_found'), 'error')
        return false
    end

    local gradeData = gangData.grades[grade]
    if not gradeData then
        gradeData = { label = 'Membro', is_boss = false }
    end

    local oldGang = self.gang

    self.gang = {
        name = gangData.name,
        label = gangData.label,
        grade = grade,
        grade_label = gradeData.label,
        is_boss = gradeData.is_boss,
    }

    Nova.Functions.Notify(self.source, _L('gang_set', gangData.label), 'success')
    self:UpdateClient('gang')

    -- Evento seguro: source + nomes (sem detalhes de grade)
    TriggerEvent('nova:server:onGangChange', self.source, self.gang.name, oldGang and oldGang.name or nil)

    return true
end

-- ============================================================
-- INVENTÁRIO
-- ============================================================

--- Obtém o inventário completo
---@return table
function Nova.Player:GetInventory()
    -- Tentar obter do nova_inventory (fonte de verdade)
    local ok, invData = pcall(function()
        return exports['nova_inventory']:GetPlayerInventory(self.source)
    end)
    if ok and invData then
        self.inventory = invData
        return invData
    end
    return self.inventory
end

--- Verifica se o jogador tem um item
---@param itemName string Nome do item
---@param amount number Quantidade mínima (padrão: 1)
---@return boolean
function Nova.Player:HasItem(itemName, amount)
    amount = amount or 1
    -- Tentar usar o nova_inventory (fonte de verdade)
    local ok, result = pcall(function()
        return exports['nova_inventory']:HasItem(self.source, itemName, amount)
    end)
    if ok then return result end
    -- Fallback: inventário local
    for _, item in pairs(self.inventory) do
        if item.name == itemName and item.amount >= amount then
            return true
        end
    end
    return false
end

--- Obtém a quantidade de um item
---@param itemName string Nome do item
---@return number
function Nova.Player:GetItemCount(itemName)
    -- Tentar usar o nova_inventory (fonte de verdade)
    local ok, result = pcall(function()
        return exports['nova_inventory']:GetItemCount(self.source, itemName)
    end)
    if ok and result then return result end
    -- Fallback: inventário local
    for _, item in pairs(self.inventory) do
        if item.name == itemName then
            return item.amount
        end
    end
    return 0
end

--- Adiciona um item ao inventário
---@param itemName string Nome do item
---@param amount number Quantidade
---@param metadata table|nil Metadata extra do item
---@return boolean
function Nova.Player:AddItem(itemName, amount, metadata)
    if not Nova.Auth:IsVerified() then return false end
    if not Nova.ItemExists(itemName) then
        Nova.Functions.Notify(self.source, _L('item_not_found'), 'error')
        return false
    end

    if amount <= 0 then return false end

    -- Delegar ao nova_inventory se estiver disponível (fonte de verdade)
    local ok, result = pcall(function()
        return exports['nova_inventory']:AddItem(self.source, itemName, amount, nil, metadata)
    end)
    if ok then
        -- Sincronizar o objecto Player com o nova_inventory
        local okInv, invData = pcall(function()
            return exports['nova_inventory']:GetPlayerInventory(self.source)
        end)
        if okInv and invData then
            self.inventory = invData
        end
        TriggerEvent('nova:server:onItemAdd', self.source, itemName)
        return result ~= false
    end

    -- Fallback: gestão interna (caso nova_inventory não esteja disponível)
    local itemData = Nova.GetItem(itemName)

    -- Procurar item existente para stackar (usar ipairs para arrays sequenciais)
    for i = 1, #self.inventory do
        local item = self.inventory[i]
        if item and item.name == itemName and not itemData.unique then
            self.inventory[i].amount = self.inventory[i].amount + amount
            Nova.Functions.Notify(self.source, _L('item_received', amount, itemData.label), 'success')
            self:UpdateClient('inventory')
            TriggerEvent('nova:server:onItemAdd', self.source, itemName)
            return true
        end
    end

    self.inventory[#self.inventory + 1] = {
        name = itemName,
        label = itemData.label,
        amount = amount,
        weight = itemData.weight,
        type = itemData.type,
        metadata = metadata or {},
    }

    Nova.Functions.Notify(self.source, _L('item_received', amount, itemData.label), 'success')
    self:UpdateClient('inventory')
    TriggerEvent('nova:server:onItemAdd', self.source, itemName)

    return true
end

--- Remove um item do inventário
---@param itemName string Nome do item
---@param amount number Quantidade
---@return boolean
function Nova.Player:RemoveItem(itemName, amount)
    if not Nova.Auth:IsVerified() then return false end
    if amount <= 0 then return false end

    -- Delegar ao nova_inventory se estiver disponível (fonte de verdade)
    local ok, result = pcall(function()
        return exports['nova_inventory']:RemoveItem(self.source, itemName, amount)
    end)
    if ok then
        -- Sincronizar o objecto Player com o nova_inventory
        local okInv, invData = pcall(function()
            return exports['nova_inventory']:GetPlayerInventory(self.source)
        end)
        if okInv and invData then
            self.inventory = invData
        end
        TriggerEvent('nova:server:onItemRemove', self.source, itemName)
        return result ~= false
    end

    -- Fallback: gestão interna (usar ipairs para arrays sequenciais)
    for i = #self.inventory, 1, -1 do
        local item = self.inventory[i]
        if item and item.name == itemName then
            if item.amount < amount then
                Nova.Functions.Notify(self.source, _L('item_not_enough'), 'error')
                return false
            end

            self.inventory[i].amount = self.inventory[i].amount - amount

            if self.inventory[i].amount <= 0 then
                table.remove(self.inventory, i)
            end

            local itemData = Nova.GetItem(itemName)
            Nova.Functions.Notify(self.source, _L('item_removed', amount, itemData and itemData.label or itemName), 'info')
            self:UpdateClient('inventory')
            TriggerEvent('nova:server:onItemRemove', self.source, itemName)

            return true
        end
    end

    Nova.Functions.Notify(self.source, _L('item_not_enough'), 'error')
    return false
end

-- ============================================================
-- METADATA
-- ============================================================

--- Obtém um valor de metadata
---@param key string Chave
---@return any
function Nova.Player:GetMetadata(key)
    if key then
        return self.metadata[key]
    end
    return self.metadata
end

--- Define um valor de metadata
---@param key string Chave
---@param value any Valor
function Nova.Player:SetMetadata(key, value)
    self.metadata[key] = value
    self:UpdateClient('metadata')
    -- Evento seguro: apenas source e chave (sem valor)
    -- Quem precisar do valor, use exports['nova_core']:GetPlayer(source):GetMetadata(key)
    TriggerEvent('nova:server:onMetadataChange', self.source, key)
end

-- ============================================================
-- POSIÇÃO
-- ============================================================

--- Obtém a posição do jogador
---@return vector4
function Nova.Player:GetPosition()
    return self.position
end

--- Define a posição do jogador
---@param coords vector4|vector3 Coordenadas
function Nova.Player:SetPosition(coords)
    if type(coords) == 'vector3' then
        self.position = vector4(coords.x, coords.y, coords.z, 0.0)
    else
        self.position = coords
    end
end

-- ============================================================
-- PERSISTÊNCIA
-- ============================================================

--- Guarda o jogador na base de dados
function Nova.Player:Save()
    if not Nova.Auth:IsVerified() then return end
    -- Atualizar posição do ped antes de salvar
    local ped = GetPlayerPed(self.source)
    if ped and DoesEntityExist(ped) then
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        self.position = vector4(coords.x, coords.y, coords.z, heading)
    end

    -- Se o nova_inventory estiver activo, ele é a fonte de verdade para o inventário
    -- e guarda-o directamente na DB. Não devemos sobrescrever com dados desactualizados.
    -- Passamos nil para que o COALESCE no SQL mantenha o valor existente na DB.
    local inventoryToSave = self.inventory
    local novaInvRunning = GetResourceState('nova_inventory') == 'started'
    if novaInvRunning then
        -- Tentar obter dados actualizados do nova_inventory
        local ok, invData = pcall(function()
            return exports['nova_inventory']:GetPlayerInventory(self.source)
        end)
        if ok and invData and next(invData) ~= nil then
            inventoryToSave = invData
        else
            -- nova_inventory já limpou os dados (playerDropped já correu)
            -- Passar nil para que o COALESCE mantenha o valor da DB
            inventoryToSave = nil
        end
    end

    Nova.Database.SaveCharacter(self.citizenid, {
        charinfo = self.charinfo,
        money = self.money,
        job = self.job,
        gang = self.gang,
        position = {
            x = self.position.x,
            y = self.position.y,
            z = self.position.z,
            w = self.position.w,
        },
        inventory = inventoryToSave,
        metadata = self.metadata,
        skin = self.skin,
    })

    Nova.Debug('Jogador guardado: ' .. self:GetFullName() .. ' (' .. self.citizenid .. ')')
end

--- Descarrega o jogador (logout)
function Nova.Player:Logout()
    if not Nova.Auth:IsVerified() then return end
    self:Save()
    Nova.Players[tostring(self.source)] = nil
    TriggerClientEvent('nova:client:onLogout', self.source)
    TriggerEvent('nova:server:onPlayerLogout', self.source, self.citizenid)
    Nova.Debug('Jogador descarregado: ' .. self:GetFullName())
end

-- ============================================================
-- SINCRONIZAÇÃO
-- ============================================================

--- Atualiza dados específicos no client
---@param dataType string Tipo de dados (money, job, gang, metadata, inventory, all)
function Nova.Player:UpdateClient(dataType)
    if dataType == 'all' then
        TriggerClientEvent('nova:client:updatePlayerData', self.source, self:GetData())
    else
        TriggerClientEvent('nova:client:updatePlayerData', self.source, {
            type = dataType,
            data = self[dataType],
        })
    end
end

-- ============================================================
-- AÇÕES
-- ============================================================

--- Envia notificação para o jogador
---@param message string Mensagem
---@param type string Tipo (success, error, info, warning)
---@param duration number|nil Duração em ms
function Nova.Player:Notify(message, type, duration)
    Nova.Functions.Notify(self.source, message, type, duration)
end

--- Expulsa o jogador do servidor
---@param reason string Motivo
function Nova.Player:Kick(reason)
    if not Nova.Auth:IsVerified() then return end
    self:Save()
    DropPlayer(self.source, _L('player_kicked', reason or 'Sem motivo'))
end

--- Bane o jogador
---@param reason string Motivo
function Nova.Player:Ban(reason)
    if not Nova.Auth:IsVerified() then return end
    self:Save()
    Nova.Database.BanUser(self.identifier, reason)
    DropPlayer(self.source, _L('player_banned', reason or 'Sem motivo'))
end

--- Revive o jogador
function Nova.Player:Revive()
    self:SetMetadata('is_dead', false)
    self:SetMetadata('health', 200)
    TriggerClientEvent('nova:client:revive', self.source)
end

--- Cura o jogador
function Nova.Player:Heal()
    self:SetMetadata('health', 200)
    self:SetMetadata('armor', 0)
    self:SetMetadata('hunger', 100)
    self:SetMetadata('thirst', 100)
    self:SetMetadata('stress', 0)
    TriggerClientEvent('nova:client:heal', self.source)
end
