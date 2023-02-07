local PlusCore= exports['plus-core']:GetCore()

RegisterNetEvent('KickForAFK', function()
	DropPlayer(source, Lang:t("text.afk_kick_message"))
end)

PlusCore.func.CreateCallback('qb-afkkick:server:GetPermissions', function(source, cb)
    cb(PlusCore.func.GetPermission(source))
end)
