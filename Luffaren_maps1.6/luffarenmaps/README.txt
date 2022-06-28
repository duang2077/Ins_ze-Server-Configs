---------------------------------------------------------------------------------
name 		= LuffarenMaps
author 		= Luffaren (STEAM_1:1:22521282 | pellevoice@gmail.com)
description = Global connector for Luffaren-maps, allowing for dynamic hotfixes, stats, events and cosmetic patron/VIP list updates
version 	= 1.6
url 		= http://luffaren.com
---------------------------------------------------------------------------------
				[INSTALLATION]
(1)	Make sure to add "csgo/addons/sourcemod/plugins/luffarenmaps.smx"
(2)	Make sure to add "csgo/addons/sourcemod/extensions/SteamWorks.ext.dll" (unless your server doesnt't already have it?)
The SteamWorks extension^ is required for reading HTTP data
If you want to assure there's no funk, you can review/recompile the .sp under "csgo/addons/sourcemod/scripting/"
---------------------------------------------------------------------------------
				[HOW IT WORKS]
(1) The plugin should be initialized when a supported Luffaren-map is loaded on the server
Supported maps can be seen listed at http://luffaren.com/ ("CSGO Vscript configs")
Note: there's no formatting when viewing the configs through a browser, rest assured that this is not intended

(2) The plugin creates a temporary .nut file, read from "http://luffaren.com/csgo_vscript_configs/MAPNAME.html"
This .nut file is stored in the "csgo/scripts/vscripts/luffaren" directory
This .nut file is called "luffarenmaps_temp.nut"
This .nut file will automatically delete itself when the plugin succeeds in reading the Vscript

(3)	If the plugin fails to accomplish this, it will retry a couple of times with 5-second intervals
If it still fails, it will unload the plugin through "ServerCommand("sm plugins unload luffarenmaps");"
Note: you can force a retry by killing the entity "luffarenmapsplugin_success" and waiting a few seconds
(when doing this^, you will also force a full re-validation on all players through the Vscript)

(4)	If the plugin succeeds, it will leave the rest to the created Vscript-scope
The plugin will still check for player validation events to give the vscript (USERID, STEAMID, NAME)
It will also assure that each player gets an "userid" vscript-variable to its handle
The plugin will also send date/time + serverIP/servername to the vscript
(allows for manual exceptions if any tweaks don't fit in with specific server + date/time based events)
---------------------------------------------------------------------------------
				[NOT YET IMPLEMENTED]
- set up a way for the plugin to send stats/world-records to database 
