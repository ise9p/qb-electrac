fx_version 'cerulean'
game 'gta5'

description 'Electrac Job System for FiveM'
version '1.0.1'
author 'Se9p Script'  

shared_script {
    '@ox_lib/init.lua',  
    'config.lua',  
}

client_scripts {
    'client/*.lua',  
}

server_scripts {
    'server/*.lua',  
}

dependencies {
    'oxmysql',  
}

lua54 'yes'  
