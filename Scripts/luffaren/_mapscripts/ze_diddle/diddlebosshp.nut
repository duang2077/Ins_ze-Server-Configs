//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

function StartTickHP()
{
	EntFire("bosshp_text", "SetText", "BOSS HP: "+self.GetHealth().tostring(), 0.00, null);
	EntFire("bosshp_text", "Display", "", 0.02, null);
	EntFireByHandle(self, "RunScriptCode", " StartTickHP(); ", 0.10, null, null);
}