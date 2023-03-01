QBCore = exports['qb-core']:GetCoreObject()

-- Version checker
local currentv = GetResourceMetadata(GetCurrentResourceName(), "version")

CreateThread(function()
    Citizen.Wait(5000)
    PerformHttpRequest("https://api.github.com/repos/properscripts/ps_lottery/releases/latest", CheckVersion, "GET")
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

            repoVersion = data.tag_name
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
    exports['qb-core']:AddItem('ticket', {
        name = 'ticket',
        label = 'Lottery Ticket',
        weight = 10,
        type = 'item',
        image = 'stickynote.png',
        unique = false,
        useable = true,
        shouldClose = true,
        combinable = nil,
        description = 'Test your luck with these Lottery Tickets!'
    })
end)

QBCore.Functions.CreateUseableItem("ticket", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        local won = math.random() < Config.winChance
        local loadFile = LoadResourceFile(GetCurrentResourceName(), "./amount.json") --> read amount.json
        local price = json.decode(loadFile).price --> Decode amount.json and get the current price
        if not won then --> If the player didn't win, increase the new price pot
            price = price + Config.increasePrice
        end
        TriggerClientEvent("ps_lotery:client:useticket", source, won, price)
        if won then --> If the player won, give him the money and reset the price pot
            Player.Functions.AddMoney(Config.type, price)
            price = Config.StartPrice
        end
        local newTable = {price = price}
        SaveResourceFile(GetCurrentResourceName(), "./amount.json", json.encode(newTable), -1) --> Save the new amount to amount.json
    end
end)

