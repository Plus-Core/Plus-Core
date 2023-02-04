fx_version 'cerulean'
games { 'gta5' }

author 'Plus-Team'
description 'Plus-Core'
version '1.0.0'

client_scripts {
    "client/*.lua",
    "client/**/*.lua",
}
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@mongodb-driver/lib/mongodb.lua',
    "server/*.lua",
    "server/**/*.lua",
}