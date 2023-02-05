PlusCore.func = {}
PlusCore.User_Buckets = {}
PlusCoreEntity_Buckets = {}
PlusCoreUsableItems = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = PlusCore.func.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

function PlusCore.func.GetCoords(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return vector4(coords.x, coords.y, coords.z, heading)
end

function PlusCore.func.GetIdentifier(source, idtype)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
    return nil
end

function PlusCore.func.GetSource(identifier)
    for src, _ in pairs(PlusCore.Users) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return src
            end
        end
    end
    return 0
end

function PlusCore.func.GetPlayer(source)
    if type(source) == 'number' then
        return PlusCore.Users[source]
    else
        return PlusCore.Users[PlusCore.func.GetSource(source)]
    end
end

function PlusCore.func.GetPlayerByCitizenId(citizenid)
    for src in pairs(PlusCore.Users) do
        if PlusCore.Users[src].UserData.citizenid == citizenid then
            return PlusCore.Users[src]
        end
    end
    return nil
end

function PlusCore.func.GetOfflinePlayerByCitizenId(citizenid)
    return PlusCore.User.GetOfflinePlayer(citizenid)
end

function PlusCore.func.GetPlayerByPhone(number)
    for src in pairs(PlusCore.Users) do
        if PlusCore.Users[src].UserData.charinfo.phone == number then
            return PlusCore.Users[src]
        end
    end
    return nil
end

function PlusCore.func.GetPlayers()
    local sources = {}
    for k in pairs(PlusCore.Users) do
        sources[#sources+1] = k
    end
    return sources
end

-- Will return an array of QB Player class instances
-- unlike the GetPlayers() wrapper which only returns IDs
function PlusCore.func.GetQBPlayers()
    return PlusCore.Users
end

--- Gets a list of all on duty players of a specified job and the number
function PlusCore.func.GetPlayersOnDuty(job)
    local players = {}
    local count = 0
    for src, Player in pairs(PlusCore.Users) do
        if Player.UserData.job.name == job then
            if Player.UserData.job.onduty then
                players[#players + 1] = src
                count += 1
            end
        end
    end
    return players, count
end

-- Returns only the amount of players on duty for the specified job
function PlusCore.func.GetDutyCount(job)
    local count = 0
    for _, Player in pairs(PlusCore.Users) do
        if Player.UserData.job.name == job then
            if Player.UserData.job.onduty then
                count += 1
            end
        end
    end
    return count
end

-- Routing buckets (Only touch if you know what you are doing)

-- Returns the objects related to buckets, first returned value is the player buckets, second one is entity buckets
function PlusCore.func.GetBucketObjects()
    return PlusCore.User_Buckets, PlusCoreEntity_Buckets
end

-- Will set the provided player id / source into the provided bucket id
function PlusCore.func.SetPlayerBucket(source --[[ int ]], bucket --[[ int ]])
    if source and bucket then
        local plicense = PlusCore.func.GetIdentifier(source, 'license')
        SetPlayerRoutingBucket(source, bucket)
        PlusCore.User_Buckets[plicense] = {id = source, bucket = bucket}
        return true
    else
        return false
    end
end

-- Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
function PlusCore.func.SetEntityBucket(entity --[[ int ]], bucket --[[ int ]])
    if entity and bucket then
        SetEntityRoutingBucket(entity, bucket)
        PlusCoreEntity_Buckets[entity] = {id = entity, bucket = bucket}
        return true
    else
        return false
    end
end

-- Will return an array of all the player ids inside the current bucket
function PlusCore.func.GetPlayersInBucket(bucket --[[ int ]])
    local curr_bucket_pool = {}
    if PlusCore.User_Buckets and next(PlusCore.User_Buckets) then
        for _, v in pairs(PlusCore.User_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

-- Will return an array of all the entities inside the current bucket (not for player entities, use GetPlayersInBucket for that)
function PlusCore.func.GetEntitiesInBucket(bucket --[[ int ]])
    local curr_bucket_pool = {}
    if PlusCoreEntity_Buckets and next(PlusCoreEntity_Buckets) then
        for _, v in pairs(PlusCoreEntity_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

-- Server side vehicle creation with optional callback
-- the CreateVehicle RPC still uses the client for creation so players must be near
function PlusCore.func.SpawnVehicle(source, model, coords, warp)
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
    return veh
end

-- Server side vehicle creation with optional callback
-- the CreateAutomobile native is still experimental but doesn't use client for creation
-- doesn't work for all vehicles!
function PlusCore.func.CreateVehicle(source, model, coords, warp)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    local CreateAutomobile = `CREATE_AUTOMOBILE`
    local veh = Citizen.InvokeNative(CreateAutomobile, model, coords, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then TaskWarpPedIntoVehicle(GetPlayerPed(source), veh, -1) end
    return veh
end

-- Paychecks (standalone - don't touch)
function PaycheckInterval()
    if next(PlusCore.Users) then
        for _, Player in pairs(PlusCore.Users) do
            if Player then
                local payment = PlusShared.Jobs[Player.UserData.job.name]['grades'][tostring(Player.UserData.job.grade.level)].payment
                if not payment then payment = Player.UserData.job.payment end
                if Player.UserData.job and payment > 0 and (PlusShared.Jobs[Player.UserData.job.name].offDutyPay or Player.UserData.job.onduty) then
                    if PlusCore.Config.Money.PayCheckSociety then
                        local account = exports['qb-management']:GetAccount(Player.UserData.job.name)
                        if account ~= 0 then -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('PlusCore:Notify', Player.UserData.source, Lang:t('error.company_too_poor'), 'error')
                            else
                                Player.Functions.AddMoney('bank', payment)
                                exports['qb-management']:RemoveMoney(Player.UserData.job.name, payment)
                                TriggerClientEvent('PlusCore:Notify', Player.UserData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            Player.Functions.AddMoney('bank', payment)
                            TriggerClientEvent('PlusCore:Notify', Player.UserData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        Player.Functions.AddMoney('bank', payment)
                        TriggerClientEvent('PlusCore:Notify', Player.UserData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
    SetTimeout(PlusCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end

-- Callback Functions --

-- Client Callback
function PlusCore.func.TriggerClientCallback(name, source, cb, ...)
    PlusCore.ClientCallbacks[name] = cb
    TriggerClientEvent('PlusCore:Client:TriggerClientCallback', source, name, ...)
end

-- Server Callback
function PlusCore.func.CreateCallback(name, cb)
    PlusCore.ServerCallbacks[name] = cb
end

function PlusCore.func.TriggerCallback(name, source, cb, ...)
    if not PlusCore.ServerCallbacks[name] then return end
    PlusCore.ServerCallbacks[name](source, cb, ...)
end

-- Items

function PlusCore.func.CreateUseableItem(item, data)
    PlusCoreUsableItems[item] = data
end

function PlusCore.func.CanUseItem(item)
    return PlusCoreUsableItems[item]
end

function PlusCore.func.UseItem(source, item)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:UseItem(source, item)
end

-- Kick Player

function PlusCore.func.Kick(source, reason, setKickReason, deferrals)
    reason = '\n' .. reason .. '\n🔸 Check our Discord for further information: ' .. PlusCore.Config.Server.Discord
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source, reason)
        end
        for _ = 0, 4 do
            while true do
                if source then
                    if GetPlayerPing(source) >= 0 then
                        break
                    end
                    Wait(100)
                    CreateThread(function()
                        DropPlayer(source, reason)
                    end)
                end
            end
            Wait(5000)
        end
    end)
end

-- Check if player is whitelisted, kept like this for backwards compatibility or future plans

function PlusCore.func.IsWhitelisted(source)
    if not PlusCore.Config.Server.Whitelist then return true end
    if PlusCore.func.HasPermission(source, PlusCore.Config.Server.WhitelistPermission) then return true end
    return false
end

-- Setting & Removing Permissions

function PlusCore.func.AddPermission(source, permission)
    if not IsPlayerAceAllowed(source, permission) then
        ExecuteCommand(('add_principal player.%s PlusCore%s'):format(source, permission))
        PlusCore.Commands.Refresh(source)
    end
end

function PlusCore.func.RemovePermission(source, permission)
    if permission then
        if IsPlayerAceAllowed(source, permission) then
            ExecuteCommand(('remove_principal player.%s PlusCore%s'):format(source, permission))
            PlusCore.Commands.Refresh(source)
        end
    else
        for _, v in pairs(PlusCore.Config.Server.Permissions) do
            if IsPlayerAceAllowed(source, v) then
                ExecuteCommand(('remove_principal player.%s PlusCore%s'):format(source, v))
                PlusCore.Commands.Refresh(source)
            end
        end
    end
end

-- Checking for Permission Level

function PlusCore.func.HasPermission(source, permission)
    if type(permission) == "string" then
        if IsPlayerAceAllowed(source, permission) then return true end
    elseif type(permission) == "table" then
        for _, permLevel in pairs(permission) do
            if IsPlayerAceAllowed(source, permLevel) then return true end
        end
    end

    return false
end

function PlusCore.func.GetPermission(source)
    local src = source
    local perms = {}
    for _, v in pairs (PlusCore.Config.Server.Permissions) do
        if IsPlayerAceAllowed(src, v) then
            perms[v] = true
        end
    end
    return perms
end

-- Opt in or out of admin reports

function PlusCore.func.IsOptin(source)
    local license = PlusCore.func.GetIdentifier(source, 'license')
    if not license or not PlusCore.func.HasPermission(source, 'admin') then return false end
    local Player = PlusCore.func.GetPlayer(source)
    return Player.UserData.optin
end

function PlusCore.func.ToggleOptin(source)
    local license = PlusCore.func.GetIdentifier(source, 'license')
    if not license or not PlusCore.func.HasPermission(source, 'admin') then return end
    local Player = PlusCore.func.GetPlayer(source)
    Player.UserData.optin = not Player.UserData.optin
    Player.Functions.SetUserData('optin', Player.UserData.optin)
end

-- Check if player is banned

function PlusCore.func.IsPlayerBanned(source)
    local plicense = PlusCore.func.GetIdentifier(source, 'license')
    local result = MySQL.single.await('SELECT * FROM bans WHERE license = ?', { plicense })
    if not result then return false end
    if os.time() < result.expire then
        local timeTable = os.date('*t', tonumber(result.expire))
        return true, 'You have been banned from the server:\n' .. result.reason .. '\nYour ban expires ' .. timeTable.day .. '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour .. ':' .. timeTable.min .. '\n'
    else
        MySQL.query('DELETE FROM bans WHERE id = ?', { result.id })
    end
    return false
end

-- Check for duplicate license

function PlusCore.func.IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license') then
                if id == license then
                    return true
                end
            end
        end
    end
    return false
end

-- Utility functions

function PlusCore.func.HasItem(source, items, amount)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:HasItem(source, items, amount)
end

function PlusCore.func.Notify(source, text, type, length)
    TriggerClientEvent('PlusCore:Notify', source, text, type, length)
end
