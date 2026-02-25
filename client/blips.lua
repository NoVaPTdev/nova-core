local createdBlips = {}

local function CreateBlipGroup(group)
    if not group or not group.locations then return end

    for _, loc in ipairs(group.locations) do
        local coords = loc.coords
        if coords then
            local blip = AddBlipForCoord(coords[1], coords[2], coords[3])
            SetBlipSprite(blip, loc.sprite or group.sprite or 1)
            SetBlipColour(blip, loc.color or group.color or 0)
            SetBlipScale(blip, loc.scale or group.scale or 0.7)
            SetBlipDisplay(blip, loc.display or group.display or 4)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(loc.label or 'Blip')
            EndTextCommandSetBlipName(blip)
            createdBlips[#createdBlips + 1] = blip
        end
    end
end

CreateThread(function()
    while not BlipsConfig do Wait(100) end

    for key, group in pairs(BlipsConfig) do
        if type(group) == 'table' and group.locations then
            CreateBlipGroup(group)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for _, blip in ipairs(createdBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end)
