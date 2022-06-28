#pragma dynamic 131072 
#include <sourcemod>
#include <SteamWorks>
#include <sdktools>
 
public Plugin myinfo =
{
	name = "LuffarenMaps",
	author = "Luffaren (STEAM_1:1:22521282 | pellevoice@gmail.com)",
	description = "Global connector for Luffaren-maps, allowing for dynamic hotfixes, stats, events and cosmetic patron/VIP list updates",
	version = "1.6",
	url = "http://luffaren.com"
};

enum struct PlayerStruct
{
	bool send;
    char userid[128];
    char name[128];
    char steamid[128];
	int index;
	int indexretries;
}

public ConVar conretries;
public ConVar conticktime;
public int LuffarenMapsInitRetries = 5;
public bool LuffarenDeletedTempFile = false;
public bool LuffarenpstInit = false;
public bool LuffarenpstUnloaded = false;
public PlayerStruct Luffarenpst[MAXPLAYERS+1];
public char LuffarenCurrentMapName[128];
public bool LuffarenMapsStarted = false;
public bool LuffarenMapsLoading = false;
public bool LuffarenMapsTicking = false;
public bool LuffarenMapsCreatedMan = false;
public Handle:ticktimer;
public void OnPluginStart(){LuffarenMapsInitialize();}
public void OnMapStart(){LuffarenMapsInitialize();}

public void LuffarenMapsInitialize()
{
	//1.5 fix	(thanks to Vauff for pointing it out)
	//-------	the plugin unloads when no luff-maps are found
	//-------	but then it never re-initializes properly
	//-------	simply put, just reset stuff on map/plugin init, i think this should suffice:
		conretries = CreateConVar("sm_luffmapsretries","5","How many times to auto-retry fetching map-data from luffaren.com");
		conticktime = CreateConVar("sm_luffmapstick","5.00","How often to tick (slower=stable)");
		LuffarenMapsInitRetries = conretries.IntValue;
		LuffarenDeletedTempFile = false;
		LuffarenpstInit = false;
		LuffarenpstUnloaded = false;
		LuffarenMapsStarted = false;
		LuffarenMapsLoading = false;
		LuffarenMapsTicking = false;
		LuffarenMapsCreatedMan = false;
	if(LuffarenpstUnloaded)return;
	if(LuffarenMapsStarted)
		return;
	LogMessage("-----------------[ Start ]-----------------");
	LuffarenMapsStarted = true;
	if(!LuffarenMapsTicking)
	{
		LuffarenMapsTicking = true;
		CreateDataTimer(0.00,LuffarenMapsTick,ticktimer,TIMER_DATA_HNDL_CLOSE);
	}
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if(LuffarenpstUnloaded)return;
	if(!LuffarenpstInit)
	{
		LogMessage("Initializing client data pool");
		LuffarenpstInit = true;
		for(new i=0;i<sizeof(Luffarenpst);i++)
		{
			Luffarenpst[i].send = false;
			Luffarenpst[i].userid = "-1";
			Luffarenpst[i].name = "";
			Luffarenpst[i].steamid = "";
			Luffarenpst[i].index = -1;
			Luffarenpst[i].indexretries = 5;
		}
	}
	char uid[32];
	IntToString(GetClientUserId(client),uid,32);
	char uname[128];
	GetClientName(client,uname,127);
	LogMessage("Client authorize attempt - clientindex(%i) userid(%i) name(%s) steamid(%s)",client,GetClientUserId(client),uname,auth);
	for(new i=0;i<sizeof(Luffarenpst);i++)
	{
		if(StrEqual(Luffarenpst[i].steamid,"BOT"))
			continue;
		if(StrEqual(Luffarenpst[i].steamid,""))
		{
			Luffarenpst[i].send = true;
			Luffarenpst[i].userid = uid;
			Luffarenpst[i].name = uname;
			strcopy(Luffarenpst[i].steamid,128,auth);
			Luffarenpst[i].index = client;
			Luffarenpst[i].indexretries = 5;
			LogMessage("Client authorize success - clientindex(%i) userid(%i) name(%s) steamid(%s)",client,GetClientUserId(client),uname,auth);
			break;
		}
	}
}

public void OnClientDisconnect(int client)	//clean the auth pool for new players joining
{
	if(LuffarenpstUnloaded)return;
	LogMessage("Client disconnect called - clientindex(%i)",client);
	for(new i=0;i<sizeof(Luffarenpst);i++)
	{
		if(Luffarenpst[i].index == client)
		{
			Luffarenpst[i].send = false;
			Luffarenpst[i].userid = "-1";
			Luffarenpst[i].name = "";
			Luffarenpst[i].steamid = "";
			Luffarenpst[i].index = -1;
			Luffarenpst[i].indexretries = 5;
			LogMessage("Client disconnected properly - clientindex(%i)",client);
			break;
		}
	}
}

public void RetryAuthPool()
{
	if(LuffarenpstUnloaded)return;
	for(new i=0;i<sizeof(Luffarenpst);i++)
	{
		if(!StrEqual("",Luffarenpst[i].steamid))
			Luffarenpst[i].send = true;
	}
}

public Action:LuffarenMapsTick(Handle:timer)
{
	if(LuffarenpstUnloaded)return;
	CreateDataTimer(conticktime.FloatValue,LuffarenMapsTick,ticktimer,TIMER_DATA_HNDL_CLOSE);
	bool validclientconnected = false;
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			validclientconnected = true;
			break;
		}
	}
	if(!validclientconnected)		//if no valid players are connected yet, abort and try again at the next tick (thanks to vauff and ice)
	{
		LogMessage("aborting tick - no valid players are connected yet, trying again later...");
		return;
	}
	if(!LuffarenMapsLoading)
	{
		bool foundreloadstart = false;
		new String:buf[60], ent = -1;
		while((ent = FindEntityByClassname(ent, "info_target")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", buf, sizeof(buf));
			if (StrEqual(buf, "luffarenmapsplugin_reload", false))
			{
				foundreloadstart = true;
			}
			else if (StrEqual(buf, "luffarenmapsplugin_success", false))
			{
				SetVariantString("OnUser1 !self:Kill::0:1");
				AcceptEntityInput(ent,"AddOutput");
				AcceptEntityInput(ent,"FireUser1");
			}
		}
		if(foundreloadstart)
			LuffarenMapsLoading = true;
		else
		{
			new entindex = CreateEntityByName("info_target");
			if (entindex != -1)
			{
				DispatchKeyValue(entindex, "targetname", "luffarenmapsplugin_reload");
			}
			DispatchSpawn(entindex);
			ActivateEntity(entindex);
		}
	}
	else
	{
		int manent = -1;
		bool foundmanager = false;
		bool foundreload = false;
		bool foundsuccess = false;
		new String:buf[60], ent = -1;
		while((ent = FindEntityByClassname(ent, "info_target")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", buf, sizeof(buf));
			if (StrEqual(buf, "luffarenmapsplugin_reload", false))
			{
				//foundreload = true;	//why_reload
				break;
			}
			if (StrEqual(buf, "luffarenmapsplugin_success", false))
			{
				foundsuccess = true;
			}
			if (StrEqual(buf, "luffarenmapsplugin_manager", false))
			{
				foundmanager = true;
				manent = ent;
			}
		}
		ent = -1;
		while((ent = FindEntityByClassname(ent, "logic_auto")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", buf, sizeof(buf));
			if (StrEqual(buf, "luffarenmapsplugin_manager", false))
			{
				foundmanager = true;
				manent = ent;
			}
		}
		if(!foundmanager || foundreload || !foundsuccess)	//thanks to vauff and alpha for finding an issue here in 1.2 (removed/merged section in 1.3)
		{
			LuffarenMapsInitRetries--;
			if(LuffarenMapsInitRetries < -1)
			{
				LogMessage("ERROR - unloading plugin due to not being able to load Vscript-data, flags:(foundmanager:%b | foundreload:%b | foundsuccess:%b",foundmanager,foundreload,foundsuccess);
				UnloadLuffarenMaps();
			}
			LogMessage("Reloading HTML due to flags (foundmanager:%b | foundreload:%b | foundsuccess:%b",foundmanager,foundreload,foundsuccess);
			LuffarenDeletedTempFile = false;
			RetryAuthPool();
			RequestLuffarenData();
		}
		else if(manent != -1)
		{
			if(!LuffarenDeletedTempFile)
			{
				LuffarenDeletedTempFile = true;
				RequestLuffarenDataCompletePost();
				
				LogMessage("Sending DateTime to 'luffarenmapsplugin_manager' Vscript");
				char sTime[64];
				FormatTime(sTime, sizeof(sTime), "%Y-%m-%d-%H-%M-%S", GetTime()); 
				char sc[512];
				StrCat(sc, sizeof(sc),"OnUser1 !self:RunScriptCode:DateTimeReceived(\"");
				StrCat(sc, sizeof(sc),sTime);
				StrCat(sc, sizeof(sc),"\");:0:1");
				SetVariantString(sc);
				AcceptEntityInput(manent,"AddOutput");
				AcceptEntityInput(manent,"FireUser1");
				LogMessage("Sending ServerInfo to 'luffarenmapsplugin_manager' Vscript");
				new Handle:convar_name = FindConVar("hostname");
				char servername[256];
				GetConVarString(convar_name, servername, sizeof(servername)); 
				CloseHandle(convar_name);
				new Handle:convar_ip = FindConVar("ip");
				char serverip[256];
				GetConVarString(convar_ip, serverip, sizeof(serverip));
				CloseHandle(convar_ip);
				ReplaceString(servername,256,":","c",false);
				ReplaceString(servername,256,"<","(",false);
				ReplaceString(servername,256,">",")",false);
				ReplaceString(servername,256,"\"","'",false);
				ReplaceString(servername,256,"\\","/",false);
				ReplaceString(servername,256,":",">",false);
				ReplaceString(servername,256,",",".",false);
				char sc2[512];
				StrCat(sc2, sizeof(sc2),"OnUser1 !self:RunScriptCode:ServerInfoReceived(\"");
				StrCat(sc2, sizeof(sc2),serverip);
				StrCat(sc2, sizeof(sc2),"-");
				StrCat(sc2, sizeof(sc2),servername);
				StrCat(sc2, sizeof(sc2),"\");:0:1");
				SetVariantString(sc2);
				AcceptEntityInput(manent,"AddOutput");
				AcceptEntityInput(manent,"FireUser1");
			}
			for(new i=0;i<sizeof(Luffarenpst);i++)
			{
				if(Luffarenpst[i].send)
				{
					if(Luffarenpst[i].indexretries==5)
					{
						LogMessage("Sending ClientValidated for player %i to 'luffarenmapsplugin_manager' Vscript",Luffarenpst[i].index);
						ReplaceString(Luffarenpst[i].steamid,512,":","c",false);
						ReplaceString(Luffarenpst[i].name,512,"<","(",false);
						ReplaceString(Luffarenpst[i].name,512,">",")",false);
						ReplaceString(Luffarenpst[i].name,512,"\"","'",false);
						ReplaceString(Luffarenpst[i].name,512,"\\","/",false);
						ReplaceString(Luffarenpst[i].name,512,":",">",false);
						ReplaceString(Luffarenpst[i].name,512,",",".",false);
						char sc[512];
						StrCat(sc, sizeof(sc),"OnUser1 !self:RunScriptCode:ClientValidated(");
						StrCat(sc, sizeof(sc),Luffarenpst[i].userid);
						StrCat(sc, sizeof(sc)," \"");
						StrCat(sc, sizeof(sc),Luffarenpst[i].steamid);
						StrCat(sc, sizeof(sc),"\" \"");
						StrCat(sc, sizeof(sc),Luffarenpst[i].name);
						StrCat(sc, sizeof(sc),"\");:0.2:1");
						SetVariantString(sc);
						AcceptEntityInput(manent,"AddOutput");
						AcceptEntityInput(manent,"FireUser1");
						Luffarenpst[i].send = false;
					}
					if(IsValidEntity(Luffarenpst[i].index))
					{
						LogMessage("Setting 'userid %s' to player Vscript-scope (client:%i)",Luffarenpst[i].userid,Luffarenpst[i].index);
						char sc2[64];
						StrCat(sc2, sizeof(sc2),"OnUser1 !self:RunScriptCode:userid<-");
						StrCat(sc2, sizeof(sc2),Luffarenpst[i].userid);
						StrCat(sc2, sizeof(sc2),";:0:1");
						SetVariantString(sc2);
						AcceptEntityInput(Luffarenpst[i].index,"AddOutput");
						AcceptEntityInput(Luffarenpst[i].index,"FireUser1");
					}
					else if(Luffarenpst[i].indexretries > 0)
					{
						Luffarenpst[i].indexretries--;
						Luffarenpst[i].send = true;
					}
				}
			}
		}
	}
}

public void RequestLuffarenData() 
{
	if(LuffarenpstUnloaded || LuffarenMapsCreatedMan)return;
	//thanks to Snowy for fixing an out-of-bounds exception here!
	char first[PLATFORM_MAX_PATH] = "http://luffaren.com/csgo_vscript_configs/{MAPNAME}.html";
	GetCurrentMap(LuffarenCurrentMapName, sizeof(LuffarenCurrentMapName));
	ReplaceString(first, sizeof(first), "{MAPNAME}", LuffarenCurrentMapName);
	LogMessage("Sending HTTP request towards: '%s'...",first);
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, first);
	SteamWorks_SetHTTPCallbacks(request, RequestLuffarenDataComplete);
	SteamWorks_SendHTTPRequest(request);
}

public int RequestLuffarenDataComplete(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data) 
{
	if(LuffarenpstUnloaded || LuffarenMapsCreatedMan)return;
	LogMessage("HTTP response received.");
	if(bRequestSuccessful && eStatusCode == k_EHTTPStatusCode200OK) 
	{
		LogMessage("HTTP response validated (status code %i)!",k_EHTTPStatusCode200OK);
		int length = 0;
		SteamWorks_GetHTTPResponseBodySize(hRequest,length);
		char[] response = new char[length];
		SteamWorks_GetHTTPResponseBodyData(hRequest, response, length);
		LogMessage("HTML body length: %i",length);		//MAX AT ~469312100 (might be machine-dependant?)
		
		LogMessage("Assuring valid path 'csgo/scripts/vscripts/luffaren/'...");
		if(!DirExists("scripts",false)){CreateDirectory("scripts",511);LogMessage("Creating dir: 'csgo/scripts/'");}
		else LogMessage("Dir...OK ('csgo/scripts/')!");
		if(!DirExists("scripts/vscripts",false)){CreateDirectory("scripts/vscripts",511);LogMessage("Creating dir: 'csgo/scripts/vscripts/'");}
		else LogMessage("Dir...OK ('csgo/scripts/vscripts/')!");
		if(!DirExists("scripts/vscripts/luffaren",false)){CreateDirectory("scripts/vscripts/luffaren",511);LogMessage("Creating dir: 'csgo/scripts/vscripts/luffaren/'");}
		else LogMessage("Dir...OK ('csgo/scripts/vscripts/luffaren/')!");
		
		LogMessage("Creating temp file: 'csgo/scripts/vscripts/luffaren/luffarenmaps_temp.nut'");
		Handle file = OpenFile("scripts/vscripts/luffaren/luffarenmaps_temp.nut","w",true,"GAME");
		FlushFile(file);
		LogMessage("Writing to temp file...");
		WriteFileString(file,response,false);
		CloseHandle(file);
		LogMessage("Written HTML body to temp file!");
		
		LogMessage("Setting up entities...");
		LogMessage("Finding/killing any pre-existing 'luffarenmapsplugin_manager' ents...");
		new String:buf[60], ent = -1;
		while((ent = FindEntityByClassname(ent, "logic_auto")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", buf, sizeof(buf));
			if (StrEqual(buf, "luffarenmapsplugin_manager", false))
			{
				SetVariantString("OnUser1 !self:Kill::0:1");
				AcceptEntityInput(ent,"AddOutput");
				AcceptEntityInput(ent,"FireUser1");
				LogMessage("Found 'luffarenmapsplugin_manager' > killing...");
			}
		}
		ent = -1;
		while((ent = FindEntityByClassname(ent, "info_target")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", buf, sizeof(buf));
			if (StrEqual(buf, "luffarenmapsplugin_manager", false))
			{
				SetVariantString("OnUser1 !self:Kill::0:1");
				AcceptEntityInput(ent,"AddOutput");
				AcceptEntityInput(ent,"FireUser1");
				LogMessage("Found 'luffarenmapsplugin_manager' > killing...");
			}
		}
		LogMessage("Creating new 'luffarenmapsplugin_manager' entity...");
		new entindex = CreateEntityByName("logic_auto");
		if (entindex != -1)
		{
			LogMessage("Loading Vscript to 'luffarenmapsplugin_manager'");
			DispatchKeyValue(entindex, "targetname", "luffarenmapsplugin_manager");
			DispatchKeyValue(entindex, "classname", "info_target");
			SetVariantString("OnMapSpawn !self:RunScriptFile:luffaren/luffarenmaps_temp.nut:1:1");
			AcceptEntityInput(entindex,"AddOutput");
			SetVariantString("OnMultiNewRound !self:RunScriptCode:RoundStart();:0:-1");
			AcceptEntityInput(entindex,"AddOutput");
			LogMessage("Created 'luffarenmapsplugin_manager' successfully!");
			LuffarenMapsCreatedMan = true;
		}
		else
			LogMessage("Error creating 'luffarenmapsplugin_manager'.");
		DispatchSpawn(entindex);
		ActivateEntity(entindex);
	}
	else 
	{
		LogMessage("HTTP response ERROR (status code %i), aborting/unloading plugin.",k_EHTTPStatusCode200OK);
		UnloadLuffarenMaps();
	}
	LogMessage("Cleaning up HTTP connection.");
	delete hRequest;
}

public void RequestLuffarenDataCompletePost()
{
	if(LuffarenpstUnloaded)return;
	LogMessage("Deleting temp file...");
	DeleteFile("scripts/vscripts/luffaren/luffarenmaps_temp.nut",false);
	LogMessage("Deleted temp file.");
}

public void UnloadLuffarenMaps()
{
	if(LuffarenpstUnloaded)return;
	//char sFilename[256];
	//GetPluginFilename(INVALID_HANDLE, sFilename, sizeof(sFilename));
	LogMessage("-----------------[ END ]-----------------");
	//ServerCommand("sm plugins unload %s", sFilename);
	
	//thanks to vauff for suggesting this, instead of self-unloading it sets a bool to stop processing stuff in the functions
	//self-unloading plugins can cause issues from what it seems
	LuffarenpstUnloaded = true;
}

