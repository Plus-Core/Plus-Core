-- Event Handler

AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not PlusCore.Users[src] then return end
    local Player = PlusCore.Users[src]
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.UserData.license .. ') left..' ..'\n **Reason:** ' .. reason)
    Player.Functions.Save()
    PlusCore.User_Buckets[Player.UserData.license] = nil
    PlusCore.Users[src] = nil
end)

-- Player Connecting

local function onPlayerConnecting(name, _, deferrals)
    local src = source
    local license
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    if PlusCore.Config.Server.Closed then
        if not IsPlayerAceAllowed(src, 'qbadmin.join') then
            deferrals.done(PlusCore.Config.Server.ClosedReason)
        end
    end

    deferrals.update(string.format(Lang:t('info.checking_ban'), name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    -- Mandatory wait
    Wait(2500)

    deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))

    local isBanned, Reason = PlusCore.func.IsPlayerBanned(src)
    local isLicenseAlreadyInUse = PlusCore.func.IsLicenseInUse(license)
    local isWhitelist, whitelisted = PlusCore.Config.Server.Whitelist, PlusCore.func.IsWhitelisted(src)

    Wait(2500)

    deferrals.update(string.format(Lang:t('info.join_server'), name))

    if not license then
      deferrals.done(Lang:t('error.no_valid_license'))
    elseif isBanned then
        deferrals.done(Reason)
    elseif isLicenseAlreadyInUse and PlusCore.Config.Server.CheckDuplicateLicense then
        deferrals.done(Lang:t('error.duplicate_license'))
    elseif isWhitelist and not whitelisted then
      deferrals.done(Lang:t('error.not_whitelisted'))
    end

    deferrals.done()

    -- Add any additional defferals you may need!
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('PlusCore:Server:CloseServer', function(reason)
    local src = source
    if PlusCore.func.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        PlusCore.Config.Server.Closed = true
        PlusCore.Config.Server.ClosedReason = reason
        for k in pairs(PlusCore.Users) do
            if not PlusCore.func.HasPermission(k, PlusCore.Config.Server.WhitelistPermission) then
                PlusCore.func.Kick(k, reason, nil, nil)
            end
        end
    else
        PlusCore.func.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

RegisterNetEvent('PlusCore:Server:OpenServer', function()
    local src = source
    if PlusCore.func.HasPermission(src, 'admin') then
        PlusCore.Config.Server.Closed = false
    else
        PlusCore.func.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('PlusCore:Server:TriggerClientCallback', function(name, ...)
    if PlusCore.ClientCallbacks[name] then
        PlusCore.ClientCallbacks[name](...)
        PlusCore.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
RegisterNetEvent('PlusCore:Server:TriggerCallback', function(name, ...)
    local src = source
    PlusCore.func.TriggerCallback(name, src, function(...)
        TriggerClientEvent('PlusCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

RegisterNetEvent('PlusCore:UpdatePlayer', function()
    local src = source
    local Player = PlusCore.func.GetPlayer(src)
    if not Player then return end
    local newHunger = Player.UserData.metadata['hunger'] - PlusCore.Config.Player.HungerRate
    local newThirst = Player.UserData.metadata['thirst'] - PlusCore.Config.Player.ThirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
    Player.Functions.Save()
end)

RegisterNetEvent('PlusCore:Server:SetMetaData', function(meta, data)
    local src = source
    local Player = PlusCore.func.GetPlayer(src)
    if not Player then return end
    if meta == 'hunger' or meta == 'thirst' then
        if data > 100 then
            data = 100
        end
    end
    Player.Functions.SetMetaData(meta, data)
    TriggerClientEvent('hud:client:UpdateNeeds', src, Player.UserData.metadata['hunger'], Player.UserData.metadata['thirst'])
end)

RegisterNetEvent('PlusCore:ToggleDuty', function()
    local src = source
    local Player = PlusCore.func.GetPlayer(src)
    if not Player then return end
    if Player.UserData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('PlusCore:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('PlusCore:Notify', src, Lang:t('info.on_duty'))
    end
    TriggerClientEvent('PlusCore:Client:SetDuty', src, Player.UserData.job.onduty)
end)

-- Items

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('PlusCore:Server:UseItem', function(item)
    print(string.format("%s triggered PlusCore:Server:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check qb-inventory for the right use on this event.", GetInvokingResource(), source))
    PlusCoreDebug(item)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot)
RegisterNetEvent('PlusCore:Server:RemoveItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered PlusCore:Server:RemoveItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot, info)
RegisterNetEvent('PlusCore:Server:AddItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered PlusCore:Server:AddItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- Non-Chat Command Calling (ex: qb-adminmenu)

RegisterNetEvent('PlusCore:CallCommand', function(command, args)
    local src = source
    if not PlusCoreCommands.List[command] then return end
    local Player = PlusCore.func.GetPlayer(src)
    if not Player then return end
    local hasPerm = PlusCore.func.HasPermission(src, "command."..PlusCoreCommands.List[command].name)
    if hasPerm then
        if PlusCoreCommands.List[command].argsrequired and #PlusCoreCommands.List[command].arguments ~= 0 and not args[#PlusCoreCommands.List[command].arguments] then
            TriggerClientEvent('PlusCore:Notify', src, Lang:t('error.missing_args2'), 'error')
        else
            PlusCoreCommands.List[command].callback(src, args)
        end
    else
        TriggerClientEvent('PlusCore:Notify', src, Lang:t('error.no_access'), 'error')
    end
end)

-- Use this for player vehicle spawning
-- Vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
PlusCore.func.CreateCallback('PlusCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then
        while GetVehiclePedIsIn(ped) ~= veh do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end
    end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

-- Use this for long distance vehicle spawning
-- vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
PlusCore.func.CreateCallback('PlusCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    model = type(model) == 'string' and GetHashKey(model) or model
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    local CreateAutomobile = GetHashKey("CREATE_AUTOMOBILE")
    local veh = Citizen.InvokeNative(CreateAutomobile, model, coords, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then TaskWarpPedIntoVehicle(GetPlayerPed(source), veh, -1) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

--PlusCore.func.CreateCallback('PlusCore:HasItem', function(source, cb, items, amount)
-- https://github.com/PlusCore-framework/qb-inventory/blob/e4ef156d93dd1727234d388c3f25110c350b3bcf/server/main.lua#L2066
--end)
