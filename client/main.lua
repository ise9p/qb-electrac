local QBCore = exports['qb-core']:GetCoreObject()
local WebhookURL = Config.WebHook
local hasCompletedMission = false
local isOnMission = false
local spawnedPed = nil
local currentVehicle = nil
local missionBlip = nil
local repairZone = nil


local function sendNotification(title, type)
    if Config.notify == "qb" then
        TriggerEvent("QBCore:Notify", title, type)
    elseif Config.notify == "ox" then
        lib.notify({
            title = title,
            type = type
        })
    end
end

local pedModel = Config.PedModel
local pedCoords = Config.PedCoords
local vehicleModel = Config.VehicleModel
local missionLocations = Config.MissionLocations

CreateThread(function()
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(500) end

    spawnedPed = CreatePed(0, pedModel, pedCoords.x, pedCoords.y, pedCoords.z - 1, pedCoords.w, false, false)
    SetEntityInvincible(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)

    local managerBlip = AddBlipForCoord(pedCoords.x, pedCoords.y, pedCoords.z)
    SetBlipSprite(managerBlip, 354)
    SetBlipDisplay(managerBlip, 4)
    SetBlipScale(managerBlip, 0.8)
    SetBlipColour(managerBlip, 16)
    SetBlipAsShortRange(managerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Electricity Job Manager")
    EndTextCommandSetBlipName(managerBlip)

    exports['qb-target']:AddTargetEntity(spawnedPed, {
        options = {
            {
                type = "client",
                event = "qb-electrac:client:menu",
                icon = "fas fa-comments",
                label = "Talk to the Manager",
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent("qb-electrac:client:menu", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local jobRep = PlayerData.metadata["jobrep"] and PlayerData.metadata["jobrep"]["electrac"] or { grade = 1, progress = 0, payment = 0 }

    local jobMenu = {
        { header = "Job Menu", icon = "fas fa-briefcase", isMenuHeader = true },
        { header = "Job Info", icon = "fas fa-info-circle", txt = "Grade: " .. jobRep.grade .. " | Progress: " .. jobRep.progress .. "%", isMenuHeader = true },
        { header = "Stored Earnings: $" .. jobRep.payment, icon = "fas fas fa-wallet", isMenuHeader = true },
    }

    if jobRep.payment > 0 then
        table.insert(jobMenu, { header = "Collect Earnings", icon = "fas fa-money-bill", txt = "Withdraw your stored money", params = { event = "qb-electrac:client:collectEarnings" } })
    end

    if not isOnMission then
        table.insert(jobMenu, { header = "Start Work", icon = "fas fa-money-bill", txt = "Begin fixing electricity issues", params = { event = "qb-electrac:client:startjob" } })
    elseif not hasCompletedMission then
        table.insert(jobMenu, { header = "Cancel Job", icon = "fas fas fa-times", txt = "Cancel current job", params = { event = "qb-electrac:client:cancelJob" } })
    end

    if hasCompletedMission then
        table.insert(jobMenu, { header = "End Job", icon = "fas fa-check", txt = "Complete the job and receive your earnings", params = { event = "qb-electrac:client:endJob" } })
    end

    table.insert(jobMenu, { header = "Close", icon = "fas fa-times-circle", params = { event = "qb-menu:closeMenu" } })

    exports["qb-menu"]:openMenu(jobMenu)
end)


RegisterNetEvent("qb-electrac:client:collectEarnings", function()
    TriggerServerEvent("qb-electrac:server:collectEarnings")
end)


RegisterNetEvent("qb-electrac:client:updateJobRep", function(jobRep)
    local PlayerData = QBCore.Functions.GetPlayerData()
    PlayerData.metadata = PlayerData.metadata or {}
    PlayerData.metadata["jobrep"] = PlayerData.metadata["jobrep"] or {}
    PlayerData.metadata["jobrep"]["electrac"] = jobRep
    sendNotification("Your job progress has been updated! Grade: " .. jobRep.grade .. " | Progress: " .. jobRep.progress .. "%", "success")
end)



local activeMissions = {}

RegisterNetEvent("qb-electrac:client:startjob", function()
    if isOnMission then
        sendNotification("You are already on a job!", "error")
        return
    end

    if #activeMissions >= Config.maxMissions then
        sendNotification("You can't take more than " .. Config.maxMissions .. " missions at the same time!", "error")
        return
    end

    local missionLocation = Config.MissionLocations[math.random(1, #Config.MissionLocations)]
    print("Mission location chosen: " .. tostring(missionLocation))

    table.insert(activeMissions, missionLocation)

    local spawnCoords = Config.spawncar[math.random(1, #Config.spawncar)]
    
    local playerPed = PlayerPedId()
    local nearbyVehicle = GetClosestVehicle(spawnCoords.x, spawnCoords.y, spawnCoords.z, 3.0, 0, 71)
    if DoesEntityExist(nearbyVehicle) then
        sendNotification("The spawn area is blocked! Move the vehicle first.", "error")
        return
    end

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do Wait(500) end

    currentVehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    TaskWarpPedIntoVehicle(playerPed, currentVehicle, -1)
    local plate = "ELEC" .. math.random(100, 999)
    SetVehicleNumberPlateText(currentVehicle, plate)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)

    local missionNumber = math.random(1, 999)
    missionBlip = AddBlipForCoord(missionLocation.x, missionLocation.y, missionLocation.z)
    SetBlipSprite(missionBlip, 354)
    SetBlipColour(missionBlip, 1)
    SetBlipScale(missionBlip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Electricity Repair [#" .. missionNumber .. "]")
    EndTextCommandSetBlipName(missionBlip)

    repairZone = "electrac_repair_" .. math.random(1000, 9999)
    exports['qb-target']:AddBoxZone(repairZone, vector3(missionLocation.x, missionLocation.y, missionLocation.z), 1.5, 1.5, {
        name = repairZone,
        heading = missionLocation.w,
        debugPoly = Config.DebugPoly,
        minZ = missionLocation.z - 1,
        maxZ = missionLocation.z + 1,
    }, {
        options = {
            {
                type = "client",
                event = "qb-electrac:client:repairElectricity",
                icon = "fas fa-bolt",
                label = "Repair Electricity",
            },
        },
        distance = 2.0
    })

    sendNotification("Drive to the marked location and fix the electricity issue.", "primary")
    isOnMission = true
end)


RegisterNetEvent("qb-electrac:client:repairElectricity", function()
    if not isOnMission then
        sendNotification("You are not on a job!", "error")
        return
    end

    if hasCompletedMission then
        sendNotification("You have already repaired this!", "error")
        return
    end

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
    QBCore.Functions.Progressbar("repair_electricity", "Repairing Electricity...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasks(playerPed)
        hasCompletedMission = true
        sendNotification("Electricity issue fixed! Return to the manager.", "success")

        if repairZone then
            exports['qb-target']:RemoveZone(repairZone)
            repairZone = nil
        end

        if missionBlip then
            RemoveBlip(missionBlip)
            missionBlip = nil
        end

        local PlayerData = QBCore.Functions.GetPlayerData()
        local jobRep = PlayerData.metadata["jobrep"] and PlayerData.metadata["jobrep"]["electrac"] or { grade = 1, progress = 0 }

        jobRep.progress = jobRep.progress + Config.ProgressPerRepair 

        if jobRep.progress >= 100 then
            jobRep.grade = jobRep.grade + 1
            jobRep.progress = 0 
            sendNotification("Congratulations! You have been promoted to Grade " .. jobRep.grade .. "!", "success")
        end

        TriggerServerEvent("qb-electrac:server:updateJobRep", jobRep)

    end, function()
        ClearPedTasks(playerPed)
        sendNotification("Repair failed!", "error")
    end)
end)



RegisterNetEvent("qb-electrac:client:endJob", function()
    if not isOnMission then
        sendNotification("You haven't started any job yet!", "error")
        return
    end

    if hasCompletedMission then
        sendNotification("Job completed! Your earnings have been stored.", "success")
        TriggerServerEvent("qb-electrac:server:payReward")
    else
        sendNotification("You haven't completed any repairs yet!", "error")
        return
    end

    if missionBlip then
        RemoveBlip(missionBlip)
        missionBlip = nil
    end

    if currentVehicle then
        DeleteEntity(currentVehicle)
        currentVehicle = nil
    end

    hasCompletedMission = false
    isOnMission = false
end)


RegisterNetEvent("qb-electrac:client:cancelJob", function()
    if isOnMission then
        if currentVehicle then
            DeleteEntity(currentVehicle)
            currentVehicle = nil
        end
        if missionBlip then
            RemoveBlip(missionBlip)
            missionBlip = nil
        end
        if repairZone then
            exports['qb-target']:RemoveZone(repairZone)
            repairZone = false
        end
        sendNotification("Job cancelled. You can start a new job anytime.", "error")
        isOnMission = false
        hasCompletedMission = false
    end
end)
