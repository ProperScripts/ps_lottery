fx_version 'cerulean'
game 'gta5'

author 'pietjepekSF#7950 & Stijnjw#1150'
description 'Lottery script, by https://properscripts.tebex.io/'
version '1.0'

client_script 'client/main.lua'
server_script 'server/main.lua'
shared_script 'config.lua'

escrow_ignore {
    "config.lua",
    "client/*.lua",
    "server/*.lua"
}

lua54 'yes'
use_fxv2_oal 'yes'