local checkedVehicles = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        local playerPed = PlayerPedId()
        
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            local vehicleHash = GetEntityModel(vehicle)
            
            if not checkedVehicles[vehicleNetId] then
                checkedVehicles[vehicleNetId] = true
                
                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    TriggerServerEvent('vehicleProtection:checkAccess', vehicleNetId, vehicleHash)
                end
            end
        end
    end
end)

RegisterNetEvent('vehicleProtection:deleteVehicle')
AddEventHandler('vehicleProtection:deleteVehicle', function(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
    end
    checkedVehicles[vehicleNetId] = nil
end)

RegisterNetEvent('vehicleProtection:deleteVehicleForAll')
AddEventHandler('vehicleProtection:deleteVehicleForAll', function(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
    end
    checkedVehicles[vehicleNetId] = nil
end)

RegisterNetEvent('vehicleProtection:showNotify')
AddEventHandler('vehicleProtection:showNotify', function(message)
    if ESX then
        ESX.ShowNotification(message, "error")
    elseif QBCore then
        QBCore.Functions.Notify(message, "error")
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
    
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"[SYSTEM]", message}
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(6000)
        
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed, false) then
            checkedVehicles = {}
        end
    end
end)
