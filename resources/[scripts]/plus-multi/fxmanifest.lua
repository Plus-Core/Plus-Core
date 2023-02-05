fx_version 'cerulean'
games { 'gta5' };

client_scripts {
    "Config.lua",
    "functions.lua",
    "client.lua",
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "Config.lua",
    "server.lua"
}

ui_page 'html/registiration.html'

files {
    'html/registiration.html',
    'html/registiration.css',
    'html/app.js',
    'html/gauge.min.js',
    'html/images/**/*.png',
    'html/images/*.jpg',
    'html/images/*.webp',
}
