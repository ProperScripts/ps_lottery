QBCore = exports['qb-core']:GetCoreObject()

-- Version checker
local currentv = GetResourceMetadata(GetCurrentResourceName(), "version")
CreateThread(function()
    Citizen.Wait(5000)
    PerformHttpRequest("https://api.github.com/repos/properscripts/ps_lottery/releases/latest", CheckVersion, "GET")

    local LoadFile = LoadResourceFile(GetCurrentResourceName(), "./amount.json")
    local jsonData = json.decode(LoadFile)
    if jsonData == nil then
        jsonData = {}
    end
    for k, v in pairs(Config.Tickets) do
        if QBCore.Shared.Items[k] ~= nil then
            if jsonData[k] == nil then
                jsonData[k] = v.StartPrice
            end
            if Config.WipeOnRestart then
                jsonData[k] = v.StartPrice
            end
        end
    end
    local updatedData = json.encode(jsonData)
    SaveResourceFile(GetCurrentResourceName(), "./amount.json", updatedData, -1)
end)

CheckVersion = function(err, responseText, headers)
    local repoVersion, repoURL, repoBody = GetRepoInformations()

    CreateThread(function()
        if currentv ~= repoVersion then
            print("[^1WARNING^0] You do not have the latest ps_lottery version installed!")
            print("[^1WARNING^0] Your Version: ^1" .. currentv .. "^0")
            print("[^1WARNING^0] Latest Version: ^2" .. repoVersion .. "^0")
            print("[^1WARNING^0] Get the latest version from: ^3" .. repoURL .. "^0")
        end
    end)
end

GetRepoInformations = function()
    local repoVersion, repoURL, repoBody = nil, nil, nil

    PerformHttpRequest("https://api.github.com/repos/properscripts/ps_lottery/releases/latest", function(err, response, headers)
        if err == 200 then
            local data = json.decode(response)

            repoVersion = data.name
            repoURL = data.html_url
            repoBody = data.body
        else
            repoVersion = curVersion
            repoURL = "https://github.com/properscripts/ps_lottery"
        end
    end, "GET")

    repeat
        Wait(50)
    until (repoVersion and repoURL and repoBody)

    return repoVersion, repoURL, repoBody
end

Citizen.CreateThread(function()
    for k,v in pairs (Config.Tickets) do
        QBCore.Functions.AddItem(k, {
            name = k,
            label = v.Label,
            weight = 10,
            type = 'item',
            image = 'lotteryticket.png',
            unique = false,
            useable = true,
            shouldClose = true,
            combinable = nil,
            description = 'Test your luck with these Lottery Tickets!'
        })
    end

    for k, v in pairs(Config.Tickets) do
        if QBCore.Shared.Items[k] ~= nil then
            QBCore.Functions.CreateUseableItem(k, function(source, item)
                local Player = QBCore.Functions.GetPlayer(source)
                if Player.Functions.RemoveItem(item.name, 1, item.slot) then
                    local won = math.random(1,100) < v.winChance
                    local taxpercent = 0
                    local paytax = 0

                    local LoadFile = LoadResourceFile(GetCurrentResourceName(), "./amount.json")
                    local jsonData = json.decode(LoadFile)

                    if Config.DebugJson then
                        DebugJson(jsonData)
                    end
                    local price = jsonData[k]

                    if not won then
                        price = price + v.increasePrice
                        -- Changed the notify event to be server sided
                        PSNotify(source, "You lost, the new price pot is now $" .. price, "error")
                    end

                    if won then
                        if Config.MoneyAsItem then
                            Player.Functions.AddItem(Config.MoneyType, price)
                            -- Enables the AP Government stuff if you have it toggled true
                            if Config.APGov then
                                taxpercent = Config.TaxPercent
                                paytax = price * (taxpercent / 100)
                                exports['ap-government']:chargeCityTax(source, "Lottery", paytax, Config.MoneyType)
                            end
                        else
                            Player.Functions.AddMoney(Config.MoneyType, price)

                            if Config.APGov then
                                taxpercent = Config.TaxPercent
                                paytax = price * (taxpercent / 100)
                                exports['ap-government']:chargeCityTax(source, "Lottery", paytax, Config.MoneyType)
                            end
                        end

                        PSNotify(source, "You Won $"..price.."!", "success")
                        price = v.StartPrice
                    end

                    jsonData[k] = price
                    local updatedData = json.encode(jsonData)
                    SaveResourceFile(GetCurrentResourceName(), "./amount.json", updatedData, -1)
                end
            end)
        else
            print("^4PS_LOTTERY^7: Cannot find ^4" .. k .. "^7 in ^4Shared/Items.lua")
        end
    end
end)



function PSNotify(src,msg,type,time)
    if not time then
        time = 5000
    end
    if Config.Notify == 'qb' then
        TriggerClientEvent("QBCore:Notify", src, msg, type,time)
    elseif Config.Notify == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src,msg,time,type)
    elseif Config.Notify == 'qs' then
        TriggerClientEvent('qs-notify:Alert', src, msg, time, type)
    end
end

function DebugJson(jsonData)
    if not jsonData then return end
    for k,v in pairs(jsonData) do
        print("Item = "..k.." Price = "..v.." !")
    end
end
