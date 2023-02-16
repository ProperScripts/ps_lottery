QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ps_lotery:client:useticket', function (won, price)
    if won then
        QBCore.Functions.Notify('You won $' .. price ..'!', 'success', 5000)
    else
        QBCore.Functions.Notify('You lost, the new price pot is now $' .. price, 'error', 5000)
    end
end)
