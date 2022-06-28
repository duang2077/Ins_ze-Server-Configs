//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

ammo <- 300;
text <- null;
target <- null;

function RenderCoinCount()
{
	if(target != null && target.IsValid())
	{
		EntFireByHandle(text, "SetText", "AMMO: "+ammo.tostring(), 0.00, target, target);
		EntFireByHandle(text, "Display", "", 0.02, target, target);
		if(GetDistance(target, self)>200)
			target = null;
	}
	EntFireByHandle(self, "RunScriptCode", " RenderCoinCount(); ", 0.20, null, null);
}

function UseItem()
{
	ammo--;
	if(ammo <= 0)
		EntFireByHandle(self, "FireUser2", "", 0.00, null, null);
}

function SetText()
{
	text = caller;
}

function PickUp()
{
	target = activator;
}

function GetDistance(vector1, vector2)
{
	local z1 = vector1.GetOrigin().z;
	local z2 = vector2.GetOrigin().z;
	if(vector1.GetClassname()=="player")z1+=48;
	else if(vector2.GetClassname()=="player")z2+=48;
	return sqrt((vector1.GetOrigin().x-vector2.GetOrigin().x)*(vector1.GetOrigin().x-vector2.GetOrigin().x) + 
				(vector1.GetOrigin().y-vector2.GetOrigin().y)*(vector1.GetOrigin().y-vector2.GetOrigin().y) + 
				(z1-z2)*(z1-z2));
}
