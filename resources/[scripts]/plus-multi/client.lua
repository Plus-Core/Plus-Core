local PlusCore = exports['plus-core']:GetCore()


CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            DoScreenFadeOut(0)
            TriggerEvent('plus-multi:client:load')
            return
        end
    end
end)

local stop = false
local allpeds = {}
local selectedped = 0
local cid = 0
local createddata = 0

AddEventHandler("onResourceStop", function(resourfce)
    if resourfce == GetCurrentResourceName() then
        for k, v in pairs(allpeds) do
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
    end

end)

AddEventHandler("plus-multi:gottospawn", function(Ped)
    choixpoitionfunction(createddata, Ped)
end)
local goahead = false
AddEventHandler("plus-multi:delete", function(data, Ped)
    stop = true

    while true do
        Wait(14)
        for m, object in pairs(GetGamePool("CObject")) do
            if GetEntityModel(object) == -1278649385 then
                SetEntityAsMissionEntity(object, true, true)
                DeleteEntity(object)
                goahead = true
            end
        end
        if goahead then
            break
        end
    end

    Wait(800)
    for k, v in pairs(allpeds) do
        if v ~= Ped then
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
    end
    choixpoitionfunction2(data, Ped)
end)

AddEventHandler("plus-multi:create", function(Ped, x, y, z, w)
    TriggerEvent("plus-multi:do:delete")
    if GetEntityModel(Ped) == GetHashKey("mp_m_freemode_01") then
        local model = 'mp_m_freemode_01'
        if IsModelInCdimage(model) and IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
        end
        Ped = PlayerPedId()
        SetPedComponentVariation(Ped, 3, 15, 0, 2) -- arms
        SetPedComponentVariation(Ped, 11, 15, 0, 2) -- torso
        SetPedComponentVariation(Ped, 8, 15, 0, 2) -- tshirt
        SetPedComponentVariation(Ped, 4, 61, 4, 2) -- pants
        SetPedComponentVariation(Ped, 6, 34, 0, 2) -- shoes
        local dict = loadDict('timetable@ron@ig_5_p3')
        TaskPlayAnim(Ped, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
        SetEntityVisible(PlayerPedId(), true)
        SetEntityInvincible(PlayerPedId(), true)
    else
        local model = 'mp_f_freemode_01'
        if IsModelInCdimage(model) and IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
        end
        Ped = PlayerPedId()
        SetPedComponentVariation(Ped, 2, 15, 1, 2) -- hair
        SetPedComponentVariation(Ped, 3, 15, 0, 2) -- arms
        SetPedComponentVariation(Ped, 11, 5, 0, 2) -- torso
        SetPedComponentVariation(Ped, 8, 15, 0, 2) -- tshirt
        SetPedComponentVariation(Ped, 4, 57, 0, 2) -- pants
        SetPedComponentVariation(Ped, 6, 35, 0, 2) -- shoes
        local dict = loadDict('timetable@reunited@ig_10')
        TaskPlayAnim(Ped, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
        SetEntityVisible(PlayerPedId(), true)
        SetEntityInvincible(PlayerPedId(), true)
    end
    whenActive = true
    DoScreenFadeOut(1500)
    Wait(1500)
    for k, v in pairs(allpeds) do
        if v ~= Ped then
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
    end
    SetEntityCoords(Ped, x, y, z)
    SetEntityHeading(Ped, w)
    selectedped = Ped
    SetEntityNoCollisionEntity(Ped, PlayerPedId(), true)
    stop = true
    FreezeEntityPosition(Ped, false)
    destroyCameraCreator(1)
    DoScreenFadeIn(1500)
    setCameraCreator(2, Ped)
    ClearPedTasks(Ped)
    Wait(1500)
    setAnimation(vector3(-80.60941, -798.8602, 243.3903), Ped)
    Wait(7300)
    setAnimation(vector3(-80.3724, -801.6242, 243.5912), Ped)
    Wait(1000)
    DoScreenFadeOut(1500)
    Wait(1500)
    destroyCameraCreator(2)
    DoScreenFadeIn(1500)
    setCameraCreator(4, Ped)
    Wait(1300)
    -- SetEntityCoords(PlayerPedId(), -80.3724, -801.6242, 243.5912)
    destroyCameraCreator(4)
    local entityofmonitor = GetClosestObjectOfType(-82.14, -803.08, 243.4, 5.0, 743064848, false, false, false)
    cam16 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    SetCamActive(cam16, true)
    PointCamAtEntity(cam16, entityofmonitor, 0, 0, 0, 1)
    SetCamParams(cam16, -80.02 - 0.9, -801.9 - 0.3, 244.14 - 0.15, 0.0, 0.0, 0.0, 40.2442, 0, 1, 1, 2)
    SetCamFov(cam16, 50.0)
    --SetCamCoord(cam16,-80.02 -0.3, -801.9+0.1, 244.14-0.7)
    --  SetCamRot(cam16,13.0, 0.0, 256.74)
    RenderScriptCams(1, 1, 3900, 1, 1)
    PlusCore.func.TriggerCallback("plus-multi:dashboard", function(result)
        local dict = loadDict('anim@heists@prison_heiststation@cop_reactions')
        TaskPlayAnim(Ped, dict, 'cop_b_idle', 1.0, -1.0, 50000, 1, 1, false, false, false)
        Wait(3900)
        DoScreenFadeOut(1000)
        Wait(4000)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "show",
            players = result["online"],
            police = result["police"],
            ems = result["ems"],
        })
    end)

end)

RegisterNUICallback("create", function(data)
    local name = data.firstname
    local lastname = data.lastname
    local birthday = data.birthdate
    local sex = data.gender
    local nationality = data.nationality
    --local number = data.phone
    -- local email = data.email
    if data.gender == "Male" then
        data.gender = 0
    elseif data.gender == "Female" then
        data.gender = 1
    end
    data.cid = cid
    SetNuiFocus(false, false)
    TriggerServerEvent("qb-multicharacter:server:createCharacter", data)
    createddata = data
    DoScreenFadeIn(1500)

    CreationPersoFunction(selectedped)
end)

local first = false
local second = false
local third = false
local fort = false

AddEventHandler("plus-multi:do:delete", function()
    while true do
        Wait(15)
        for k, object in pairs(GetGamePool("CObject")) do
            if GetEntityModel(object) == 1339364336 then
                print("deleted")
                SetEntityAsMissionEntity(object, true, true)
                DeleteEntity(object)
                break
            end
        end
    end
end)

RegisterNetEvent("plus-multi:client:load")
AddEventHandler("plus-multi:client:load", function()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    loadIplCreator(true)
    SetEntityVisible(PlayerPedId(), false)
    SetEntityInvincible(PlayerPedId(), false)
    SetEntityCoords(PlayerPedId(), -80.3724, -801.6242, 243.5912)
    --DoScreenFadeOut(1500)
    DisplayRadar(false)
    TriggerServerEvent("Creator:setPlayerToBucket", GetPlayerServerId(PlayerId()))
    PlusCore.func.TriggerCallback('qb-multicharacter:server:setupCharacters', function(result)
        if result[1] ~= nil and not first then
            PlusCore.func.TriggerCallback('qb-multicharacter:server:getSkin', function(skinData)
                local model = skinData.model
                first = true
                if model ~= nil then
                    CreateThread(function()
                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            Wait(0)
                        end
                        charPed = CreatePed(2, model, -69.41, -803.99 - 0.5, 243.82 - 1.4, 172.8, false, true)
                        table.insert(allpeds, charPed)
                        setCameraCreator(1, charPed)
                        SetPedComponentVariation(charPed, 0, 0, 0, 2)
                        if model == "mp_f_freemode_01" then
                            local dict = loadDict('timetable@reunited@ig_10')
                            TaskPlayAnim(charPed, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        else
                            local dict = loadDict('timetable@ron@ig_5_p3')
                            TaskPlayAnim(charPed, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        end
                        FreezeEntityPosition(charPed, true)
                        SetEntityInvincible(charPed, true)
                        PlaceObjectOnGroundProperly(charPed)
                        SetBlockingOfNonTemporaryEvents(charPed, true)
                        exports['fivem-appearance']:setPedAppearance(charPed, skinData)

                        Citizen.CreateThread(function()
                            while true do
                                Wait(1)
                                if stop then
                                    break
                                end
                                LeMessage("To Select a Character Press 1, 2, 3, 4")
                                if IsDisabledControlJustReleased(0, 157) then
                                    DoScreenFadeOut(1500)
                                    Wait(1500)
                                    TriggerEvent("plus-multi:delete", result[1], charPed)
                                    --Wait(500)
                                    --choixpoitionfunction2(charPed)
                                    break
                                end
                            end
                        end)
                    end)
                end
            end, result[1].citizenid)
        else
            if not first then
                first = true
                CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    charPed = CreatePed(2, model, -69.41, -803.99 - 0.5, 243.82 - 1.4, 172.8, false, true)
                    table.insert(allpeds, charPed)
                    setCameraCreator(1, charPed)
                    if model == GetHashKey("mp_f_freemode_01") then
                        local dict = loadDict('timetable@reunited@ig_10')
                        TaskPlayAnim(charPed, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    else
                        local dict = loadDict('timetable@ron@ig_5_p3')
                        TaskPlayAnim(charPed, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    end
                    --FreezeEntityPosition(charPed, true)
                    SetEntityAlpha(charPed, 200, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    SetPedDefaultComponentVariation(charPed)

                    if model == GetHashKey('mp_m_freemode_01') then
                        SetPedComponentVariation(charPed, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed, 11, 15, 0, 2) -- torso
                        SetPedComponentVariation(charPed, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed, 4, 61, 4, 2) -- pants
                        SetPedComponentVariation(charPed, 6, 34, 0, 2) -- shoes

                    elseif model == GetHashKey('mp_f_freemode_01') then
                        SetPedComponentVariation(charPed, 2, 15, 1, 2) -- hair
                        SetPedComponentVariation(charPed, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed, 11, 5, 0, 2) -- torso
                        SetPedComponentVariation(charPed, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed, 4, 57, 0, 2) -- pants
                        SetPedComponentVariation(charPed, 6, 35, 0, 2) -- shoes

                    end
                    Citizen.CreateThread(function()
                        while true do
                            Wait(3)
                            if stop then
                                break
                            end
                            LeMessage("To Select a Character Press 1, 2, 3, 4")
                            if IsDisabledControlJustReleased(0, 157) then
                                cid = 1
                                TriggerEvent("plus-multi:create", charPed, -69.41, -803.99 - 0.5, 243.82 - 1.4, 172.8)
                                break
                            end
                        end
                    end)
                end)
            end
        end

        if result[2] ~= nil and not second then
            second = true
            Wait(2000)
            PlusCore.func.TriggerCallback('qb-multicharacter:server:getSkin', function(skinData)
                local model = skinData.model
                if model ~= nil then
                    CreateThread(function()
                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            Wait(0)
                        end
                        charPed2 = CreatePed(2, model, -68.73 - 0.2, -804.15 - 0.5, 243.82 - 1.4, 165.39, false, true)
                        table.insert(allpeds, charPed2)
                        setCameraCreator(1, charPed2)
                        SetPedComponentVariation(charPed2, 0, 0, 0, 2)
                        if model == "mp_f_freemode_01" then
                            local dict = loadDict('timetable@reunited@ig_10')
                            TaskPlayAnim(charPed2, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        else
                            local dict = loadDict('timetable@ron@ig_5_p3')
                            TaskPlayAnim(charPed2, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        end
                        FreezeEntityPosition(charPed2, true)
                        SetEntityInvincible(charPed2, true)
                        PlaceObjectOnGroundProperly(charPed2)
                        SetBlockingOfNonTemporaryEvents(charPed2, true)
                        exports['fivem-appearance']:setPedAppearance(charPed2, skinData)

                        Citizen.CreateThread(function()
                            while true do
                                if stop then
                                    break
                                end
                                Wait(3)
                                if IsDisabledControlJustReleased(0, 158) then
                                    DoScreenFadeOut(1500)
                                    Wait(1500)
                                    TriggerEvent("plus-multi:delete", result[2], charPed2)
                                    --Wait(500)
                                    --choixpoitionfunction2(charPed2)
                                    break
                                end
                            end
                        end)
                    end)
                end
            end, result[2].citizenid)
        else
            if not second then
                second = true
                CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    charPed2 = CreatePed(2, model, -68.73 - 0.2, -804.15 - 0.5, 243.82 - 1.4, 165.39, false, true)
                    table.insert(allpeds, charPed2)
                    setCameraCreator(1, charPed2)
                    if model == GetHashKey("mp_f_freemode_01") then
                        local dict = loadDict('timetable@reunited@ig_10')
                        TaskPlayAnim(charPed2, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    else
                        local dict = loadDict('timetable@ron@ig_5_p3')
                        TaskPlayAnim(charPed2, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    end
                    --SetPedComponentVariation(charPed3, 0, 0, 0, 2)
                    --FreezeEntityPosition(charPed2, true)
                    SetEntityAlpha(charPed2, 200, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed2)
                    SetBlockingOfNonTemporaryEvents(charPed2, true)
                    SetPedDefaultComponentVariation(charPed2)

                    if model == GetHashKey('mp_m_freemode_01') then
                        SetPedComponentVariation(charPed2, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed2, 11, 15, 0, 2) -- torso
                        SetPedComponentVariation(charPed2, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed2, 4, 61, 4, 2) -- pants
                        SetPedComponentVariation(charPed2, 6, 34, 0, 2) -- shoes

                    elseif model == GetHashKey('mp_f_freemode_01') then
                        SetPedComponentVariation(charPed2, 2, 15, 1, 2) -- hair
                        SetPedComponentVariation(charPed2, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed2, 11, 5, 0, 2) -- torso
                        SetPedComponentVariation(charPed2, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed2, 4, 57, 0, 2) -- pants
                        SetPedComponentVariation(charPed2, 6, 35, 0, 2) -- shoes

                    end
                    Citizen.CreateThread(function()
                        while true do
                            Wait(3)
                            if stop then
                                break
                            end
                            if IsDisabledControlJustReleased(0, 158) then
                                cid = 2
                                TriggerEvent("plus-multi:create", charPed2, -68.73 - 0.2, -804.15 - 0.5, 243.82 - 1.4,
                                    165.39)
                                break
                            end
                        end
                    end)
                end)
            end
        end

        if result[3] ~= nil and not third then
            third = true
            Wait(2000)
            PlusCore.func.TriggerCallback('qb-multicharacter:server:getSkin', function(skinData)
                local model = skinData.model
                if model ~= nil then
                    CreateThread(function()
                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            Wait(0)
                        end
                        charPed3 = CreatePed(2, model, -68.21, -804.34 - 0.5, 243.82 - 1.4, 167.71, false, true)
                        table.insert(allpeds, charPed3)
                        setCameraCreator(1, charPed3)
                        SetPedComponentVariation(charPed3, 0, 0, 0, 2)
                        if model == "mp_f_freemode_01" then
                            local dict = loadDict('timetable@reunited@ig_10')
                            TaskPlayAnim(charPed3, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        else
                            local dict = loadDict('timetable@ron@ig_5_p3')
                            TaskPlayAnim(charPed3, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        end
                        FreezeEntityPosition(charPed3, true)
                        SetEntityInvincible(charPed3, true)
                        PlaceObjectOnGroundProperly(charPed3)
                        SetBlockingOfNonTemporaryEvents(charPed3, true)
                        exports['fivem-appearance']:setPedAppearance(charPed3, skinData)

                        Citizen.CreateThread(function()
                            while true do
                                Wait(3)
                                if stop then
                                    break
                                end
                                if IsDisabledControlJustReleased(0, 160) then
                                    DoScreenFadeOut(1500)
                                    Wait(1500)
                                    TriggerEvent("plus-multi:delete", result[3], charPed3)
                                    --Wait(500)
                                    --choixpoitionfunction2(charPed3)
                                    break
                                end
                            end
                        end)
                    end)
                end
            end, result[3].citizenid)
        else
            if not third then
                third = true
                CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    charPed3 = CreatePed(2, model, -68.21, -804.34 - 0.5, 243.82 - 1.4, 167.71, false, true)
                    table.insert(allpeds, charPed3)
                    setCameraCreator(1, charPed3)
                    if model == GetHashKey("mp_f_freemode_01") then
                        local dict = loadDict('timetable@reunited@ig_10')
                        TaskPlayAnim(charPed3, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    else
                        local dict = loadDict('timetable@ron@ig_5_p3')
                        TaskPlayAnim(charPed3, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    end
                    SetPedComponentVariation(charPed3, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed3, true)
                    SetEntityAlpha(charPed3, 200, false)
                    SetEntityInvincible(charPed3, true)
                    PlaceObjectOnGroundProperly(charPed3)
                    SetBlockingOfNonTemporaryEvents(charPed3, true)
                    SetPedDefaultComponentVariation(charPed3)

                    if model == GetHashKey('mp_m_freemode_01') then
                        SetPedComponentVariation(charPed3, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed3, 11, 15, 0, 2) -- torso
                        SetPedComponentVariation(charPed3, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed3, 4, 61, 4, 2) -- pants
                        SetPedComponentVariation(charPed3, 6, 34, 0, 2) -- shoes


                    elseif model == GetHashKey('mp_f_freemode_01') then
                        SetPedComponentVariation(charPed3, 2, 15, 1, 2) -- hair
                        SetPedComponentVariation(charPed3, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed3, 11, 5, 0, 2) -- torso
                        SetPedComponentVariation(charPed3, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed3, 4, 57, 0, 2) -- pants
                        SetPedComponentVariation(charPed3, 6, 35, 0, 2) -- shoes

                    end

                    Citizen.CreateThread(function()
                        while true do
                            Wait(3)
                            if stop then
                                break
                            end
                            if IsDisabledControlJustReleased(0, 160) then
                                cid = 3
                                TriggerEvent("plus-multi:create", charPed3, -68.21, -804.34 - 0.5, 243.82 - 1.4, 167.71)
                                break
                            end
                        end
                    end)
                end)
            end
        end


        if result[4] ~= nil and not fort then
            fort = true
            Wait(2000)
            PlusCore.func.TriggerCallback('qb-multicharacter:server:getSkin', function(skinData)
                local model = skinData.model
                if model ~= nil then
                    CreateThread(function()
                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            Wait(0)
                        end
                        charPed4 = CreatePed(2, model, -67.72, -804.52 - 0.5, 243.82 - 1.4, 163.28, false, true)
                        table.insert(allpeds, charPed4)
                        setCameraCreator(1, charPed4)
                        SetPedComponentVariation(charPed4, 0, 0, 0, 2)
                        if model == "mp_f_freemode_01" then
                            local dict = loadDict('timetable@reunited@ig_10')
                            TaskPlayAnim(charPed4, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        else
                            local dict = loadDict('timetable@ron@ig_5_p3')
                            TaskPlayAnim(charPed4, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                        end
                        FreezeEntityPosition(charPed4, true)
                        SetEntityInvincible(charPed4, true)
                        PlaceObjectOnGroundProperly(charPed4)
                        SetBlockingOfNonTemporaryEvents(charPed4, true)
                        exports['fivem-appearance']:setPedAppearance(charPed4, skinData)

                        Citizen.CreateThread(function()
                            while true do
                                Wait(3)
                                if stop then
                                    break
                                end
                                if IsDisabledControlJustReleased(0, 164) then
                                    DoScreenFadeOut(1500)
                                    Wait(1500)
                                    TriggerEvent("plus-multi:delete", result[4], charPed4)
                                    --Wait(500)
                                    --choixpoitionfunction2(charPed4)
                                    break
                                end
                            end
                        end)
                    end)
                end
            end, result[4].citizenid)
        else
            if not fort then
                fort = true
                CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    charPed4 = CreatePed(2, model, -67.72, -804.52 - 0.5, 243.82 - 1.4, 163.28, false, true)
                    table.insert(allpeds, charPed4)
                    setCameraCreator(1, charPed4)
                    if model == GetHashKey("mp_f_freemode_01") then
                        local dict = loadDict('timetable@reunited@ig_10')
                        TaskPlayAnim(charPed4, dict, 'base_amanda', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    else
                        local dict = loadDict('timetable@ron@ig_5_p3')
                        TaskPlayAnim(charPed4, dict, 'ig_5_p3_base', 1.0, -1.0, 950000, 1, 1, false, false, false)
                    end
                    SetPedComponentVariation(charPed4, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed4, true)
                    SetEntityAlpha(charPed4, 200, false)
                    SetEntityInvincible(charPed4, true)
                    PlaceObjectOnGroundProperly(charPed4)
                    SetBlockingOfNonTemporaryEvents(charPed4, true)
                    SetPedDefaultComponentVariation(charPed4)

                    if model == GetHashKey('mp_m_freemode_01') then
                        SetPedComponentVariation(charPed4, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed4, 11, 15, 0, 2) -- torso
                        SetPedComponentVariation(charPed4, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed4, 4, 61, 4, 2) -- pants
                        SetPedComponentVariation(charPed4, 6, 34, 0, 2) -- shoes

                    elseif model == GetHashKey('mp_f_freemode_01') then
                        SetPedComponentVariation(charPed4, 2, 15, 1, 2) -- hair
                        SetPedComponentVariation(charPed4, 3, 15, 0, 2) -- arms
                        SetPedComponentVariation(charPed4, 11, 5, 0, 2) -- torso
                        SetPedComponentVariation(charPed4, 8, 15, 0, 2) -- tshirt
                        SetPedComponentVariation(charPed4, 4, 57, 0, 2) -- pants
                        SetPedComponentVariation(charPed4, 6, 35, 0, 2) -- shoes

                    end

                    Citizen.CreateThread(function()
                        while true do
                            Wait(3)
                            if stop then
                                break
                            end
                            if IsDisabledControlJustReleased(0, 164) then
                                cid = 4
                                TriggerEvent("plus-multi:create", charPed4, -67.72, -804.52 - 0.5, 243.82 - 1.4, 163.28)
                                break
                            end
                        end
                    end)
                end)
            end
        end
        Wait(2500)
        DoScreenFadeIn(2500)
    end)
end)
