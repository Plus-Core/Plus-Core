PlusConfig = {}

PlusConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
PlusConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
PlusConfig.UpdateInterval = 5 -- how often to update player data in minutes
PlusConfig.StatusInterval = 5000 -- how often to check hunger/thirst status in milliseconds

PlusConfig.Money = {}
PlusConfig.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
PlusConfig.Money.DontAllowMinus = { 'cash', 'crypto' } -- Money that is not allowed going in minus
PlusConfig.Money.PayCheckTimeOut = 10 -- The time in minutes that it will give the paycheck
PlusConfig.Money.PayCheckSociety = false -- If true paycheck will come from the society account that the player is employed at, requires qb-management

PlusConfig.Player = {}
PlusConfig.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
PlusConfig.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.
PlusConfig.Player.Bloodtypes = {
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-",
}

PlusConfig.Server = {} -- General server config
PlusConfig.Server.Closed = false -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
PlusConfig.Server.ClosedReason = "Server Closed" -- Reason message to display when people can't join the server
PlusConfig.Server.Uptime = 0 -- Time the server has been up.
PlusConfig.Server.Whitelist = false -- Enable or disable whitelist on the server
PlusConfig.Server.WhitelistPermission = 'admin' -- Permission that's able to enter the server when the whitelist is on
PlusConfig.Server.PVP = true -- Enable or disable pvp on the server (Ability to shoot other players)
PlusConfig.Server.Discord = "" -- Discord invite link
PlusConfig.Server.CheckDuplicateLicense = true -- Check for duplicate rockstar license on join
PlusConfig.Server.Permissions = { 'god', 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

PlusConfig.Notify = {}

PlusConfig.Notify.NotificationStyling = {
    group = false, -- Allow notifications to stack with a badge instead of repeating
    position = "right", -- top-left | top-right | bottom-left | bottom-right | top | bottom | left | right | center
    progress = true -- Display Progress Bar
}

-- These are how you define different notification variants
-- The "color" key is background of the notification
-- The "icon" key is the css-icon code, this project uses `Material Icons` & `Font Awesome`
PlusConfig.Notify.VariantDefinitions = {
    success = {
        classes = 'success',
        icon = 'done'
    },
    primary = {
        classes = 'primary',
        icon = 'info'
    },
    error = {
        classes = 'error',
        icon = 'dangerous'
    },
    police = {
        classes = 'police',
        icon = 'local_police'
    },
    ambulance = {
        classes = 'ambulance',
        icon = 'fas fa-ambulance'
    }
}
