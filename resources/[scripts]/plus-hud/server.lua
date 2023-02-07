local PlusCore = exports['plus-core']:GetCore()
local ResetStress = false

PlusCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source, _)
    local Player = PlusCore.func.GetPlayer(source)
    local cashamount = User.UserData.money.cash
    TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', cashamount)
end)

PlusCore.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source, _)
    local Player = PlusCore.func.GetPlayer(source)
    local bankamount = User.UserData.money.bank
    TriggerClientEvent('hud:client:ShowAccounts', source, 'bank', bankamount)
end)

PlusCore.Commands.Add("dev", "Enable/Disable developer Mode", {}, false, function(source, _)
    TriggerClientEvent("qb-admin:client:ToggleDevmode", source)
end, 'admin')

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local Player = PlusCore.func.GetPlayer(src)
    local newStress
    if not Player or (Config.DisablePoliceStress and User.UserData.job.name == 'police') then return end
    if not ResetStress then
        if not User.UserData.metadata['stress'] then
            User.UserData.metadata['stress'] = 0
        end
        newStress = User.UserData.metadata['stress'] + amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('PlusCore:Notify', src, Lang:t("notify.stress_gain"), 'error', 1500)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = PlusCore.func.GetPlayer(src)
    local newStress
    if not Player then return end
    if not ResetStress then
        if not User.UserData.metadata['stress'] then
            User.UserData.metadata['stress'] = 0
        end
        newStress = User.UserData.metadata['stress'] - amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('PlusCore:Notify', src, Lang:t("notify.stress_removed"))
end)

PlusCore.func.CreateCallback('hud:server:getMenu', function(_, cb)
    cb(Config.Menu)
end)
