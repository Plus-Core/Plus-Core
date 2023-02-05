PlusCore.Users = {}
PlusCore.User = {}

-- On player login get their data or set defaults
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function PlusCore.User.Login(source, citizenid, newData)
    if source and source ~= '' then
        if citizenid then
            local license = PlusCore.func.GetIdentifier(source, 'license')
            local UserData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
            if UserData and license == UserData.license then
                UserData.money = json.decode(UserData.money)
                UserData.job = json.decode(UserData.job)
                UserData.position = json.decode(UserData.position)
                UserData.metadata = json.decode(UserData.metadata)
                UserData.charinfo = json.decode(UserData.charinfo)
                if UserData.gang then
                    UserData.gang = json.decode(UserData.gang)
                else
                    UserData.gang = {}
                end
                PlusCore.User.CheckUserData(source, UserData)
            else
                DropPlayer(source, Lang:t("info.exploit_dropped"))
                TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Joining Exploit', false)
            end
        else
            PlusCore.User.CheckUserData(source, newData)
        end
        return true
    else
        PlusCoreShowError(GetCurrentResourceName(), 'ERROR PlusCore.User.LOGIN - NO SOURCE GIVEN!')
        return false
    end
end

function PlusCore.User.GetOfflinePlayer(citizenid)
    if citizenid then
        local UserData = MySQL.Sync.prepare('SELECT * FROM players where citizenid = ?', {citizenid})
        if UserData then
            UserData.money = json.decode(UserData.money)
            UserData.job = json.decode(UserData.job)
            UserData.position = json.decode(UserData.position)
            UserData.metadata = json.decode(UserData.metadata)
            UserData.charinfo = json.decode(UserData.charinfo)
            if UserData.gang then
                UserData.gang = json.decode(UserData.gang)
            else
                UserData.gang = {}
            end

            return PlusCore.User.CheckUserData(nil, UserData)
        end
    end
    return nil
end

function PlusCore.User.CheckUserData(source, UserData)
    UserData = UserData or {}
    local Offline = true
    if source then
        UserData.source = source
        UserData.license = UserData.license or PlusCore.func.GetIdentifier(source, 'license')
        UserData.name = GetPlayerName(source)
        Offline = false
    end

    UserData.citizenid = UserData.citizenid or PlusCore.User.CreateCitizenId()
    UserData.cid = UserData.cid or 1
    UserData.money = UserData.money or {}
    UserData.optin = UserData.optin or true
    for moneytype, startamount in pairs(PlusCore.Config.Money.MoneyTypes) do
        UserData.money[moneytype] = UserData.money[moneytype] or startamount
    end

    -- Charinfo
    UserData.charinfo = UserData.charinfo or {}
    UserData.charinfo.firstname = UserData.charinfo.firstname or 'Firstname'
    UserData.charinfo.lastname = UserData.charinfo.lastname or 'Lastname'
    UserData.charinfo.birthdate = UserData.charinfo.birthdate or '00-00-0000'
    UserData.charinfo.gender = UserData.charinfo.gender or 0
    UserData.charinfo.backstory = UserData.charinfo.backstory or 'placeholder backstory'
    UserData.charinfo.nationality = UserData.charinfo.nationality or 'USA'
    UserData.charinfo.phone = UserData.charinfo.phone or PlusCore.func.CreatePhoneNumber()
    UserData.charinfo.account = UserData.charinfo.account or PlusCore.func.CreateAccountNumber()
    -- Metadata
    UserData.metadata = UserData.metadata or {}
    UserData.metadata['hunger'] = UserData.metadata['hunger'] or 100
    UserData.metadata['thirst'] = UserData.metadata['thirst'] or 100
    UserData.metadata['stress'] = UserData.metadata['stress'] or 0
    UserData.metadata['isdead'] = UserData.metadata['isdead'] or false
    UserData.metadata['inlaststand'] = UserData.metadata['inlaststand'] or false
    UserData.metadata['armor'] = UserData.metadata['armor'] or 0
    UserData.metadata['ishandcuffed'] = UserData.metadata['ishandcuffed'] or false
    UserData.metadata['tracker'] = UserData.metadata['tracker'] or false
    UserData.metadata['injail'] = UserData.metadata['injail'] or 0
    UserData.metadata['jailitems'] = UserData.metadata['jailitems'] or {}
    UserData.metadata['status'] = UserData.metadata['status'] or {}
    UserData.metadata['phone'] = UserData.metadata['phone'] or {}
    UserData.metadata['fitbit'] = UserData.metadata['fitbit'] or {}
    UserData.metadata['commandbinds'] = UserData.metadata['commandbinds'] or {}
    UserData.metadata['bloodtype'] = UserData.metadata['bloodtype'] or PlusCore.Config.Player.Bloodtypes[math.random(1, #PlusCore.Config.Player.Bloodtypes)]
    UserData.metadata['dealerrep'] = UserData.metadata['dealerrep'] or 0
    UserData.metadata['craftingrep'] = UserData.metadata['craftingrep'] or 0
    UserData.metadata['attachmentcraftingrep'] = UserData.metadata['attachmentcraftingrep'] or 0
    UserData.metadata['currentapartment'] = UserData.metadata['currentapartment'] or nil
    UserData.metadata['jobrep'] = UserData.metadata['jobrep'] or {}
    UserData.metadata['jobrep']['tow'] = UserData.metadata['jobrep']['tow'] or 0
    UserData.metadata['jobrep']['trucker'] = UserData.metadata['jobrep']['trucker'] or 0
    UserData.metadata['jobrep']['taxi'] = UserData.metadata['jobrep']['taxi'] or 0
    UserData.metadata['jobrep']['hotdog'] = UserData.metadata['jobrep']['hotdog'] or 0
    UserData.metadata['callsign'] = UserData.metadata['callsign'] or 'NO CALLSIGN'
    UserData.metadata['fingerprint'] = UserData.metadata['fingerprint'] or PlusCore.User.CreateFingerId()
    UserData.metadata['walletid'] = UserData.metadata['walletid'] or PlusCore.User.CreateWalletId()
    UserData.metadata['criminalrecord'] = UserData.metadata['criminalrecord'] or {
        ['hasRecord'] = false,
        ['date'] = nil
    }
    UserData.metadata['licences'] = UserData.metadata['licences'] or {
        ['driver'] = true,
        ['business'] = false,
        ['weapon'] = false
    }
    UserData.metadata['inside'] = UserData.metadata['inside'] or {
        house = nil,
        apartment = {
            apartmentType = nil,
            apartmentId = nil,
        }
    }
    UserData.metadata['phonedata'] = UserData.metadata['phonedata'] or {
        SerialNumber = PlusCore.User.CreateSerialNumber(),
        InstalledApps = {},
    }
    -- Job
    if UserData.job and UserData.job.name and not PlusCore.Shared.Jobs[UserData.job.name] then UserData.job = nil end
    UserData.job = UserData.job or {}
    UserData.job.name = UserData.job.name or 'unemployed'
    UserData.job.label = UserData.job.label or 'Civilian'
    UserData.job.payment = UserData.job.payment or 10
    UserData.job.type = UserData.job.type or 'none'
    if PlusCore.Shared.ForceJobDefaultDutyAtLogin or UserData.job.onduty == nil then
        UserData.job.onduty = PlusCore.Shared.Jobs[UserData.job.name].defaultDuty
    end
    UserData.job.isboss = UserData.job.isboss or false
    UserData.job.grade = UserData.job.grade or {}
    UserData.job.grade.name = UserData.job.grade.name or 'Freelancer'
    UserData.job.grade.level = UserData.job.grade.level or 0
    -- Gang
    if UserData.gang and UserData.gang.name and not PlusCore.Shared.Gangs[UserData.gang.name] then UserData.gang = nil end
    UserData.gang = UserData.gang or {}
    UserData.gang.name = UserData.gang.name or 'none'
    UserData.gang.label = UserData.gang.label or 'No Gang Affiliaton'
    UserData.gang.isboss = UserData.gang.isboss or false
    UserData.gang.grade = UserData.gang.grade or {}
    UserData.gang.grade.name = UserData.gang.grade.name or 'none'
    UserData.gang.grade.level = UserData.gang.grade.level or 0
    -- Other
    UserData.position = UserData.position or PlusConfig.DefaultSpawn
    UserData.items = GetResourceState('qb-inventory') ~= 'missing' and exports['qb-inventory']:LoadInventory(UserData.source, UserData.citizenid) or {}
    return PlusCore.User.CreatePlayer(UserData, Offline)
end

-- On player logout

function PlusCore.User.Logout(source)
    TriggerClientEvent('PlusCore:Client:OnPlayerUnload', source)
    TriggerEvent('PlusCore:Server:OnPlayerUnload', source)
    TriggerClientEvent('PlusCore:Player:UpdateUserData', source)
    Wait(200)
    PlusCore.Users[source] = nil
end

-- Create a new character
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function PlusCore.User.CreatePlayer(UserData, Offline)
    local self = {}
    self.Functions = {}
    self.UserData = UserData
    self.Offline = Offline

    function self.Functions.UpdateUserData()
        if self.Offline then return end -- Unsupported for Offline Players
        TriggerEvent('PlusCore:Player:SetUserData', self.UserData)
        TriggerClientEvent('PlusCore:Player:SetUserData', self.UserData.source, self.UserData)
    end

    function self.Functions.SetJob(job, grade)
        job = job:lower()
        grade = tostring(grade) or '0'
        if not PlusCore.Shared.Jobs[job] then return false end
        self.UserData.job.name = job
        self.UserData.job.label = PlusCore.Shared.Jobs[job].label
        self.UserData.job.onduty = PlusCore.Shared.Jobs[job].defaultDuty
        self.UserData.job.type = PlusCore.Shared.Jobs[job].type or 'none'
        if PlusCore.Shared.Jobs[job].grades[grade] then
            local jobgrade = PlusCore.Shared.Jobs[job].grades[grade]
            self.UserData.job.grade = {}
            self.UserData.job.grade.name = jobgrade.name
            self.UserData.job.grade.level = tonumber(grade)
            self.UserData.job.payment = jobgrade.payment or 30
            self.UserData.job.isboss = jobgrade.isboss or false
        else
            self.UserData.job.grade = {}
            self.UserData.job.grade.name = 'No Grades'
            self.UserData.job.grade.level = 0
            self.UserData.job.payment = 30
            self.UserData.job.isboss = false
        end

        if not self.Offline then
            self.Functions.UpdateUserData()
            TriggerEvent('PlusCore:Server:OnJobUpdate', self.UserData.source, self.UserData.job)
            TriggerClientEvent('PlusCore:Client:OnJobUpdate', self.UserData.source, self.UserData.job)
        end

        return true
    end

    function self.Functions.SetGang(gang, grade)
        gang = gang:lower()
        grade = tostring(grade) or '0'
        if not PlusCore.Shared.Gangs[gang] then return false end
        self.UserData.gang.name = gang
        self.UserData.gang.label = PlusCore.Shared.Gangs[gang].label
        if PlusCore.Shared.Gangs[gang].grades[grade] then
            local ganggrade = PlusCore.Shared.Gangs[gang].grades[grade]
            self.UserData.gang.grade = {}
            self.UserData.gang.grade.name = ganggrade.name
            self.UserData.gang.grade.level = tonumber(grade)
            self.UserData.gang.isboss = ganggrade.isboss or false
        else
            self.UserData.gang.grade = {}
            self.UserData.gang.grade.name = 'No Grades'
            self.UserData.gang.grade.level = 0
            self.UserData.gang.isboss = false
        end

        if not self.Offline then
            self.Functions.UpdateUserData()
            TriggerEvent('PlusCore:Server:OnGangUpdate', self.UserData.source, self.UserData.gang)
            TriggerClientEvent('PlusCore:Client:OnGangUpdate', self.UserData.source, self.UserData.gang)
        end

        return true
    end

    function self.Functions.SetJobDuty(onDuty)
        self.UserData.job.onduty = not not onDuty -- Make sure the value is a boolean if nil is sent
        self.Functions.UpdateUserData()
    end

    function self.Functions.SetUserData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.UserData[key] = val
        self.Functions.UpdateUserData()
    end

    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = val > 100 and 100 or val
        end
        self.UserData.metadata[meta] = val
        self.Functions.UpdateUserData()
    end

    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.UserData.metadata[meta]
    end

    function self.Functions.AddJobReputation(amount)
        if not amount then return end
        amount = tonumber(amount)
        self.UserData.metadata['jobrep'][self.UserData.job.name] = self.UserData.metadata['jobrep'][self.UserData.job.name] + amount
        self.Functions.UpdateUserData()
    end

    function self.Functions.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.UserData.money[moneytype] then return false end
        self.UserData.money[moneytype] = self.UserData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdateUserData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.UserData.source) .. ' (citizenid: ' .. self.UserData.citizenid .. ' | id: ' .. self.UserData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.UserData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.UserData.source) .. ' (citizenid: ' .. self.UserData.citizenid .. ' | id: ' .. self.UserData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.UserData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.UserData.source, moneytype, amount, false)
            TriggerClientEvent('PlusCore:Client:OnMoneyChange', self.UserData.source, moneytype, amount, "add", reason)
            TriggerEvent('PlusCore:Server:OnMoneyChange', self.UserData.source, moneytype, amount, "add", reason)
        end

        return true
    end

    function self.Functions.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.UserData.money[moneytype] then return false end
        for _, mtype in pairs(PlusCore.Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.UserData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        self.UserData.money[moneytype] = self.UserData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdateUserData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.UserData.source) .. ' (citizenid: ' .. self.UserData.citizenid .. ' | id: ' .. self.UserData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.UserData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.UserData.source) .. ' (citizenid: ' .. self.UserData.citizenid .. ' | id: ' .. self.UserData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.UserData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.UserData.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.UserData.source, amount)
            end
            TriggerClientEvent('PlusCore:Client:OnMoneyChange', self.UserData.source, moneytype, amount, "remove", reason)
            TriggerEvent('PlusCore:Server:OnMoneyChange', self.UserData.source, moneytype, amount, "remove", reason)
        end

        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return false end
        if not self.UserData.money[moneytype] then return false end
        local difference = amount - self.UserData.money[moneytype]
        self.UserData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdateUserData()
            TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.UserData.source) .. ' (citizenid: ' .. self.UserData.citizenid .. ' | id: ' .. self.UserData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.UserData.money[moneytype] .. ' reason: ' .. reason)
            TriggerClientEvent('hud:client:OnMoneyChange', self.UserData.source, moneytype, math.abs(difference), difference < 0)
            TriggerClientEvent('PlusCore:Client:OnMoneyChange', self.UserData.source, moneytype, amount, "set", reason)
            TriggerEvent('PlusCore:Server:OnMoneyChange', self.UserData.source, moneytype, amount, "set", reason)
        end

        return true
    end

    function self.Functions.GetMoney(moneytype)
        if not moneytype then return false end
        moneytype = moneytype:lower()
        return self.UserData.money[moneytype]
    end

    function self.Functions.SetCreditCard(cardNumber)
        self.UserData.charinfo.card = cardNumber
        self.Functions.UpdateUserData()
    end

    function self.Functions.GetCardSlot(cardNumber, cardType)
        local item = tostring(cardType):lower()
        local slots = exports['qb-inventory']:GetSlotsByItem(self.UserData.items, item)
        for _, slot in pairs(slots) do
            if slot then
                if self.UserData.items[slot].info.cardNumber == cardNumber then
                    return slot
                end
            end
        end
        return nil
    end

    function self.Functions.Save()
        if self.Offline then
            PlusCore.User.SaveOffline(self.UserData)
        else
            PlusCore.User.Save(self.UserData.source)
        end
    end

    function self.Functions.Logout()
        if self.Offline then return end -- Unsupported for Offline Players
        PlusCore.User.Logout(self.UserData.source)
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    if self.Offline then
        return self
    else
        PlusCore.Users[self.UserData.source] = self
        PlusCore.User.Save(self.UserData.source)

        -- At this point we are safe to emit new instance to third party resource for load handling
        TriggerEvent('PlusCore:Server:PlayerLoaded', self)
        self.Functions.UpdateUserData()
    end
end

-- Add a new function to the Functions table of the player class
-- Use-case:
--[[
    AddEventHandler('PlusCore:Server:PlayerLoaded', function(Player)
        PlusCore.func.AddPlayerMethod(Player.UserData.source, "functionName", function(oneArg, orMore)
            -- do something here
        end)
    end)
]]

function PlusCore.func.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(PlusCore.Users) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not PlusCore.Users[ids] then return end

            PlusCore.Users[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            PlusCore.func.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

-- Add a new field table of the player class
-- Use-case:
--[[
    AddEventHandler('PlusCore:Server:PlayerLoaded', function(Player)
        PlusCore.func.AddPlayerField(Player.UserData.source, "fieldName", "fieldData")
    end)
]]

function PlusCore.func.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(PlusCore.Users) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not PlusCore.Users[ids] then return end

            PlusCore.Users[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            PlusCore.func.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

-- Save player info to database (make sure citizenid is the primary key in your database)

function PlusCore.User.Save(source)
    local ped = GetPlayerPed(source)
    local pcoords = GetEntityCoords(ped)
    local UserData = PlusCore.Users[source].UserData
    if UserData then
        MySQL.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
            citizenid = UserData.citizenid,
            cid = tonumber(UserData.cid),
            license = UserData.license,
            name = UserData.name,
            money = json.encode(UserData.money),
            charinfo = json.encode(UserData.charinfo),
            job = json.encode(UserData.job),
            gang = json.encode(UserData.gang),
            position = json.encode(pcoords),
            metadata = json.encode(UserData.metadata)
        })
        if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(source) end
        PlusCoreShowSuccess(GetCurrentResourceName(), UserData.name .. ' PLAYER SAVED!')
    else
        PlusCoreShowError(GetCurrentResourceName(), 'ERROR PlusCore.User.SAVE - UserData IS EMPTY!')
    end
end

function PlusCore.User.SaveOffline(UserData)
    if UserData then
        MySQL.Async.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
            citizenid = UserData.citizenid,
            cid = tonumber(UserData.cid),
            license = UserData.license,
            name = UserData.name,
            money = json.encode(UserData.money),
            charinfo = json.encode(UserData.charinfo),
            job = json.encode(UserData.job),
            gang = json.encode(UserData.gang),
            position = json.encode(UserData.position),
            metadata = json.encode(UserData.metadata)
        })
        if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(UserData, true) end
        PlusCoreShowSuccess(GetCurrentResourceName(), UserData.name .. ' OFFLINE PLAYER SAVED!')
    else
        PlusCoreShowError(GetCurrentResourceName(), 'ERROR PlusCore.User.SAVEOFFLINE - UserData IS EMPTY!')
    end
end

-- Delete character

local playertables = { -- Add tables as needed
    { table = 'players' },
    { table = 'apartments' },
    { table = 'bank_accounts' },
    { table = 'crypto_transactions' },
    { table = 'phone_invoices' },
    { table = 'phone_messages' },
    { table = 'playerskins' },
    { table = 'player_contacts' },
    { table = 'player_houses' },
    { table = 'player_mails' },
    { table = 'player_outfits' },
    { table = 'player_vehicles' }
}

function PlusCore.User.DeleteCharacter(source, citizenid)
    local license = PlusCore.func.GetIdentifier(source, 'license')
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if license == result then
        local query = "DELETE FROM %s WHERE citizenid = ?"
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)

        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = {query = query:format(v.table), values = { citizenid }}
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red', '**' .. GetPlayerName(source) .. '** ' .. license .. ' deleted **' .. citizenid .. '**..')
            end
        end)
    else
        DropPlayer(source, Lang:t("info.exploit_dropped"))
        TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
    end
end

function PlusCore.User.ForceDeleteCharacter(citizenid)
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if result then
        local query = "DELETE FROM %s WHERE citizenid = ?"
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)
        local Player = PlusCore.func.GetPlayerByCitizenId(citizenid)

        if Player then
            DropPlayer(Player.UserData.source, "An admin deleted the character which you are currently using")
        end
        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = {query = query:format(v.table), values = { citizenid }}
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red', 'Character **' .. citizenid .. '** got deleted')
            end
        end)
    end
end

-- Inventory Backwards Compatibility

function PlusCore.User.SaveInventory(source)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:SaveInventory(source, false)
end

function PlusCore.User.SaveOfflineInventory(UserData)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:SaveInventory(UserData, true)
end

function PlusCore.User.GetTotalWeight(items)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetTotalWeight(items)
end

function PlusCore.User.GetSlotsByItem(items, itemName)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetSlotsByItem(items, itemName)
end

function PlusCore.User.GetFirstSlotByItem(items, itemName)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetFirstSlotByItem(items, itemName)
end

-- Util Functions

function PlusCore.User.CreateCitizenId()
    local UniqueFound = false
    local CitizenId = nil
    while not UniqueFound do
        CitizenId = tostring(PlusCore.Shared.RandomStr(3) .. PlusCore.Shared.RandomInt(5)):upper()
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE citizenid = ?', { CitizenId })
        if result == 0 then
            UniqueFound = true
        end
    end
    return CitizenId
end

function PlusCore.func.CreateAccountNumber()
    local UniqueFound = false
    local AccountNumber = nil
    while not UniqueFound do
        AccountNumber = 'US0' .. math.random(1, 9) .. 'PlusCore' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
        local query = '%' .. AccountNumber .. '%'
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE charinfo LIKE ?', { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return AccountNumber
end

function PlusCore.func.CreatePhoneNumber()
    local UniqueFound = false
    local PhoneNumber = nil
    while not UniqueFound do
        PhoneNumber = math.random(100,999) .. math.random(1000000,9999999)
        local query = '%' .. PhoneNumber .. '%'
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE charinfo LIKE ?', { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return PhoneNumber
end

function PlusCore.User.CreateFingerId()
    local UniqueFound = false
    local FingerId = nil
    while not UniqueFound do
        FingerId = tostring(PlusCore.Shared.RandomStr(2) .. PlusCore.Shared.RandomInt(3) .. PlusCore.Shared.RandomStr(1) .. PlusCore.Shared.RandomInt(2) .. PlusCore.Shared.RandomStr(3) .. PlusCore.Shared.RandomInt(4))
        local query = '%' .. FingerId .. '%'
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM `players` WHERE `metadata` LIKE ?', { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return FingerId
end

function PlusCore.User.CreateWalletId()
    local UniqueFound = false
    local WalletId = nil
    while not UniqueFound do
        WalletId = 'QB-' .. math.random(11111111, 99999999)
        local query = '%' .. WalletId .. '%'
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?', { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return WalletId
end

function PlusCore.User.CreateSerialNumber()
    local UniqueFound = false
    local SerialNumber = nil
    while not UniqueFound do
        SerialNumber = math.random(11111111, 99999999)
        local query = '%' .. SerialNumber .. '%'
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?', { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return SerialNumber
end

PaycheckInterval() -- This starts the paycheck system
