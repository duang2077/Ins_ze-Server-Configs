//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

fade <- false;
fadevalue <- 255;
ticking <- false;
FADE_TIME <- 1.0;
visual <- null;

function Initialize()
{
	visual = caller;
}

function Hurt()
{
	//the "8" in "fadevalue/8" controls the amount it should hurt, higher value=hurts LESS
	if(activator.GetClassname()=="player")
		//test2//EntFireByHandle(activator, "SetHealth", (activator.GetHealth()-(fadevalue/5)).tointeger().tostring(), 0.00, null, null);
		//test3//EntFireByHandle(activator, "SetHealth", (activator.GetHealth()-(fadevalue/8)).tointeger().tostring(), 0.00, null, null);
		//v1_3//EntFireByHandle(activator, "SetHealth", (activator.GetHealth()-(fadevalue/12)).tointeger().tostring(), 0.00, null, null);
		//v1_4//EntFireByHandle(activator, "SetHealth", (activator.GetHealth()-(fadevalue/16)).tointeger().tostring(), 0.00, null, null);
		//v2//EntFireByHandle(activator, "SetHealth", (activator.GetHealth()-(fadevalue/20)).tointeger().tostring(), 0.00, null, null);
		EntFireByHandle(activator, "SetHealth", (activator.GetHealth()-(fadevalue/25)).tointeger().tostring(), 0.00, null, null);
}

function FadeIn(time)
{
	FADE_TIME = time;
	if(FADE_TIME < 0)FADE_TIME = 0;
	fade = false;
	if(!ticking)
	{
		EntFireByHandle(visual, "AddOutput", "rendermode 1", 0.00, null, null);
		ticking = true;
		Tick();
	}
}

function FadeOut(time)
{
	FADE_TIME = time;
	if(FADE_TIME < 0)FADE_TIME = 0;
	fade = true;
	if(!ticking)
	{
		EntFireByHandle(visual, "AddOutput", "rendermode 1", 0.00, null, null);
		ticking = true;
		Tick();
	}
}

function Tick()
{
	if(fade)
	{
		if(fadevalue > 0)
		{
			fadevalue -= (255/(50.0*FADE_TIME));
			EntFireByHandle(self, "RunScriptCode", " Tick(); ", 0.01, null, null);
		}
		else 
		{
			fadevalue = 0;
			ticking = false;
		}
		EntFireByHandle(visual, "Alpha", ""+fadevalue, 0.0, null, null);
	}
	else
	{
		if(fadevalue < 255)
		{
			fadevalue += (255/(50.0*FADE_TIME));
			EntFireByHandle(self, "RunScriptCode", " Tick(); ", 0.01, null, null);
		}
		else
		{
			fadevalue = 255;
			ticking = false;
		}
		EntFireByHandle(visual, "Alpha", ""+fadevalue, 0.0, null, null);
	}
}