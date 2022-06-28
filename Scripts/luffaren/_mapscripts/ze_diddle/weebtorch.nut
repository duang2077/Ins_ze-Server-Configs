//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

//if the torch (self) detects func_breakable with name: X69Xhichhouse WITHIN 512 units 
//then FireUser1 the house and the rest will handle itself

function Init()
{
	Tick();
}

function Tick()
{
	CheckHouse();
	EntFireByHandle(self,"RunScriptCode"," Tick(); ",0.05,null,null);
}

function CheckHouse()
{
	local p = Entities.FindByNameNearest("X69Xhichhouse",self.GetOrigin(),512);
	if(p != null && p.IsValid())
		EntFireByHandle(p,"FireUser1","",0.00,null,null);
}