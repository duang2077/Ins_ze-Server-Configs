//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

hp <- null;

function SetHP()
{
	hp = caller;
}

function Init()
{
	if(hp != null && hp.IsValid() && hp.GetHealth() > 0)
	{
		local p = null;
		while(null!=(p=Entities.FindByClassname(p,"player")))
		{
			if(p.GetTeam()==3)
				EntFireByHandle(hp,"AddHealth","15",0.00,null,null);//v2:20, v3:15
		}
	}
	DefaultTick();
}

function Hurt()
{
	local r = RandomInt(0,2);
	if(r == 0)
		EntFireByHandle(self,"SetAnimation","HURT1",0.00,null,null);
	else if(r == 1)
		EntFireByHandle(self,"SetAnimation","HURT2",0.00,null,null);
	else
		EntFireByHandle(self,"SetAnimation","HURT3",0.00,null,null);
	DefaultTick();
}

function DefaultTick()
{
	local r = RandomInt(0,2);
	local speed = "";
	if(r == 0)speed = "";
	else if(r == 1)speed = "FAST";
	else speed = "SLOW";
	r = RandomInt(0,4);
	if(r == 0)
		EntFireByHandle(self,"SetDefaultAnimation","IDLE1"+speed,0.00,null,null);
	else if(r == 1)
		EntFireByHandle(self,"SetDefaultAnimation","IDLE2"+speed,0.00,null,null);
	else if(r == 2)
		EntFireByHandle(self,"SetDefaultAnimation","IDLE3"+speed,0.00,null,null);
	else if(r == 3)
		EntFireByHandle(self,"SetDefaultAnimation","IDLE4"+speed,0.00,null,null);
	else
		EntFireByHandle(self,"SetDefaultAnimation","IDLE5"+speed,0.00,null,null);
}

::blobtimer <- 4.00;
function Death()
{
	local r = RandomInt(0,2);
	if(r == 0)
		EntFireByHandle(self,"SetAnimation","DIE1",0.00,null,null);
	else if(r == 1)
		EntFireByHandle(self,"SetAnimation","DIE2",0.00,null,null);
	else
		EntFireByHandle(self,"SetAnimation","DIE3",0.00,null,null);
	EntFireByHandle(self,"SetDefaultAnimation","DIEIDLE",0.02,null,null);
	EntFireByHandle(self,"SetDefaultAnimation","DIEIDLE",0.05,null,null);
	EntFireByHandle(self,"SetDefaultAnimation","DIEIDLE",0.25,null,null);
	EntFireByHandle(self,"FireUser4","",10,null,null);
	::blobtimer += 2.00;
	EntFire("blobb_timer","AddOutput","UpperRandomBound "+::blobtimer.tostring(),0.00,null);
	EntFire("blobb_timer","AddOutput","LowerRandomBound "+(::blobtimer/3).tostring(),0.00,null);
}

function SpawnArms()
{
	EntFire("s_blobarm","AddOutput","origin 9393 3348 -1154",0.00,null);
	EntFire("s_blobarm","AddOutput","angles 60 -50 0",0.00,null);
	EntFire("s_blobarm","ForceSpawn","",0.05,null);
	EntFire("s_blobarm","AddOutput","origin 11047 4811 -2052",0.10,null);
	EntFire("s_blobarm","AddOutput","angles 55 -47 100",0.10,null);
	EntFire("s_blobarm","ForceSpawn","",0.15,null);
	EntFire("s_blobarm","AddOutput","origin 11032 4780 94",0.20,null);
	EntFire("s_blobarm","AddOutput","angles -33 -57 45",0.20,null);
	EntFire("s_blobarm","ForceSpawn","",0.25,null);
	EntFire("s_blobarm","AddOutput","origin 12639 4684 -1658",0.30,null);
	EntFire("s_blobarm","AddOutput","angles 8 -102 70",0.30,null);
	EntFire("s_blobarm","ForceSpawn","",0.35,null);
	EntFire("s_blobarm","AddOutput","origin 13577 3640 -2852",0.40,null);
	EntFire("s_blobarm","AddOutput","angles 55 -170 260",0.40,null);
	EntFire("s_blobarm","ForceSpawn","",0.45,null);
	EntFire("s_blobarm","AddOutput","origin 11124 4600 -2259",0.50,null);
	EntFire("s_blobarm","AddOutput","angles -30 -50 120",0.50,null);
	EntFire("s_blobarm","ForceSpawn","",0.55,null);
	EntFire("s_blobarm","AddOutput","origin 12638 4765 -2515",0.60,null);
	EntFire("s_blobarm","AddOutput","angles -10 -70 180",0.60,null);
	EntFire("s_blobarm","ForceSpawn","",0.65,null);
	EntFire("s_blobarm","AddOutput","origin 12953 4076 -18",0.70,null);
	EntFire("s_blobarm","AddOutput","angles 25 -108 0",0.70,null);
	EntFire("s_blobarm","ForceSpawn","",0.75,null);
	EntFire("s_blobarm","AddOutput","origin 11146 4779 -1961",0.80,null);
	EntFire("s_blobarm","AddOutput","angles -5 -25 -45",0.80,null);
	EntFire("s_blobarm","ForceSpawn","",0.85,null);
	EntFire("s_blobarm","AddOutput","origin 13645 3317 -1460",0.90,null);
	EntFire("s_blobarm","AddOutput","angles 0 -120 0",0.90,null);
	EntFire("s_blobarm","ForceSpawn","",0.95,null);
	EntFire("s_blobarm","AddOutput","origin 12465 3855 1844",1.00,null);
	EntFire("s_blobarm","AddOutput","angles 56 -150 270",1.00,null);
	EntFire("s_blobarm","ForceSpawn","",1.05,null);
	EntFire("s_blobarm","AddOutput","origin 9850 3551 1113",1.10,null);
	EntFire("s_blobarm","AddOutput","angles 28 -33 270",1.10,null);
	EntFire("s_blobarm","ForceSpawn","",1.15,null);
	EntFire("s_blobarm","AddOutput","origin 11226 4624 1804",1.20,null);
	EntFire("s_blobarm","AddOutput","angles 13 -35 -20",1.20,null);
	EntFire("s_blobarm","ForceSpawn","",1.25,null);
	EntFire("s_blobarm","AddOutput","origin 13536 2172 -1871",1.30,null);
	EntFire("s_blobarm","AddOutput","angles 4 163 45",1.30,null);
	EntFire("s_blobarm","ForceSpawn","",1.35,null);
	EntFire("s_blobarm","AddOutput","origin 12903 3820 -464",1.40,null);
	EntFire("s_blobarm","AddOutput","angles -24 -118 15",1.40,null);
	EntFire("s_blobarm","ForceSpawn","",1.45,null);
	EntFire("s_blobarm","AddOutput","origin ",1.50,null);
	EntFire("s_blobarm","AddOutput","angles ",1.50,null);
	EntFire("s_blobarm","ForceSpawn","",1.55,null);
	EntFire("s_blobarm","AddOutput","origin 8919 2787 -1831",1.60,null);
	EntFire("s_blobarm","AddOutput","angles 1 -12 25",1.60,null);
	EntFire("s_blobarm","ForceSpawn","",1.65,null);
	EntFire("s_blobarm","AddOutput","origin 9911 1940 -50",1.70,null);
	EntFire("s_blobarm","AddOutput","angles 2 26 0",1.70,null);
	EntFire("s_blobarm","ForceSpawn","",1.75,null);
	EntFire("s_blobarm","AddOutput","origin 13318 5012 -2604",1.80,null);
	EntFire("s_blobarm","AddOutput","angles -46 -130 0",1.80,null);
	EntFire("s_blobarm","ForceSpawn","",1.85,null);
	EntFire("s_blobarm","AddOutput","origin 13764 2449 -2987",1.90,null);
	EntFire("s_blobarm","AddOutput","angles 29 163 0",1.90,null);
	EntFire("s_blobarm","ForceSpawn","",1.95,null);
	EntFire("s_blobarm","AddOutput","origin 13153 4319 -1497",2.00,null);
	EntFire("s_blobarm","AddOutput","angles 32 -145 180",2.00,null);
	EntFire("s_blobarm","ForceSpawn","",2.05,null);
}
