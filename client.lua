local safeZones = {}
local isRestricted = false 

function restrictZones(playerPed, zone, isEntering)
    if not zone then return end 
    local speedLimitMps = zone.maxSpeed * 0.44704
    if isEntering then
        Citizen.Wait(50)
        SetEntityMaxSpeed(playerPed, speedLimitMps)
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsUsing(playerPed)
            if veh and DoesEntityExist(veh) then
                SetVehicleMaxSpeed(veh, speedLimitMps)
            end
        end

        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
        DisablePlayerFiring(playerPed, true)
        local controls = {24, 25, 47, 58, 37, 140, 141, 142, 143, 263, 264, 257}
        for _, control in ipairs(controls) do
            DisableControlAction(0, control, true)
        end
    else
        SetEntityMaxSpeed(playerPed, -1.0)
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsUsing(playerPed)
            if veh and DoesEntityExist(veh) then
                SetVehicleMaxSpeed(veh, -1.0)
            end
        end

        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
        DisablePlayerFiring(playerPed, false)
        local controls = {24, 25, 47, 58, 37, 140, 141, 142, 143, 263, 264, 257}
        for _, control in ipairs(controls) do
            EnableControlAction(0, control, true)
        end
    end
end

Citizen.CreateThread(function()
    local bypassed = lib.callback.await('Kratos-Safezones:Bypass', true)
    for _, zone in ipairs(Config.SafeZones) do
        safeZones[zone.name] = lib.zones.poly({
            points = zone.points,
            thickness = zone.thickness,
            debug = zone.debug,
            onEnter = function(self)
                local playerPed = PlayerPedId()
                if not bypassed then
                    restrictZones(playerPed, zone, true)
                    isRestricted = true
                end
                Config.Notify("You have entered a safezone", "success")
            end,
            onExit = function(self)
                local playerPed = PlayerPedId()
                if not bypassed then
                    restrictZones(playerPed, zone, false)
                    isRestricted = false
                end
                Config.Notify("You have exited a safezone", "success")
            end
        })
    end
    while true do
        Citizen.Wait(1)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local inZone = false
        for _, zone in ipairs(Config.SafeZones) do
            if safeZones[zone.name]:contains(playerCoords) then
                inZone = true
                break
            end
        end

        if inZone then
            if not isRestricted then
                local zone = Config.SafeZones[1]
                restrictZones(playerPed, zone, true)
                isRestricted = true
            end

            local currentWeapon = GetSelectedPedWeapon(playerPed)
            if currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
                SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                DisablePlayerFiring(playerPed, true)
            end
        elseif not inZone and isRestricted then
            restrictZones(playerPed, nil, false)
            isRestricted = false
        end
    end
end)
