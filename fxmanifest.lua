fx_version 'cerulean'
games { 'gta5' }

client_scripts {
  'config.lua',
  'client/cl_*.lua',
  --'@unwind-rpc/client/cl_main.lua', --uncomment this line if using np-base
}

server_scripts {
  'config.lua',
  'server/sv_*.lua',
  --'@unwind-rpc/server/sv_main.lua', --uncomment this line if using np-base
}

ui_page 'ui/index.html'

files {
  'ui/*'
}
