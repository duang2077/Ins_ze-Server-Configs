//===================================\\
// Fog Controller script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/)
// ***********************************
// This script is made to ease up Fog blending
// It can transition/fade color, start/end distance and farz distance
// 
// [HOW TO USE]
// > Add an env_fog_controller in the map and add this script to it
// > Call the following methods at round start:
// >-----> 		Initialize();
// >-----> 		SetFarz(50000);
// >-----> 		SetFogColor(255,255,255);
// >-----> 		SetDistance(500,20000);
// > You can use whatever parameter values you want, the ones applied above are default
// > You can also call other initial settings, such as fade speed, see the full function list below
// 
// [NOTE]
// Do not call Initialize(); more than once per round (it should be called ONCE EVERY ROUND START)
// When a target-based function is called, the 0.01 Tick(); method will start looping for the entire round
// Do NOT call Tick(); or StartTick(); manually
// ONLY use the functions listed below
// 
// Function list:
// >-----> 		SetFogColor(r,g,b);				> sets the fog color AND target fog color directly
// >-----> 		SetFarz(farz_amount);			> sets the farz AND target farz directly
// >-----> 		SetDistance(start,end);			> sets the start/end dist AND target start/end dist directly
// >-----> 		SetFogColorTarget(r,g,b);		> sets the fog color target (which the current color will fade towards)
// >-----> 		SetFarzTarget(farz_amount);		> sets the farz target (which the current farz will fade towards)
// >-----> 		SetDistanceTarget(start,end);	> sets the start/end dist target (which the current start/end dist will fade towards)
// >-----> 		SetSpeedColor(speed);			> sets the color fade speed
// >-----> 		SetSpeedZ(speed);				> sets the farz fade speed
// >-----> 		SetSpeedDistance(speed);		> sets the start/end dist fade speed
// 
//===================================\\

z <- 50000;
tz <- 50000;
r <- 255.00;
g <- 255.00;
b <- 255.00;
tr <- 255.00;
tg <- 255.00;
tb <- 255.00;
ds <- 500.00;
tds <- 500.00;
de <- 20000.00;
tde <- 20000.00;
speed <- 0.25;
speed_dist <- 5.0;
speed_z <- 5.0;
ticking <- false;

//-----------------------------------
function SetFarzTarget(amount)
{
	tz = amount;
	StartTick();
}
function SetFarz(amount)
{
	z = amount;
	tz = amount;
	EntFireByHandle(self "SetFarz", z.tointeger().tostring(), 0.00, null, null);
}
function SetSpeedZ(amount)
{
	speed_z = amount;
}
//-----------------------------------
function SetFogColorTarget(_r, _g, _b)
{
	tr = _r;
	tg = _g;
	tb = _b;
	StartTick();
}
function SetFogColor(_r, _g, _b)
{
	r = _r;
	g = _g;
	b = _b;
	tr = _r;
	tg = _g;
	tb = _b;
	EntFireByHandle(self "SetColor", (r.tointeger().tostring()+" "+g.tointeger().tostring()+" "+b.tointeger().tostring()), 0.00, null, null);
}
function SetSpeedColor(amount)
{
	speed = amount;
}
//-----------------------------------
function SetDistanceTarget(start,end)
{
	tds = start;
	tde = end;
	StartTick();
}
function SetDistance(start,end)
{
	ds = start;
	de = end;
	tds = start;
	tde = end;
	EntFireByHandle(self "SetStartDist", ds.tointeger().tostring(), 0.00, null, null);
	EntFireByHandle(self "SetEndDist", de.tointeger().tostring(), 0.00, null, null);
}
function SetSpeedDistance(amount)
{
	speed_dist = amount;
}
//-----------------------------------
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
	if(abs(r-tr)<speed)r=tr;else if(r<tr)r+=speed;else if(r>tr)r-=speed;
	if(abs(g-tg)<speed)g=tg;else if(g<tg)g+=speed;else if(g>tg)g-=speed;
	if(abs(b-tb)<speed)b=tb;else if(b<tb)b+=speed;else if(b>tb)b-=speed;
	if(abs(z-tz)<speed_z)z=tz;else if(z<tz)z+=speed_z;else if(z>tz)z-=speed_z;
	if(abs(ds-tds)<speed_dist)ds=tds;else if(ds<tds)ds+=speed_dist;else if(ds>tds)ds-=speed_dist;
	if(abs(de-tde)<speed_dist)de=tde;else if(de<tde)de+=speed_dist;else if(de>tde)de-=speed_dist;
	EntFireByHandle(self "SetStartDist", ds.tointeger().tostring(), 0.00, null, null);
	EntFireByHandle(self "SetEndDist", de.tointeger().tostring(), 0.00, null, null);
	EntFireByHandle(self "SetFarz", z.tointeger().tostring(), 0.00, null, null);
	EntFireByHandle(self "SetColor", (r.tointeger().tostring()+" "+g.tointeger().tostring()+" "+b.tointeger().tostring()), 0.00, null, null);
	EntFireByHandle(self "RunScriptCode", " Tick(); ", 0.01, null, null);
}
