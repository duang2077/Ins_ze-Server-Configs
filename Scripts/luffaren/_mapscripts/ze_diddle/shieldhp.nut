//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

function AddHP(add_amount)
{
	local add = 100.00;
	local p = null;while(null != (p = Entities.FindByClassname(p,"player")))
	{if(p.GetTeam() == 2)add += add_amount;}
	EntFireByHandle(self,"SetHealth",add.tostring(),0.00,null,null);
}