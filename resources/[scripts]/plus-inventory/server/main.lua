--#region Variables

local PlusCore = exports['plus-core']:GetCore()
local Drops = {}
local Trunks = {}
local Gloveboxes = {}
local Stashes = {}
local ShopItems = {}

--#endregion Variables
--print(json.encode(PlusCore))

--#region Functions

---Loads the inventory for the player with the citizenid that is provided
---@param source number Source of the player
---@param citizenid string CitizenID of the player
---@return { [number]: { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } } loadedInventory Table of items with slot as index
local function LoadInventory(source, citizenid)
    local inventory = MySQL.prepare.await('SELECT inventory FROM players WHERE citizenid = ?', { citizenid })
	local loadedInventory = {}
    local missingItems = {}

    if not inventory then return loadedInventory end

	inventory = json.decode(inventory)
	if table.type(inventory) == "empty" then return loadedInventory end

	for _, item in pairs(inventory) do
		if item then
			local itemInfo = PlusCore.Shared.Items[item.name:lower()]
			if itemInfo then
				loadedInventory[item.slot] = {
					name = itemInfo['name'],
					amount = item.amount,
					info = item.info or '',
					label = itemInfo['label'],
					description = itemInfo['description'] or '',
					weight = itemInfo['weight'],
					type = itemInfo['type'],
					unique = itemInfo['unique'],
					useable = itemInfo['useable'],
					image = itemInfo['image'],
					shouldClose = itemInfo['shouldClose'],
					slot = item.slot,
					combinable = itemInfo['combinable']
				}
			else
				missingItems[#missingItems + 1] = item.name:lower()
			end
		end
	end

    if #missingItems > 0 then
        print(("The following items were removed for player %s as they no longer exist"):format(GetPlayerName(source)))
    end

    return loadedInventory
end

exports("LoadInventory", LoadInventory)

---Saves the inventory for the player with the provided source or UserData is they're offline
---@param source number | table Source of the player, if offline, then provide the UserData in this argument
---@param offline boolean Is the player offline or not, if true, it will expect a table in source
local function SaveInventory(source, offline)
	local UserData
	if not offline then
		local Player = PlusCore.func.GetPlayer(source)

		if not Player then return end

		UserData = Player.UserData
	else
		UserData = source -- for offline users, the UserData gets sent over the source variable
	end

    local items = UserData.items
    local ItemsJson = {}
    if items and table.type(items) ~= "empty" then
        for slot, item in pairs(items) do
            if items[slot] then
                ItemsJson[#ItemsJson+1] = {
                    name = item.name,
                    amount = item.amount,
                    info = item.info,
                    type = item.type,
                    slot = slot,
                }
            end
        end
        MySQL.prepare('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode(ItemsJson), UserData.citizenid })
    else
        MySQL.prepare('UPDATE players SET inventory = ? WHERE citizenid = ?', { '[]', UserData.citizenid })
    end
end

exports("SaveInventory", SaveInventory)

---Gets the totalweight of the items provided
---@param items { [number]: { amount: number, weight: number } } Table of items, usually the inventory table of the player
---@return number weight Total weight of param items
local function GetTotalWeight(items)
	local weight = 0
    if not items then return 0 end
    for _, item in pairs(items) do
        weight += item.weight * item.amount
    end
    return tonumber(weight)
end

exports("GetTotalWeight", GetTotalWeight)

---Gets the slots that the provided item is in
---@param items { [number]: { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } } Table of items, usually the inventory table of the player
---@param itemName string Name of the item to the get the slots from
---@return number[] slotsFound Array of slots that were found for the item
local function GetSlotsByItem(items, itemName)
    local slotsFound = {}
    if not items then return slotsFound end
    for slot, item in pairs(items) do
        if item.name:lower() == itemName:lower() then
            slotsFound[#slotsFound+1] = slot
        end
    end
    return slotsFound
end

exports("GetSlotsByItem", GetSlotsByItem)

---Get the first slot where the item is located
---@param items { [number]: { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } } Table of items, usually the inventory table of the player
---@param itemName string Name of the item to the get the slot from
---@return number | nil slot If found it returns a number representing the slot, otherwise it sends nil
local function GetFirstSlotByItem(items, itemName)
    if not items then return nil end
    for slot, item in pairs(items) do
        if item.name:lower() == itemName:lower() then
            return tonumber(slot)
        end
    end
    return nil
end

exports("GetFirstSlotByItem", GetFirstSlotByItem)

---Add an item to the inventory of the player
---@param source number The source of the player
---@param item string The item to add to the inventory
---@param amount? number The amount of the item to add
---@param slot? number The slot to add the item to
---@param info? table Extra info to add onto the item to use whenever you get the item
---@return boolean success Returns true if the item was added, false it the item couldn't be added
local function AddItem(source, item, amount, slot, info)
	local Player = PlusCore.func.GetPlayer(source)

	if not Player then return false end

	local totalWeight = GetTotalWeight(Player.UserData.items)
	local itemInfo = PlusCore.Shared.Items[item:lower()]
	if not itemInfo and not Player.Offline then
		PlusCore.func.Notify(source, "Item does not exist", 'error')
		return false
	end

	amount = tonumber(amount) or 1
	slot = tonumber(slot) or GetFirstSlotByItem(Player.UserData.items, item)
	info = info or {}

	if itemInfo['type'] == 'weapon' then
		info.serie = info.serie or tostring(PlusCore.Shared.RandomInt(2) .. PlusCore.Shared.RandomStr(3) .. PlusCore.Shared.RandomInt(1) .. PlusCore.Shared.RandomStr(2) .. PlusCore.Shared.RandomInt(3) .. PlusCore.Shared.RandomStr(4))
		info.quality = info.quality or 100
	end
	if (totalWeight + (itemInfo['weight'] * amount)) <= Config.MaxInventoryWeight then
		if (slot and Player.UserData.items[slot]) and (Player.UserData.items[slot].name:lower() == item:lower()) and (itemInfo['type'] == 'item' and not itemInfo['unique']) then
			Player.UserData.items[slot].amount = Player.UserData.items[slot].amount + amount
			Player.Functions.SetUserData("items", Player.UserData.items)

			if Player.Offline then return true end

			TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. Player.UserData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. Player.UserData.items[slot].amount)

			return true
		elseif not itemInfo['unique'] and slot or slot and Player.UserData.items[slot] == nil then
			Player.UserData.items[slot] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = slot, combinable = itemInfo['combinable'] }
			Player.Functions.SetUserData("items", Player.UserData.items)

			if Player.Offline then return true end

			TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. Player.UserData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. Player.UserData.items[slot].amount)

			return true
		elseif itemInfo['unique'] or (not slot or slot == nil) or itemInfo['type'] == 'weapon' then
			for i = 1, Config.MaxInventorySlots, 1 do
				if Player.UserData.items[i] == nil then
					Player.UserData.items[i] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = i, combinable = itemInfo['combinable'] }
					Player.Functions.SetUserData("items", Player.UserData.items)

					if Player.Offline then return true end

					TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** got item: [slot:' .. i .. '], itemname: ' .. Player.UserData.items[i].name .. ', added amount: ' .. amount .. ', new total amount: ' .. Player.UserData.items[i].amount)

					return true
				end
			end
		end
	elseif not Player.Offline then
		PlusCore.func.Notify(source, "Inventory too full", 'error')
	end
	return false
end

exports("AddItem", AddItem)

---Remove an item from the inventory of the player
---@param source number The source of the player
---@param item string The item to remove from the inventory
---@param amount? number The amount of the item to remove
---@param slot? number The slot to remove the item from
---@return boolean success Returns true if the item was remove, false it the item couldn't be removed
local function RemoveItem(source, item, amount, slot)
	local Player = PlusCore.func.GetPlayer(source)

	if not Player then return false end

	amount = tonumber(amount) or 1
	slot = tonumber(slot)

	if slot then
		if Player.UserData.items[slot].amount > amount then
			Player.UserData.items[slot].amount = Player.UserData.items[slot].amount - amount
			Player.Functions.SetUserData("items", Player.UserData.items)

			if not Player.Offline then
				TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. Player.UserData.items[slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. Player.UserData.items[slot].amount)
			end

			return true
		elseif Player.UserData.items[slot].amount == amount then
			Player.UserData.items[slot] = nil
			Player.Functions.SetUserData("items", Player.UserData.items)

			if Player.Offline then return true end

			TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. item .. ', removed amount: ' .. amount .. ', item removed')

			return true
		end
	else
		local slots = GetSlotsByItem(Player.UserData.items, item)
		local amountToRemove = amount

		if not slots then return false end

		for _, _slot in pairs(slots) do
			if Player.UserData.items[_slot].amount > amountToRemove then
				Player.UserData.items[_slot].amount = Player.UserData.items[_slot].amount - amountToRemove
				Player.Functions.SetUserData("items", Player.UserData.items)

				if not Player.Offline then
					TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. _slot .. '], itemname: ' .. Player.UserData.items[_slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. Player.UserData.items[_slot].amount)
				end

				return true
			elseif Player.UserData.items[_slot].amount == amountToRemove then
				Player.UserData.items[_slot] = nil
				Player.Functions.SetUserData("items", Player.UserData.items)

				if Player.Offline then return true end

				TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'RemoveItem', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** lost item: [slot:' .. _slot .. '], itemname: ' .. item .. ', removed amount: ' .. amount .. ', item removed')

				return true
			end
		end
	end
	return false
end

exports("RemoveItem", RemoveItem)

---Get the item with the slot
---@param source number The source of the player to get the item from the slot
---@param slot number The slot to get the item from
---@return { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } | nil item Returns the item table, if there is no item in the slot, it will return nil
local function GetItemBySlot(source, slot)
	local Player = PlusCore.func.GetPlayer(source)
	slot = tonumber(slot)
	return Player.UserData.items[slot]
end

exports("GetItemBySlot", GetItemBySlot)

---Get the item from the inventory of the player with the provided source by the name of the item
---@param source number The source of the player
---@param item string The name of the item to get
---@return { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } | nil item Returns the item table, if the item wasn't found, it will return nil
local function GetItemByName(source, item)
	local Player = PlusCore.func.GetPlayer(source)
	item = tostring(item):lower()
	local slot = GetFirstSlotByItem(Player.UserData.items, item)
	return Player.UserData.items[slot]
end

exports("GetItemByName", GetItemByName)

---Get the item from the inventory of the player with the provided source by the name of the item in an array for all slots that the item is in
---@param source number The source of the player
---@param item string The name of the item to get
---@return { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table }[] item Returns an array of the item tables found, if the item wasn't found, it will return an empty table
local function GetItemsByName(source, item)
	local Player = PlusCore.func.GetPlayer(source)
	item = tostring(item):lower()
	local items = {}
	local slots = GetSlotsByItem(Player.UserData.items, item)
	for _, slot in pairs(slots) do
		if slot then
			items[#items+1] = Player.UserData.items[slot]
		end
	end
	return items
end

exports("GetItemsByName", GetItemsByName)

---Clear the inventory of the player with the provided source and filter any items out of the clearing of the inventory to keep (optional)
---@param source number Source of the player to clear the inventory from
---@param filterItems? string | string[] Array of item names to keep
local function ClearInventory(source, filterItems)
	local Player = PlusCore.func.GetPlayer(source)
	local savedItemData = {}

	if filterItems then
		local filterItemsType = type(filterItems)
		if filterItemsType == "string" then
			local item = GetItemByName(source, filterItems)

			if item then
				savedItemData[item.slot] = item
			end
		elseif filterItemsType == "table" and table.type(filterItems) == "array" then
			for i = 1, #filterItems do
				local item = GetItemByName(source, filterItems[i])

				if item then
					savedItemData[item.slot] = item
				end
			end
		end
	end

	Player.Functions.SetUserData("items", savedItemData)

	if Player.Offline then return end

	TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'ClearInventory', 'red', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** inventory cleared')
end

exports("ClearInventory", ClearInventory)

---Sets the items UserData to the provided items param
---@param source number The source of player to set it for
---@param items { [number]: { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } } Table of items, the inventory table of the player
local function SetInventory(source, items)
	local Player = PlusCore.func.GetPlayer(source)

	Player.Functions.SetUserData("items", items)

	if Player.Offline then return end

	TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'SetInventory', 'blue', '**' .. GetPlayerName(source) .. ' (citizenid: ' .. Player.UserData.citizenid .. ' | id: ' .. source .. ')** items set: ' .. json.encode(items))
end

exports("SetInventory", SetInventory)

---Set the data of a specific item
---@param source number The source of the player to set it for
---@param itemName string Name of the item to set the data for
---@param key string Name of the data index to change
---@param val any Value to set the data to
---@return boolean success Returns true if it worked
local function SetItemData(source, itemName, key, val)
	if not itemName or not key then return false end

	local Player = PlusCore.func.GetPlayer(source)

	if not Player then return end

	local item = GetItemByName(source, itemName)

	if not item then return false end

	item[key] = val
	Player.UserData.items[item.slot] = item
	Player.Functions.SetUserData("items", Player.UserData.items)

	return true
end

exports("SetItemData", SetItemData)

---Checks if you have an item or not
---@param source number The source of the player to check it for
---@param items string | string[] | table<string, number> The items to check, either a string, array of strings or a key-value table of a string and number with the string representing the name of the item and the number representing the amount
---@param amount? number The amount of the item to check for, this will only have effect when items is a string or an array of strings
---@return boolean success Returns true if the player has the item
local function HasItem(source, items, amount)
    local Player = PlusCore.func.GetPlayer(source)
    if not Player then return false end
    local isTable = type(items) == 'table'
    local isArray = isTable and table.type(items) == 'array' or false
    local totalItems = #items
    local count = 0
    local kvIndex = 2
    if isTable and not isArray then
        totalItems = 0
        for _ in pairs(items) do totalItems += 1 end
        kvIndex = 1
    end
    if isTable then
        for k, v in pairs(items) do
            local itemKV = {k, v}
            local item = GetItemByName(source, itemKV[kvIndex])
            if item and ((amount and item.amount >= amount) or (not isArray and item.amount >= v) or (not amount and isArray)) then
                count += 1
            end
        end
        if count == totalItems then
            return true
        end
    else -- Single item as string
        local item = GetItemByName(source, items)
        if item and (not amount or (item and amount and item.amount >= amount)) then
            return true
        end
    end
    return false
end

exports("HasItem", HasItem)

---Create a usable item with a callback on use
---@param itemName string The name of the item to make usable
---@param data any
local function CreateUsableItem(itemName, data)
	PlusCore.func.CreateUseableItem(itemName, data)
end

exports("CreateUsableItem", CreateUsableItem)

---Get the usable item data for the specified item
---@param itemName string The item to get the data for
---@return any usable_item
local function GetUsableItem(itemName)
	return PlusCore.func.CanUseItem(itemName)
end

exports("GetUsableItem", GetUsableItem)

---Use an item from the QBCore.UsableItems table if a callback is present
---@param itemName string The name of the item to use
---@param ... any Arguments for the callback, this will be sent to the callback and can be used to get certain values
local function UseItem(itemName, ...)
	local itemData = GetUsableItem(itemName)
	local callback = type(itemData) == 'table' and (rawget(itemData, '__cfx_functionReference') and itemData or itemData.cb or itemData.callback) or type(itemData) == 'function' and itemData
	if not callback then return end
	callback(...)
end

exports("UseItem", UseItem)

---Check if a recipe contains the item
---@param recipe table The recipe of the item
---@param fromItem { name: string, amount: number, info?: table, label: string, description: string, weight: number, type: string, unique: boolean, useable: boolean, image: string, shouldClose: boolean, slot: number, combinable: table } The item to check
---@return boolean success Returns true if the recipe contains the item
local function recipeContains(recipe, fromItem)
	for _, v in pairs(recipe.accept) do
		if v == fromItem.name then
			return true
		end
	end

	return false
end

---Checks if the provided source has the items to craft
---@param source number The source of the player to check it for
---@param CostItems table The item costs
---@param amount number The amount of the item to craft
local function hasCraftItems(source, CostItems, amount)
	for k, v in pairs(CostItems) do
		local item = GetItemByName(source, k)

		if not item then return false end

		if item.amount < (v * amount) then return false end
	end
	return true
end

---Checks if the vehicle with the provided plate is owned by any player
---@param plate string The plate to check
---@return boolean owned
local function IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate})
    return result
end

---Setup the shop items
---@param shopItems table
---@return table items
local function SetupShopItems(shopItems)
	local items = {}
	if shopItems and next(shopItems) then
		for _, item in pairs(shopItems) do
			local itemInfo = PlusCore.Shared.Items[item.name:lower()]
			if itemInfo then
				items[item.slot] = {
					name = itemInfo["name"],
					amount = tonumber(item.amount),
					info = item.info or "",
					label = itemInfo["label"],
					description = itemInfo["description"] or "",
					weight = itemInfo["weight"],
					type = itemInfo["type"],
					unique = itemInfo["unique"],
					useable = itemInfo["useable"],
					price = item.price,
					image = itemInfo["image"],
					slot = item.slot,
				}
			end
		end
	end
	return items
end

---Get items in a stash
----@param stashId string The id of the stash to get
----@return table items
local function GetStashItems(stashId)
	local items = {}
	local result = MySQL.scalar.await('SELECT items FROM stashitems WHERE stash = ?', {stashId})
	if not result then return items end

	local stashItems = json.decode(result)
	if not stashItems then return items end

	for _, item in pairs(stashItems) do
		local itemInfo = PlusCore.Shared.Items[item.name:lower()]
		if itemInfo then
			items[item.slot] = {
				name = itemInfo["name"],
				amount = tonumber(item.amount),
				info = item.info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = item.slot,
			}
		end
	end
	return items
end

---Save the items in a stash
---@param stashId string The stash id to save the items from
---@param items table items to save
local function SaveStashItems(stashId, items)
	if Stashes[stashId].label == "Stash-None" or not items then return end

	for _, item in pairs(items) do
		item.description = nil
	end

	MySQL.insert('INSERT INTO stashitems (stash, items) VALUES (:stash, :items) ON DUPLICATE KEY UPDATE items = :items', {
		['stash'] = stashId,
		['items'] = json.encode(items)
	})

	Stashes[stashId].isOpen = false
end

---Add items to a stash
---@param stashId string Stash id to save it to
---@param slot number Slot of the stash to save the item to
---@param otherslot number Slot of the stash to swap it to the item isn't unique
---@param itemName string The name of the item
---@param amount? number The amount of the item
---@param info? table The info of the item
local function AddToStash(stashId, slot, otherslot, itemName, amount, info)
	amount = tonumber(amount) or 1
	local ItemData = PlusCore.Shared.Items[itemName]
	if not ItemData.unique then
		if Stashes[stashId].items[slot] and Stashes[stashId].items[slot].name == itemName then
			Stashes[stashId].items[slot].amount = Stashes[stashId].items[slot].amount + amount
		else
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Stashes[stashId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	else
		if Stashes[stashId].items[slot] and Stashes[stashId].items[slot].name == itemName then
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Stashes[stashId].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = otherslot,
			}
		else
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Stashes[stashId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	end
end

---Remove the item from the stash
---@param stashId string Stash id to remove the item from
---@param slot number Slot to remove the item from
---@param itemName string Name of the item to remove
---@param amount? number The amount to remove
local function RemoveFromStash(stashId, slot, itemName, amount)
	amount = tonumber(amount) or 1
	if Stashes[stashId].items[slot] and Stashes[stashId].items[slot].name == itemName then
		if Stashes[stashId].items[slot].amount > amount then
			Stashes[stashId].items[slot].amount = Stashes[stashId].items[slot].amount - amount
		else
			Stashes[stashId].items[slot] = nil
		end
	else
		Stashes[stashId].items[slot] = nil
		if Stashes[stashId].items == nil then
			Stashes[stashId].items[slot] = nil
		end
	end
end

---Get the items in the trunk of a vehicle
---@param plate string The plate of the vehicle to check
---@return table items
local function GetOwnedVehicleItems(plate)
	local items = {}
	local result = MySQL.scalar.await('SELECT items FROM trunkitems WHERE plate = ?', {plate})
	if not result then return items end

	local trunkItems = json.decode(result)
	if not trunkItems then return items end

	for _, item in pairs(trunkItems) do
		local itemInfo = PlusCore.Shared.Items[item.name:lower()]
		if itemInfo then
			items[item.slot] = {
				name = itemInfo["name"],
				amount = tonumber(item.amount),
				info = item.info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = item.slot,
			}
		end
	end
	return items
end

---Save the items in a trunk
---@param plate string The plate to save the items from
---@param items table
local function SaveOwnedVehicleItems(plate, items)
	if Trunks[plate].label == "Trunk-None" or not items then return end

	for _, item in pairs(items) do
		item.description = nil
	end

	MySQL.insert('INSERT INTO trunkitems (plate, items) VALUES (:plate, :items) ON DUPLICATE KEY UPDATE items = :items', {
		['plate'] = plate,
		['items'] = json.encode(items)
	})

	Trunks[plate].isOpen = false
end

---Add items to a trunk
---@param plate string The plate of the car
---@param slot number Slot of the trunk to save the item to
---@param otherslot number Slot of the trunk to swap it to the item isn't unique
---@param itemName string The name of the item
---@param amount? number The amount of the item
---@param info? table The info of the item
local function AddToTrunk(plate, slot, otherslot, itemName, amount, info)
	amount = tonumber(amount) or 1
	local ItemData = PlusCore.Shared.Items[itemName]

	if not ItemData.unique then
		if Trunks[plate].items[slot] and Trunks[plate].items[slot].name == itemName then
			Trunks[plate].items[slot].amount = Trunks[plate].items[slot].amount + amount
		else
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Trunks[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	else
		if Trunks[plate].items[slot] and Trunks[plate].items[slot].name == itemName then
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Trunks[plate].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = otherslot,
			}
		else
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Trunks[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	end
end

---Remove the item from the trunk
---@param plate string plate of the car to remove the item from
---@param slot number Slot to remove the item from
---@param itemName string Name of the item to remove
---@param amount? number The amount to remove
local function RemoveFromTrunk(plate, slot, itemName, amount)
	amount = tonumber(amount) or 1
	if Trunks[plate].items[slot] and Trunks[plate].items[slot].name == itemName then
		if Trunks[plate].items[slot].amount > amount then
			Trunks[plate].items[slot].amount = Trunks[plate].items[slot].amount - amount
		else
			Trunks[plate].items[slot] = nil
		end
	else
		Trunks[plate].items[slot] = nil
		if Trunks[plate].items == nil then
			Trunks[plate].items[slot] = nil
		end
	end
end

---Get the items in the glovebox of a vehicle
---@param plate string The plate of the vehicle to check
---@return table items
local function GetOwnedVehicleGloveboxItems(plate)
	local items = {}
	local result = MySQL.scalar.await('SELECT items FROM gloveboxitems WHERE plate = ?', {plate})
	if not result then return items end

	local gloveboxItems = json.decode(result)
	if not gloveboxItems then return items end

	for _, item in pairs(gloveboxItems) do
		local itemInfo = PlusCore.Shared.Items[item.name:lower()]
		if itemInfo then
			items[item.slot] = {
				name = itemInfo["name"],
				amount = tonumber(item.amount),
				info = item.info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = item.slot,
			}
		end
	end
	return items
end

---Save the items in a glovebox
---@param plate string The plate to save the items from
---@param items table
local function SaveOwnedGloveboxItems(plate, items)
	if Gloveboxes[plate].label == "Glovebox-None" or not items then return end

	for _, item in pairs(items) do
		item.description = nil
	end

	MySQL.insert('INSERT INTO gloveboxitems (plate, items) VALUES (:plate, :items) ON DUPLICATE KEY UPDATE items = :items', {
		['plate'] = plate,
		['items'] = json.encode(items)
	})

	Gloveboxes[plate].isOpen = false
end

---Add items to a glovebox
---@param plate string The plate of the car
---@param slot number Slot of the glovebox to save the item to
---@param otherslot number Slot of the glovebox to swap it to the item isn't unique
---@param itemName string The name of the item
---@param amount? number The amount of the item
---@param info? table The info of the item
local function AddToGlovebox(plate, slot, otherslot, itemName, amount, info)
	amount = tonumber(amount) or 1
	local ItemData = PlusCore.Shared.Items[itemName]

	if not ItemData.unique then
		if Gloveboxes[plate].items[slot] and Gloveboxes[plate].items[slot].name == itemName then
			Gloveboxes[plate].items[slot].amount = Gloveboxes[plate].items[slot].amount + amount
		else
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Gloveboxes[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	else
		if Gloveboxes[plate].items[slot] and Gloveboxes[plate].items[slot].name == itemName then
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Gloveboxes[plate].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = otherslot,
			}
		else
			local itemInfo = PlusCore.Shared.Items[itemName:lower()]
			Gloveboxes[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	end
end

---Remove the item from the glovebox
---@param plate string Plate of the car to remove the item from
---@param slot number Slot to remove the item from
---@param itemName string Name of the item to remove
---@param amount? number The amount to remove
local function RemoveFromGlovebox(plate, slot, itemName, amount)
	amount = tonumber(amount) or 1
	if Gloveboxes[plate].items[slot] and Gloveboxes[plate].items[slot].name == itemName then
		if Gloveboxes[plate].items[slot].amount > amount then
			Gloveboxes[plate].items[slot].amount = Gloveboxes[plate].items[slot].amount - amount
		else
			Gloveboxes[plate].items[slot] = nil
		end
	else
		Gloveboxes[plate].items[slot] = nil
		if Gloveboxes[plate].items == nil then
			Gloveboxes[plate].items[slot] = nil
		end
	end
end

---Add an item to a drop
---@param dropId integer The id of the drop
---@param slot number The slot of the drop inventory to add the item to
---@param itemName string Name of the item to add
---@param amount? number The amount of the item to add
---@param info? table Extra info to add to the item
local function AddToDrop(dropId, slot, itemName, amount, info)
	amount = tonumber(amount) or 1
	Drops[dropId].createdTime = os.time()
	if Drops[dropId].items[slot] and Drops[dropId].items[slot].name == itemName then
		Drops[dropId].items[slot].amount = Drops[dropId].items[slot].amount + amount
	else
		local itemInfo = PlusCore.Shared.Items[itemName:lower()]
		Drops[dropId].items[slot] = {
			name = itemInfo["name"],
			amount = amount,
			info = info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = slot,
			id = dropId,
		}
	end
end

---Remove an item from a drop
---@param dropId integer The id of the drop to remove it from
---@param slot number The slot of the drop inventory
---@param itemName string The name of the item to remove
---@param amount? number The amount to remove
local function RemoveFromDrop(dropId, slot, itemName, amount)
	amount = tonumber(amount) or 1
	Drops[dropId].createdTime = os.time()
	if Drops[dropId].items[slot] and Drops[dropId].items[slot].name == itemName then
		if Drops[dropId].items[slot].amount > amount then
			Drops[dropId].items[slot].amount = Drops[dropId].items[slot].amount - amount
		else
			Drops[dropId].items[slot] = nil
		end
	else
		Drops[dropId].items[slot] = nil
		if Drops[dropId].items == nil then
			Drops[dropId].items[slot] = nil
		end
	end
end

---Creates a new id for a drop
---@return integer
local function CreateDropId()
	if Drops then
		local id = math.random(10000, 99999)
		local dropid = id
		while Drops[dropid] do
			id = math.random(10000, 99999)
			dropid = id
		end
		return dropid
	else
		local id = math.random(10000, 99999)
		local dropid = id
		return dropid
	end
end

---Creates a new drop
---@param source number The source of the player
---@param fromSlot number The slot that the item comes from
---@param toSlot number The slot that the item goes to
---@param itemAmount? number The amount of the item drop to create
local function CreateNewDrop(source, fromSlot, toSlot, itemAmount)
	itemAmount = tonumber(itemAmount) or 1
	local Player = PlusCore.func.GetPlayer(source)
	local itemData = GetItemBySlot(source, fromSlot)

	if not itemData then return end

	local coords = GetEntityCoords(GetPlayerPed(source))
	if RemoveItem(source, itemData.name, itemAmount, itemData.slot) then
		TriggerClientEvent("inventory:client:CheckWeapon", source, itemData.name)
		local itemInfo = PlusCore.Shared.Items[itemData.name:lower()]
		local dropId = CreateDropId()
		Drops[dropId] = {}
		Drops[dropId].coords = coords
		Drops[dropId].createdTime = os.time()

		Drops[dropId].items = {}

		Drops[dropId].items[toSlot] = {
			name = itemInfo["name"],
			amount = itemAmount,
			info = itemData.info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = toSlot,
			id = dropId,
		}
		TriggerEvent("qb-log:server:CreateLog", "drop", "New Item Drop", "red", "**".. GetPlayerName(source) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..source.."*) dropped new item; name: **"..itemData.name.."**, amount: **" .. itemAmount .. "**")
		TriggerClientEvent("inventory:client:DropItemAnim", source)
		TriggerClientEvent("inventory:client:AddDropItem", -1, dropId, source, coords)
		if itemData.name:lower() == "radio" then
			TriggerClientEvent('Radio.Set', source, false)
		end
	else
		PlusCore.func.Notify(source, Lang:t("notify.missitem"), "error")
	end
end

local function OpenInventory(name, id, other, origin)
	local src = origin
	local ply = Player(src)
    local Player = PlusCore.func.GetPlayer(src)
	if ply.state.inv_busy then
		return PlusCore.func.Notify(src, Lang:t("notify.noaccess"), 'error')
	end
	if name and id then
		local secondInv = {}
		if name == "stash" then
			if Stashes[id] then
				if Stashes[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Stashes[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Stashes[id].isOpen, name, id, Stashes[id].label)
					else
						Stashes[id].isOpen = false
					end
				end
			end
			local maxweight = 1000000
			local slots = 50
			if other then
				maxweight = other.maxweight or 1000000
				slots = other.slots or 50
			end
			secondInv.name = "stash-"..id
			secondInv.label = "Stash-"..id
			secondInv.maxweight = maxweight
			secondInv.inventory = {}
			secondInv.slots = slots
			if Stashes[id] and Stashes[id].isOpen then
				secondInv.name = "none-inv"
				secondInv.label = "Stash-None"
				secondInv.maxweight = 1000000
				secondInv.inventory = {}
				secondInv.slots = 0
			else
				local stashItems = GetStashItems(id)
				if next(stashItems) then
					secondInv.inventory = stashItems
					Stashes[id] = {}
					Stashes[id].items = stashItems
					Stashes[id].isOpen = src
					Stashes[id].label = secondInv.label
				else
					Stashes[id] = {}
					Stashes[id].items = {}
					Stashes[id].isOpen = src
					Stashes[id].label = secondInv.label
				end
			end
		elseif name == "trunk" then
			if Trunks[id] then
				if Trunks[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Trunks[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Trunks[id].isOpen, name, id, Trunks[id].label)
					else
						Trunks[id].isOpen = false
					end
				end
			end
			secondInv.name = "trunk-"..id
			secondInv.label = "Trunk-"..id
			secondInv.maxweight = other.maxweight or 60000
			secondInv.inventory = {}
			secondInv.slots = other.slots or 50
			if (Trunks[id] and Trunks[id].isOpen) or (PlusCore.Shared.SplitStr(id, "PLZI")[2] and (Player.UserData.job.name ~= "police" or Player.UserData.job.type ~= "leo")) then
				secondInv.name = "none-inv"
				secondInv.label = "Trunk-None"
				secondInv.maxweight = other.maxweight or 60000
				secondInv.inventory = {}
				secondInv.slots = 0
			else
				if id then
					local ownedItems = GetOwnedVehicleItems(id)
					if IsVehicleOwned(id) and next(ownedItems) then
						secondInv.inventory = ownedItems
						Trunks[id] = {}
						Trunks[id].items = ownedItems
						Trunks[id].isOpen = src
						Trunks[id].label = secondInv.label
					elseif Trunks[id] and not Trunks[id].isOpen then
						secondInv.inventory = Trunks[id].items
						Trunks[id].isOpen = src
						Trunks[id].label = secondInv.label
					else
						Trunks[id] = {}
						Trunks[id].items = {}
						Trunks[id].isOpen = src
						Trunks[id].label = secondInv.label
					end
				end
			end
		elseif name == "glovebox" then
			if Gloveboxes[id] then
				if Gloveboxes[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Gloveboxes[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Gloveboxes[id].isOpen, name, id, Gloveboxes[id].label)
					else
						Gloveboxes[id].isOpen = false
					end
				end
			end
			secondInv.name = "glovebox-"..id
			secondInv.label = "Glovebox-"..id
			secondInv.maxweight = 10000
			secondInv.inventory = {}
			secondInv.slots = 5
			if Gloveboxes[id] and Gloveboxes[id].isOpen then
				secondInv.name = "none-inv"
				secondInv.label = "Glovebox-None"
				secondInv.maxweight = 10000
				secondInv.inventory = {}
				secondInv.slots = 0
			else
				local ownedItems = GetOwnedVehicleGloveboxItems(id)
				if Gloveboxes[id] and not Gloveboxes[id].isOpen then
					secondInv.inventory = Gloveboxes[id].items
					Gloveboxes[id].isOpen = src
					Gloveboxes[id].label = secondInv.label
				elseif IsVehicleOwned(id) and next(ownedItems) then
					secondInv.inventory = ownedItems
					Gloveboxes[id] = {}
					Gloveboxes[id].items = ownedItems
					Gloveboxes[id].isOpen = src
					Gloveboxes[id].label = secondInv.label
				else
					Gloveboxes[id] = {}
					Gloveboxes[id].items = {}
					Gloveboxes[id].isOpen = src
					Gloveboxes[id].label = secondInv.label
				end
			end
		elseif name == "shop" then
			secondInv.name = "itemshop-"..id
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = SetupShopItems(other.items)
			ShopItems[id] = {}
			ShopItems[id].items = other.items
			secondInv.slots = #other.items
		elseif name == "traphouse" then
			secondInv.name = "traphouse-"..id
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = other.items
			secondInv.slots = other.slots
		elseif name == "crafting" then
			secondInv.name = "crafting"
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = other.items
			secondInv.slots = #other.items
		elseif name == "attachment_crafting" then
			secondInv.name = "attachment_crafting"
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = other.items
			secondInv.slots = #other.items
		elseif name == "otherplayer" then
			local OtherPlayer = PlusCore.func.GetPlayer(tonumber(id))
			if OtherPlayer then
				secondInv.name = "otherplayer-"..id
				secondInv.label = "Player-"..id
				secondInv.maxweight = Config.MaxInventoryWeight
				secondInv.inventory = OtherPlayer.UserData.items
				if (Player.UserData.job.name == "police" or Player.UserData.job.type == "leo") and Player.UserData.job.onduty then
					secondInv.slots = Config.MaxInventorySlots
				else
					secondInv.slots = Config.MaxInventorySlots - 1
				end
				Wait(250)
			end
		else
			if Drops[id] then
				if Drops[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Drops[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Drops[id].isOpen, name, id, Drops[id].label)
					else
						Drops[id].isOpen = false
					end
				end
			end
			if Drops[id] and not Drops[id].isOpen then
				secondInv.coords = Drops[id].coords
				secondInv.name = id
				secondInv.label = "Dropped-"..tostring(id)
				secondInv.maxweight = 100000
				secondInv.inventory = Drops[id].items
				secondInv.slots = 30
				Drops[id].isOpen = src
				Drops[id].label = secondInv.label
				Drops[id].createdTime = os.time()
			else
				secondInv.name = "none-inv"
				secondInv.label = "Dropped-None"
				secondInv.maxweight = 100000
				secondInv.inventory = {}
				secondInv.slots = 0
			end
		end
		TriggerClientEvent("qb-inventory:client:closeinv", id)
		TriggerClientEvent("inventory:client:OpenInventory", src, {}, Player.UserData.items, secondInv)
	else
		TriggerClientEvent("inventory:client:OpenInventory", src, {}, Player.UserData.items)
	end
end
exports('OpenInventory',OpenInventory)

--#endregion Functions

--#region Events

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
	PlusCore.func.AddPlayerMethod(Player.UserData.source, "AddItem", function(item, amount, slot, info)
		return AddItem(Player.UserData.source, item, amount, slot, info)
	end)

	PlusCore.func.AddPlayerMethod(Player.UserData.source, "RemoveItem", function(item, amount, slot)
		return RemoveItem(Player.UserData.source, item, amount, slot)
	end)

	PlusCore.func.AddPlayerMethod(Player.UserData.source, "GetItemBySlot", function(slot)
		return GetItemBySlot(Player.UserData.source, slot)
	end)

	PlusCore.func.AddPlayerMethod(Player.UserData.source, "GetItemByName", function(item)
		return GetItemByName(Player.UserData.source, item)
	end)

	PlusCore.func.AddPlayerMethod(Player.UserData.source, "GetItemsByName", function(item)
		return GetItemsByName(Player.UserData.source, item)
	end)

	PlusCore.func.AddPlayerMethod(Player.UserData.source, "ClearInventory", function(filterItems)
		ClearInventory(Player.UserData.source, filterItems)
	end)

	PlusCore.func.AddPlayerMethod(Player.UserData.source, "SetInventory", function(items)
		SetInventory(Player.UserData.source, items)
	end)
end)

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
	local Players = PlusCore.func.GetQBPlayers()
	for k in pairs(Players) do
		PlusCore.func.AddPlayerMethod(k, "AddItem", function(item, amount, slot, info)
			return AddItem(k, item, amount, slot, info)
		end)

		PlusCore.func.AddPlayerMethod(k, "RemoveItem", function(item, amount, slot)
			return RemoveItem(k, item, amount, slot)
		end)

		PlusCore.func.AddPlayerMethod(k, "GetItemBySlot", function(slot)
			return GetItemBySlot(k, slot)
		end)

		PlusCore.func.AddPlayerMethod(k, "GetItemByName", function(item)
			return GetItemByName(k, item)
		end)

		PlusCore.func.AddPlayerMethod(k, "GetItemsByName", function(item)
			return GetItemsByName(k, item)
		end)

		PlusCore.func.AddPlayerMethod(k, "ClearInventory", function(filterItems)
			ClearInventory(k, filterItems)
		end)

		PlusCore.func.AddPlayerMethod(k, "SetInventory", function(items)
			SetInventory(k, items)
		end)
	end
end)
RegisterNetEvent('QBCore:Server:UpdateObject', function()
    if source ~= '' then return end -- Safety check if the event was not called from the server.
    PlusCore = exports['plus-core']:GetCore()
end)
function addTrunkItems(plate, items)
	Trunks[plate] = {}
	Trunks[plate].items = items
end
exports('addTrunkItems',addTrunkItems)
function addGloveboxItems(plate, items)
	Gloveboxes[plate] = {}
	Gloveboxes[plate].items = items
end
exports('addGloveboxItems',addGloveboxItems)

RegisterNetEvent('inventory:server:combineItem', function(item, fromItem, toItem)
	local src = source

	-- Check that inputs are not nil
	-- Most commonly when abusing this exploit, this values are left as
	if fromItem == nil  then return end
	if toItem == nil then return end

	-- Check that they have the items
	fromItem = GetItemByName(src, fromItem)
	toItem = GetItemByName(src, toItem)

	if fromItem == nil  then return end
	if toItem == nil then return end

	-- Check the recipe is valid
	local recipe = PlusCore.Shared.Items[toItem.name].combinable

	if recipe and recipe.reward ~= item then return end
	if not recipeContains(recipe, fromItem) then return end

	TriggerClientEvent('inventory:client:ItemBox', src, PlusCore.Shared.Items[item], 'add')
	AddItem(src, item, 1)
	RemoveItem(src, fromItem.name, 1)
	RemoveItem(src, toItem.name, 1)
end)

RegisterNetEvent('inventory:server:CraftItems', function(itemName, itemCosts, amount, toSlot, points)
	local src = source
	local Player = PlusCore.func.GetPlayer(src)

	amount = tonumber(amount)

	if not itemName or not itemCosts then return end

	for k, v in pairs(itemCosts) do
		RemoveItem(src, k, (v*amount))
	end
	AddItem(src, itemName, amount, toSlot)
	Player.Functions.SetMetaData("craftingrep", Player.UserData.metadata["craftingrep"] + (points * amount))
	TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
end)

RegisterNetEvent('inventory:server:CraftAttachment', function(itemName, itemCosts, amount, toSlot, points)
	local src = source
	local Player = PlusCore.func.GetPlayer(src)

	amount = tonumber(amount)

	if not itemName or not itemCosts then return end

	for k, v in pairs(itemCosts) do
		RemoveItem(src, k, (v*amount))
	end
	AddItem(src, itemName, amount, toSlot)
	Player.Functions.SetMetaData("attachmentcraftingrep", Player.UserData.metadata["attachmentcraftingrep"] + (points * amount))
	TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
end)

RegisterNetEvent('inventory:server:SetIsOpenState', function(IsOpen, type, id)
	if IsOpen then return end

	if type == "stash" then
		Stashes[id].isOpen = false
	elseif type == "trunk" then
		Trunks[id].isOpen = false
	elseif type == "glovebox" then
		Gloveboxes[id].isOpen = false
	elseif type == "drop" then
		Drops[id].isOpen = false
	end
end)

RegisterNetEvent('inventory:server:OpenInventory', function(name, id, other)
--	print('inventory:server:OpenInventory is deprecated use exports[\'qb-inventory\']:OpenInventory() instead.')
	local src = source
	local ply = Player(src)
	local Player = PlusCore.func.GetPlayer(src)
	if ply.state.inv_busy then
		return PlusCore.func.Notify(src, Lang:t("notify.noaccess"), 'error')
	end
	if name and id then
		local secondInv = {}
		if name == "stash" then
			if Stashes[id] then
				if Stashes[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Stashes[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Stashes[id].isOpen, name, id, Stashes[id].label)
					else
						Stashes[id].isOpen = false
					end
				end
			end
			local maxweight = 1000000
			local slots = 50
			if other then
				maxweight = other.maxweight or 1000000
				slots = other.slots or 50
			end
			secondInv.name = "stash-"..id
			secondInv.label = "Stash-"..id
			secondInv.maxweight = maxweight
			secondInv.inventory = {}
			secondInv.slots = slots
			if Stashes[id] and Stashes[id].isOpen then
				secondInv.name = "none-inv"
				secondInv.label = "Stash-None"
				secondInv.maxweight = 1000000
				secondInv.inventory = {}
				secondInv.slots = 0
			else
				local stashItems = GetStashItems(id)
				if next(stashItems) then
					secondInv.inventory = stashItems
					Stashes[id] = {}
					Stashes[id].items = stashItems
					Stashes[id].isOpen = src
					Stashes[id].label = secondInv.label
				else
					Stashes[id] = {}
					Stashes[id].items = {}
					Stashes[id].isOpen = src
					Stashes[id].label = secondInv.label
				end
			end
		elseif name == "trunk" then
			if Trunks[id] then
				if Trunks[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Trunks[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Trunks[id].isOpen, name, id, Trunks[id].label)
					else
						Trunks[id].isOpen = false
					end
				end
			end
			secondInv.name = "trunk-"..id
			secondInv.label = "Trunk-"..id
			secondInv.maxweight = other.maxweight or 60000
			secondInv.inventory = {}
			secondInv.slots = other.slots or 50
			if (Trunks[id] and Trunks[id].isOpen) or (PlusCore.Shared.SplitStr(id, "PLZI")[2] and (Player.UserData.job.name ~= "police" or Player.UserData.job.type ~= "leo")) then
				secondInv.name = "none-inv"
				secondInv.label = "Trunk-None"
				secondInv.maxweight = other.maxweight or 60000
				secondInv.inventory = {}
				secondInv.slots = 0
			else
				if id then
					local ownedItems = GetOwnedVehicleItems(id)
					if IsVehicleOwned(id) and next(ownedItems) then
						secondInv.inventory = ownedItems
						Trunks[id] = {}
						Trunks[id].items = ownedItems
						Trunks[id].isOpen = src
						Trunks[id].label = secondInv.label
					elseif Trunks[id] and not Trunks[id].isOpen then
						secondInv.inventory = Trunks[id].items
						Trunks[id].isOpen = src
						Trunks[id].label = secondInv.label
					else
						Trunks[id] = {}
						Trunks[id].items = {}
						Trunks[id].isOpen = src
						Trunks[id].label = secondInv.label
					end
				end
			end
		elseif name == "glovebox" then
			if Gloveboxes[id] then
				if Gloveboxes[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Gloveboxes[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Gloveboxes[id].isOpen, name, id, Gloveboxes[id].label)
					else
						Gloveboxes[id].isOpen = false
					end
				end
			end
			secondInv.name = "glovebox-"..id
			secondInv.label = "Glovebox-"..id
			secondInv.maxweight = 10000
			secondInv.inventory = {}
			secondInv.slots = 5
			if Gloveboxes[id] and Gloveboxes[id].isOpen then
				secondInv.name = "none-inv"
				secondInv.label = "Glovebox-None"
				secondInv.maxweight = 10000
				secondInv.inventory = {}
				secondInv.slots = 0
			else
				local ownedItems = GetOwnedVehicleGloveboxItems(id)
				if Gloveboxes[id] and not Gloveboxes[id].isOpen then
					secondInv.inventory = Gloveboxes[id].items
					Gloveboxes[id].isOpen = src
					Gloveboxes[id].label = secondInv.label
				elseif IsVehicleOwned(id) and next(ownedItems) then
					secondInv.inventory = ownedItems
					Gloveboxes[id] = {}
					Gloveboxes[id].items = ownedItems
					Gloveboxes[id].isOpen = src
					Gloveboxes[id].label = secondInv.label
				else
					Gloveboxes[id] = {}
					Gloveboxes[id].items = {}
					Gloveboxes[id].isOpen = src
					Gloveboxes[id].label = secondInv.label
				end
			end
		elseif name == "shop" then
			secondInv.name = "itemshop-"..id
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = SetupShopItems(other.items)
			ShopItems[id] = {}
			ShopItems[id].items = other.items
			secondInv.slots = #other.items
		elseif name == "traphouse" then
			secondInv.name = "traphouse-"..id
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = other.items
			secondInv.slots = other.slots
		elseif name == "crafting" then
			secondInv.name = "crafting"
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = other.items
			secondInv.slots = #other.items
		elseif name == "attachment_crafting" then
			secondInv.name = "attachment_crafting"
			secondInv.label = other.label
			secondInv.maxweight = 900000
			secondInv.inventory = other.items
			secondInv.slots = #other.items
		elseif name == "otherplayer" then
			local OtherPlayer = PlusCore.func.GetPlayer(tonumber(id))
			if OtherPlayer then
				secondInv.name = "otherplayer-"..id
				secondInv.label = "Player-"..id
				secondInv.maxweight = Config.MaxInventoryWeight
				secondInv.inventory = OtherPlayer.UserData.items
				if (Player.UserData.job.name == "police" or Player.UserData.job.type == "leo") and Player.UserData.job.onduty then
					secondInv.slots = Config.MaxInventorySlots
				else
					secondInv.slots = Config.MaxInventorySlots - 1
				end
				Wait(250)
			end
		else
			if Drops[id] then
				if Drops[id].isOpen then
					local Target = PlusCore.func.GetPlayer(Drops[id].isOpen)
					if Target then
						TriggerClientEvent('inventory:client:CheckOpenState', Drops[id].isOpen, name, id, Drops[id].label)
					else
						Drops[id].isOpen = false
					end
				end
			end
			if Drops[id] and not Drops[id].isOpen then
				secondInv.coords = Drops[id].coords
				secondInv.name = id
				secondInv.label = "Dropped-"..tostring(id)
				secondInv.maxweight = 100000
				secondInv.inventory = Drops[id].items
				secondInv.slots = 30
				Drops[id].isOpen = src
				Drops[id].label = secondInv.label
				Drops[id].createdTime = os.time()
			else
				secondInv.name = "none-inv"
				secondInv.label = "Dropped-None"
				secondInv.maxweight = 100000
				secondInv.inventory = {}
				secondInv.slots = 0
			end
		end
		TriggerClientEvent("qb-inventory:client:closeinv", id)
		TriggerClientEvent("inventory:client:OpenInventory", src, {}, Player.UserData.items, secondInv)
	else
		TriggerClientEvent("inventory:client:OpenInventory", src, {}, Player.UserData.items)
	end
end)

RegisterNetEvent('inventory:server:SaveInventory', function(type, id)
	if type == "trunk" then
		if IsVehicleOwned(id) then
			SaveOwnedVehicleItems(id, Trunks[id].items)
		else
			Trunks[id].isOpen = false
		end
	elseif type == "glovebox" then
		if (IsVehicleOwned(id)) then
			SaveOwnedGloveboxItems(id, Gloveboxes[id].items)
		else
			Gloveboxes[id].isOpen = false
		end
	elseif type == "stash" then
		SaveStashItems(id, Stashes[id].items)
	elseif type == "drop" then
		if Drops[id] then
			Drops[id].isOpen = false
			if Drops[id].items == nil or next(Drops[id].items) == nil then
				Drops[id] = nil
				TriggerClientEvent("inventory:client:RemoveDropItem", -1, id)
			end
		end
	end
end)

RegisterNetEvent('inventory:server:UseItemSlot', function(slot)
	local src = source
	local itemData = GetItemBySlot(src, slot)
	if not itemData then return end
	local itemInfo = PlusCore.Shared.Items[itemData.name]
	if itemData.type == "weapon" then
		TriggerClientEvent("inventory:client:UseWeapon", src, itemData, itemData.info.quality and itemData.info.quality > 0)
		TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
	elseif itemData.useable then
		UseItem(itemData.name, src, itemData)
		TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
	end
end)

RegisterNetEvent('inventory:server:UseItem', function(inventory, item)
	local src = source
	if inventory ~= "player" and inventory ~= "hotbar" then return end
	local itemData = GetItemBySlot(src, item.slot)
	if not itemData then return end
	local itemInfo = PlusCore.Shared.Items[itemData.name]
	if itemData.type == "weapon" then
		TriggerClientEvent("inventory:client:UseWeapon", src, itemData, itemData.info.quality and itemData.info.quality > 0)
		TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
	else
		UseItem(itemData.name, src, itemData)
		TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
	end
end)

RegisterNetEvent('inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
	local src = source
	local Player = PlusCore.func.GetPlayer(src)
	fromSlot = tonumber(fromSlot)
	toSlot = tonumber(toSlot)

	if (fromInventory == "player" or fromInventory == "hotbar") and (PlusCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
		return
	end

	if fromInventory == "player" or fromInventory == "hotbar" then
		local fromItemData = GetItemBySlot(src, fromSlot)
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
					end
				end
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			elseif PlusCore.Shared.SplitStr(toInventory, "-")[1] == "otherplayer" then
				local playerId = tonumber(PlusCore.Shared.SplitStr(toInventory, "-")[2])
				local OtherPlayer = PlusCore.func.GetPlayer(playerId)
				local toItemData = OtherPlayer.UserData.items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					local itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(playerId, itemInfo["name"], toAmount, fromSlot)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.UserData.source) .. "** (citizenid: *"..OtherPlayer.UserData.citizenid.."* | id: *"..OtherPlayer.UserData.source.."*)")
					end
				else
					local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "robbing", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** to player: **".. GetPlayerName(OtherPlayer.UserData.source) .. "** (citizenid: *"..OtherPlayer.UserData.citizenid.."* | id: *"..OtherPlayer.UserData.source.."*)")
				end
				local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddItem(playerId, itemInfo["name"], fromAmount, toSlot, fromItemData.info)
			elseif PlusCore.Shared.SplitStr(toInventory, "-")[1] == "trunk" then
				local plate = PlusCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Trunks[plate].items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					local itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromTrunk(plate, fromSlot, itemInfo["name"], toAmount)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "trunk", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif PlusCore.Shared.SplitStr(toInventory, "-")[1] == "glovebox" then
				local plate = PlusCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					local itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], toAmount)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif PlusCore.Shared.SplitStr(toInventory, "-")[1] == "stash" then
				local stashId = PlusCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Stashes[stashId].items[toSlot]
				RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					local itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						--RemoveFromStash(stashId, fromSlot, itemInfo["name"], toAmount)
						RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
						AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
					end
				else
					local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("qb-log:server:CreateLog", "stash", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
				end
				local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif PlusCore.Shared.SplitStr(toInventory, "-")[1] == "traphouse" then
				-- Traphouse
				local traphouseId = PlusCore.Shared.SplitStr(toInventory, "_")[2]
				local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
				local IsItemValid = exports['qb-traphouse']:CanItemBeSaled(fromItemData.name:lower())
				if IsItemValid then
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData  then
						local itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount)
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent("qb-log:server:CreateLog", "traphouse", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
						end
					else
						local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "traphouse", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
					end
					local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
					exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
				else
					PlusCore.func.Notify(src, Lang:t("notify.nosell"), 'error')
				end
			else
				-- drop
				toInventory = tonumber(toInventory)
				if toInventory == nil or toInventory == 0 then
					CreateNewDrop(src, fromSlot, toSlot, fromAmount)
				else
					local toItemData = Drops[toInventory].items[toSlot]
					RemoveItem(src, fromItemData.name, fromAmount, fromSlot)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData then
						local itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						toAmount = tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							AddItem(src, toItemData.name, toAmount, fromSlot, toItemData.info)
							RemoveFromDrop(toInventory, fromSlot, itemInfo["name"], toAmount)
							TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
						end
					else
						local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("qb-log:server:CreateLog", "drop", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
					end
					local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
					AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
					if itemInfo["name"] == "radio" then
						TriggerClientEvent('Radio.Set', src, false)
					end
				end
			end
		else
			PlusCore.func.Notify(src, Lang:t("notify.missitem"), "error")
		end
	elseif PlusCore.Shared.SplitStr(fromInventory, "-")[1] == "otherplayer" then
		local playerId = tonumber(PlusCore.Shared.SplitStr(fromInventory, "-")[2])
		local OtherPlayer = PlusCore.func.GetPlayer(playerId)
		local fromItemData = OtherPlayer.UserData.items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.UserData.source, fromItemData.name)
				if toItemData then
					itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** from player: **".. GetPlayerName(OtherPlayer.UserData.source) .. "** (citizenid: *"..OtherPlayer.UserData.citizenid.."* | *"..OtherPlayer.UserData.source.."*)")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "robbing", "Retrieved Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) took item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** from player: **".. GetPlayerName(OtherPlayer.UserData.source) .. "** (citizenid: *"..OtherPlayer.UserData.citizenid.."* | *"..OtherPlayer.UserData.source.."*)")
				end
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = OtherPlayer.UserData.items[toSlot]
				RemoveItem(playerId, itemInfo["name"], fromAmount, fromSlot)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						RemoveItem(playerId, itemInfo["name"], toAmount, toSlot)
						AddItem(playerId, itemInfo["name"], toAmount, fromSlot, toItemData.info)
					end
				end
				itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddItem(playerId, itemInfo["name"], fromAmount, toSlot, fromItemData.info)
			end
		else
			PlusCore.func.Notify(src, "Item doesn't exist", "error")
		end
	elseif PlusCore.Shared.SplitStr(fromInventory, "-")[1] == "trunk" then
		local plate = PlusCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Trunks[plate].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "trunk", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
				end
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = Trunks[plate].items[toSlot]
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						RemoveFromTrunk(plate, toSlot, itemInfo["name"], toAmount)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				end
				itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			PlusCore.func.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif PlusCore.Shared.SplitStr(fromInventory, "-")[1] == "glovebox" then
		local plate = PlusCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Gloveboxes[plate].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Swapped", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src..")* swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "glovebox", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
				end
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						RemoveFromGlovebox(plate, toSlot, itemInfo["name"], toAmount)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				end
				itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			PlusCore.func.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif PlusCore.Shared.SplitStr(fromInventory, "-")[1] == "stash" then
		local stashId = PlusCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Stashes[stashId].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. stashId .. "*")
				end
				SaveStashItems(stashId, Stashes[stashId].items)
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = Stashes[stashId].items[toSlot]
				RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
						AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				end
				itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			PlusCore.func.Notify(src, Lang:t("notify.itemexist"), "error")
		end
	elseif PlusCore.Shared.SplitStr(fromInventory, "-")[1] == "traphouse" then
		local traphouseId = PlusCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, fromSlot)
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
						TriggerEvent("qb-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. traphouseId .. "*")
				end
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = exports['qb-traphouse']:GetInventoryData(traphouseId, toSlot)
				exports['qb-traphouse']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						exports['qb-traphouse']:RemoveHouseItem(traphouseId, toSlot, itemInfo["name"], toAmount)
						exports['qb-traphouse']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
					end
				end
				itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				exports['qb-traphouse']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
			end
		else
			PlusCore.func.Notify(src, "Item doesn't exist??", "error")
		end
	elseif PlusCore.Shared.SplitStr(fromInventory, "-")[1] == "itemshop" then
		local shopType = PlusCore.Shared.SplitStr(fromInventory, "-")[2]
		local itemData = ShopItems[shopType].items[fromSlot]
		local itemInfo = PlusCore.Shared.Items[itemData.name:lower()]
		local bankBalance = Player.UserData.money["bank"]
		local price = tonumber((itemData.price*fromAmount))

		if PlusCore.Shared.SplitStr(shopType, "_")[1] == "Dealer" then
			if PlusCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
				price = tonumber(itemData.price)
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					itemData.info.serie = tostring(PlusCore.Shared.RandomInt(2) .. PlusCore.Shared.RandomStr(3) .. PlusCore.Shared.RandomInt(1) .. PlusCore.Shared.RandomStr(2) .. PlusCore.Shared.RandomInt(3) .. PlusCore.Shared.RandomStr(4))
					itemData.info.quality = 100
					AddItem(src, itemData.name, 1, toSlot, itemData.info)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, 1)
					PlusCore.func.Notify(src, itemInfo["label"] .. " bought!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
				else
					PlusCore.func.Notify(src, Lang:t("notify.notencash"), "error")
				end
			else
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
					TriggerClientEvent('qb-drugs:client:updateDealerItems', src, itemData, fromAmount)
					PlusCore.func.Notify(src, itemInfo["label"] .. " bought!", "success")
					TriggerEvent("qb-log:server:CreateLog", "dealers", "Dealer item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. "  for $"..price)
				else
					PlusCore.func.Notify(src, "You don't have enough cash..", "error")
				end
			end
		elseif PlusCore.Shared.SplitStr(shopType, "_")[1] == "Itemshop" then
			if Player.Functions.RemoveMoney("cash", price, "itemshop-bought-item") then
                if PlusCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(PlusCore.Shared.RandomInt(2) .. PlusCore.Shared.RandomStr(3) .. PlusCore.Shared.RandomInt(1) .. PlusCore.Shared.RandomStr(2) .. PlusCore.Shared.RandomInt(3) .. PlusCore.Shared.RandomStr(4))
					itemData.info.quality = 100
                end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				TriggerClientEvent('qb-shops:client:UpdateShop', src, PlusCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
				PlusCore.func.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			elseif bankBalance >= price then
				Player.Functions.RemoveMoney("bank", price, "itemshop-bought-item")
                if PlusCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                    itemData.info.serie = tostring(PlusCore.Shared.RandomInt(2) .. PlusCore.Shared.RandomStr(3) .. PlusCore.Shared.RandomInt(1) .. PlusCore.Shared.RandomStr(2) .. PlusCore.Shared.RandomInt(3) .. PlusCore.Shared.RandomStr(4))
					itemData.info.quality = 100
                end
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				TriggerClientEvent('qb-shops:client:UpdateShop', src, PlusCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
				PlusCore.func.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			else
				PlusCore.func.Notify(src, "You don't have enough cash..", "error")
			end
		else
			if Player.Functions.RemoveMoney("cash", price, "unkown-itemshop-bought-item") then
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				PlusCore.func.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			elseif bankBalance >= price then
				Player.Functions.RemoveMoney("bank", price, "unkown-itemshop-bought-item")
				AddItem(src, itemData.name, fromAmount, toSlot, itemData.info)
				PlusCore.func.Notify(src, itemInfo["label"] .. " bought!", "success")
				TriggerEvent("qb-log:server:CreateLog", "shops", "Shop item bought", "green", "**"..GetPlayerName(src) .. "** bought a " .. itemInfo["label"] .. " for $"..price)
			else
				PlusCore.func.Notify(src, Lang:t("notify.notencash"), "error")
			end
		end
	elseif fromInventory == "crafting" then
		local itemData = Config.CraftingItems[fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftItems", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			PlusCore.func.Notify(src, Lang:t("notify.noitem"), "error")
		end
	elseif fromInventory == "attachment_crafting" then
		local itemData = Config.AttachmentCrafting["items"][fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftAttachment", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			PlusCore.func.Notify(src, Lang:t("notify.noitem"), "error")
		end
	else
		-- drop
		fromInventory = tonumber(fromInventory)
		local fromItemData = Drops[fromInventory].items[fromSlot]
		fromAmount = tonumber(fromAmount) or fromItemData.amount
		if fromItemData and fromItemData.amount >= fromAmount then
			local itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = GetItemBySlot(src, toSlot)
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				if toItemData then
					toAmount = tonumber(toAmount) and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						RemoveItem(src, toItemData.name, toAmount, toSlot)
						AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('Radio.Set', src, false)
						end
						TriggerEvent("qb-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
					else
						TriggerEvent("qb-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
					end
				else
					TriggerEvent("qb-log:server:CreateLog", "drop", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.UserData.citizenid.."* | id: *"..src.."*) received item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  dropid: *" .. fromInventory .. "*")
				end
				AddItem(src, fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				toInventory = tonumber(toInventory)
				local toItemData = Drops[toInventory].items[toSlot]
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				--Player.UserData.items[toSlot] = fromItemData
				if toItemData then
					--Player.UserData.items[fromSlot] = toItemData
					toAmount = tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						itemInfo = PlusCore.Shared.Items[toItemData.name:lower()]
						RemoveFromDrop(toInventory, toSlot, itemInfo["name"], toAmount)
						AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('Radio.Set', src, false)
						end
					end
				end
				itemInfo = PlusCore.Shared.Items[fromItemData.name:lower()]
				AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
				if itemInfo["name"] == "radio" then
					TriggerClientEvent('Radio.Set', src, false)
				end
			end
		else
			PlusCore.func.Notify(src, "Item doesn't exist??", "error")
		end
	end
end)

RegisterServerEvent("inventory:server:GiveItem", function(target, name, amount, slot)
    local src = source
    local Player = PlusCore.func.GetPlayer(src)
	target = tonumber(target)
    local OtherPlayer = PlusCore.func.GetPlayer(target)
    local dist = #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(target)))
	if Player == OtherPlayer then return PlusCore.func.Notify(src, Lang:t("notify.gsitem")) end
	if dist > 2 then return PlusCore.func.Notify(src, Lang:t("notify.tftgitem")) end
	local item = GetItemBySlot(src, slot)
	if not item then PlusCore.func.Notify(src, Lang:t("notify.infound")); return end
	if item.name ~= name then PlusCore.func.Notify(src, Lang:t("notify.iifound")); return end

	if amount <= item.amount then
		if amount == 0 then
			amount = item.amount
		end
		if RemoveItem(src, item.name, amount, item.slot) then
			if AddItem(target, item.name, amount, false, item.info) then
				TriggerClientEvent('inventory:client:ItemBox',target, PlusCore.Shared.Items[item.name], "add")
				PlusCore.func.Notify(target, Lang:t("notify.gitemrec")..amount..' '..item.label..Lang:t("notify.gitemfrom")..Player.UserData.charinfo.firstname.." "..Player.UserData.charinfo.lastname)
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", target, true)
				TriggerClientEvent('inventory:client:ItemBox',src, PlusCore.Shared.Items[item.name], "remove")
				PlusCore.func.Notify(src, Lang:t("notify.gitemyg") .. OtherPlayer.UserData.charinfo.firstname.." "..OtherPlayer.UserData.charinfo.lastname.. " " .. amount .. " " .. item.label .."!")
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
				TriggerClientEvent('qb-inventory:client:giveAnim', src)
				TriggerClientEvent('qb-inventory:client:giveAnim', target)
			else
				AddItem(src, item.name, amount, item.slot, item.info)
				PlusCore.func.Notify(src, Lang:t("notify.gitinvfull"), "error")
				PlusCore.func.Notify(target, Lang:t("notify.giymif"), "error")
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
				TriggerClientEvent("inventory:client:UpdatePlayerInventory", target, false)
			end
		else
			PlusCore.func.Notify(src, Lang:t("notify.gitydhei"), "error")
		end
	else
		PlusCore.func.Notify(src, Lang:t("notify.gitydhitt"))
	end
end)

RegisterNetEvent('inventory:server:snowball', function(action)
	if action == "add" then
		AddItem(source, "weapon_snowball")
	elseif action == "remove" then
		RemoveItem(source, "weapon_snowball")
	end
end)
RegisterNetEvent('inventory:server:addTrunkItems', function()
	print('inventory:server:addTrunkItems has been deprecated please use exports[\'qb-inventory\']:addTrunkItems(plate, items)')
end)
RegisterNetEvent('inventory:server:addGloveboxItems', function()
	print('inventory:server:addGloveboxItems has been deprecated please use exports[\'qb-inventory\']:addGloveboxItems(plate, items)')
end)
--#endregion Events

--#region Callbacks

PlusCore.func.CreateCallback('qb-inventory:server:GetStashItems', function(_, cb, stashId)
	cb(GetStashItems(stashId))
end)

PlusCore.func.CreateCallback('inventory:server:GetCurrentDrops', function(_, cb)
	cb(Drops)
end)

PlusCore.func.CreateCallback('QBCore:HasItem', function(source, cb, items, amount)
	print("^3QBCore:HasItem is deprecated, please use PlusCore.func.HasItem, it can be used on both server- and client-side and uses the same arguments.^0")
    local retval = false
    local Player = PlusCore.func.GetPlayer(source)
    if not Player then return cb(false) end
    local isTable = type(items) == 'table'
    local isArray = isTable and table.type(items) == 'array' or false
    local totalItems = #items
    local count = 0
    local kvIndex = 2
    if isTable and not isArray then
        totalItems = 0
        for _ in pairs(items) do totalItems += 1 end
        kvIndex = 1
    end
    if isTable then
        for k, v in pairs(items) do
            local itemKV = {k, v}
            local item = GetItemByName(source, itemKV[kvIndex])
            if item and ((amount and item.amount >= amount) or (not amount and not isArray and item.amount >= v) or (not amount and isArray)) then
                count += 1
            end
        end
        if count == totalItems then
            retval = true
        end
    else -- Single item as string
        local item = GetItemByName(source, items)
        if item and not amount or (item and amount and item.amount >= amount) then
            retval = true
        end
    end
    cb(retval)
end)

--#endregion Callbacks

--#region Commands
--[[
PlusCoreCommands.Add("resetinv", "Reset Inventory (Admin Only)", {{name="type", help="stash/trunk/glovebox"},{name="id/plate", help="ID of stash or license plate"}}, true, function(source, args)
	local invType = args[1]:lower()
	table.remove(args, 1)
	local invId = table.concat(args, " ")
	if invType and invId then
		if invType == "trunk" then
			if Trunks[invId] then
				Trunks[invId].isOpen = false
			end
		elseif invType == "glovebox" then
			if Gloveboxes[invId] then
				Gloveboxes[invId].isOpen = false
			end
		elseif invType == "stash" then
			if Stashes[invId] then
				Stashes[invId].isOpen = false
			end
		else
			PlusCore.func.Notify(source,  Lang:t("notify.navt"), "error")
		end
	else
		PlusCore.func.Notify(source,  Lang:t("notify.anfoc"), "error")
	end
end, "admin")

PlusCoreCommands.Add("rob", "Rob Player", {}, false, function(source, _)
	TriggerClientEvent("police:client:RobPlayer", source)
end)

PlusCoreCommands.Add("giveitem", "Give An Item (Admin Only)", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, false, function(source, args)
	local id = tonumber(args[1])
	local Player = PlusCore.func.GetPlayer(id)
	local amount = tonumber(args[3]) or 1
	local itemData = PlusCore.Shared.Items[tostring(args[2]):lower()]
	if Player then
			if itemData then
				-- check iteminfo
				local info = {}
				if itemData["name"] == "id_card" then
					info.citizenid = Player.UserData.citizenid
					info.firstname = Player.UserData.charinfo.firstname
					info.lastname = Player.UserData.charinfo.lastname
					info.birthdate = Player.UserData.charinfo.birthdate
					info.gender = Player.UserData.charinfo.gender
					info.nationality = Player.UserData.charinfo.nationality
				elseif itemData["name"] == "driver_license" then
					info.firstname = Player.UserData.charinfo.firstname
					info.lastname = Player.UserData.charinfo.lastname
					info.birthdate = Player.UserData.charinfo.birthdate
					info.type = "Class C Driver License"
				elseif itemData["type"] == "weapon" then
					amount = 1
					info.serie = tostring(PlusCore.Shared.RandomInt(2) .. PlusCore.Shared.RandomStr(3) .. PlusCore.Shared.RandomInt(1) .. PlusCore.Shared.RandomStr(2) .. PlusCore.Shared.RandomInt(3) .. PlusCore.Shared.RandomStr(4))
					info.quality = 100
				elseif itemData["name"] == "harness" then
					info.uses = 20
				elseif itemData["name"] == "markedbills" then
					info.worth = math.random(5000, 10000)
				elseif itemData["name"] == "labkey" then
					info.lab = exports["qb-methlab"]:GenerateRandomLab()
				elseif itemData["name"] == "printerdocument" then
					info.url = "https://cdn.discordapp.com/attachments/870094209783308299/870104331142189126/Logo_-_Display_Picture_-_Stylized_-_Red.png"
				end

				if AddItem(id, itemData["name"], amount, false, info) then
					PlusCore.func.Notify(source, Lang:t("notify.yhg") ..GetPlayerName(id).." "..amount.." "..itemData["name"].. "", "success")
				else
					PlusCore.func.Notify(source,  Lang:t("notify.cgitem"), "error")
				end
			else
				PlusCore.func.Notify(source,  Lang:t("notify.idne"), "error")
			end
	else
		PlusCore.func.Notify(source,  Lang:t("notify.pdne"), "error")
	end
end, "admin")

PlusCoreCommands.Add("randomitems", "Give Random Items (God Only)", {}, false, function(source, _)
	local filteredItems = {}
	for k, v in pairs(PlusCore.Shared.Items) do
		if PlusCore.Shared.Items[k]["type"] ~= "weapon" then
			filteredItems[#filteredItems+1] = v
		end
	end
	for _ = 1, 10, 1 do
		local randitem = filteredItems[math.random(1, #filteredItems)]
		local amount = math.random(1, 10)
		if randitem["unique"] then
			amount = 1
		end
		if AddItem(source, randitem["name"], amount) then
			TriggerClientEvent('inventory:client:ItemBox', source, PlusCore.Shared.Items[randitem["name"]-------], 'add')
            Wait(500)
		end
	end
end, "god")

PlusCoreCommands.Add('clearinv', 'Clear Players Inventory (Admin Only)', { { name = 'id', help = 'Player ID' } }, false, function(source, args)
    local playerId = args[1] ~= '' and tonumber(args[1]) or source
    local Player = PlusCore.func.GetPlayer(playerId)
    if Player then
        ClearInventory(playerId)
    else
        PlusCore.func.Notify(source, "Player not online", 'error')
    end
end, 'admin')
]]
--#endregion Commands

--#region Items

CreateUsableItem("driver_license", function(source, item)
	local playerPed = GetPlayerPed(source)
	local playerCoords = GetEntityCoords(playerPed)
	local players = PlusCore.func.GetPlayers()
	for _, v in pairs(players) do
		local targetPed = GetPlayerPed(v)
		local dist = #(playerCoords - GetEntityCoords(targetPed))
		if dist < 3.0 then
			TriggerClientEvent('chat:addMessage', v,  {
					template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>First Name:</strong> {1} <br><strong>Last Name:</strong> {2} <br><strong>Birth Date:</strong> {3} <br><strong>Licenses:</strong> {4}</div></div>',
					args = {
						"Drivers License",
						item.info.firstname,
						item.info.lastname,
						item.info.birthdate,
						item.info.type
					}
				}
			)
		end
	end
end)

CreateUsableItem("id_card", function(source, item)
	local playerPed = GetPlayerPed(source)
	local playerCoords = GetEntityCoords(playerPed)
	local players = PlusCore.func.GetPlayers()
	for _, v in pairs(players) do
		local targetPed = GetPlayerPed(v)
		local dist = #(playerCoords - GetEntityCoords(targetPed))
		if dist < 3.0 then
			local gender = "Man"
			if item.info.gender == 1 then
				gender = "Woman"
			end
			TriggerClientEvent('chat:addMessage', v,  {
					template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>Civ ID:</strong> {1} <br><strong>First Name:</strong> {2} <br><strong>Last Name:</strong> {3} <br><strong>Birthdate:</strong> {4} <br><strong>Gender:</strong> {5} <br><strong>Nationality:</strong> {6}</div></div>',
					args = {
						"ID Card",
						item.info.citizenid,
						item.info.firstname,
						item.info.lastname,
						item.info.birthdate,
						gender,
						item.info.nationality
					}
				}
			)
		end
	end
end)

--#endregion Items

--#region Threads

CreateThread(function()
	while true do
		for k, v in pairs(Drops) do
			if v and (v.createdTime + Config.CleanupDropTime < os.time()) and not Drops[k].isOpen then
				Drops[k] = nil
				TriggerClientEvent("inventory:client:RemoveDropItem", -1, k)
			end
		end
		Wait(60 * 1000)
	end
end)

--#endregion Threads