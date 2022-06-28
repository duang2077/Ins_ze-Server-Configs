//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

//shrekhead bounds:
//X:		-1000		5500
//Y:		-13296		-12304
//Z:		13320

function SpawnShrekHeads()
{
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.00,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.10,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.20,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.30,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.40,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.50,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.60,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.70,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.80,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",0.90,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.00,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.10,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.20,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.30,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.40,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.50,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.60,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.70,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.80,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",1.90,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.00,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.10,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.20,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.30,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.40,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.50,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.60,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.70,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.80,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",2.90,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.00,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.10,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.20,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.30,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.40,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.50,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.60,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.70,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.80,null,null);
	EntFireByHandle(self,"RunScriptCode"," SpawnDoodler(); ",3.90,null,null);
	EntFire(self,"RunScriptCode"," SpawnDoodler(); ",4.00,null);
	
	EntFireByHandle("X69Xluff_npc_phys2gg*","RunScriptCode"," AddHP(50,10); ",25.00,null,null);
	EntFireByHandle("X69Xluff_npc_killme*","Enable","",25.00,null,null);
	EntFireByHandle("X69Xluff_npc_killme*","Enable","",26.00,null,null);
	//EntFireByHandle("X69Xluff_npc_phys2gg*","RunScriptCode"," AddHP(50,20); ",25.00,null,null);
}

function SpawnDoodler()
{
	local x = RandomInt(-1000,5500);
	local y = RandomInt(-13296,-12304);
	local pos = "origin "+x+" "+y+" 13320";
	EntFire("s_shrekface","AddOutput",pos,0.00,null);
	EntFire("s_shrekface","ForceSpawn","",0.05,null);
}