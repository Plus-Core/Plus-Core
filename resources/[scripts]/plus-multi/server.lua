------------------ QBCore ------------------------------------

RegisterNetEvent("Creator:setPlayerToBucket")
AddEventHandler("Creator:setPlayerToBucket", function(id)
    SetPlayerRoutingBucket(source, id)
end)
RegisterNetEvent("Creator:setPlayerToNormalBucket")
AddEventHandler("Creator:setPlayerToNormalBucket", function()
    SetPlayerRoutingBucket(source, 0)
end)









local PlusCore = exports['plus-core']:GetCore()

-- Functions

RegisterNetEvent('qb-multicharacter:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    if PlusCore.User.Login(src, false, newData) then
         print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
	end
end)

PlusCore.func.CreateCallback("plus-multi:dashboard",function (source,cb)
    local tabletoreturn = {}
    local policecount = 0
    local onlinecount = 0
    local emscount = 0

    for k, v in pairs(PlusCore.func.GetPlayers()) do
        onlinecount = onlinecount +1

        local xPlayer = PlusCore.func.GetPlayer(v)
        if xPlayer.PlayerData.job.name == "police" and xPlayer.PlayerData.job.onduty then
            policecount = policecount +1
        elseif xPlayer.PlayerData.job.name == "ambulance" and xPlayer.PlayerData.job.onduty then
            emscount = emscount + 1
        end
    end

    tabletoreturn["online"] = onlinecount
    tabletoreturn["ems"] = emscount
    tabletoreturn["police"] = policecount
    cb(tabletoreturn)
end)

local function GiveStarterItems(source)
    local src = source
    local Player = PlusCore.func.GetPlayer(src)

    for k, v in pairs(PlusCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
        end
        Player.Functions.AddItem(v.item, v.amount, false, info)
    end
end

local function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
    local result = MySQL.Sync.fetchAll('SELECT * FROM houselocations', {})
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = v.owned,
                price = v.price,
                locked = true,
                adress = v.label,
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage,
            }
        end
    end
    TriggerClientEvent("qb-garages:client:houseGarageConfig", -1, HouseGarages)
    TriggerClientEvent("qb-houses:client:setHouseConfig", -1, Houses)
end

-- Commands


PlusCore.Commands.Add("closeNUI", "Close Multi NUI", {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-multicharacter:client:closeNUI', src)
end)

-- Events

RegisterNetEvent('qb-multicharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "You have disconnected")
end)

RegisterNetEvent('qb-multicharacter:server:loadUserData', function(cData)
    local src = source
    if PlusCore.User.Login(src, cData.citizenid) then
        print('^2[qb-core]^7 ' .. GetPlayerName(src) .. ' (Citizen ID: ' .. cData.citizenid ..
            ') has succesfully loaded!')
        PlusCore.Commands.Refresh(src)
        loadHouseData()
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("qb-log:server:CreateLog", "joinleave", "Loaded", "green",
            "**" ..
            GetPlayerName(src) ..
            "** (" ..
            (PlusCore.func.GetIdentifier(src, 'discord') or 'undefined') ..
            " |  ||" ..
            (PlusCore.func.GetIdentifier(src, 'ip') or 'undefined') ..
            "|| | " ..
            (PlusCore.func.GetIdentifier(src, 'license') or 'undefined') ..
            " | " .. cData.citizenid .. " | " .. src .. ") loaded..")
    end
end)

RegisterNetEvent('qb-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    print(src, citizenid)
    PlusCore.User.DeleteCharacter(src, citizenid)

end)

-- Callbacks

RegisterNetEvent("plus-multi:spawn",function (cData)
    local src = source
    if PlusCore.User.Login(src, cData.citizenid) then
        print('^2[qb-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        PlusCore.Commands.Refresh(src)
        loadHouseData()
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("qb-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..(PlusCore.func.GetIdentifier(src, 'discord') or 'undefined') .." |  ||"  ..(PlusCore.func.GetIdentifier(src, 'ip') or 'undefined') ..  "|| | " ..(PlusCore.func.GetIdentifier(src, 'license') or 'undefined') .." | " ..cData.citizenid.." | "..src..") loaded..")
	end
end)

RegisterNetEvent("plus-multi:create:spawn",function (newData)
    local src = source
    local randbucket = (GetPlayerPed(src) .. math.random(1,999))
    SetPlayerRoutingBucket(src, randbucket)
    print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
    PlusCore.Commands.Refresh(src)
    loadHouseData()
    TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
    GiveStarterItems(src)
    
end)

PlusCore.func.CreateCallback('qb-multi:server:GetCurrentPlayers', function(source, cb)
    local TotalPlayers = 0
    for k, v in pairs(PlusCore.func.GetPlayers()) do
        TotalPlayers = TotalPlayers + 1
    end
    cb(TotalPlayers)
end)

PlusCore.func.CreateCallback("qb-multicharacter:server:GetUserCharacters", function(source, cb)
    local src = source
    local license = PlusCore.func.GetIdentifier(src, 'license')

    MySQL.Async.execute('SELECT * FROM players WHERE license = ?', { license }, function(result)
        cb(result)
    end)
end)

PlusCore.func.CreateCallback("qb-multicharacter:server:GetServerLogs", function(source, cb)
    MySQL.Async.execute('SELECT * FROM server_logs', {}, function(result)
        cb(result)
    end)
end)

PlusCore.func.CreateCallback("qb-multicharacter:server:GetNumberOfCharacters", function(source, cb)
    local src = source
    local license = PlusCore.func.GetIdentifier(src, 'license')
    local numOfChars = 0

    if next(Config.PlayersNumberOfCharacters) then
        for i, v in pairs(Config.PlayersNumberOfCharacters) do
            if v.license == license then
                numOfChars = v.numberOfChars
                break
            else
                numOfChars = Config.DefaultNumberOfCharacters
            end
        end
    else
        numOfChars = Config.DefaultNumberOfCharacters
    end
    cb(numOfChars)
end)

PlusCore.func.CreateCallback("qb-multicharacter:server:setupCharacters", function(source, cb)
    local license = PlusCore.func.GetIdentifier(source, 'license')
    local plyChars = {}
    MySQL.Async.fetchAll('SELECT * FROM players WHERE license = ?', { license }, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)
            plyChars[#plyChars + 1] = result[i]
        end
        cb(plyChars)
    end)
end)

PlusCore.func.CreateCallback("qb-multicharacter:server:getSkin", function(source, cb, cid)
    local result = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1})
    if result[1] ~= nil then
        cb(json.decode(result[1].skin))
    else
        cb(nil)
    end
end)