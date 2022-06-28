//===================================\\
// Entity Cleaner script by Luffaren  (STEAM_0:1:22521282)
// ***********************************
// This script is made to clean up all entities in the map
// Could be useful for OnRoundEnd in order to lower the general edict count
// 
// [NOTE]
// To clean all entities, call CleanEntities(); 
// It will clean all entities except for permanent ones, game-breaking ones, weapons and !self
// It is suggested to use a game_weapon_manager separately to keep weapons cleaned
// 
//===================================\\

function CleanEntities()
{
	local h = Entities.First();
	while(null!=(h=Entities.Next(h)))
	{
		local cn = h.GetClassname();
		local isweapon = false;
		if(cn.len()>6&&cn.slice(0,7)=="weapon_")isweapon = true;
		if(h!=null&&h.IsValid()&&h!=self&&!isweapon
		&&cn!="func_brush"
		&&cn!="info_target"
		&&cn!="player"
		&&cn!="logic_auto"
		&&cn!="worldspawn"
		&&cn!="cs_team_manager"
		&&cn!="cs_player_manager"
		&&cn!="game_round_end"
		&&cn!="func_illusionary"
		&&cn!="env_fog_controller"
		&&cn!="env_tonemap_controller"
		&&cn!="sky_camera"
		&&cn!="func_buyzone"
		&&cn!="info_player_terrorist"
		&&cn!="info_player_counterterrorist"
		&&cn!="func_areaportalwindow"
		&&cn!="info_teleport_destination"
		&&cn!="player_speedmod"
		&&cn!="func_areaportal"
		&&cn!="info_player_start"
		&&cn!="game_player_equip"
		&&cn!="logic_measure_movement"
		&&cn!="point_servercommand"
		&&cn!="point_clientcommand"
		&&cn!="env_cubemap"
		&&cn!="soundent"
		&&cn!="cs_gamerules"
		&&cn!="vote_controller"
		&&cn!="water_lod_control"
		&&cn!="point_template"
		&&cn!="filter_activator_team"
		&&cn!="filter_activator_name"
		&&cn!="filter_activator_class"
		&&cn!="filter_multi"
		&&cn!="skybox_swapper"
		&&cn!="func_clip_vphysics"
		&&cn!="ai_network"
		&&cn!="env_cascade_light"
		&&cn!="predicted_viewmodel"
		&&cn!="scene_manager"
		&&cn!="wearable_item"
		&&cn!="weaponworldmodel"
		&&cn!="game_weapon_manager")
			EntFireByHandle(h,"Kill","",0.00,null,null);
	}
}

