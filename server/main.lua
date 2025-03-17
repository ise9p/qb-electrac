local QBCore = exports['qb-core']:GetCoreObject()
local WebhookURL = Config.WebHook

RegisterNetEvent("qb-electrac:server:payReward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("[qb-electrac] Error: Player not found!")
        return
    end

    local metadata = Player.PlayerData.metadata or {}
    metadata["jobrep"] = metadata["jobrep"] or {}
    metadata["jobrep"]["electrac"] = metadata["jobrep"]["electrac"] or { grade = 1, progress = 0, payment = 0 }

    local jobRep = metadata["jobrep"]["electrac"]
    local grade = jobRep.grade or 1

    local gradeReward = Config.gradeRewards[grade] or { min = 150, max = 300 }
    local rewardAmount = math.random(gradeReward.min, gradeReward.max)

    jobRep.payment = (jobRep.payment or 0) + rewardAmount

    local extraBonus = 0
    if grade >= 5 then
        extraBonus = Config.baseExtraBonus + (grade * Config.extraBonusPerGrade)
        jobRep.payment = jobRep.payment + extraBonus
        TriggerClientEvent("QBCore:Notify", src, "Bonus $" .. extraBonus .. " stored for your high rank!", "success")
    end

    local bonusItem, bonusAmount = nil, 0
    if Config.giveBonusItem and Config.bonusItem then
        bonusItem = Config.bonusItem
        bonusAmount = Config.bonusAmount or 1
        if Player.Functions.AddItem(bonusItem, bonusAmount) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[bonusItem], "add")
            TriggerClientEvent("QBCore:Notify", src, "You received a bonus item: " .. bonusItem, "success")
        else
            print("[qb-electrac] Warning: Failed to give bonus item (" .. bonusItem .. ") to player " .. src)
        end
    end

    Player.Functions.SetMetaData("jobrep", metadata["jobrep"])

    TriggerClientEvent("QBCore:Notify", src, "Your job earnings have been stored: $" .. rewardAmount, "success")

    SendRewardToDiscord(Player, rewardAmount, "stored", bonusItem, bonusAmount, extraBonus)
end)


RegisterNetEvent("qb-electrac:server:collectEarnings", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("[qb-electrac] Error: Player not found!")
        return
    end

    local metadata = Player.PlayerData.metadata or {}
    metadata["jobrep"] = metadata["jobrep"] or {}
    metadata["jobrep"]["electrac"] = metadata["jobrep"]["electrac"] or { grade = 1, progress = 0, payment = 0 }

    local storedPayment = metadata["jobrep"]["electrac"].payment or 0

    if storedPayment > 0 then
        Player.Functions.AddMoney(Config.paymentMethod or "cash", storedPayment, "Electrician Job Payout")

        metadata["jobrep"]["electrac"].payment = 0
        Player.Functions.SetMetaData("jobrep", metadata["jobrep"])

        TriggerClientEvent("QBCore:Notify", src, "You collected $" .. storedPayment .. "!", "success")

        SendRewardToDiscord(Player, storedPayment, Config.paymentMethod or "cash", nil, 0, 0)
    else
        TriggerClientEvent("QBCore:Notify", src, "No earnings to collect!", "error")
    end
end)

RegisterNetEvent("qb-electrac:server:updateJobRep", function(jobRep)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then

        local metadata = Player.PlayerData.metadata or {}
        metadata["jobrep"] = metadata["jobrep"] or {}

        metadata["jobrep"]["electrac"] = metadata["jobrep"]["electrac"] or { grade = 1, progress = 0 }


        metadata["jobrep"]["electrac"].grade = jobRep.grade
        metadata["jobrep"]["electrac"].progress = jobRep.progress

        Player.Functions.SetMetaData("jobrep", metadata["jobrep"])

        TriggerClientEvent("qb-electrac:client:updateJobRep", src, metadata["jobrep"]["electrac"])

        SendToDiscord(Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, jobRep.grade, jobRep.progress)
    end
end)


function SendToDiscord(playerName, grade, progress)
    if not WebhookURL or WebhookURL == "" then return end 

    local embedData = {
        {
            ["color"] = 3066993,
            ["title"] = "🔧 Job Progress Update",
            ["description"] = "**Player:** " .. playerName .. "\n**Grade:** " .. grade .. "\n**Progress:** " .. progress .. "%",
            ["footer"] = { ["text"] = os.date("%Y-%m-%d %H:%M:%S") }
        }
    }

    PerformHttpRequest(WebhookURL, function(err, text, headers) end, "POST", json.encode({username = "Electrac Logs", embeds = embedData}), {["Content-Type"] = "application/json"})
end

function SendRewardToDiscord(Player, rewardAmount, paymentMethod, bonusItem, bonusAmount, extraBonus)
    if not WebhookURL or WebhookURL == "" then return end

    local embedData = {{
        ["title"] = "📜 Job Reward Log",
        ["color"] = 16753920,
        ["fields"] = {
            { name = "🆔 Player ID", value = tostring(Player.PlayerData.source), inline = true },
            { name = "👤 Player Name", value = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, inline = true },
            { name = "💵 Reward Amount", value = "$" .. rewardAmount, inline = true },
            { name = "🏦 Payment Method", value = paymentMethod, inline = true },
            { name = "🎁 Bonus Item", value = bonusItem and (bonusAmount .. "x " .. bonusItem) or "None", inline = true },
            { name = "🎖️ Extra Bonus", value = extraBonus > 0 and "$" .. extraBonus or "None", inline = true }
        },
        ["footer"] = { ["text"] = "Electrac Job System | " .. os.date("%Y-%m-%d %H:%M:%S") }
    }}

    PerformHttpRequest(WebhookURL, function(err, text, headers) end, "POST", json.encode({username = "Electrac Logs", embeds = embedData}), {["Content-Type"] = "application/json"})
end

