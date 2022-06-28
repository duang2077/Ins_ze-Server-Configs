//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

SPEED <- 3.00;
//v1_6: 4.00 / v2: 3.00

function Init()
{
	Tick();
}

function Tick()
{
	self.SetOrigin(self.GetOrigin()+(self.GetForwardVector()*SPEED));
	if(TraceLine(self.GetOrigin(),(self.GetOrigin()+(self.GetForwardVector()*20)),self)<1.00)
		EntFireByHandle(self,"FireUser1","",0.00,null,null);
	EntFireByHandle(self,"RunScriptCode"," Tick(); ",0.01,null,null);
}