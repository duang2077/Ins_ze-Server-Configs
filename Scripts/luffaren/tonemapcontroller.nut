//===================================\\
// Tonemap Controller script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/)
// ***********************************
// This script is made to ease up tonemap blending
// It can transition the bloom scale
// 
// [HOW TO USE]
// > Add an env_tonemap_controller in the map and add this script to it
// > Call the following methods at round start:
// >-----> 		Initialize();
// >-----> 		SetBloom(0);
// >-----> 		SetSpeed(0.1);
// > You can use whatever parameter values you want, the ones applied above are default
// 
// [NOTE]
// Do not call Initialize(); more than once per round (it should be called ONCE EVERY ROUND START)
// When a target-based function is called, the 0.01 Tick(); method will start looping for the entire round
// Do NOT call Tick(); or StartTick(); manually
// ONLY use the functions listed below
// 
// Function list:
// >-----> 		SetBloom(amount);				> sets the bloom AND target bloom directly
// >-----> 		SetBloomTarget(amount);			> sets the bloom target (which the current bloom will fade towards)
// >-----> 		SetSpeed(speed);				> sets the bloom fade speed
// 
//===================================\\

scale <- 0.00;
target <- 0.00;
speed <- 0.1;
ticking <- false;

function SetBloomTarget(amount)
{
	target = amount;
	StartTick();
}

function SetBloom(amount)
{
	scale = amount;
	target = amount;
	EntFireByHandle(self "SetBloomScale", amount.tostring(), 0.00, null, null);
}

function SetSpeed(amount)
{
	speed = amount;
}

function Initialize()
{
	ticking = false;
}

function StartTick()
{
	if(!ticking)
	{
		ticking = true;
		Tick();
	}
}

function Tick()
{
	if(scale < target)
		scale += speed;
	else if(scale > target)
		scale -= speed;
	EntFireByHandle(self "SetBloomscale", scale.tostring(), 0.00, null, null);
	EntFireByHandle(self "RunScriptCode", " Tick(); ", 0.01, null, null);
}
