//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

//small: Xplode at 3 sec
//big: Xplode at 6 sec

//blobb_timer					AddOutput > UpperRandomBound 4 (go higher when arms break)
//blobb_laser					TurnOn/TurnOff
//blobb_laser_relay				Enable
//blobb_laser_ex				Explode
//blobb_laser_particle			FireUser1
//blobb_laser_particleex		FireUser1
//blobb_laser_s					PlaySound
//blobb_laser_shake				StartShake
//blobb_laser_shakepre			StartShake
//add "1" at the end for the big laser

function StartLaser()
{
	local target = null;
	local p = null;
	local plist = [];
	//while(null != (p = Entities.FindByClassname(p, "player")))
	while(null!=(p=Entities.FindInSphere(p,self.GetOrigin(),30000)))
	{
		if(p != null && p.IsValid() && p.GetClassname() == "player" && p.GetTeam() == 3 && p.GetHealth()>0)
		{
			local ppos = p.GetOrigin();ppos.z+=48;
			if(TraceLine(ppos,Vector(11320,2608,2616),null) >= 1.0)
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
			local pos = ""+poss.x+" "+poss.y+" "+poss.z;
			if(caller.GetName()=="blobb_laser_relay1")
			{
				EntFire("blobb_laser_target1","AddOutput","origin "+pos,0.00,null);
				EntFire("blobb_laser1","TurnOn","",0.10,null);
				EntFire("blobb_laser1","TurnOff","",6.10,null);
				EntFire("blobblaser_tem1","AddOutput","origin "+pos,0.00,null);
				EntFire("blobblaser_tem1","ForceSpawn","",0.10,null);
				EntFire("blobb_laser_relay1","Disable","",0.00,null);
				EntFire("blobb_laser_relay1","Enable","",6.10,null);
			}
			else
			{
				EntFire("blobb_laser_target","AddOutput","origin "+pos,0.00,null);
				EntFire("blobb_laser","TurnOn","",0.10,null);
				EntFire("blobb_laser","TurnOff","",3.10,null);
				EntFire("blobblaser_tem","AddOutput","origin "+pos,0.00,null);
				EntFire("blobblaser_tem","ForceSpawn","",0.10,null);
				EntFire("blobb_laser_relay","Disable","",0.00,null);
				EntFire("blobb_laser_relay","Enable","",3.10,null);
			}
		}
	}
	else
	{
		if(caller.GetName()=="blobb_laser_relay1")
			EntFire("blobb_laser_relay1","Enable","",0.00,null);
		else
			EntFire("blobb_laser_relay","Enable","",0.00,null);
		target = null;
	}
}
