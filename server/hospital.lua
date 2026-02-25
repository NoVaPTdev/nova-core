local patientsInBed = {}
Nova.GangDuty = Nova.GangDuty or {}

local function IsMedic(player)
    if player.job and player.job.name == HospitalConfig.MedicJob then
        return true
    end
    if player.gang and player.gang.name == HospitalConfig.MedicJob then
        return true
    end
    return false
end

local function IsMedicOnDuty(player, src)
    if player.job and player.job.name == HospitalConfig.MedicJob then
        return player.job.duty == true
    end
    if player.gang and player.gang.name == HospitalConfig.MedicJob then
        return Nova.GangDuty[src] == true
    end
    return false
end

local function CountMedicsOnDuty()
    local count = 0
    for _, p in pairs(Nova.Players) do
        if p.job and p.job.name == HospitalConfig.MedicJob and p.job.duty then
            count = count + 1
        end
    end
    for src, onDuty in pairs(Nova.GangDuty) do
        if onDuty then count = count + 1 end
    end
    return count
end

Nova.Functions.CreateCallback('nova:hospital:selfHeal', function(source, cb)
    local medics = CountMedicsOnDuty()
    if medics > 0 then
        cb({ blocked = true })
        return
    end

    local player = Nova.Functions.GetPlayer(source)
    if not player then
        cb({})
        return
    end

    local cash = player.money.cash or 0
    if cash < HospitalConfig.SelfHealCost then
        cb({ noMoney = true })
        return
    end

    player:RemoveMoney('cash', HospitalConfig.SelfHealCost, 'Auto-tratamento hospital')
    patientsInBed[source] = nil

    cb({ success = true })
end)

Nova.Functions.CreateCallback('nova:hospital:checkMedic', function(source, cb)
    local player = Nova.Functions.GetPlayer(source)
    if not player then cb(false) return end
    cb(IsMedicOnDuty(player, source))
end)

RegisterNetEvent('nova:hospital:layDown', function()
    local src = source
    patientsInBed[src] = true

    local medics = CountMedicsOnDuty()
    if medics > 0 then
        for mSrc, _ in pairs(Nova.GangDuty) do
            if Nova.GangDuty[mSrc] then
                Nova.Functions.Notify(mSrc, 'Um paciente deitou-se numa cama do hospital!', 'info')
            end
        end
        for _, p in pairs(Nova.Players) do
            if p.job and p.job.name == HospitalConfig.MedicJob and p.job.duty and p.source then
                Nova.Functions.Notify(p.source, 'Um paciente deitou-se numa cama do hospital!', 'info')
            end
        end
    end
end)

RegisterNetEvent('nova:hospital:standUp', function()
    local src = source
    patientsInBed[src] = nil
end)

RegisterNetEvent('nova:hospital:treatPlayer', function(targetId)
    local src = source
    local medic = Nova.Functions.GetPlayer(src)
    if not medic then return end

    if not IsMedic(medic) then
        return Nova.Functions.Notify(src, 'Apenas médicos podem tratar pacientes.', 'error')
    end

    if not IsMedicOnDuty(medic, src) then
        return Nova.Functions.Notify(src, 'Tens de estar em serviço. Usa /servico.', 'error')
    end

    targetId = tonumber(targetId)
    if not targetId then return end

    local target = Nova.Functions.GetPlayer(targetId)
    if not target then
        return Nova.Functions.Notify(src, 'Jogador não encontrado.', 'error')
    end

    if not patientsInBed[targetId] then
        return Nova.Functions.Notify(src, 'Este jogador não está numa cama.', 'error')
    end

    patientsInBed[targetId] = nil
    TriggerClientEvent('nova:hospital:healed', targetId)

    medic:AddMoney('cash', HospitalConfig.MedicPayment, 'Tratamento hospitalar')
    Nova.Functions.Notify(src, 'Paciente tratado! Recebeste $' .. HospitalConfig.MedicPayment, 'success')
end)

CreateThread(function()
    while not Nova.Functions.RegisterCommand do Wait(100) end

    Nova.Functions.RegisterCommand('tratamento', nil, function(source, args)
        local medic = Nova.Functions.GetPlayer(source)
        if not medic then return end

        if not IsMedic(medic) then
            Nova.Functions.Notify(source, 'Apenas médicos podem usar este comando.', 'error')
            return
        end

        if not IsMedicOnDuty(medic, source) then
            Nova.Functions.Notify(source, 'Tens de estar em serviço. Usa /servico para entrar em serviço.', 'error')
            return
        end

        local targetId = tonumber(args[1])
        if not targetId then
            Nova.Functions.Notify(source, 'Uso: /tratamento [id do jogador]', 'error')
            return
        end

        local target = Nova.Functions.GetPlayer(targetId)
        if not target then
            Nova.Functions.Notify(source, 'Jogador não encontrado.', 'error')
            return
        end

        if not patientsInBed[targetId] then
            Nova.Functions.Notify(source, 'Este jogador não está deitado numa cama de hospital.', 'error')
            return
        end

        patientsInBed[targetId] = nil
        TriggerClientEvent('nova:hospital:healed', targetId)

        medic:AddMoney('cash', HospitalConfig.MedicPayment, 'Tratamento hospitalar')
        Nova.Functions.Notify(source, 'Paciente tratado com sucesso! Recebeste $' .. HospitalConfig.MedicPayment, 'success')
    end, {
        help = 'Trata um jogador deitado numa cama de hospital',
        params = {
            { name = 'id', help = 'ID do jogador a tratar' },
        },
    })

end)

AddEventHandler('playerDropped', function()
    patientsInBed[source] = nil
    Nova.GangDuty[source] = nil
end)
