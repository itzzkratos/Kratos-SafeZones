fx_version "cerulean"
games {"rdr3","gta5"}
lua54 'yes'

author 'itzzkratos | Sirius Studios'
description 'SafeZone System for FiveM Servers'

shared_scripts {
    '@ox_lib/init.lua',
    "config.lua"
} 

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server.lua"
}

client_scripts {
    "client.lua",
}

dependencies {
    'ox_lib',
    'PolyZone'
}
