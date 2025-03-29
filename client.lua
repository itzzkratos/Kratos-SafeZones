local safeZones = {}
local lastCheckedPos = vector3(0, 0, 0)

function restrictZones(playerPed, zone, isEntering)
    local speedLimitMps = zone.maxSpeed * 0.44704
    local defaultSpeedMps = 100.0 * 0.44704

    SetEntityMaxSpeed(playerPed, isEntering and speedLimitMps or defaultSpeedMps)

    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsUsing(playerPed)
        if not IsPedInAnyHeli(playerPed) and not IsPedInAnyPlane(playerPed) then
            SetVehicleMaxSpeed(veh, isEntering and speedLimitMps or defaultSpeedMps)
        end
    end

    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)

    local controls = {24, 25, 47, 58, 37, 140, 141, 142, 143, 263, 264, 257}
    for _, control in ipairs(controls) do
        if isEntering then
            DisableControlAction(0, control, true)
        else
            EnableControlAction(0, control, true)
        end
    end

    DisablePlayerFiring(playerPed, isEntering)
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
                end
                Config.Notify("You have entered a safezone", "success")
            end,
            onExit = function(self)
                local playerPed = PlayerPedId()
                if not bypassed then
                    restrictZones(playerPed, zone, false)
                end
                Config.Notify("You have exited a safezone", "success")
            end
        })
    end

    while true do
        Citizen.Wait(1000)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if #(playerCoords - lastCheckedPos) > 5.0 then
            lastCheckedPos = playerCoords

            for _, zone in ipairs(Config.SafeZones) do
                local inZone = safeZones[zone.name]:contains(playerCoords)

                if inZone then
                    if not bypassed then
                        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                        SetEntityMaxSpeed(playerPed, zone.maxSpeed * 0.44704)

                        if IsPedInAnyVehicle(playerPed, false) then
                            local veh = GetVehiclePedIsUsing(playerPed)
                            if not IsPedInAnyHeli(playerPed) and not IsPedInAnyPlane(playerPed) then
                                SetVehicleMaxSpeed(veh, zone.maxSpeed * 0.44704)
                            end
                        end
                    end
                end
            end
        end
    end
end)
