PlusCore = {}
PlusCore.UserData = {}
PlusCore.Config = PlusConfig
PlusCore.Shared = PlusShared
PlusCore.ClientCallbacks = {}
PlusCore.ServerCallbacks = {}

exports('GetCore', function()
    return PlusCore
end)
