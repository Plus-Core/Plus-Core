-- Add or change (a) method(s) in the PlusCore.func table
local function SetMethod(methodName, handler)
    if type(methodName) ~= "string" then
        return false, "invalid_method_name"
    end

    PlusCore.func[methodName] = handler

    TriggerEvent('PlusCore:Server:UpdateObject')

    return true, "success"
end

PlusCore.func.SetMethod = SetMethod
exports("SetMethod", SetMethod)

-- Add or change (a) field(s) in the PlusCore table
local function SetField(fieldName, data)
    if type(fieldName) ~= "string" then
        return false, "invalid_field_name"
    end

    PlusCore[fieldName] = data

    TriggerEvent('PlusCore:Server:UpdateObject')

    return true, "success"
end

PlusCore.func.SetField = SetField
exports("SetField", SetField)

-- Single add job function which should only be used if you planning on adding a single job
local function AddJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if PlusCore.Shared.Jobs[jobName] then
        return false, "job_exists"
    end

    PlusCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.AddJob = AddJob
exports('AddJob', AddJob)

-- Multiple Add Jobs
local function AddJobs(jobs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(jobs) do
        if type(key) ~= "string" then
            message = 'invalid_job_name'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        if PlusCore.Shared.Jobs[key] then
            message = 'job_exists'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        PlusCore.Shared.Jobs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('PlusCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, message, nil
end

PlusCore.func.AddJobs = AddJobs
exports('AddJobs', AddJobs)

-- Single Remove Job
local function RemoveJob(jobName)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not PlusCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    PlusCore.Shared.Jobs[jobName] = nil

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.RemoveJob = RemoveJob
exports('RemoveJob', RemoveJob)

-- Single Update Job
local function UpdateJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not PlusCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    PlusCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

-- Single add item
local function AddItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if PlusCore.Shared.Items[itemName] then
        return false, "item_exists"
    end

    PlusCore.Shared.Items[itemName] = item

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.AddItem = AddItem
exports('AddItem', AddItem)

-- Single update item
local function UpdateItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end
    if not PlusCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end
    PlusCore.Shared.Items[itemName] = item
    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

-- Multiple Add Items
local function AddItems(items)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if PlusCore.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        PlusCore.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('PlusCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, message, nil
end

PlusCore.func.AddItems = AddItems
exports('AddItems', AddItems)

-- Single Remove Item
local function RemoveItem(itemName)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if not PlusCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end

    PlusCore.Shared.Items[itemName] = nil

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

-- Single Add Gang
local function AddGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if PlusCore.Shared.Gangs[gangName] then
        return false, "gang_exists"
    end

    PlusCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.AddGang = AddGang
exports('AddGang', AddGang)

-- Multiple Add Gangs
local function AddGangs(gangs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(gangs) do
        if type(key) ~= "string" then
            message = "invalid_gang_name"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        if PlusCore.Shared.Gangs[key] then
            message = "gang_exists"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        PlusCore.Shared.Gangs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('PlusCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, message, nil
end

PlusCore.func.AddGangs = AddGangs
exports('AddGangs', AddGangs)

-- Single Remove Gang
local function RemoveGang(gangName)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not PlusCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    PlusCore.Shared.Gangs[gangName] = nil

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.RemoveGang = RemoveGang
exports('RemoveGang', RemoveGang)

-- Single Update Gang
local function UpdateGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not PlusCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    PlusCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('PlusCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('PlusCore:Server:UpdateObject')
    return true, "success"
end

PlusCore.func.UpdateGang = UpdateGang
exports('UpdateGang', UpdateGang)

local function GetCoreVersion(InvokingResource)
    local resourceVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
    if InvokingResource and InvokingResource ~= '' then
        print(("%s called PlusCore version check: %s"):format(InvokingResource or 'Unknown Resource', resourceVersion))
    end
    return resourceVersion
end

PlusCore.func.GetCoreVersion = GetCoreVersion
exports('GetCoreVersion', GetCoreVersion)

local function ExploitBan(playerId, origin)
    local name = GetPlayerName(playerId)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        name,
        PlusCore.func.GetIdentifier(playerId, 'license'),
        PlusCore.func.GetIdentifier(playerId, 'discord'),
        PlusCore.func.GetIdentifier(playerId, 'ip'),
        origin,
        2147483647,
        'Anti Cheat'
    })
    DropPlayer(playerId, Lang:t('info.exploit_banned', {discord = PlusCore.Config.Server.Discord}))
    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Anti-Cheat", "red", name .. " has been banned for exploiting " .. origin, true)
end

exports('ExploitBan', ExploitBan)
