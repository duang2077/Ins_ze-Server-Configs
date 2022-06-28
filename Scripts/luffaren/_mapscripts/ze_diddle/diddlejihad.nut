//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

function CheckJihad()
{
	local c = null;
	c = Entities.FindByNameWithin(c,"NO_JIHAD",self.GetOrigin(),512);
	if(c == null)
		EntFireByHandle(self,"FireUser4","",0.00,null,null);
	else
		EntFireByHandle(self,"FireUser3","",0.00,null,null);
}
