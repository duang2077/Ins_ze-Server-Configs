//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

HP_ADD <- 25;				//the amount of HP to add for each human alive				//v1_6: 50
TARGET_RANGE <- 4000; 		//units where it starts spawning lasers at people
SPEED <- 5;					//speed that baby moves towards target
//check IsZombieBaby() for the zombie-item-baby settings!

zombie <- false;
model <- null;
sound <- "";
laser <- null;
ltarget <- null;
spawner <- null;
moving <- false;
particle <- null;

function SetEnt(index)
{
	if(index==1)
		model = caller;
	else if(index==2)
		sound = caller.GetName();
	else if(index==3)
		laser = caller;
	else if(index==4)
		ltarget = caller;
	else if(index==5)
		spawner = caller;
	else if(index==6)
		particle = caller;
}

function Init()
{
	IsZombieBaby();
	local r = RandomFloat(0.00,15.00);
	EntFireByHandle(self,"RunScriptCode"," PlayBabySound(); ",r,null,null);
	EntFireByHandle(self,"RunScriptCode"," PrepareLaser(); ",2.00,null,null);
	RunAnimation();
	TickMovement();
	local p = null;
	local hp = 100;
	while(null!=(p=Entities.FindByClassname(p,"player")))
	{
		if(p.GetTeam()==3)
			hp+=HP_ADD;
	}
	EntFireByHandle(self,"SetHealth",hp.tostring(),0.00,null,null);
}

function IsZombieBaby()
{
	local check = null;
	check = Entities.FindByNameNearest("ITEMX_hich_zmboost_maker2*",self.GetOrigin(),128);
	if(check != null && check.IsValid())
	{
		//if the baby spawns next to a zombie (zombie item)
		//buff the baby
		EntFireByHandle(model,"AddOutput","modelscale 1.2", 0.00, null, null);
		EntFireByHandle(model,"AddOutput","rendercolor 255 0 0",0.00,null,null);
		EntFireByHandle(model,"Color","255 0 0",0.02,null,null);
		zombie = true;
		HP_ADD = 50;					//v1_6: 100
		TARGET_RANGE = 10000;
		SPEED = 8;						//v1_6: 10
	}
}

function PlayBabySound()
{
	EntFire(sound,"StopSound","0",0.00,null);
	EntFire(sound,"Volume","0",0.00,null);
	EntFire(sound,"PlaySound","",0.03,null);
	EntFire(sound,"Volume","10",0.03,null);
	local r = RandomFloat(5.00,30.00);
	if(zombie)
		r = RandomFloat(5.00,15.00);
	EntFireByHandle(self,"RunScriptCode"," PlayBabySound(); ",r,null,null);
}

function RunAnimation()
{
	local r = RandomInt(1,9);
	EntFireByHandle(model,"SetAnimation","idle"+r,0.00,null,null);
	EntFireByHandle(model,"SetDefaultAnimation","idle"+r,0.05,null,null);
	local l = RandomFloat(0.10,20.00);
	EntFireByHandle(self,"RunScriptCode"," RunAnimation(); ",l,null,null);
}

function HitBaby()
{
	local r = RandomInt(1,9);
	EntFireByHandle(model,"SetAnimation","idle"+r,0.00,null,null);
	EntFireByHandle(model,"SetDefaultAnimation","idle"+r,0.01,null,null);
	EntFireByHandle(particle,"FireUser1","",0.00,null,null);
}

function CheckDiddleCannonProjectile()
{
	//search in a 56 unit radius
	//hp = self-breakable
	//projectile_hurt = projectile name, i guess wildcard works?
	local p = null;while(null != (p = Entities.FindByNameWithin(p,"projectile_hurt*",self.GetOrigin(),56)))
	{
		EntFireByHandle(p,"FireUser1","",0.00,null,null);
		EntFireByHandle(self,"RemoveHealth","300",0.00,null,null);
	} 
	//new in v2: also check for finale elevator (finale_firstelev) at a radius of 300
	p = null;while(null != (p = Entities.FindByNameWithin(p,"finale_firstelev*",self.GetOrigin(),300)))
	{
		EntFireByHandle(self,"RemoveHealth","50000",0.00,null,null);
	} 
}

function PrepareLaser()
{
	if(!zombie)
	{
		local r = RandomFloat(0.00,5.00);
		EntFireByHandle(self,"RunScriptCode"," StartLaser(); ",r,null,null);
	}
	else
	{
		//new in v2: randomize value instead of running new laser instantly
		local r = RandomFloat(0.00,1.00);
		EntFireByHandle(self,"RunScriptCode"," StartLaser(); ",r,null,null);
	}
}

function StartLaser()
{
	local target = null;
	local p = null;
	local plist = [];
	while(null!=(p=Entities.FindInSphere(p,self.GetOrigin(),TARGET_RANGE)))
	{
		if(p != null && p.IsValid() && p.GetClassname() == "player" && p.GetTeam() == 3 && p.GetHealth()>0)
		{
			local ppos = p.GetOrigin();ppos.z+=48;
			if(TraceLine(ppos,laser.GetOrigin(),self) >= 1.0)
				plist.push(p);
		}
	} 
	if(plist.len() > 0)
	{
		if(plist.len() == 1)target = plist[0];
		else target = plist[RandomInt(0,plist.len()-1)];
		if(target != null && target.IsValid() && target.GetHealth()>0)
		{
			local poss = target.GetOrigin();
			poss.z += 48;
			ltarget.SetOrigin(poss);
			EntFireByHandle(laser,"TurnOn","",0.10,null,null);
			EntFireByHandle(laser,"TurnOff","",3.10,null,null);
			EntFireByHandle(spawner,"ForceSpawn","",0.10,null,null);
			moving = true;
			EntFireByHandle(self,"RunScriptCode"," moving = false; ",3.10,null,null);
			EntFireByHandle(self,"RunScriptCode"," PrepareLaser(); ",3.11,null,null);
		}
		else 
			EntFireByHandle(self,"RunScriptCode"," StartLaser(); ",0.50,null,null);
	}
	else
		EntFireByHandle(self,"RunScriptCode"," StartLaser(); ",0.50,null,null);
}

function TickMovement()
{
	CheckDiddleCannonProjectile();
	if(moving)
	{
		if(GetDistance(self,ltarget)<=(SPEED+2))
			moving = false;
		else
		{
			local t1 = self.GetOrigin();
			local t2 = ltarget.GetOrigin();
			local dir = Vector(t2.x - t1.x, t2.y - t1.y, t2.z - t1.z);
			local length = dir.Norm();
			self.SetForwardVector(Vector(dir.x * length, dir.y * length, dir.z * length));
			local newpos = self.GetOrigin() + (self.GetForwardVector()*SPEED);
			self.SetOrigin(newpos);
			particle.SetOrigin(self.GetOrigin());
			particle.SetAngles(self.GetAngles().x,self.GetAngles().y,self.GetAngles().z);
		}
	}
	EntFireByHandle(self,"RunScriptCode"," TickMovement(); ",0.01,null,null);
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
