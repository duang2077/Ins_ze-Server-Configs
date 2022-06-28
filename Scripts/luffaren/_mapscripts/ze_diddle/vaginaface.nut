//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

target <- null;
speed <- 0.0;
speed_acceleration <- 0.1;
speed_max <- 15.0;
model <- null;
s_target <- null;
s_hit <- null;
s_hurt1 <- null;
s_hurt2 <- null;
s_hurt3 <- null;
s_die <- null;
hp <- null;
dead <- false;
deadbig <- false;
deadscale <- 1.0;
retarget <- 14;

function SetEnt(i)
{
	if(i==1)model = caller;
	else if(i==2)s_target = caller;
	else if(i==3)s_hit = caller;
	else if(i==4)s_hurt1 = caller;
	else if(i==5)s_hurt2 = caller;
	else if(i==6)s_hurt3 = caller;
	else if(i==7)s_die = caller;
	else if(i==8)hp = caller;
}

function Start()
{
	Tick();
	SetHealth();
	EntFire("manager", "RunScriptCode", " AddVagina(); ", 0.00, self);
}

function CheckDiddleCannonProjectile()
{
	//search in a 100 unit radius
	//hp = self-breakable
	//projectile_hurt = projectile name, i guess wildcard works?
	local p = null;while(null != (p = Entities.FindByNameWithin(p,"projectile_hurt*",self.GetOrigin(),100)))
	{
		EntFireByHandle(p,"FireUser1","",0.00,null,null);
		EntFireByHandle(hp,"RemoveHealth","400",0.00,null,null);
	} 
}

function Tick()
{
	if(!dead && target != null && target.IsValid() && target.GetHealth() > 0)
	{	
		retarget -= 0.02;
		CheckDiddleCannonProjectile();
		local t1 = self.GetOrigin();
		local t2 = target.GetOrigin();
		t2.z += 48;
		if(retarget <= 0.0 || TraceLine(self.GetOrigin(),t2,self) < 1.0)
		{	
			SearchTarget();
		}
		else
		{
			local dir = Vector(t2.x - t1.x, t2.y - t1.y, t2.z - t1.z);
			local length = dir.Norm();
			self.SetForwardVector(Vector(dir.x * length, dir.y * length, dir.z * length));
			local newpos = self.GetOrigin() + (self.GetForwardVector()*speed);
			self.SetOrigin(newpos);
			if(speed < speed_max)
				speed += speed_acceleration;
		}
	}
	else if(dead)
	{
		if(!deadbig)
		{
			deadscale += 0.1;
			if(deadscale > 2.0)
				deadbig = true;
		}
		else
		{
			deadscale -= 0.1;
			if(deadscale <= 0.0)
			{
				deadscale = 0.01;
				EntFireByHandle(model, "Disable", "", 0.00, null, null);
			}
		}
		EntFireByHandle(model, "AddOutput", "modelscale " + deadscale, 0.00, null, null);
	}
	else
		SearchTarget();
	EntFireByHandle(self, "RunScriptCode", " Tick() ", 0.01, null, null);
}

function Die()
{
	dead = true;
	EntFireByHandle(s_die, "PlaySound", "", 0.00, null, null);
	local rand = GetRandomValue(2);
	if(rand==0)EntFireByHandle(model, "SetAnimation", "hurt_1", 0.00, null, null);
	if(rand==1)EntFireByHandle(model, "SetAnimation", "hurt_2", 0.00, null, null);
	if(rand==2)EntFireByHandle(model, "SetAnimation", "hurt_3", 0.00, null, null);
}

function Hurt()
{
	speed = 0.0;
	local rand = GetRandomValue(2);
	if(rand==0)EntFireByHandle(model, "SetAnimation", "hurt_1", 0.00, null, null);
	if(rand==1)EntFireByHandle(model, "SetAnimation", "hurt_2", 0.00, null, null);
	if(rand==2)EntFireByHandle(model, "SetAnimation", "hurt_3", 0.00, null, null);
	rand = GetRandomValue(2);
	if(rand==0)EntFireByHandle(s_hurt1, "PlaySound", "", 0.00, null, null);
	if(rand==1)EntFireByHandle(s_hurt2, "PlaySound", "", 0.00, null, null);
	if(rand==2)EntFireByHandle(s_hurt3, "PlaySound", "", 0.00, null, null);
}

function HitPlayer()
{
	EntFireByHandle(s_hit, "PlaySound", "", 0.00, null, null);
	speed = 0.0;
}

function SearchTarget()
{
	if(!dead)
	{
		if(target != null && target.IsValid() && target.GetHealth() > 0){}
		else
		{
			target = null;
			speed = 0.0;
		}
		local p = null;
		local pa = [];
		while(null != (p = Entities.FindByClassname(p,"player")))
		{
			if(p.GetTeam() == 3)
			{
				local ppos = p.GetOrigin();ppos.z+=48;
				if(TraceLine(self.GetOrigin(),ppos,self) == 1.0)
					pa.push(p);
			}
		}
		if(pa.len() > 0)
		{
			retarget = 14;
			EntFireByHandle(s_target, "PlaySound", "", 0.00, null, null);
			target = pa[GetRandomValue(pa.len()-1)];
		}
	}
}

function SetHealth()
{
	local base_hp = 500;
	local foreachplayer_hpadd = 100;
	
	if(hp != null && hp.IsValid())
	{
		local hpadd = 0;
		local p = null;
		while(null != (p = Entities.FindByClassname(p,"player")))
		{
			if(p.GetTeam() == 3)
				hpadd += foreachplayer_hpadd;
		}
		EntFireByHandle(hp, "SetHealth", "" + (base_hp+hpadd), 0.00, null, null);
	}
}

function GetRandomValue(max)
{   
    //random int between 0 and max
    local r = (1.0 * rand() / RAND_MAX) * (max + 1);
    return r.tointeger();
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

function GetDistanceXY(vector1, vector2)
{
	return sqrt((vector1.GetOrigin().x-vector2.GetOrigin().x)*(vector1.GetOrigin().x-vector2.GetOrigin().x) + 
				(vector1.GetOrigin().y-vector2.GetOrigin().y)*(vector1.GetOrigin().y-vector2.GetOrigin().y));
}
