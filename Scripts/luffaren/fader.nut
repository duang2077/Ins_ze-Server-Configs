//===================================\\
// Fader script by Luffaren  (STEAM_0:1:22521282)
// (FADE_TIME calculation help from Wan (STEAM_0:0:2279973))
// ***********************************
// This script is made to fade in/out entities at the desired time
// It works on entities that supports the "Color" RenderMode
// 
// [NOTE]
// When calling this it will automatically set the entity RenderMode to 1 = "Color"
// This script fades between 0-255 and 255-0 at the desired fade time
// It is safe to call this multiple times (calling FadeOut when it's halfways fading in will simply revert the fade)'
// You can fade in with RunScriptCode > " FadeIn(1.0); "
// You can fade out with RunScriptCode > " FadeOut(1.0); "
// The parameter in FadeIn() and FadeOut() is the desired fade time in seconds (1.0 = 1 sec, 0.5 = half a sec)
// Typing a negative number as the parameter will set the fade time to 0 (instant fade)
// Do NOT leave the parameter field empty
// Do NOT type anything else than numbers (preferably decimals, like 1.25 for example)
// Do NOT call Tick() manually, use the FadeIn() and FadeOut() functions (otherwise the speed might get messed up)
// 
//===================================\\

fade <- false;
fadevalue <- 255;
ticking <- false;
FADE_TIME <- 1.0;

function FadeIn(time)
{
	FADE_TIME = time;
	if(FADE_TIME < 0)FADE_TIME = 0;
	fade = false;
	if(!ticking)
	{
		EntFireByHandle(self, "AddOutput", "rendermode 1", 0.00, null, null);
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
		EntFireByHandle(self, "AddOutput", "rendermode 1", 0.00, null, null);
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
		EntFireByHandle(self, "Alpha", ""+fadevalue, 0.0, null, null);
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
		EntFireByHandle(self, "Alpha", ""+fadevalue, 0.0, null, null);
	}
}