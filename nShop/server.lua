ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local playerBasket = {}
local totalBasket = 0

RegisterNetEvent("nShop:buyItem")
AddEventHandler("nShop:buyItem", function(data)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    table.insert(playerBasket, {
        label = data.label,
        price = data.price,
        item = data.item,
    })
    TriggerClientEvent("esx:showNotification", _src, "Vous avez ajoutez ~b~"..data.label.."~s~ dans votre panier")
end)

ESX.RegisterServerCallback("nShop:getPlayerBasket", function(source, cb)
    cb(playerBasket)
end)

ESX.RegisterServerCallback("nShop:getTotalBasket", function(source, cb)
    totalBasket = 0
    for k, v in pairs(playerBasket) do
        totalBasket = totalBasket + v.price
    end
    cb(totalBasket)
end)

RegisterNetEvent("nShop:removeItem")
AddEventHandler("nShop:removeItem", function(data)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    table.remove(playerBasket, data)
end)

RegisterNetEvent("nShop:validateBasket")
AddEventHandler("nShop:validateBasket", function(type)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    if type == 1 then
        if xPlayer.getMoney() >= totalBasket then
            xPlayer.removeMoney(totalBasket)
            for k, v in pairs(playerBasket) do
                xPlayer.addInventoryItem(v.item, 1)
            end
            TriggerClientEvent("esx:showNotification", _src, "Vous avez payé ~g~"..totalBasket.."$~s~")
            playerBasket = {}
            totalBasket = 0
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'avez pas assez d'argent sur vous")
        end
    else
        if xPlayer.getAccount('bank').money >= totalBasket then
            xPlayer.removeMoney(totalBasket)
            for k, v in pairs(playerBasket) do
                xPlayer.addInventoryItem(v.item, 1)
            end
            TriggerClientEvent("esx:showNotification", _src, "Vous avez payé ~g~"..totalBasket.."$~s~")
            playerBasket = {}
            totalBasket = 0
        else
            TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'avez pas assez d'argent sur vous")
        end
    end
end)
