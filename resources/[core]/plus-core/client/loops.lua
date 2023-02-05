CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * PlusCoreConfig.UpdateInterval
            TriggerServerEvent('PlusCore:UpdatePlayer')
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if (PlusCore.UserData.metadata['hunger'] <= 0 or PlusCore.UserData.metadata['thirst'] <= 0) and not PlusCore.UserData.metadata['isdead'] then
                local ped = PlayerPedId()
                local currentHealth = GetEntityHealth(ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(ped, currentHealth - decreaseThreshold)
            end
        end
        Wait(PlusCoreConfig.StatusInterval)
    end
end)
