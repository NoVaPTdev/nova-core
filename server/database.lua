--[[
    NOVA Framework - Módulo de Base de Dados (Server)
    Operações de base de dados com oxmysql
]]

Nova.Database = {}

-- ============================================================
-- INICIALIZAÇÃO
-- ============================================================

--- Verifica se as tabelas existem na base de dados
function Nova.Database.Initialize()
    Nova.Print('A verificar tabelas na base de dados...')

    MySQL.ready(function()
        Nova.Print(_L('db_connected'))

        -- Verificar se as tabelas principais existem
        MySQL.query('SHOW TABLES LIKE ?', { 'nova_users' }, function(result)
            if not result or #result == 0 then
                Nova.Warn('Tabelas não encontradas! Executa o ficheiro sql/nova.sql na tua base de dados.')
            else
                Nova.Print('Tabelas da base de dados verificadas com sucesso.')
            end
        end)
    end)
end

-- ============================================================
-- UTILIZADORES
-- ============================================================

--- Obtém ou cria um utilizador
---@param identifier string Identificador do jogador
---@param playerName string Nome do jogador
---@param identifiers table Todos os identificadores
---@param callback function Callback com os dados do utilizador
function Nova.Database.GetOrCreateUser(identifier, playerName, identifiers, callback)
    MySQL.single('SELECT * FROM nova_users WHERE identifier = ?', { identifier }, function(user)
        if user then
            -- Atualizar última vez visto
            MySQL.update('UPDATE nova_users SET name = ?, last_seen = NOW() WHERE identifier = ?', {
                playerName, identifier
            })
            if callback then callback(user) end
        else
            -- Criar novo utilizador
            local license = identifiers.license or nil
            local steam = identifiers.steam or nil
            local discord = identifiers.discord or nil

            MySQL.insert('INSERT INTO nova_users (identifier, license, steam, discord, name) VALUES (?, ?, ?, ?, ?)', {
                identifier, license, steam, discord, playerName
            }, function(id)
                if id then
                    MySQL.single('SELECT * FROM nova_users WHERE id = ?', { id }, function(newUser)
                        if callback then callback(newUser) end
                    end)
                else
                    Nova.Error('Erro ao criar utilizador: ' .. identifier)
                    if callback then callback(nil) end
                end
            end)
        end
    end)
end

--- Verifica se o utilizador está banido
---@param identifier string Identificador
---@param callback function Callback (banned, reason)
function Nova.Database.IsUserBanned(identifier, callback)
    MySQL.single('SELECT banned, ban_reason FROM nova_users WHERE identifier = ?', { identifier }, function(result)
        if result and result.banned == 1 then
            callback(true, result.ban_reason or 'Sem motivo especificado')
        else
            callback(false, nil)
        end
    end)
end

--- Bane um utilizador
---@param identifier string Identificador
---@param reason string Motivo do ban
function Nova.Database.BanUser(identifier, reason)
    MySQL.update('UPDATE nova_users SET banned = 1, ban_reason = ? WHERE identifier = ?', {
        reason or 'Sem motivo especificado', identifier
    })
end

--- Remove o ban de um utilizador
---@param identifier string Identificador
function Nova.Database.UnbanUser(identifier)
    MySQL.update('UPDATE nova_users SET banned = 0, ban_reason = NULL WHERE identifier = ?', { identifier })
end

--- Define o grupo de permissão
---@param identifier string Identificador
---@param group string Nome do grupo
function Nova.Database.SetUserGroup(identifier, group)
    MySQL.update('UPDATE nova_users SET `group` = ? WHERE identifier = ?', { group, identifier })
end

-- ============================================================
-- PERSONAGENS
-- ============================================================

--- Obtém todos os personagens de um utilizador
---@param userId number ID do utilizador
---@param callback function Callback com lista de personagens
function Nova.Database.GetCharacters(userId, callback)
    MySQL.query('SELECT * FROM nova_characters WHERE user_id = ? ORDER BY id ASC', { userId }, function(characters)
        callback(characters or {})
    end)
end

--- Obtém um personagem específico
---@param citizenId string CitizenID do personagem
---@param callback function Callback com dados do personagem
function Nova.Database.GetCharacter(citizenId, callback)
    MySQL.single('SELECT * FROM nova_characters WHERE citizenid = ?', { citizenId }, function(character)
        callback(character)
    end)
end

--- Cria um novo personagem
---@param userId number ID do utilizador
---@param citizenId string CitizenID gerado
---@param charData table Dados do personagem
---@param callback function Callback (success, characterId)
function Nova.Database.CreateCharacter(userId, citizenId, charData, callback)
    local position = json.encode({
        x = NovaConfig.DefaultSpawn.x,
        y = NovaConfig.DefaultSpawn.y,
        z = NovaConfig.DefaultSpawn.z,
        w = NovaConfig.DefaultSpawn.w,
    })

    local metadata = json.encode(NovaConfig.DefaultMetadata)

    MySQL.insert([[
        INSERT INTO nova_characters 
        (user_id, citizenid, firstname, lastname, dateofbirth, gender, nationality, phone, cash, bank, black_money, position, metadata)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        userId,
        citizenId,
        charData.firstname or '',
        charData.lastname or '',
        charData.dateofbirth or '01/01/2000',
        charData.gender or 0,
        charData.nationality or 'Português',
        charData.phone,
        NovaConfig.MoneyTypes.cash.default,
        NovaConfig.MoneyTypes.bank.default,
        NovaConfig.MoneyTypes.black_money.default,
        position,
        metadata,
    }, function(id)
        if id then
            callback(true, id)
        else
            callback(false, nil)
        end
    end)
end

--- Elimina um personagem
---@param citizenId string CitizenID
---@param callback function Callback (success)
function Nova.Database.DeleteCharacter(citizenId, callback)
    MySQL.update('DELETE FROM nova_characters WHERE citizenid = ?', { citizenId }, function(affectedRows)
        callback(affectedRows > 0)
    end)
end

--- Guarda os dados de um personagem
---@param citizenId string CitizenID
---@param data table Dados a guardar
function Nova.Database.SaveCharacter(citizenId, data)
    -- COALESCE no inventory: se for nil, mantém o valor existente na DB
    -- Isto evita que o nova_core sobrescreva o inventário quando o nova_inventory
    -- já o guardou (race condition no playerDropped)
    MySQL.update([[
        UPDATE nova_characters SET
            firstname = ?,
            lastname = ?,
            cash = ?,
            bank = ?,
            black_money = ?,
            job = ?,
            job_grade = ?,
            job_duty = ?,
            gang = ?,
            gang_grade = ?,
            position = ?,
            inventory = COALESCE(?, inventory),
            metadata = ?,
            skin = ?,
            is_dead = ?,
            last_played = NOW()
        WHERE citizenid = ?
    ]], {
        data.charinfo.firstname,
        data.charinfo.lastname,
        data.money.cash,
        data.money.bank,
        data.money.black_money,
        data.job.name,
        data.job.grade,
        data.job.duty and 1 or 0,
        data.gang.name,
        data.gang.grade,
        data.position and json.encode(data.position) or nil,
        data.inventory and json.encode(data.inventory) or nil,
        data.metadata and json.encode(data.metadata) or nil,
        data.skin and json.encode(data.skin) or nil,
        data.metadata and data.metadata.is_dead and 1 or 0,
        citizenId,
    })
end

-- ============================================================
-- EMPREGOS
-- ============================================================

--- Obtém dados de um emprego com os seus graus
---@param jobName string Nome do emprego
---@param callback function Callback com dados do emprego
function Nova.Database.GetJob(jobName, callback)
    MySQL.single('SELECT * FROM nova_jobs WHERE name = ?', { jobName }, function(job)
        if job then
            MySQL.query('SELECT * FROM nova_job_grades WHERE job_name = ? ORDER BY grade ASC', { jobName }, function(grades)
                job.grades = {}
                if grades then
                    for _, grade in ipairs(grades) do
                        job.grades[grade.grade] = {
                            label = grade.label,
                            salary = grade.salary,
                            is_boss = grade.is_boss == 1,
                        }
                    end
                end
                callback(job)
            end)
        else
            callback(nil)
        end
    end)
end

--- Obtém todos os empregos
---@param callback function Callback com tabela de empregos
function Nova.Database.GetAllJobs(callback)
    MySQL.query('SELECT j.*, jg.grade, jg.label as grade_label, jg.salary, jg.is_boss FROM nova_jobs j LEFT JOIN nova_job_grades jg ON j.name = jg.job_name ORDER BY j.name, jg.grade', {},
        function(results)
            local jobs = {}
            if results then
                for _, row in ipairs(results) do
                    if not jobs[row.name] then
                        jobs[row.name] = {
                            name = row.name,
                            label = row.label,
                            type = row.type,
                            default_duty = row.default_duty == 1,
                            grades = {},
                        }
                    end
                    if row.grade ~= nil then
                        jobs[row.name].grades[row.grade] = {
                            label = row.grade_label,
                            salary = row.salary,
                            is_boss = row.is_boss == 1,
                        }
                    end
                end
            end
            callback(jobs)
        end)
end

-- ============================================================
-- GANGS
-- ============================================================

--- Obtém dados de uma gang
---@param gangName string Nome da gang
---@param callback function Callback
function Nova.Database.GetGang(gangName, callback)
    MySQL.single('SELECT * FROM nova_gangs WHERE name = ?', { gangName }, function(gang)
        if gang then
            MySQL.query('SELECT * FROM nova_gang_grades WHERE gang_name = ? ORDER BY grade ASC', { gangName }, function(grades)
                gang.grades = {}
                if grades then
                    for _, grade in ipairs(grades) do
                        gang.grades[grade.grade] = {
                            label = grade.label,
                            is_boss = grade.is_boss == 1,
                        }
                    end
                end
                callback(gang)
            end)
        else
            callback(nil)
        end
    end)
end

--- Obtém todas as gangs
---@param callback function Callback
function Nova.Database.GetAllGangs(callback)
    MySQL.query('SELECT g.*, gg.grade, gg.label as grade_label, gg.is_boss FROM nova_gangs g LEFT JOIN nova_gang_grades gg ON g.name = gg.gang_name ORDER BY g.name, gg.grade', {},
        function(results)
            local gangs = {}
            if results then
                for _, row in ipairs(results) do
                    if not gangs[row.name] then
                        gangs[row.name] = {
                            name = row.name,
                            label = row.label,
                            grades = {},
                        }
                    end
                    if row.grade ~= nil then
                        gangs[row.name].grades[row.grade] = {
                            label = row.grade_label,
                            is_boss = row.is_boss == 1,
                        }
                    end
                end
            end
            callback(gangs)
        end)
end
