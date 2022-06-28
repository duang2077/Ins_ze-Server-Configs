//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

//max radius from !self: 1312

amount <- 0;
minrate <- 0.00;
maxrate <- 0.00;

function SpawnBarrage(_amount,_minrate,_maxrate)
{
	amount = _amount;
	minrate = _minrate;
	maxrate = _maxrate;
	SpawnMortar();
}

function SpawnMortar()
{
	local x = RandomInt((self.GetOrigin().x-1312),(self.GetOrigin().x+1312));
	local y = RandomInt((self.GetOrigin().y-1312),(self.GetOrigin().y+1312));
	local z = self.GetOrigin().z;
	local pos = "origin "+x+" "+y+" "+z;
	EntFire("s_mortar","AddOutput",pos,0.00,null);
	EntFire("s_mortar","ForceSpawn","",0.02,null);
	amount--;
	if(amount>0)
	{
		local rand = RandomFloat(minrate,maxrate);
		EntFireByHandle(self,"RunScriptCode"," SpawnMortar(); ",rand,null,null);
	}
}