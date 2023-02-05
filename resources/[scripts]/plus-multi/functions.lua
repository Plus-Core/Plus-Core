whenActive, PlayerLoaded, FirstSpawn, CinemaMode = false, false, true, false


loadIplCreator = function(load)
    CreateThread(function()
        while load do
            Wait(0)
            RequestIpl('ex_dt1_11_office_01a')
            break
        end
    end)
end

function PlayAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 1, 1, false, false, false)
    RemoveAnimDict(animDict)
end

function LeMessage(messages)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.40, 0.40)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(messages)
    DrawText(0.41, 0.91)
end

setAnimation = function(coords, Ped)
    CinemaMode = true
    TaskGoStraightToCoord(Ped, coords, 1.0, 8000, 265.25466, 5)
    CinemaMode = false
end

setAnimation2 = function(coords, Ped)
    CinemaMode = true
    TaskGoStraightToCoord(Ped, coords, 1.0, 8000, 69.03946685791, 5)
    CinemaMode = false
end


CreationPersoFunction = function(Ped)
    DoScreenFadeOut(1500)
    Wait(1500)
    destroyCameraCreator(4)
    DoScreenFadeIn(1500)
    setCameraCreator(3, Ped)
    Wait(2000)
    ClearPedTasks(Ped)
    Wait(1500)
    setAnimation(vector3(-81.74915, -803.7766, 243.3904), Ped)
    Wait(1500)
    setAnimation(vector3(-76.96708, -806.5789, 243.3902), Ped)
    Wait(3000)
    DoScreenFadeOut(1500)
    setAnimation2(vector3(-78.74894, -812.334, 243.386), Ped)
    Wait(1500)
    destroyCameraCreator(3)
    DoScreenFadeIn(1500)
    setCameraCreator(5, Ped)
    Wait(3500)
    TriggerEvent('qb-clothes:client:CreateFirstCharacter', GetEntityModel(Ped), Ped)
    whenActive = false
end

local goahead = false
choixpoitionfunction = function(data, Ped)
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
    Ped = PlayerPedId()
    stop = true
    whenActive = true
    setAnimation(vector3(-79.18546, -813.5646, 243.386), Ped)
    Wait(1000)
    DoScreenFadeOut(1500)
    setAnimation(vector3(-68.96505, -818.043, 243.386), Ped)
    Wait(1500)
    destroyCameraCreator(5)
    DoScreenFadeIn(1500)
    setCameraCreator(6, Ped)
    Wait(4500)
    DoScreenFadeOut(1500)
    setAnimation(vector3(-65.19776, -807.9307, 243.386), Ped)
    Wait(1500)
    destroyCameraCreator(6)
    DoScreenFadeIn(1500)
    setCameraCreator(7, Ped)
    Wait(4800)
    DoScreenFadeOut(1500)
    setAnimation(vector3(-62.11924, -808.5383, 243.3883), Ped)
    Wait(1500)
    destroyCameraCreator(7)
    DoScreenFadeIn(1500)
    setCameraCreator(8, Ped)
    Wait(1500)
    local dict = loadDict('amb@prop_human_bum_shopping_cart@male@idle_a')
    TaskPlayAnim(Ped, dict, 'idle_c', 1.0, -1.0, 950000, 1, 1, false, false, false)
    TriggerServerEvent("Creator:setPlayerToNormalBucket")
    Wait(2200)
    TriggerServerEvent("plus-multi:create:spawn", data)
    Wait(1000)
    destroyCameraCreator(8)
    whenActive = false
end


choixpoitionfunction2 = function(data, Ped)
    FreezeEntityPosition(Ped, false)
    stop = true
    whenActive = true
    DoScreenFadeIn(1500)
    setCameraCreator(9, Ped)
    Wait(500)
    -- DoScreenFadeOut(1500)
    --DoScreenFadeOut(1500)
    setAnimation(vector3(-62.11924, -808.5383, 243.3883), Ped)
    Wait(6300)
    destroyCameraCreator(9)
    setCameraCreator(8, Ped)
    Wait(300)
    local dict = loadDict('amb@prop_human_bum_shopping_cart@male@idle_a')
    TaskPlayAnim(Ped, dict, 'idle_c', 1.0, -1.0, 950000, 1, 1, false, false, false)
    TriggerServerEvent("Creator:setPlayerToNormalBucket")
    Wait(2200)
    TriggerServerEvent("plus-multi:spawn", data)
    Wait(1000)
    destroyCameraCreator(8)
    whenActive = false
    SetEntityAsMissionEntity(Ped, true, true)
    DeleteEntity(Ped)
end


setCameraCreator = function(camType, Ped)
    if camType == 1 then
        cam1 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam1, true)
        --PointCamAtEntity(cam1, Ped, 0, 0, 0, 1)
        SetCamParams(cam1, -69.49, -806.95, 243.4, 2.0, 0.0, 341.09, 170.2442, 0, 1, 1, 2)
        SetCamFov(cam1, 80.0)
        RenderScriptCams(1, 0, 0, 1, 1)
    elseif camType == 2 then
        cam2 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam2, true)
        PointCamAtEntity(cam2, Ped, 0, 0, 0, 1)
        SetCamParams(cam2, -75.55272, -806.2805, 244.386, 20.0, 0.0, 84.65463, 42.2442, 0, 1, 1, 2)
        SetCamFov(cam2, 50.0)
        RenderScriptCams(1, 1, 0, 1, 1)
    elseif camType == 3 then
        cam3 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam3, true)
        PointCamAtEntity(cam3, Ped, 0, 0, 0, 1)
        SetCamParams(cam3, -74.97608, -801.8835, 244.3903, 20.0, 0.0, 84.65463, 42.2442, 0, 1, 1, 2)
        SetCamFov(cam3, 50.0)
        RenderScriptCams(1, 1, 10000, 1, 1)
    elseif camType == 4 then
        cam4 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam4, true)
        PointCamAtEntity(cam4, Ped, 0, 0, 0, 1)
        SetCamParams(cam4, -81.9896, -803.7953, 244.3903, 2.0, 0.0, 129.0322265625, 70.2442, 0, 1, 1, 2)
        SetCamFov(cam4, 50.0)
        RenderScriptCams(1, 0, 0, 1, 1)


    elseif camType == 5 then
        cam5 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam5, true)
        PointCamAtEntity(cam5, Ped, 0, 0, 0, 1)
        SetCamParams(cam5, -79.97163, -811.4866, 243.386, 2.0, 0.0, 129.0322265625, 70.2442, 0, 1, 1, 2)
        SetCamFov(cam5, 70.0)

        RenderScriptCams(1, 0, 0, 1, 1)
    elseif camType == 6 then
        cam6 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam6, true)
        PointCamAtEntity(cam6, Ped, 0, 0, 0, 1)
        SetCamParams(cam6, -73.73689, -818.9836, 244.386, 2.0, 0.0, 129.0322265625, 70.2442, 0, 1, 1, 2)
        SetCamFov(cam6, 70.0)
        RenderScriptCams(1, 0, 0, 1, 1)
    elseif camType == 7 then
        cam7 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam7, true)
        PointCamAtEntity(cam7, Ped, 0, 0, 0, 1)
        SetCamParams(cam7, -65.1357, -804.7418, 244.4058, 2.0, 0.0, 129.0322265625, 70.2442, 0, 1, 1, 2)
        SetCamFov(cam7, 50.0)
        RenderScriptCams(1, 0, 0, 1, 1)
    elseif camType == 8 then
        cam8 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam8, true)
        PointCamAtEntity(cam8, Ped, 0, 0, 0, 1)
        SetCamParams(cam8, -58.78357, -809.7481, 245.388, 2.0, 0.0, 72.709175109863, 70.2442, 0, 1, 1, 2)
        SetCamFov(cam8, 70.0)
        RenderScriptCams(1, 0, 0, 1, 1)

    elseif camType == 9 then
        cam9 = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
        SetCamActive(cam9, true)
        PointCamAtEntity(cam9, Ped, 0, 0, 0, 1)
        SetCamParams(cam9, -62.99, -810.91, 243.39, 2.0, 0.0, 27.03, 70.2442, 0, 1, 1, 2)
        SetCamFov(cam9, 50.0)
        RenderScriptCams(1, 1, 1500, 1, 1)
    end
end

loadDict = function(dict, anim)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end

function LoadDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
end

destroyCameraCreator = function(destroyCam)
    if destroyCam == 1 then
        DestroyCam(cam1, false)
        RenderScriptCams(false, true, 1500, false, false)
    elseif destroyCam == 2 then
        DestroyCam(cam2, false)
        RenderScriptCams(false, true, 800, false, false)
    elseif destroyCam == 3 then
        DestroyCam(cam3, false)
        RenderScriptCams(false, true, 800, false, false)
    elseif destroyCam == 4 then
        DestroyCam(cam4, false)
        RenderScriptCams(false, true, 800, false, false)
    elseif destroyCam == 5 then
        DestroyCam(cam5, false)
        RenderScriptCams(false, true, 800, false, false)
    elseif destroyCam == 6 then
        DestroyCam(cam6, false)
        RenderScriptCams(false, true, 800, false, false)
    elseif destroyCam == 7 then
        DestroyCam(cam7, false)
        RenderScriptCams(false, true, 800, false, false)
    elseif destroyCam == 8 then
        DestroyCam(cam8, false)
        RenderScriptCams(false, true, 800, false, false)
    elseif destroyCam == 9 then
        DestroyCam(cam9, false)
        RenderScriptCams(false, true, 800, false, false)
    end
end

CreateThread(function()
    while true do
        Wait(1)
        if CinemaMode then
            DrawRect(0.471, 0.0485, 1.065, 0.13, 0, 0, 0, 255)
            DrawRect(0.503, 0.935, 1.042, 0.13, 0, 0, 0, 255)
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(19)
            HideHudAndRadarThisFrame()
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1)
        if whenActive then
            DisableControlAction(0, 1, true) -- Disable pan
            DisableControlAction(0, 2, true) -- Disable tilt
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 44, true) -- Cover
            DisableControlAction(0, 37, true) -- Select Weapon
            DisableControlAction(0, 23, true) -- Also 'enter'?
            DisableControlAction(0, 288, true) -- Disable phone
            DisableControlAction(0, 289, true) -- Inventory
            DisableControlAction(0, 170, true) -- Animations
            DisableControlAction(0, 167, true) -- Job
            DisableControlAction(0, 0, true) -- Disable changing view
            DisableControlAction(0, 26, true) -- Disable looking behind
            DisableControlAction(0, 73, true) -- Disable clearing animation
            DisableControlAction(2, 199, true) -- Disable pause screen
            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
            DisableControlAction(0, 72, true) -- Disable reversing in vehicle
            DisableControlAction(2, 36, true) -- Disable going stealth
            DisableControlAction(0, 47, true) -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, 75, true) -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle
        else
            Wait(100)
        end
    end
end)
