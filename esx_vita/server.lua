local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
AddEventHandler('onResourceStart', function(resourceName) if resourceName ~= nil then print("Script created by zThundy__") end end)

RegisterServerEvent("esx_vita:saveVita")
AddEventHandler("esx_vita:saveVita", function(vita)
    local player = source
    local identifier = GetPlayerIdentifier(player, 0)

    if player ~= nil then
        vita = vita - 100
        if vita < 0 then
            vita = 0
        end
        if vita ~= nil and vita >= 0 then
            MySQL.Async.execute("UPDATE users SET vita = @vita WHERE identifier = @identifier", {['@vita'] = vita, ['@identifier'] = identifier})
        end
    end
end)

ESX.RegisterServerCallback('esx_vita:getVita', function(source, cb)
    local player = source
    local identifier = GetPlayerIdentifier(player, 0)

    if identifier ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier}, function(result)
            if result[1] ~= nil then
                local table = {vita = tonumber(result[1].vita), player = player}
                cb(table)
            end
        end)
    end
end)

ESX.RegisterServerCallback('esx_vita:pulisciInventario', function(source, cb)
    local player = source
	local xPlayer = ESX.GetPlayerFromId(player)

	if cfg.pulisciSoldi then
		if xPlayer.getMoney() > 0 then
			xPlayer.removeMoney(xPlayer.getMoney())
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0)
		end
	end

	if cfg.pulisciInventario then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	local armi = {}
	if cfg.pulisciArmi then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else
		for i=1, #xPlayer.loadout, 1 do
			table.insert(armi, xPlayer.loadout[i])
		end

        SetTimeout(5000, function()
            for i = 1, #armi, 1 do
                if armi[i].label ~= nil then
                    xPlayer.addWeapon(armi[i].name, armi[i].ammo)
                end
            end
        end)
    end

	cb()
end)
