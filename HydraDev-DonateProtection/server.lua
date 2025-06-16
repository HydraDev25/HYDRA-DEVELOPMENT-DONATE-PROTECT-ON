function GetPlayerDiscordID(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in pairs(identifiers) do
        if string.match(id, "discord:") then
            return string.gsub(id, "discord:", "")
        end
    end
    return nil
end

function IsPlayerAuthorizedForVehicle(playerId, vehicleHash)
    local discordID = GetPlayerDiscordID(playerId)
    if not discordID then
        return false
    end

    local authorizedIDs = Config.VehicleAccess[vehicleHash]
    if authorizedIDs then
        for _, authorizedID in pairs(authorizedIDs) do
            if discordID == authorizedID then
                return true
            end
        end
    end
    
    return false
end

function IsVehicleProtected(vehicleHash)
    return Config.VehicleAccess[vehicleHash] ~= nil
end

function GetVehicleNameFromHash(vehicleHash)
    return Config.VehicleNames[vehicleHash] or ("Hash: " .. tostring(vehicleHash))
end

RegisterNetEvent('vehicleProtection:checkAccess')
AddEventHandler('vehicleProtection:checkAccess', function(vehicleNetId, vehicleHash)
    local playerId = source
    local playerName = GetPlayerName(playerId)
    local vehicleName = GetVehicleNameFromHash(vehicleHash)

    if IsVehicleProtected(vehicleHash) then
        if not IsPlayerAuthorizedForVehicle(playerId, vehicleHash) then
            local discordID = GetPlayerDiscordID(playerId)
            print(string.format("^3[Vehicle Protection]^7 %s (ID: %s, Discord: %s) unauthorized access attempt to %s! Vehicle deleted.", 
                playerName, playerId, discordID or "Unknown", vehicleName))

            TriggerClientEvent('vehicleProtection:deleteVehicle', playerId, vehicleNetId)

            TriggerClientEvent('vehicleProtection:showNotify', playerId, 
                string.format("You are not authorized to drive this vehicle (%s)!", vehicleName))

            TriggerClientEvent('vehicleProtection:deleteVehicleForAll', -1, vehicleNetId)
        else
            local discordID = GetPlayerDiscordID(playerId)
            print(string.format("^2[Vehicle Protection]^7 %s (ID: %s, Discord: %s) authorized access to %s granted.", 
                playerName, playerId, discordID, vehicleName))
        end
    end
end)

RegisterCommand('vehicleprotection_info', function(source, args)
    if source == 0 then
        print("^6=== Vehicle Protection Info ===^7")
        print("^3Vehicle-Based Permissions:^7")
        for vehicleHash, authorizedIDs in pairs(Config.VehicleAccess) do
            local vehicleName = GetVehicleNameFromHash(vehicleHash)
            print(string.format("^5%s (Hash: %s):^7", vehicleName, vehicleHash))
            for i, id in pairs(authorizedIDs) do
                print(string.format("  - %s", id))
            end
        end
        if #Config.SuperAdmins > 0 then
            print("^3Super Admins:^7")
            for i, id in pairs(Config.SuperAdmins) do
                print(string.format("  %d. %s", i, id))
            end
        end
    end
end)
