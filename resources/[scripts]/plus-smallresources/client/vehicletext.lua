local PlusCore= exports['plus-core']:GetCore()

CreateThread(function()
    for _, v in pairs(PlusCore.Shared.Vehicles) do
        local text
        if v["brand"] then
            text = v["brand"] .. " " .. v["name"]
        else
            text = v["name"]
        end
        if v['hash'] ~= 0 and v['hash'] ~= nil then
            AddTextEntryByHash(v["hash"],text)
        end
    end
end)
