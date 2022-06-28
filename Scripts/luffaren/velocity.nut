//===================================\\
// Velocity script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/)
// ***********************************
// This script is made to control general velocity functions with ease
// It also includes a player_speedmod functionality that keeps track of current velocities
// Diddled a bit for ze_diddle
//===================================\\

function SetVelocity(x,y,z)
{
	local vel = activator.GetVelocity();
	if(x==-1)x=vel.x;if(y==-1)y=vel.y;if(z==-1)z=vel.z;
	par <- "basevelocity "+((-vel.x)+x)+" "+((-vel.y)+y)+" "+((-vel.z)+z);
	EntFireByHandle(activator,"AddOutput",par,0.00,null,null);
}

function AddVelocity(x,y,z)
{
	par <- "basevelocity "+x+" "+y+" "+z;
	EntFireByHandle(activator,"AddOutput",par,0.00,null,null);
}