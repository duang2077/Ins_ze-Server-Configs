//===================================\\
// Item Controller script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/itemcontroller/)
// ***********************************

player <- null;
distcheck <- null;
backup <- null;
base <- null;
pistol <- null;
killed <- false;
cooldown <- 0.0;
initwindow <- true;
ticking <- false;
tickingbackup <- false;
tickingdropped <- false;

function SetDistcheck(){distcheck = caller;}
function SetBackup(){backup = caller;}
function SetBase(){base = caller;}
function SetPistol(){pistol = caller;}

function KillItem()
{
	if(!killed)
	{
		if(pistol != null && pistol.IsValid())
			EntFireByHandle(pistol, "Kill", "", 0.00, null, null);
		if(base != null && base.IsValid())
			EntFireByHandle(base, "Kill", "", 0.00, null, null);
		if(distcheck != null && distcheck.IsValid())
			EntFireByHandle(distcheck, "Kill", "", 0.00, null, null);
		EntFireByHandle(backup, "Kill", "", 0.00, null, null);
		EntFireByHandle(self, "Kill", "", 0.00, null, null);
	}
	killed = true;
}

function DoNotRespawn()
{
	killed = true;
}

function UseItem(cd)
{
	cooldown = cd;
	if(!tickingcooldown)
		TickCooldown();
}

function PickUp()
{
	player = activator;
	initwindow = false;
	tickingdropped = false;
	if(!ticking)
	{
		ticking = true;
		Tick();
	}
	if(!tickingbackup)
	{
		tickingbackup = true;
		TickBackup();
	}
}

function Drop()
{
	ticking = false;
	if(CheckNullValidity())
	{
		EntFireByHandle(base, "ClearParent", "", 0.00, null, null);
		tickingdropped = true;
		TickDropped();
	}
	else
		RunBackup();
}

function CloseInitWindow()
{
	EntFireByHandle(pistol, "AddOutput", "CanBePickedUp 1", 0.00, null, null);
	initwindow = false;
}

function InitBackUp(cd)
{
	if(initwindow)
	{
		initwindow = false;
		cooldown = cd;
		if(!tickingcooldown)
			TickCooldown();
		EntFireByHandle(self, "Disable", "", 0.00, null, null);
	}
}

function RunBackup()
{
	if(!killed)
	{
		local bup = " InitBackUp("+cooldown+"); ";
		killed = true;
		if(base != null && base.IsValid())
			EntFireByHandle(base, "Kill", "", 0.00, null, null);
		if(distcheck != null && distcheck.IsValid())
			EntFireByHandle(distcheck, "Kill", "", 0.00, null, null);
		EntFireByHandle(backup, "ForceSpawn", "", 0.02, null, null);
		EntFireByHandle(backup, "Kill", "", 0.10, null, null);
		EntFireByHandle(self, "Kill", "", 0.10, null, null);
		DoEntFire(self.GetPreTemplateName()+"*", "RunScriptCode", bup, 0.20, null, null);
	}
	else
	{
		if(base != null && base.IsValid())
			EntFireByHandle(base, "Kill", "", 0.00, null, null);
		if(distcheck != null && distcheck.IsValid())
			EntFireByHandle(distcheck, "Kill", "", 0.00, null, null);
	}
}

function TickDropped()
{
	if(CheckNullValidity())
	{
		if(tickingdropped)
		{
			base.SetOrigin(distcheck.GetOrigin());
			base.SetAngles(distcheck.GetAngles().x,distcheck.GetAngles().y,distcheck.GetAngles().z);
			EntFireByHandle(self, "RunScriptCode", " TickDropped(); ", 0.01, null, null);
		}
	}
	else
		RunBackup();
}

function TickBackup()
{
	if(CheckNullValidity())
	{
		if(base != null && base.IsValid())
		{
			backup.SetOrigin(base.GetOrigin());
			EntFireByHandle(self, "RunScriptCode", " TickBackup(); ", 0.01, null, null);
		}
	}
}

tickingcooldown <- false;
function TickCooldown()
{
	if(cooldown <= 0)
	{
		cooldown = 0;
		tickingcooldown = false;
		EntFireByHandle(self, "FireUser1", "", 0.00, null, null);
	}
	else
	{
		cooldown -= 0.02;
		EntFireByHandle(self, "RunScriptCode", " TickCooldown(); ", 0.01, null, null);
	}
}

function Tick()
{
	if(CheckNullValidity())
	{
		dist <- sqrt((player.GetOrigin().x-distcheck.GetOrigin().x)*(player.GetOrigin().x-distcheck.GetOrigin().x) + 
					(player.GetOrigin().y-distcheck.GetOrigin().y)*(player.GetOrigin().y-distcheck.GetOrigin().y) + 
					(player.GetOrigin().z-distcheck.GetOrigin().z)*(player.GetOrigin().z-distcheck.GetOrigin().z));
		if(player.GetHealth() <= 0 || dist > 100)
		{
			Drop();
		}
		else
			EntFireByHandle(self, "RunScriptCode", " Tick(); ", 0.05, null, null);
	}
	else
		RunBackup();
}

function CheckNullValidity()
{
	if(player != null && distcheck != null && distcheck.IsValid() && base != null && base.IsValid())
		return true;
	else
		return false;
}
