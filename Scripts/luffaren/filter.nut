//===================================\\
// Filter script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/)
// ***********************************
// This script is made to filter entities to one specific owner entity (player OR some other ent)
// It does not require targetnames, and it will work on its own
// AKA you/some entity can gain a filtered ownership of entities that checks !activator OR !caller
// This filter can also lock any specified OnUserX to the owner of the script-holder (optional)
//
// [HOW TO USE]
// > Add the script to whatever entity (E) you want to run your filter-check logic in
// > To set !activator as the owner of (E): OnTrigger > (E) > RunScriptCode > SetFilterOwner(1);
// > To set !caller as the owner of (E): OnTrigger > (E) > RunScriptCode > SetFilterOwner(2);
// > To nullify the owner of (E): OnTrigger > (E) > RunScriptCode > SetFilterOwner(0);
// > To check if !activator is the owner of (E): OnTrigger > (E) > RunScriptCode > FilterCheck(1,1);
// > To check if !caller is the owner of (E): OnTrigger > (E) > RunScriptCode > FilterCheck(2,1);
//   (The last parameter of FilterCheck() is the FireUserX *between 1-4* that runs IF the check passes)
// > If the FilterCheck() passes, it will return FireUserX (dependant on the last parameter) to !self (E)
// > Then simply add your outputs/logic to the desired OnUserX command
// 
// ONUSERX OUTPUT LOCKING (locks any specified OnUser command, so ONLY the owner of the ent can call it):
// Since external ents (triggers/physboxes/etc) may or may not call the "pass" OnUserX UNINTENTIONALLY
// you can now COMPLETELY LOCK the specified OnUserX output(s) to the owner
// You can do this by: LockUserCall(onuserX);  *1-4* which will lock that specific OnUserX call to the owner
// Any other entities that call FireUserX to the specified locked X will just be ignored
// If you want to use this you need to run it on the script-holder ent as it's spawned/initialized
// If you want to lock multiple OnUser outputs you need to call the same function multiple times
// You can reset the locked OnUserX output(s) by: ResetLockUserCall();
//
// [NOTE]
// The script will remember the owner once set (until you nullify OR set a new owner)
// Invalid parameter inputs (integers only) will cause errors and will not perform the intended actions
// ----------
// SetFilterOwner(activator_or_caller)
// FilterCheck(activator_or_caller, fireuserX)
// LockUserCall(onuserX)
// ResetLockUserCall()
// ----------
// "activator_or_caller"
// null = 0 *only for SetFilterOwner();*
// activator = 1
// caller = 2
// ----------
// "fireuserX" / "onuserX"
// FireUser1 = 1
// FireUser2 = 2
// FireUser3 = 3
// FireUser4 = 4
// 
//===================================\\

owner <- null;
fuc1 <- false;
fuc2 <- false;
fuc3 <- false;
fuc4 <- false;

function SetFilterOwner(activator_or_caller)
{
	if(activator_or_caller == 0)
		owner = null;
	else if(activator_or_caller == 1)
		owner = activator;
	else if(activator_or_caller == 2)
		owner = caller;
}

function FilterCheck(activator_or_caller, fireuserX)
{
	if(owner == null)
	{
		return false;
	}
	else
	{
		if(activator_or_caller == 1)
		{
			if(owner == activator)
			{
				if(fireuserX == 1)
					EntFireByHandle(self, "FireUser1", "", 0.0, activator, activator);
				else if(fireuserX == 2)
					EntFireByHandle(self, "FireUser2", "", 0.0, activator, activator);
				else if(fireuserX == 3)
					EntFireByHandle(self, "FireUser3", "", 0.0, activator, activator);
				else if(fireuserX == 4)
					EntFireByHandle(self, "FireUser4", "", 0.0, activator, activator);
				return true;
			}
		}
		else if(activator_or_caller == 2)
		{
			if(owner == caller)
			{
				if(fireuserX == 1)
					EntFireByHandle(self, "FireUser1", "", 0.0, caller, caller);
				else if(fireuserX == 2)
					EntFireByHandle(self, "FireUser2", "", 0.0, caller, caller);
				else if(fireuserX == 3)
					EntFireByHandle(self, "FireUser3", "", 0.0, caller, caller);
				else if(fireuserX == 4)
					EntFireByHandle(self, "FireUser4", "", 0.0, caller, caller);
				return true;
			}
		}
	}
	return false;
}

function LockUserCall(onuserX)
{
	if(onuserX == 1)
		fuc1 = true;
	else if(onuserX == 2)
		fuc2 = true;
	else if(onuserX == 3)
		fuc3 = true;
	else if(onuserX == 4)
		fuc4 = true;
}

function ResetLockUserCall()
{
	fuc1 = false;
	fuc2 = false;
	fuc3 = false;
	fuc4 = false;
}

function InputFireUser1()
{
	if(activator == owner) return true;
	else if(fuc1) return false;
	return true;
}

function InputFireUser2()
{
	if(activator == owner) return true;
	else if(fuc2) return false;
	return true;
}

function InputFireUser3()
{
	if(activator == owner) return true;
	else if(fuc3) return false;
	return true;
}

function InputFireUser4()
{
	if(activator == owner) return true;
	else if(fuc4) return false;
	return true;
}


