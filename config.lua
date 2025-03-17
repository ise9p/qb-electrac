Config = {}

Config.DebugPoly = false -- Enable Debug Poly

-- NPC Information
Config.PedModel = `a_m_m_business_01` -- Ped model
Config.PedCoords = vector4(287.98, -23.37, 74.47, 257.37) -- Ped location

Config.WebHook = "" -- Add your webhook URL here

Config.VehicleModel = `utillitruck3` -- Vehicle model
Config.spawncar = { -- Vehicle spawn location
    vector4(274.04, 6.06, 78.87, 247.49),
    vector4(273.41, 1.66, 78.84, 248.91),
    vector4(276.41, 9.87, 78.9, 246.0)
} 

Config.MissionLocations = {
    vector4(282.55, -32.66, 72.8, 138.69), -- Mission 1
    vector4(263.63, -20.01, 73.55, 340.71), -- Mission 2
    vector4(261.35, -19.29, 73.54, 335.35)  -- Mission 3
}

-- Set the minimum and maximum number of missions at once
Config.minMissions = 3
Config.maxMissions = 4

-- 📜 Job Information
Config.notify = "ox" -- You can change the notify between "ox" and "qb" depending on the framework you're using
Config.menu = "qb" -- You can change the menu between "ox" and "qb" depending on the framework you're using

-- 💰 Payment method: "cash" or "bank"
Config.paymentMethod = "cash" -- Payment type

Config.gradeRewards = { -- Rewards for each grade
    [1] = { min = 150, max = 300 },
    [2] = { min = 200, max = 350 },
    [3] = { min = 250, max = 400 },
    [4] = { min = 300, max = 450 },
    [5] = { min = 350, max = 500 },
    [6] = { min = 400, max = 550 },
    [7] = { min = 450, max = 600 },
    [8] = { min = 500, max = 650 },
    [9] = { min = 550, max = 700 },
    [10] = { min = 600, max = 750 }
}

Config.extraBonusPerGrade = 5 -- Additional bonus per level after level 5
Config.baseExtraBonus = 50 -- Base extra bonus for higher levels

-- 🎁 Bonus item when completing the mission
Config.giveBonusItem = false  -- Do you want to give an extra item?
Config.bonusItem = "phone" -- Name of the bonus item
Config.bonusAmount = 1 -- Number of items given

-- 🏆 Extra bonus when reaching a certain rank
Config.extraBonus = 50 -- Extra bonus value when ranked up

-- 📈 Player progress
Config.ProgressPerRepair = 0.5    -- Amount of progress after each repair
Config.xpThreshold = 100  -- Maximum progress before promotion
