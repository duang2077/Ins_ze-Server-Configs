//===================================\\
// HP adder  script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/)
// ***********************************
// This script is made to easily add HP based on the current alive-CT's-count
// 
// [NOTE]
// This script sets a base HP + extra-hp-for-each-alive-ct on !self
// !self SHOULD be func_breakable/prop_physics (or anything that has health)
// > To set HP directly: 			RunScriptCode > SetHP(100);		  	(100 hp)
// > To add HP dynamically: 		RunScriptCode > AddHP(100,20);	  	(100 hp base, +20 hp for each alive CT)
// > To add extra HP: 			RunScriptCode > AddExtraHP(20);		(+20 hp for each alive CT)
// (SetHP and AddHP SETS the health, AddExtraHP keeps the current health and adds on top of it)
// Negative values work (though negative base health by SetHP or AddHP-base_amount will insta-break the ent)
// 
//===================================\\

function SetHP(amount)
{
	EntFireByHandle(self,"SetHealth",amount.tostring(),0.00,null,null);
}

function AddHP(base_amount, add_amount)
{
	local add = 0.00+base_amount;
	local p = null;while(null != (p = Entities.FindByClassname(p,"player")))
	{if(p.GetTeam() == 3)add += add_amount;}
	EntFireByHandle(self,"SetHealth",add.tostring(),0.00,null,null);
}

function AddExtraHP(add_amount)
{
	local add = 0.00+self.GetHealth();
	local p = null;while(null != (p = Entities.FindByClassname(p,"player")))
	{if(p.GetTeam() == 3)add += add_amount;}
	EntFireByHandle(self,"SetHealth",add.tostring(),0.00,null,null);
}
