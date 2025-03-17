local SCRIPT_VERSION = "1.0.0"
local GITHUB_REPO = "https://github.com/ise9p/qb-gym"
local UPDATE_URL = GITHUB_REPO .. "/raw/main/version.txt"
local CHANGELOG_URL = GITHUB_REPO .. "/raw/main/changelog.txt"

--## Display Script Information on Server Start
CreateThread(function()
    Wait(1000) 
    print("^3============================================^0")
    print("^5 qb-gym Script Information ^0")
    print("^3 Version:^0 " .. SCRIPT_VERSION)
    print("^3 GitHub Repository:^0 " .. GITHUB_REPO)
    print("^3============================================^0")
end)

--## Check for Updates
CreateThread(function()
    PerformHttpRequest(UPDATE_URL, function(err, version, headers)
        if err == 200 and version then
            local latestVersion = version:gsub("\n", ""):gsub("\r", "")
            if latestVersion ~= SCRIPT_VERSION then
                print("^1[UPDATE] A new version is available: " .. latestVersion .. "! Please update from: " .. GITHUB_REPO .. "^0")

                -- Fetch and display changelog
                PerformHttpRequest(CHANGELOG_URL, function(err2, changelog, headers2)
                    if err2 == 200 and changelog then
                        print("^3=========== 🆕 CHANGELOG 🆕 ===========^0")
                        print(changelog)
                        print("^3====================================^0")
                    else
                        print("^1[ERROR] Failed to fetch the changelog!^0")
                    end
                end, "GET", "", {})

            else
                print("^2[INFO] You have the latest version of the script!^0")
            end
        else
            --print("^1[ERROR] Failed to fetch update information!^0")
        end
    end, "GET", "", {})
end)
