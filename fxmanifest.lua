fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Trusted-Studios <@trusted-studios>'
description 'OX Logs'
version '0.0.2'

shared_script '@es_extended/imports.lua'
server_script '@oxmysql/lib/MySQL.lua'

server_script 'config.lua'

-- What to run
client_scripts {
    "client/*.lua"
}

server_scripts {
    "configs/*.lua",
    "server/*.lua"
}
