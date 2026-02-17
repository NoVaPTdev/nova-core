--[[
    NOVA Framework - Configuração de Salários
    Define intervalos, bónus e regras de pagamento
]]

NovaGroups = NovaGroups or {}

NovaGroups.Salary = {
    enabled = true,
    interval = 15,              -- Minutos entre cada pagamento
    payOnDutyOnly = true,       -- Só pagar quando em serviço
    moneyType = 'bank',         -- Tipo de dinheiro (bank, cash)
    bonusPerGrade = 0.10,       -- +10% de bónus por cada grau acima de 0
    notifyPlayer = true,        -- Notificar jogador ao receber salário
    minSalary = 50,             -- Salário mínimo (desempregados)
}
