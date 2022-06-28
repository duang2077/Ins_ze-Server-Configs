//===================================\\
// Script by Luffaren
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

maxhp <- 10000000.00;
index <- 1;

function Initialize()
{
	maxhp = 0.00+self.GetHealth();
	Tick();
}

function Tick()
{
	if(index == 1 && (self.GetHealth() / maxhp) <= 0.75)
	{
		index++;
		EntFire("dd_case_2", "FireUser1", "", 0.00, null);
	}
	else if(index == 2 && (0.00+self.GetHealth() / maxhp) <= 0.50)
	{
		index++;
		EntFire("dd_case_3", "FireUser1", "", 0.00, null);
	}
	else if(index == 3 && (0.00+self.GetHealth() / maxhp) <= 0.25)
	{
		index++;
		EntFire("dd_case_4", "FireUser1", "", 0.00, null);
	}
	EntFireByHandle(self, "RunScriptCode", " Tick(); ", 0.01, null, null);
}

function SpawnZombie()
{
	local pp = [];
	local p = null;while(null != (p = Entities.FindByClassname(p,"player")))
	{if(p!=null&&p.IsValid()&&p.GetHealth()>0&&p.GetTeam()==2)pp.push(p);}
	if(pp.len()>0)
	{
		local rpp = RandomInt(0,pp.len()-1);
		EntFireByHandle(pp[rpp],"AddOutput","origin -14592 -14048 2688",0.00,null,null);
		EntFireByHandle(pp[rpp],"SetHealth","666",0.00,null,null);
		EntFire("feb_timer_zombie","RunScriptCode"," SetVelocity(0,0,0); ",0.01,pp[rpp]);
	}
		
}
