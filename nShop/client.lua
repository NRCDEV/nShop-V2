ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local isMenuOpen = false
local playerBasket = {}
local totalBasket = 0

local main_menu = RageUI.CreateMenu("Superette", "Intéraction")
local food_menu = RageUI.CreateSubMenu(main_menu, "Superette", "Nourritures")
local water_menu = RageUI.CreateSubMenu(main_menu, "Superette", "Boissons")
local divers_menu = RageUI.CreateSubMenu(main_menu, "Superette", "Divers")
local basket_menu = RageUI.CreateSubMenu(main_menu, "Superette", "Votre panier")
main_menu.Closed = function ()
    isMenuOpen = false
end

local paidList = {
    type = {"~g~Liquide~s~", "~b~Banque~s~"},
    list = 1
}

function OpenShop()
    ESX.TriggerServerCallback("nShop:getPlayerBasket", function(result)
        playerBasket = result
    end)
    ESX.TriggerServerCallback("nShop:getTotalBasket", function(result)
        totalBasket = result
    end)
    if not isMenuOpen then
        isMenuOpen = true
        RageUI.Visible(main_menu, true)
        while isMenuOpen do
            RageUI.IsVisible(main_menu, function()
                RageUI.Button("Nourritures", nil, {RightLabel = "→→"}, true, {}, food_menu)
                RageUI.Button("Boissons", nil, {RightLabel = "→→"}, true, {}, water_menu)
                RageUI.Button("Divers", nil, {RightLabel = "→→"}, true, {}, divers_menu)
                RageUI.Line()
                RageUI.Button("Votre panier (~r~"..#playerBasket.."~s~)", nil, {RightLabel = "→→"}, true, {
                    onSelected = function()
                        totalBasket = 0
                        ESX.TriggerServerCallback("nShop:getTotalBasket", function(result)
                            totalBasket = result
                        end)
                    end
                }, basket_menu)
            end)

            RageUI.IsVisible(food_menu, function()
                for k, v in pairs(Config.FoodItems) do
                    RageUI.Button(v.label.." - [~g~"..v.price.."$~s~]", nil, {RightLabel = "→"}, true, {
                        onSelected = function()
                            TriggerServerEvent("nShop:buyItem", v)
                            ESX.TriggerServerCallback("nShop:getPlayerBasket", function(result)
                                playerBasket = result
                            end)
                        end
                    })
                end
            end)

            RageUI.IsVisible(water_menu, function()
                for k, v in pairs(Config.BoissonItems) do
                    RageUI.Button(v.label.." - [~g~"..v.price.."$~s~]", nil, {RightLabel = "→"}, true, {
                        onSelected = function()
                            TriggerServerEvent("nShop:buyItem", v)
                            ESX.TriggerServerCallback("nShop:getPlayerBasket", function(result)
                                playerBasket = result
                            end)
                            
                        end
                    })
                end
            end)

            RageUI.IsVisible(divers_menu, function()
                for k, v in pairs(Config.DiversItem) do
                    RageUI.Button(v.label.." - [~g~"..v.price.."$~s~]", nil, {RightLabel = "→"}, true, {
                        onSelected = function()
                            TriggerServerEvent("nShop:buyItem", v)
                            ESX.TriggerServerCallback("nShop:getPlayerBasket", function(result)
                                playerBasket = result
                            end)
                            
                        end
                    })
                end
            end)

            RageUI.IsVisible(basket_menu, function()
                if #playerBasket >= 1 then
                    RageUI.Separator("Total à payer : [~g~"..totalBasket.."$~s~]")
                    RageUI.Line()
                    for k, v in pairs(playerBasket) do
                        RageUI.Button(v.label.." - [~g~"..v.price.."$~s~]", "Appuyer sur ~r~[ENTRER]~s~ pour retirer du panier", {RightLabel = "→"}, true, {
                            onSelected = function()
                                TriggerServerEvent("nShop:removeItem", k)
                                ESX.TriggerServerCallback("nShop:getPlayerBasket", function(result)
                                    playerBasket = result
                                end)
                                ESX.TriggerServerCallback("nShop:getTotalBasket", function(result)
                                    totalBasket = result
                                end)
                            end
                        })
                    end 
                    RageUI.Line()
                    RageUI.List("Valider le panier", paidList.type, paidList.list, nil, {}, true, {
                        onListChange = function(Index, Item)
                            paidList.list = Index
                        end,
                        onSelected = function(Index)
                            print(Index)
                            TriggerServerEvent("nShop:validateBasket", Index)
                            ESX.TriggerServerCallback("nShop:getPlayerBasket", function(result)
                                playerBasket = result
                            end)
                            ESX.TriggerServerCallback("nShop:getTotalBasket", function(result)
                                totalBasket = result
                            end)
                        end
                    })
                else
                    RageUI.Separator("")
                    RageUI.Separator("~r~Votre panier est vide")
                    RageUI.Separator("")
                end
            end)
            Wait(1)
        end
    end
end

CreateThread(function()
    while true do
        local InZone = false
        local playerPos = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.ShopPos) do
            local distance = GetDistanceBetweenCoords(playerPos, v.pos.x, v.pos.y, v.pos.z, true)
            if distance < 10 then
                DrawMarker(25, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 200, 0, 1, 2, 0, nil, nil, 0)
                InZone = true
                if distance < 2 then
                    Visual.Subtitle("Appuyer sur ~r~[E]~s~ pour accéder au shop", 1)
                    if IsControlJustPressed(1, 38) then
                        OpenShop()
                    end
                end
            end
        end
        if not InZone then
            Wait(500)
        else
            Wait(1)
        end
    end
end)