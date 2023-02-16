QBCore = exports['qb-core']:GetCoreObject()

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

