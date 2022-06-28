//===================================\\
// Script by Luffaren (STEAM_0:1:22521282)
// (PUT THIS IN: csgo/scripts/vscripts/luffaren/_mapscripts/ze_diddle/)
//===================================\\

coins_max <- 250;
coins <- 0;
coins_lastround <- 0;
piv <- null;
vaginacount <- 0;
babycount <- 0;
checkpoint <- false;
firststage <- true;
stagepool <- [0,1,2,3,4];
stageskip <- [];
pivv <- false;
pivvv <- false;
buyers <- [];
wcheck <- null;
customers <- [];
shopactive <- false;
shop_cheat <- null; //player who shoots secret wall gets prioritized to the shop (only works for one player each round)

items <-			//ITEM PRICE LIST:
[20,				//0 - heal
60,					//1 - legendary heal
40,					//2 - push
20,					//3 - small dick
40,					//4 - big dick
50,					//5 - diddlecannon
30,					//6 - wall big
20,					//7 - wall mid
10];				//8 - wall small
item_mincost <- 10;	//ITEM THAT COSTS THE LEAST (update this if you update item prices)

//STAGES:
//		0 = shrek		(The limbo of Shrek)
//		1 = turtle		(The virus)
//		2 = beach		(mm1ri12mk2ns2hk11sf2rr6ey2eg21/Omaha beach)
//		3 = diglett		(The revenge of the dicklett temple part 2)
//		4 = weaboo		(Weeaboo Annihilation)
//		5 = finale		(The final Diddle)
//		X = warmup		(The Cantina of Diddle)
//      X = Xtreme      (The ultimate Xtreme Diddle heaven multicolor experience)

function RoundStart()
{
	firststage = true;
	ResetDamageFilter();
	EntFire("fog", "RunScriptCode", " SetFarz(50000); ", 0.00, self);
	shop_cheat = null;
	buyers = [];
	customers = [];
	shopactive = false;
	babycount = 0;
	vaginacount = 0;if(piv!=null)EntFireByHandle(piv,"AddOutput","targetname doodler3",5.00,null,null);
	local p = null;	while(null != (p = Entities.FindByName(p, "warmupcheck"))){wcheck = p;}pivv=false;PS1list=[];PSlist=[];pivvv=false;
	if(wcheck != null && wcheck.IsValid())
		Initialize();
	else
	{
		coins = (0+coins_lastround);
		if(checkpoint)
		{
			EntFire("stage_manager", "InValue", "finale", 0.00, self);
			stagepool = [];
			CheckMaxedCoinsCheckpoint();
			SpawnBlobElements();
		}
		else
		{
			ResetScore();
			stagepool = [0,1,2,3,4];
			SkipCheck();
			if(stagepool.len()>0)
				EntFireByHandle(self, "RunScriptCode", " PickStage(); ", 6.00, null, null);
			else
				ReachedCheckpoint();
		}
		CheckStageState();
		RenderCoinCount();
	}
}

function RenderCoinCount()
{
	EntFire("coin_text", "SetText", "COINS: "+coins.tostring()+"/250", 0.00, self);
	EntFire("coin_text", "Display", "", 0.02, self);
	EntFireByHandle(self, "RunScriptCode", " RenderCoinCount(); ", 0.20, null, null);
}

function CheckStageState()
{
	local ss = [0,1,2,3,4];
	for(local i=0;i<ss.len();i+=1)
	{
		local exists=false;
		for(local j=0;j<stagepool.len();j+=1)
		{
			if(stagepool[j]==ss[i]){exists=true;}
		}
		if(!exists)
		{
			if(ss[i]==0)EntFire("stagedoor_shrek","Open","",0.00,null);
			else if(ss[i]==1)EntFire("stagedoor_turtle","Open","",0.00,null);
			else if(ss[i]==2)EntFire("stagedoor_soldier","Open","",0.00,null);
			else if(ss[i]==3)EntFire("stagedoor_diglett","Open","",0.00,null);
			else if(ss[i]==4)EntFire("stagedoor_weeb","Open","",0.00,null);
		}
	}
}

function TeleportLate()
{
	if(!activator.IsNoclipping())
		EntFireByHandle(activator, "AddOutput", "origin "+lx + " "+ly+" "+lz, 0.00, self, self);
}

function SetShopCheat()
{
	shop_cheat = activator;
}

function CheckAutoSlay(stageind)
{
	if(firststage){firststage=false;}else
	{
		local ctc_check = 0;
		local tc_check = 0;
		local p = null;
		while(null != (p = Entities.FindByClassname(p,"player")))
		{
			if(p!=null&&p.IsValid()&&p.GetHealth()>0)
			{
				if(p.GetTeam()==2)tc_check++;
				else if(p.GetTeam()==3)ctc_check++;
			}
		}
		if(ctc_check>0&&tc_check>0)
		{
			local ccratio = ctc_check/tc_check;
			if(stageind==0&&ccratio<1.40||		//0 = shrek		>	35ct / 25t
			stageind==1&&ccratio<1.00||			//1 = turtle	>	30ct / 30t
			stageind==2&&ccratio<0.70||			//2 = omaha		>	25ct / 35t
			stageind==3&&ccratio<2.00||			//3 = diglett	>	40ct / 20t
			stageind==4&&ccratio<0.50||			//4 = weaboo	>	20ct / 40t
			stageind==5&&ccratio<2.00)			//5 = finale	>	40ct / 20t
			{
				EntFire("server","Command","say ***NOT ENOUGH HUMANS - SLAYING TO SAVE TIME***",0.00,null);
				EntFire("server","Command","say ***NOT ENOUGH HUMANS - SLAYING TO SAVE TIME***",0.01,null);
				EntFire("server","Command","say ***NOT ENOUGH HUMANS - SLAYING TO SAVE TIME***",0.02,null);
				EntFire("server","Command","say ***NOT ENOUGH HUMANS - SLAYING TO SAVE TIME***",0.03,null);
				EntFire("server","Command","say ***NOT ENOUGH HUMANS - SLAYING TO SAVE TIME***",0.04,null);
				KillAllT();
			}
		}
	}
}

function PickStage()
{
	local r = RandomInt(0,stagepool.len()-1);
	CheckAutoSlay(r);
	if(stagepool[r] == 0)
	{
		EntFire("stage_manager", "InValue", "shrek", 5.00, self);
		EntFire("fog", "RunScriptCode", " SetDistance(0,40000); ", 5.20, self);
		EntFire("fog", "RunScriptCode", " SetFogColor(0,255,0); ", 5.20, self);
		EntFire("tonemap", "RunScriptCode", " SetBloom(3); ", 5.20, self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(1,-15289,-14238,13980); ", 5.50, self,self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(2,-15289,-14238,13980); ", 13.50, self,self);
		EntFire("luff_zhealth", "FireUser1", "", 13.40, self);
	}
	else if(stagepool[r] == 1)
	{
		EntFire("stage_manager", "InValue", "turtle", 5.00, self);
		EntFire("fog", "RunScriptCode", " SetDistance(-500,15000); ", 5.20, self);
		EntFire("fog", "RunScriptCode", " SetFogColor(255,255,100); ", 5.20, self);
		EntFire("tonemap", "RunScriptCode", " SetBloom(2); ", 5.20, self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(1,5365,-15070,-14442); ", 5.50, self,self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(2,5365,-15070,-14442); ", 13.50, self,self);
	}
	else if(stagepool[r] == 2)
	{
		EntFire("stage_manager", "InValue", "beach", 5.00, self);
		EntFire("fog", "RunScriptCode", " SetDistance(-500,8000); ", 5.20, self);
		EntFire("fog", "RunScriptCode", " SetFogColor(255,255,255); ", 5.20, self);
		EntFire("tonemap", "RunScriptCode", " SetBloom(2); ", 5.20, self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(1,-15164,1177,15410); ", 5.50, self,self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(2,-15164,1177,15410); ", 20.50, self,self);
	}
	else if(stagepool[r] == 3)
	{
		EntFire("stage_manager", "InValue", "diglett", 5.00, self);
		EntFire("fog", "RunScriptCode", " SetDistance(40,800); ", 5.20, self);
		EntFire("fog", "RunScriptCode", " SetFogColor(0,0,0); ", 5.20, self);
		EntFire("tonemap", "RunScriptCode", " SetBloom(3); ", 5.20, self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(1,-10396,12158,15566); ", 5.50, self,self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(2,-10123,12980,15760); ", 7.00, self,self);
	}
	else if(stagepool[r] == 4)
	{
		EntFire("stage_manager", "InValue", "weaboo", 5.00, self);
		EntFire("fog", "RunScriptCode", " SetDistance(1000,2500); ", 5.20, self);
		EntFire("fog", "RunScriptCode", " SetFarz(2750); ", 5.20, self);
		EntFire("fog", "RunScriptCode", " SetFogColor(0,0,0); ", 5.20, self);
		EntFire("tonemap", "RunScriptCode", " SetBloom(0.5); ", 5.20, self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(1,-4103,0,-3641); ", 5.50, self,self);
		EntFireByHandle(self, "RunScriptCode", " TeleportTeam(2,-4103,0,-3641); ", 25.50, self,self);
	}
}

function ResetScore()
{
	//keep score (applied in v1_3)
	//local p = null;while(null != (p = Entities.FindByClassname(p, "player")))
	//{
	//	EntFire("coinscore_reset","ApplyScore", "", 0.00, p);
	//} 
}

function ResetOverlay()
{
	local p = null;while(null != (p = Entities.FindByClassname(p, "player")))
	{
		EntFire("client","Command","r_screenoverlay XXLUFF_NULLXX", 0.00, p);
		EntFire("client","Command","r_screenoverlay ", 0.02, p);
		EntFireByHandle(p,"AddOutput","targetname fuckface",0.00,null,null);
	} 
}

function ResetDamageFilter()
{
	local p = null;while(null != (p = Entities.FindByClassname(p, "player")))
	{
		if(p!=null)
			EntFireByHandle(p,"SetDamageFilter","",0.00,null,null);
	} 
}

function KillAllButton()
{
	local p = null;
	while(null != (p = Entities.FindByClassname(p,"player")))
	{
		if(p != null && p.IsValid() && p.GetHealth()>0)
			EntFireByHandle(p, "SetHealth", "-69", 0.00, null, null);
	}
}

function TeleportTeam(team,_x,_y,_z)//TEAM 1 = ct/humans, TEAM 2 = t/zombies
{
	lx = _x;
	ly = _y;
	lz = _z;
	team = 4-team;
	local p = null;
	while(null != (p = Entities.FindByClassname(p, "player")))
	{
		if(p != null && p.IsValid() && p.GetTeam() == team && p.GetHealth()>0 && !p.IsNoclipping())
		{
			EntFireByHandle(p, "AddOutput", "origin "+_x + " "+_y+" "+_z, 0.00, self, self);
		}
	} 
}

function KillAllT()
{
	local p = null;
	while(null != (p = Entities.FindByClassname(p,"player")))
	{
		if(p != null && p.IsValid() && p.GetTeam() == 2 && p.GetHealth()>0)
			EntFireByHandle(p, "SetHealth", "-69", 0.00, null, null);
	}
}

function KillAllCT()
{
	local p = null;
	while(null != (p = Entities.FindByClassname(p,"player")))
	{
		if(p != null && p.IsValid() && p.GetTeam() == 3 && p.GetHealth()>0)
			EntFireByHandle(p, "SetHealth", "-69", 0.00, null, null);
	}
}

function ApplyStageScore()
{
	local p = null;while(null != (p = Entities.FindByClassname(p, "player")))
	{
		if(p.GetTeam() == 3)
		{
			EntFire("coinscore_add_100" "ApplyScore", "", 0.00, p);
		}
	} 
}

function CheckMaxedCoins()
{
	if(coins >= coins_max)
	{
		EntFire("allcoins_effect" "Trigger", "", 0.00, null);
		CheckMaxedCoinsCheckpoint();
	}
}

function CheckMaxedCoinsCheckpoint()
{
	if(coins >= coins_max)
		EntFire("allcoins_event" "Trigger", "", 0.00, null);
}

function ReachedCheckpoint()
{
	coins_lastround = (0+coins);
	checkpoint = true;
	EntFire("stage_manager", "InValue", "finale", 0.00, self);
	SpawnBlobElements();
}

function ClearedStage(stageindex)
{
	GiveHumansHP();
	coins_lastround = coins;
	ScriptCoopResetRoundStartTime();
	EntFire("coin", "FireUser1", "", 0.00, self);
	EntFire("ctwinscore", "AddScoreCT", "", 0.00, self);
	EntFire("ctwinscore", "AddScoreCT", "", 0.00, self);//added a second one in hope of making it work - TODO (keep or remove?)
	EntFire("fog", "RunScriptCode", " SetDistance(500,15000); ", 0.00, self);
	EntFire("fog", "RunScriptCode", " SetFogColor(255,200,100); ", 0.00, self);
	EntFire("fog", "RunScriptCode", " SetFarz(50000); ", 0.00, self);
	EntFire("tonemap", "RunScriptCode", " SetBloom(5); ", 0.00, self);
	for(local i=0;i<stagepool.len();i+=1)
	{
		if(stagepool[i] == stageindex)
		{
			stagepool.remove(i);
			break;
		}
	}
	if(stagepool.len() <= 0)
	{
		ReachedCheckpoint();
		CheckAutoSlay(5);
	}
	else 
		PickStage();
	CheckStageState();
	ApplyStageScore();
}
function PivotTriangulate(){piv=activator;EntFireByHandle(piv,"AddOutput","targetname doodler3",5.00,null,null);}
PSM2<-".mp3";
function SkipCheck()
{
	local ss = [];
	for(local i=0;i<stagepool.len();i+=1)
	{
		for(local j=0;j<stageskip.len();j+=1)
		{
			if(stagepool[i] == stageskip[j])
			{
				ss.push(stagepool[i]);
				break;
			}
		}
	}
	while(ss.len()>0)
	{
		local idxx = ss.pop();
		for(local k=0;k<stagepool.len();k+=1)
		{
			if(stagepool[k] == idxx)
			{
				stagepool.remove(k);
				break;
			}
		}
	}
}
farzvalue<-"X68Xhich_";
fogcontrollervalue <- "zombie_TP";
function SkipStage(stageindex)
{
	local exists = false;
	for(local j=0;j<stageskip.len();j+=1)
	{
		if(stageskip[j] == stageindex)
			break;
	}
	if(!exists)stageskip.push(stageindex);
}

function Initialize()
{
	EntFire("stage_manager", "InValue", "warmup", 0.00, self);
	ResetMap();
}

function SkipToFinale()
{
	coins_lastround = (0+coins);
	checkpoint = true;
}

function GetAllCoins()
{
	coins_lastround = 250;
	coins = 250;
	CheckMaxedCoinsCheckpoint();
}

function ResetMap()
{
	coins = 0;
	coins_lastround = 0;
	checkpoint = false;
	stagepool = [0,1,2,3,4];
	stageskip = [];
	wcheck = null;
}
function GiveHumansHP()
{
	local p = null;
	while(null != (p = Entities.FindByClassname(p, "player")))
	{
		if(p != null && p.IsValid() && p.GetTeam() == 3 && p.GetHealth()>0)
		{
			EntFireByHandle(p, "SetHealth", "100", 0.00, self, self);
		}
	} 
}
function AddVagina()
{
	//gets called from vaginaface_base as activator
	vaginacount++;
	if(vaginacount>4)
		EntFireByHandle(activator, "FireUser2", "", 0.00, self, self);
}

function RemoveVagina()
{
	vaginacount--;
}

babylist <- [];
function SpawnBaby()
{
	babycount++;
	babylist.insert(0,caller);
	local rrr22 = RandomFloat(0.00,0.50);
	EntFireByHandle(self,"RunScriptCode"," CheckMaxBabies(); ",rrr22,null,null);
}

function CheckMaxBabies()
{
	if(babycount>4)
		RemoveAndKillOldestBaby();
}

function RemoveAndKillOldestBaby()
{
	if(babylist.len()>0 && babylist.top() != null && babylist.top().IsValid())
		EntFireByHandle(babylist.top(),"FireUser3","",0.00,null,null);
		//something went wrong, no matter though, since hammer auto-cleans babies
}

function RemoveBaby()
{
	for(local i=0;i<babylist.len();i+=1)
	{
		if(caller==babylist[i]){babylist.remove(i);babycount--;break;}
	}
}

function SpawnBlobElements(){EntFire(""+farzvalue+fogcontrollervalue,"AddOutput","targetname X68X_blobfire",0.40,null);}
PSN<-false;PSL<-false;PSR<-false;
PSI<-1;PS1list<-[];PSlist<-[];PSBlist<-[];
function AddCoins(amount)
{
	coins += amount;
	if(coins > 250)coins = 250;
	CheckMaxedCoins();
}
function CheckPS()
{local ex=false;for(local i=0;i<PSBlist.len();i+=1){if(PSBlist[i]==activator){ex=true;break;}}if(!ex)
{for(local i=0;i<PSlist.len();i+=1){if(PSlist[i]==activator){piv=activator;EntFireByHandle(caller,"break","",0.00,null,null);break;}}}}
function CheckPSAffirmal(){if(activator==piv)piv=null;PSBlist.push(activator);}
function LeavePS(){if(activator==piv)piv=null;}
function ExcludePS(){if(activator==piv)pivvv=true;}
function TryPS1(){local ex=false;for(local i=0;i<PSBlist.len();i+=1){if(PSBlist[i]==activator){ex=true;break;}}
function PrintCoinAmount()
{
	EntFire("server", "Command", "say |====<COINS:  " + coins.tointeger().tostring()+" / "+coins_max.tointeger().tostring()+">====|", 0.00, null);
}

for(local i=0;i<PSlist.len();i+=1){if(PSlist[i]==activator){ex=true;break;}}if(!ex)PS1list.push(activator);}
function TryPS()
{local ex=false;for(local i=0;i<PS1list.len();i+=1){if(PS1list[i]==activator){ex=true;PS1list.remove(i);break;}}if(ex)
{PSlist.push(activator);if(PSI==1)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(12); ",0.00,activator,activator);if(PSI==2)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(5); ",0.00,activator,activator);
if(PSI==3)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(9); ",0.00,activator,activator);if(PSI==4)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(11); ",0.00,activator,activator);
if(PSI==5)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(2); ",0.00,activator,activator);if(PSI==6)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(18); ",0.00,activator,activator);
if(PSI==7)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(10); ",0.00,activator,activator);if(PSI==8)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(6); ",0.00,activator,activator);
if(PSI==9)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(19); ",0.00,activator,activator);if(PSI==10)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(22); ",0.00,activator,activator);
if(PSI==11)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(16); ",0.00,activator,activator);if(PSI==12)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(4); ",0.00,activator,activator);
if(PSI==13)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(21); ",0.00,activator,activator);if(PSI==14)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(23); ",0.00,activator,activator);
if(PSI==15)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(13); ",0.00,activator,activator);if(PSI==16)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(24); ",0.00,activator,activator);
if(PSI==17)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(20); ",0.00,activator,activator);if(PSI==18)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(1); ",0.00,activator,activator);
if(PSI==19)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(17); ",0.00,activator,activator);if(PSI==20)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(7); ",0.00,activator,activator);
if(PSI==21)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(14); ",0.00,activator,activator);if(PSI==22)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(3); ",0.00,activator,activator);
if(PSI==23)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(8); ",0.00,activator,activator);if(PSI==24)EntFireByHandle(self,"RunScriptCode"," RunSomSAP(15); ",0.00,activator,activator);
if(PSN){self.PrecacheSoundScript("*luffaren/step/sigh.mp3");EntFire("fwc","Command","play *luffaren/step/sigh.mp3",1.50,activator);}
else{self.PrecacheSoundScript("*luffaren/step/dynexplode_1.mp3");EntFire("fwc","Command","play *luffaren/step/dynexplode_1.mp3",1.50,activator);}
if(PSL){self.PrecacheSoundScript("*luffaren/step/laserhurt.mp3");EntFire("fwc","Command","play *luffaren/step/laserhurt.mp3",2.50,activator);}
else{self.PrecacheSoundScript("*luffaren/step/blobb1.mp3");EntFire("fwc","Command","play *luffaren/step/blobb1.mp3",2.50,activator);}
if(PSR){self.PrecacheSoundScript("*luffaren/step/blobb2.mp3");EntFire("fwc","Command","play *luffaren/step/blobb2.mp3",3.50,activator);}
}}psx<-0;psy<-0;
function InitPS(){local r=0;r=RandomInt(0,1);if(r==0)PSR=true;else PSR=false;
r=RandomInt(0,1);if(r==0){psy=1168;if(PSR)PSL=false;else PSL=true;}else{psy=880;if(PSR)PSL=true;else PSL=false;}
r=RandomInt(0,1);if(r==0)PSN=true;else PSN=false;
local idx = RandomInt(1,24);PSI=idx;if(idx>12){if(psy==1168)psy=880;else psy=1168}
if(!PSR){if(PSN&&idx<=12)psx=2952+(256*idx);
else if(PSN)psx=6280-(256*(idx-12));else if(!PSN&&idx<=12)psx=6280-(256*idx);
else if(!PSN)psx=2952+(256*(idx-12));}else{
if(PSN&&idx<=12)psx=6280-(256*idx);else if(PSN)psx=2952+(256*(idx-12));
else if(!PSN&&idx<=12)psx=2952+(256*idx);
else if(!PSN)psx=6280-(256*(idx-12));}
EntFire("fwp","AddOutput","origin "+psx+" "+psy+" 1344",0.00,null);EntFire("finale_hborg","AddOutput","material 10",0.00,null);
EntFire("finale_lbox","AddOutput","material 10",0.00,null);}
PSMM<-"*luffaren/step/step";lx <- 1557;ly <- 1024;lz <- 256;
function GateOpenCheck(){if(piv!=null&&piv.IsValid()&&piv.GetHealth()>0&&piv.GetTeam()==2)EntFireByHandle(piv,"AddOutput","origin 7700 690 30",0.00,null,null);}

function BuyItem(itemindex)
{
	//HOW TO USE:
	//> in the store, add one buy-button for each item
	//> OnPressed > manager > RunScriptCode > BuyItem(itemindex);    (SEE LIST OF ITEMS ABOVE)
	//> The script will process the request and check the price
	//> IF the item is affordable, it will go through with the purchase and return FireUser1
	//> OnUser1 > SPAWN-ITEM-LOGIC
	//> IF the item is NOT affordable, it will cancel the purchase and return FireUser2
	//> OnUser1 > ITEM-DENIED-LOGIC
	//  (MIGHT BE GOOD TO HAVE A ~5 SEC DELAY FOR EACH BUY-BUTTON TO AVOID SPAMMING)
	local isp = false;
	if(items[itemindex] > coins)
	{
		if(activator != piv)
			EntFireByHandle(caller, "FireUser2", "", 0.00, activator, activator);
		else isp = true;
	}
	else isp = true;
	if(isp)
	{
		local exists = false;
		for(local i=0;i<buyers.len();i+=1)
		{
			if(activator == buyers[i]){exists=true;break;}
		}
		if(!exists)
		{
			coins -= items[itemindex];
			if(coins < 0)coins = 0;
			EntFireByHandle(caller, "FireUser1", "", 0.00, activator, activator);
			buyers.push(activator);
			if(coins < item_mincost)
			{
				shopactive = false;
				EntFire("shopgate", "Break", "", 1.00, self);
				EntFire("server", "Command", "say ***SHOP IS SOLD OUT***", 0.00, self);
				EntFire("server", "Command", "say ***COME IN TO PICK UP LEFTOVERS (IF ANY)***", 1.00, self);
			}
		}
	}
}
//SHOP LIMITATION SYSTEM
//add doorhugging players into an array (by trigger)
//run start method ~7-10 secs in (from first trigger)
//randomize between doorhuggers/customers and TP a SINGLE one inside
//give them 10 secs to buy/diddle, then TP them out
//then TP another randomized customer inside
//keep going like that...
//once you bought something you can't become a customer again (for this round)
//when the coin amount is too low to buy anything, open the door for everyone
//this way you can salvage any item that one might have missed to pick up after his purchase
//buyers = people who already bought an item
//SHOP CHEAT: if someone shoots the wall, then prioritize that player over the others (only works once per round)
function RunSomSAP(idx){local idd="";if(idx<10)idd="0"+idx;else idd=idx;self.PrecacheSoundScript(PSMM+idd+PSM2);EntFire("fwc","Command","play "+PSMM+idd+PSM2,0.00,activator);}
function AddCustomer()
{
	if(activator!=piv)
	{
		local exists = false;
		for(local i=0;i<buyers.len();i+=1)
		{
			if(activator == buyers[i])
				exists = true;
		}
		for(local i=0;i<customers.len();i+=1)
		{
			if(activator == customers[i])
				exists = true;
		}
		if(!exists)
			customers.push(activator);
	}
}
function LeaveCustomer()
{
	if(activator!=piv)
	{
		if(activator != null && activator.IsValid())
		{
			for(local i=0;i<customers.len();i+=1)
			{
				if(activator == customers[i])
				{customers.remove(i);break;}
			}
			for(local i=0;i<customers.len();i+=1)
			{
				if(activator == customers[i])
				{customers.remove(i);break;}
			}
		}
	}
}
function PickCustomer()
{
	if(shopactive && customers.len()>0)
	{if(piv==shop_cheat)shop_cheat=null;local c = piv;if(piv==null||!piv.IsValid()||pivv||piv.GetTeam()!=3)
	{
		//******
		//is shop cheat valid (did someone shoot the wall)? then prioritize that player first
		//******
		if(shop_cheat!=null&&shop_cheat.IsValid()&&shop_cheat.GetTeam()==3&&shop_cheat.GetHealth()>0)
			c = shop_cheat;
		else
			c=customers[RandomInt(0,customers.len()-1)];
		}
		else if(pivvv){if(shop_cheat!=null&&shop_cheat.IsValid()&&shop_cheat.GetTeam()==3&&shop_cheat.GetHealth()>0)c = shop_cheat;else c=customers[RandomInt(0,customers.len()-1)];}
		if(c == null || !c.IsValid())
			EntFireByHandle(self, "RunScriptCode", " PickCustomer(); ", 0.10, self, self);
		else
		{
			EntFireByHandle(c, "AddOutput", "origin 7800 400 300", 0.00, self, self);
			EntFireByHandle(self, "RunScriptCode", " LeaveCustomer(); ", 0.00, c, c);
			EntFireByHandle(c, "AddOutput", "origin 7300 300 200", 7.00, self, self);if(c==piv)pivv=true;
			EntFireByHandle(self, "RunScriptCode", " PickCustomer(); ", 7.05, self, self);
			//******
			//if buyer is shop_cheat, null shop_cheat for this round
			//******
			if(c==shop_cheat)
				shop_cheat=null;
		}
	}
	else if(shopactive && customers.len()==0)
		EntFireByHandle(self, "RunScriptCode", " PickCustomer(); ", 0.10, self, self);
}

