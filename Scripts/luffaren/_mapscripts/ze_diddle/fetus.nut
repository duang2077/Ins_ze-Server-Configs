//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\


//TODO
//add start/stop function to start/stop targeting players (for custom attacks/manual anim/etc)
//activate the _base hurtpoint LATER, when the boss lands on the ground!
//ragemode crawl SetSpeed(2500,50) works fine when moving forward, CAN get stuck though, 
//^^^^prevent it INCREASE SIDE SPEED WHEN HUMAN IS BEHIND

//PRESETS
//<physbox Override Parameters> <SetSpeed(forward,turning);>
//DEFAULT: damping,1.0,rotdamping,40 / SetSpeed(1250,600);
//ACCURATE: damping,5.0,rotdamping,40 / SetSpeed(3000,1000);


::soundloop_clientcommand <- Entities.CreateByClassname("point_clientcommand");
events <- null;
dead <- false;
autotarget <- true;
drawtarget <- false;
drawdamage <- false;
target <- null;
target_time_reset <- 0.00;
target_time <- 0.00;
targetdistance <- 2000;
//---------
targetpriority <- [0];
//(this is a list of targetpriorities which you can set however you wish, more values = more checks = more expensive)
//(when searching for a target, it will loop through the priority-checks in the order you add them)
//(if a specified value already exists in the array, it will not add it again)
//(if all priority-checks fails, the npc will stop/stand still/go idle but keep searching for a new target)
//(to add a target priority, use " AddTargetPriority(value); ")
//(to clear all target priorities, use " ClearTargetPriorities(); ")
//(if you pick an invalid value it will revert to 0 as default)
//(if you want to manually target a specific entity/player, you can leave it empty and use " SetTarget(activator_or_caller); ")
//("in sight" = TraceLine() between the npc hporigin and the target, if there's no static world in between it'll work)
//0: random ct in targetdistance 
//1: random ct in sight and targetdistance
//2: closest ct in targetdistance
//3: closest ct in sight and targetdistance
//4: furthest ct in targetdistance
//5: furthest ct in sight and targetdistance
//6: ct that has dealed most damage in targetdistance
//7: ct that has dealed most damage in sight and targetdistance
//8: ct that has dealed least damage in targetdistance
//9: ct that has dealed least damage in sight and targetdistance
//10: ct that has most hp in targetdistance
//11: ct that has most hp in sight and targetdistance
//12: ct that has least hp in targetdistance
//13: ct that has least hp in sight and targetdistance
//---------
tf <- null;
ts <- null;
tu <- null;
s_tf <- 1250;
s_ts <- 600;
s_tu <- 800;
hp <- null;
hpbar <- null;
hpbarmaxhealth <- 1000000;
hpbarhealth <- 1000000;
s_target <- null;
s_hurt <- null;
s_die <- null;
model <- null;
head <- null;
headparent <- null;
ticking <- false;
damagepoints <- [];
damageactives <- [];
damagedistancebaseds <- [];
damageamounts <- [];
damageradiuses <- [];
damagerefires <- [];
damageplayers <- [];
damageplayersrefire <- [];
halfhp <- 0;
rageinit <- false;
lpos <- self.GetOrigin();

function SetEnt(i)
{
	if(i==1)tf = caller;
	else if(i==2)ts = caller;
	else if(i==3)tu = caller;
	else if(i==4)hp = caller;
	else if(i==5)model = caller;
	else if(i==6)hpbar = caller;
	else if(i==7)events = caller.GetName();
	else if(i==8)head = caller;
	else if(i==9)headparent = caller;
}

function RunEvent(event,callback)
{
	EntFire(events, "InValue", event, 0.00, callback);
}

function SetDamagePoint(activator_or_caller, damage_amount, enabled, distance_based, damage_radius, damage_refire)
{
	local exists = false;
	local eindex = -1;
	for(local i=0;i<(damagepoints.len()-1);i+=1)
	{
		if(damagepoints[i] == activator || damagepoints[i] == caller)
		{
			exists = true;
			eindex = i;
			break;
		}
	}
	if(exists)
	{
		damageactives[eindex] = enabled;
		damagedistancebaseds[eindex] = distance_based;
		damageamounts[eindex] = damage_amount;
		damageradiuses[eindex] = damage_radius;
		damagerefires[eindex] = damage_refire;
	}
	else
	{
		if(activator_or_caller == 1)
			damagepoints.push(activator);
		else
			damagepoints.push(caller);
		damageactives.push(enabled);
		damagedistancebaseds.push(distance_based);
		damageamounts.push(damage_amount);
		damageradiuses.push(damage_radius);
		damagerefires.push(damage_refire);
	}
}

function RemoveDamagePoint(activator_or_caller)
{
	if(activator_or_caller == 1)
	{
		for(local i=0;i<(damagepoints.len()-1);i+=1)
		{
			if(activator == damagepoints[i])
			{
				damagepoints.remove(i);
				damageactives.remove(i);
				damagedistancebaseds.remove(i);
				damageamounts.remove(i);
				damageradiuses.remove(i);
				damagerefires.remove(i);
				break;
			}
		}
	}
	else
	{
		for(local i=0;i<(damagepoints.len()-1);i+=1)
		{
			if(caller == damagepoints[i])
			{
				damagepoints.remove(i);
				damageactives.remove(i);
				damagedistancebaseds.remove(i);
				damageamounts.remove(i);
				damageradiuses.remove(i);
				damagerefires.remove(i);
				break;
			}
		}
	}
}

function ClearDamagePoints()
{
	damageplayers.clear();
	damageplayersrefire.clear();
	damagepoints.clear();
	damageactives.clear();
	damagedistancebaseds.clear();
	damageamounts.clear();
	damageradiuses.clear();
	damagerefires.clear();
}

function GetDamageBasedOnDistance(center,_target,damageradius,damageamount)
{
	local totaldamage = 0.00;
	local targetdistance = GetDistance(center,_target);
	if(targetdistance < damageradius)
		totaldamage = (damageamount*(1.00-(targetdistance/damageradius)));
	return totaldamage;
}

function DealDamage(_target,_index)
{
	if(_target.IsValid() && _target.GetHealth() > 0)
	{
		local exists = false;
		local eindex = -1;
		for(local j=0;j<(damageplayers.len());j+=1)
		{
			if(damageplayers[j] == _target)
			{
				exists = true;
				eindex = j;
				break;
			}
		}
		if(!exists)
		{
			if(damagedistancebaseds[_index])
			{
				EntFireByHandle(_target, "SetHealth", "" + (_target.GetHealth()-
				GetDamageBasedOnDistance(damagepoints[_index],_target,damageradiuses[_index],damageamounts[_index])), 0.0, null, null);
			}
			else
				EntFireByHandle(_target, "SetHealth", "" + (_target.GetHealth()-damageamounts[_index]), 0.0, null, null);
			damageplayers.push(_target);
			damageplayersrefire.push(damagerefires[_index]);
			if(_target.GetClassname() == "player")//client test for magmadrake (does this work/play sound for individual players?)
				EntFireByHandle(soundloop_clientcommand,"Command","play *luffaren/clienthurt.mp3",0.00,_target,_target);
		}
		else
		{
			//-------------
			//TODO: remove this, replace _hurtindex with eindex (from above) ???????
			local _hurtindex = -1;
			for(local i=0;i<(damageplayers.len());i+=1)
			{
				if(damageplayers[i] == _target)
				{
					_hurtindex = i;
					break;
				}
			}
			if(damageplayersrefire[_hurtindex] <= 0)
			//-------------
			{
				if(damagedistancebaseds[_index])
				{   
					EntFireByHandle(_target, "SetHealth", "" + (_target.GetHealth()-
					GetDamageBasedOnDistance(damagepoints[_index],_target,damageradiuses[_index],damageamounts[_index])), 0.0, null, null);
				}
				else
					EntFireByHandle(_target, "SetHealth", "" + (_target.GetHealth()-damageamounts[_index]), 0.0, null, null);
				damageplayersrefire[eindex] = damagerefires[_index];
				if(_target.GetClassname() == "player")//client test for magmadrake (does this work/play sound for individual players?)
					EntFireByHandle(soundloop_clientcommand,"Command","play *luffaren/clienthurt.mp3",0.00,_target,_target);
			}
		}
	}
}

function TickDamageRefire()
{
	for(local i=0;i<(damageplayers.len());i+=1)
	{
		if(damageplayersrefire[i] > 0)
			damageplayersrefire[i] -= 0.03;
	}
}

function TickDamageCheck()
{
	for(local i=0;i<(damagepoints.len());i+=1)
	{
		if(damagepoints[i] == null || !damagepoints[i].IsValid() || !damageactives[i])continue;
		if(drawdamage)
		{
			local v = damagepoints[i].GetOrigin();
			local vf = damagepoints[i].GetForwardVector();
			local vl = damagepoints[i].GetLeftVector();
			local vu = damagepoints[i].GetUpVector();
			DebugDrawLine(v-(vf*damageradiuses[i]),v+(vf*damageradiuses[i]), 255, 0, 0, false, 0.04);
			DebugDrawLine(v-(vf*damageradiuses[i]),v+(vf*damageradiuses[i]), 255, 0, 0, false, 0.04);
			DebugDrawLine(v-(vl*damageradiuses[i]),v+(vl*damageradiuses[i]), 255, 0, 0, false, 0.04);
			DebugDrawLine(v-(vl*damageradiuses[i]),v+(vl*damageradiuses[i]), 255, 0, 0, false, 0.04);
			DebugDrawLine(v-(vu*damageradiuses[i]),v+(vu*damageradiuses[i]), 255, 0, 0, false, 0.04);
			DebugDrawLine(v-(vu*damageradiuses[i]),v+(vu*damageradiuses[i]), 255, 0, 0, false, 0.04);
		}
		if(target != null && target.IsValid() && target.GetClassname() != "player" && target.GetHealth() > 0)
		{
			if(GetDistance(damagepoints[i].GetOrigin(),target.GetOrigin()) <= damageradiuses[i])
				DealDamage(target,i);
		}
		local p = null;
		while(null != (p = Entities.FindInSphere(p,damagepoints[i].GetOrigin(),damageradiuses[i])))
		{
			if(p.GetClassname() == "player" && p.GetTeam() == 3)
				DealDamage(p,i);
			else if(p.GetClassname() == "func_breakable" && p.GetName() == "fetuswall")
			{
				EntFire("s_fetuswalleffect_maker","ForceSpawnAtEntityOrigin","!activator",0.00,p);
				EntFireByHandle(p,"Break","",0.01,null,null);
			}
		}
	}
}

function Start()
{
	ticking = true;
	Tick();
	TickHead();
}

function TickHealthBar()
{
	if(hp == null || !hp.IsValid())
	{
		hpbarhealth = 0;
		EntFireByHandle(hpbar, "SetTextureIndex", "0", 0.00, null, null);
	}
	else if(hpbar != null && hpbar.IsValid())
	{
		hpbarhealth = hp.GetHealth();
		if(hpbarhealth > (hpbarmaxhealth*0.9))
		EntFireByHandle(hpbar, "SetTextureIndex", "10", 0.00, null, null);if(hpbarhealth <= (hpbarmaxhealth*0.1))
			EntFireByHandle(hpbar, "SetTextureIndex", "1", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.2))
			EntFireByHandle(hpbar, "SetTextureIndex", "2", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.3))
			EntFireByHandle(hpbar, "SetTextureIndex", "3", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.4))
			EntFireByHandle(hpbar, "SetTextureIndex", "4", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.5))
			EntFireByHandle(hpbar, "SetTextureIndex", "5", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.6))
			EntFireByHandle(hpbar, "SetTextureIndex", "6", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.7))
			EntFireByHandle(hpbar, "SetTextureIndex", "7", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.8))
			EntFireByHandle(hpbar, "SetTextureIndex", "8", 0.00, null, null);
		else if(hpbarhealth <= (hpbarmaxhealth*0.9))
			EntFireByHandle(hpbar, "SetTextureIndex", "9", 0.00, null, null);
	}
}

function SpawnZombie()
{
	local pp = [];
	local p = null;while(null != (p = Entities.FindByClassname(p,"player")))
	{if(p!=null&&p.IsValid()&&p.GetHealth()>0&&p.GetTeam()==2)pp.push(p);}
	if(pp.len()>0)
	{
		local loc = null;loc = Entities.FindByName(loc,"feb_baby");
		local location = loc.GetOrigin();location.z+=32;
		local locationlotion = "origin "+location.x+" "+location.y+" "+location.z;
		local rpp = RandomInt(0,pp.len()-1);
		EntFireByHandle(pp[rpp],"AddOutput",locationlotion,0.00,null,null);
		EntFireByHandle(pp[rpp],"SetHealth","666",0.00,null,null);
		EntFire("feb_timer_zombie","RunScriptCode"," SetVelocity(0,0,0); ",0.01,pp[rpp]);
	}
}

function TickHead()
{
	if(GetDistanceVector(self.GetOrigin(),lpos) < 2)
		UnStuck();
	lpos = self.GetOrigin();
	if(!rageinit && hpbarhealth <= halfhp)
	{
		rageinit = true;
		ScriptCoopResetRoundStartTime();
		EntFire("npc_base_1","Disablemotion","",0.00,null);
		EntFire("fb_attack_timer","Disable","",0.00,null);
		EntFire("fb_attack_timer","Enable","",7.00,null);
		EntFire("finale_escapetimer","Enable","",0.00,null);
		EntFire("finale_escapetimer2","Enable","",0.00,null);
		EntFire("fb_soundrage_relay","FireUser1","",0.00,null);
		EntFire("dd_shake_intro","StartShake","",0.00,null);
		EntFire("dd_shake_intro","StartShake","",3.00,null);
		EntFire("dd_shake_intro","StartShake","",7.00,null);
		EntFire("fb_swingrage_relay","Enable","",0.00,null);
		EntFire("fb_swing_relay","Disable","",0.00,null);
		EntFire("fb_sound_relay","Disable","",0.00,null);
		EntFire("fb_sound_timer","Disable","",0.00,null);
		EntFire("fb_soundrage_1","PlaySound","",0.00,null);
		EntFire("fb_sound_1","Volume","0",0.00,null);
		EntFire("fb_sound_2","Volume","0",0.00,null);
		EntFire("fb_sound_3","Volume","0",0.00,null);
		EntFire("fb_sound_4","Volume","0",0.00,null);
		EntFire("fb_sound_5","Volume","0",0.00,null);
		EntFire("fb_sound_timer","Enable","",10.00,null);
		EntFire("fb_body","Setanimation","ragemode",0.00,null);
		EntFire("fb_head","Setanimation","hurt",0.00,null);
		EntFire("fb_head","Setanimation","hurt",3.00,null);
		EntFire("fb_head","Setanimation","hurt",7.00,null);
		EntFire("fb_head","Setanimation","hurt",10.00,null);
		EntFire("fb_head","SetDefaultanimation","freak",4.02,null);
		EntFire("fb_body","SetDefaultanimation","rage_crawl",0.02,null);
		EntFire("i_npc_tf_1","AddOutput","force 2500",0.00,null);
		EntFire("i_npc_tf_1","Deactivate","",0.05,null);
		EntFire("i_npc_ts_1","Deactivate","",0.05,null);
		EntFire("npc_base_1","Enablemotion","",4.00,null);
		EntFire("feb_timer_zombie","Disable","",0.00,null);
		EntFire("feb_timer_baby","Disable","",0.00,null);
		EntFire("i_npc_tf_1","Dectivate","",5.02,null);
		EntFire("i_npc_ts_1","Dectivate","",5.02,null);
		EntFire("i_npc_tf_1","Activate","",5.05,null);
		EntFire("i_npc_ts_1","Activate","",5.05,null);
	}
	if(head != null && headparent != null)
	{
		head.SetOrigin(headparent.GetOrigin());
		if(target != null && target.IsValid())
		{
			local t1 = head.GetOrigin();
			local t2 = target.GetOrigin();
			local dir = Vector(t2.x - t1.x, t2.y - t1.y, t2.z - t1.z);
			local length = dir.Norm();
			head.SetForwardVector(Vector(dir.x * length, dir.y * length, dir.z * length));
		}
		if(!dead)
			EntFireByHandle(self, "RunScriptCode", " TickHead() ", 0.01, null, null);
	}
}	

shrink <- 1.00;

function Tick()
{
	if(ticking)
	{
		if(dead)
		{
			if(shrink <= 0.05)
				ticking = false;
			else
				shrink = (0.9975*shrink);
			EntFire("fb_body","AddOutput","modelscale " + shrink,0.00,null);
			EntFire("fb_head","AddOutput","modelscale " + shrink,0.00,null);
			EntFire("fb_head","SetParentAttachment","head1",0.00,null);
		}
		else
		{
			if(target == null || !target.IsValid() || target_time <= 0 || target.GetTeam() == 2 || target.GetHealth() <= 0 
			|| GetDistance(self,target) > targetdistance)
			{
				//target = null;
				EntFireByHandle(tf, "Deactivate", "", 0.0, null, null);
				EntFireByHandle(ts, "Deactivate", "", 0.0, null, null);
				target_time = target_time_reset;
				if(autotarget)
					SearchTarget();
				TickDamageRefire();
				TickDamageCheck();
			}
			else
			{
				TraceCheck();
				UpdateDirectionCheck();
				Move();
				TickDamageRefire();
				TickDamageCheck();
				target_time -= 0.03;
				if(drawtarget && hp != null && hp.IsValid())
				{
					if(target.GetClassname() == "player")
					{
						local tpos = target.GetOrigin();tpos.z+=48;
						DebugDrawLine(tpos, hp.GetOrigin(), 255, 255, 0, false, 0.04);
					}
					else DebugDrawLine(target.GetOrigin(), hp.GetOrigin(), 255, 255, 0, false, 0.04);
				}
			}
		}
		EntFireByHandle(self, "RunScriptCode", " Tick() ", 0.02, null, null);
	}
}

function TraceCheck()
{
	//DebugDrawLine(self.GetOrigin(),(self.GetOrigin()+self.GetForwardVector()*30), 0, 255, 0, false, 0.04);
	if(TraceLine(self.GetOrigin(),self.GetOrigin()+self.GetForwardVector()*30,self) < 1.0)
	{
		EntFireByHandle(tf, "Deactivate", "", 0.00, null, null);
		EntFireByHandle(tf, "AddOutput", "angles 0 180 0", 0.00, null, null);
		EntFireByHandle(tf, "AddOutput", "Force 10000", 0.00, null, null);
		EntFireByHandle(tf, "Activate", "", 0.01, null, null);
		EntFireByHandle(tf, "AddOutput", "Force " + s_tf, 0.1, null, null);
		EntFireByHandle(tf, "AddOutput", "angles 0 0 0", 0.1, null, null);
		EntFireByHandle(tf, "Deactivate", "", 0.1, null, null);
		
		//TODO - add feature to make npc jump over objects
	}
}

function Jump(force)
{
	EntFireByHandle(tf, "Deactivate", "", 0.00, null, null);
	EntFireByHandle(tf, "AddOutput", "angles -90 0 0", 0.00, null, null);
	EntFireByHandle(tf, "AddOutput", "Force " + force, 0.00, null, null);
	EntFireByHandle(tf, "Activate", "", 0.01, null, null);
	EntFireByHandle(tf, "AddOutput", "angles 0 0 0", 0.1, null, null);
	EntFireByHandle(tf, "AddOutput", "Force " + s_tf, 0.1, null, null);
	EntFireByHandle(tf, "Deactivate", "", 0.1, null, null);
}

target_isonright <- false;
target_isonfront <- false;
target_isondeadzone <- false;
target_deadzone <- 25.00;
function UpdateDirectionCheck()
{
	local p = Vector(target.GetOrigin().x-self.GetOrigin().x,target.GetOrigin().y-self.GetOrigin().y,target.GetOrigin().z-self.GetOrigin().z);
	local a = self.GetForwardVector().Cross(p);
	local angle = (a.Dot(self.GetUpVector())) / ((GetDistanceXY(self,target)/2));
	if(angle < 0)target_isonright = true;
	else target_isonright = false;
	
	if(angle < (target_deadzone/100) && angle > (-(target_deadzone/100)))target_isondeadzone = true;
	else target_isondeadzone = false;
	
	a = self.GetLeftVector().Cross(p);
	angle = (a.Dot(self.GetUpVector())) / ((GetDistanceXY(self,target)/2));
	if(angle < 0)target_isonfront = false;
	else target_isonfront = true;
}

function Move()
{
	if(target_isondeadzone && target_isonfront)
	{
		EntFireByHandle(ts, "Deactivate", "", 0.0, null, null);
		EntFireByHandle(tf, "Activate", "", 0.01, null, null);
	}
	else if(target_isonright)
	{
		EntFireByHandle(ts, "Deactivate", "", 0.0, null, null);
		EntFireByHandle(ts, "AddOutput", "angles 0 270 0", 0.00, null, null);
		EntFireByHandle(ts, "Activate", "", 0.01, null, null);
	}
	else
	{
		EntFireByHandle(ts, "Deactivate", "", 0.0, null, null);
		EntFireByHandle(ts, "AddOutput", "angles 0 90 0", 0.00, null, null);
		EntFireByHandle(ts, "Activate", "", 0.01, null, null);
	}
	if(!target_isonfront)
	{
		EntFireByHandle(tf, "Deactivate", "", 0.00, null, null);
		UnStuck();
	}
	else
		EntFireByHandle(tf, "Activate", "", 0.01, null, null);
		
	//if(RandomChance(1))Jump(5000); //TODO: remove this, just for fun atm
}

function UnStuck()
{
	EntFire("i_npc_ts_1","AddOutput","force 1000",0.00,null);
	EntFire("i_npc_ts_1","AddOutput","force 75",0.03,null);
}

function SearchTarget()
{
	local plist = [];
	local p = null;
	while(null != (p = Entities.FindInSphere(p,self.GetOrigin(),20000)))
	{
		if(p != null && p.IsValid() && p.GetClassname() == "player" && p.GetTeam() == 3 && p.GetHealth()>0)
			plist.push(p);
	}
	if(plist.len() > 0)
	{
		if(plist.len() == 1)
			target = plist[0];
		else
			target = plist[RandomInt(0,plist.len()-1)];
	}
}

function SetHealth(base_hp, foreachplayer_hpadd)
{
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
		hpbarmaxhealth = (base_hp+hpadd);
		hpbarhealth = (base_hp+hpadd);
		EntFireByHandle(self, "RunScriptCode", " TickHealthBar(); ", 0.01, null, null);
		EntFireByHandle(hpbar, "FireUser2", "", 0.02, null, null);
		halfhp = ((base_hp+hpadd) * 0.30); //v2:0.50, v3:0.30
	}
}

function AddHealth(add_health)
{
	if(hp != null && hp.IsValid())
	{
		hpbarhealth += add_health;
		if(hpbarhealth > hpbarmaxhealth)
			hpbarmaxhealth = hpbarhealth;
		if(hpbarhealth <= 0)
		{
			EntFireByHandle(hpbar, "SetTextureIndex", "0", 0.00, null, null);
			EntFireByHandle(hp, "Break", "", 0.00, null, null);
		}
		else
		{
			EntFireByHandle(hp, "AddHealth", "" + (add_health), 0.00, null, null);
			EntFireByHandle(self, "RunScriptCode", " TickHealthBar(); ", 0.01, null, null);
			EntFireByHandle(hpbar, "FireUser2", "", 0.02, null, null);
		}
	}
}

function SetHealthPercentageByInitialHealth(percentage_health)
{
	if(hp != null && hp.IsValid())
	{
		if(hpbarmaxhealth*((0.00+percentage_health)/100) <= 0)
		{
			EntFireByHandle(hpbar, "SetTextureIndex", "0", 0.00, null, null);
			EntFireByHandle(hp, "Break", "", 0.00, null, null);
		}
		else
		{
			EntFireByHandle(hp, "SetHealth", "" + (hpbarmaxhealth*((0.00+percentage_health)/100)), 0.00, null, null);
			hpbarhealth = hpbarmaxhealth * ((0.00+percentage_health) / 100);
			if(hpbarhealth > hpbarmaxhealth)
				hpbarmaxhealth = hpbarhealth;
			EntFireByHandle(self, "RunScriptCode", " TickHealthBar(); ", 0.01, null, null);
			EntFireByHandle(hpbar, "FireUser2", "", 0.02, null, null);
		}
	}
}

function SetHealthPercentage(percentage_health)
{
	if(hp != null && hp.IsValid())
	{
		if(hpbarhealth*((0.00+percentage_health)/100) <= 0)
		{
			EntFireByHandle(hpbar, "SetTextureIndex", "0", 0.00, null, null);
			EntFireByHandle(hp, "Break", "", 0.00, null, null);
		}
		else
		{
			EntFireByHandle(hp, "SetHealth", "" + (hpbarhealth*((0.00+percentage_health)/100)), 0.00, null, null);
			hpbarhealth = hpbarhealth * ((0.00+percentage_health) / 100);
			EntFireByHandle(self, "RunScriptCode", " TickHealthBar(); ", 0.01, null, null);
			EntFireByHandle(hpbar, "FireUser2", "", 0.02, null, null);
		}
	}
}

function SetSpeed(forward, turning)
{
	s_tf = forward;
	s_ts = turning;
	EntFireByHandle(tf, "Deactivate", "", 0.00, null, null);
	EntFireByHandle(ts, "Deactivate", "", 0.00, null, null);
	EntFireByHandle(tf, "AddOutput", "Force " + forward, 0.00, null, null);
	EntFireByHandle(ts, "AddOutput", "Force " + turning, 0.00, null, null);
}

function SetTargetTime(time)
{
	target_time_reset = time;
}

function SetTargetMethod(target_distance, target_closest, target_closest_timereset, attack_or_flee)
{
	targetdistance = target_distance;
}

function SetAutoTarget(state)
{
	autotarget = state;
}

function SetDrawTarget(state)
{
	drawtarget = state;
}

function SetDrawDamage(state)
{
	drawdamage = state;
}

function SetTarget(activator_or_caller)
{
	if(activator_or_caller == 1)
		target = activator;
	else if(activator_or_caller == 2)
		target = caller;
	else
		target = null;
}

function Death()
{
	dead = true;
	//ticking = false;
	EntFireByHandle(ts, "FireUser4", "", 0.00, null, null);
	EntFireByHandle(tf, "FireUser4", "", 0.00, null, null);
	EntFireByHandle(model, "FireUser4", "", 0.00, null, null);
	
	EntFire("fb_soundrage_case","Pickrandom","",0.00,null);
	EntFire("fb_sound_timer","Disable","",0.00,null);
	EntFire("fb_sound_timer","Kill","",0.05,null);
	EntFire("fb_attack_timer","Disable","",0.00,null);
	EntFire("fb_attack_timer","Kill","",0.05,null);
	
	//TODO: maybe remove this? (maybe make it a thing for the mapper to decide with logic_case events?)
	if(hpbar != null && hpbar.IsValid())
		EntFireByHandle(hpbar, "FireUser3", "", 0.25, null, null);
}

function KillEnts()
{
	dead = true;
	ticking = false;
}

function GetRandomValue(max)
{   
    //random int between 0 and max
    local r = (1.0 * rand() / RAND_MAX) * (max + 1);
    return r.tointeger();
}
function RandomChance(percentage)
{
	//returns true at a random chance, the higher "percentage" the higher chance
	if(percentage > RandomFloat(0.00,100.00))
		return true;
	return false;
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
function GetDistanceVector(vector1, vector2)
{
	return sqrt((vector1.x-vector2.x)*(vector1.x-vector2.x) + 
				(vector1.y-vector2.y)*(vector1.y-vector2.y) + 
				(vector1.z-vector2.z)*(vector1.z-vector2.z));
}
function GetDistanceXY(vector1, vector2)
{
	return sqrt((vector1.GetOrigin().x-vector2.GetOrigin().x)*(vector1.GetOrigin().x-vector2.GetOrigin().x) + 
				(vector1.GetOrigin().y-vector2.GetOrigin().y)*(vector1.GetOrigin().y-vector2.GetOrigin().y));
}

//TODO:
//function GetVectorBetweenVectors(vector1, vector2, percentage)
//{
//	var dir = vector2.clone().sub(vector1);
//    var len = dir.length();
//    dir = dir.normalize().multiplyScalar(len*percentage);
//    return vector1.clone().add(dir);
//}
