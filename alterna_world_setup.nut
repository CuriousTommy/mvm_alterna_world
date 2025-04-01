
function CollectEventsInScope(events)
{
	local events_id = UniqueString()
	getroottable()[events_id] <- events
	local events_table = getroottable()[events_id]
	foreach (name, callback in events) events_table[name] = callback.bindenv(this)
	local cleanup_user_func, cleanup_event = "OnGameEvent_scorestats_accumulated_update"
    if (cleanup_event in events) cleanup_user_func = events[cleanup_event].bindenv(this)
	events_table[cleanup_event] <- function(params)
	{
		if (cleanup_user_func) cleanup_user_func(params)
		delete getroottable()[events_id]
	} __CollectGameEventCallbacks(events_table)
}

IncludeScript("alterna_world_chat_commands.nut");
IncludeScript("alterna_world_chip_logic.nut");
IncludeScript("alterna_world_chip_organiser.nut");
IncludeScript("alterna_world_chip.nut");
IncludeScript("alterna_world_misc.nut");
IncludeScript("alterna_world_player.nut");
IncludeScript("alterna_world_playerinventory.nut");
IncludeScript("alterna_world_weapon.nut");

// Initalize global variables

chat_command_manager <- ChatCommandManager(this);
shared_chip_table <- CreateSharedTeamChip(Convars.GetInt("tf_mvm_defenders_team_size"));
player_inventory_table <- {};

function GetPlayerInventory(/*CTFPlayer*/ player) {
    local steam_id = NetProps.GetPropString(player, "m_szNetworkIDString");

    if (!(steam_id in player_inventory_table)) {
        local name = NetProps.GetPropString(player, "m_szNetname");
        DebugPrintToConsole(format("Initalizing player inventory for %s (%s)", steam_id, name));
        player_inventory_table[steam_id] <- PlayerInventory(player, shared_chip_table);
    }

    return player_inventory_table[steam_id];
}

::PostPlayerSpawn <- function()
{
    ApplyDefaultPlayerAttributes(self);

    local player_inventory = GetPlayerInventory(self);
    player_inventory.ApplyChipsUpgradesToPlayer(self);
}

// See following for more details on the events and it's params:
// https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Game_Events

CollectEventsInScope
({
	OnGameEvent_post_inventory_application = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)

        if (player instanceof CTFPlayer && !player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) {
            local player_name = NetProps.GetPropString(player, "m_szNetname");
            local player_inventory = GetPlayerInventory(player);

            DebugPrintToConsole(format("Found non-AI player %s", player_name));
            player_inventory.ReapplyWeaponsToPlayer(player);
        }
	}

    OnGameEvent_player_say = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        local chat_msg = params.text;
        chat_command_manager.ProcessCommand(player, chat_msg);
    }

    OnGameEvent_player_spawn = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)

        if (player != null && player instanceof CTFPlayer && !player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) {
            // There are scenarios where SteamID3 is not yet available. This forces it to be available.
            // https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Fetching_player_name_or_Steam_ID
            if (player.GetTeam() == 0) {
                SendGlobalGameEvent("player_activate", {userid = params.userid})
            }

            // Workaround for applying attributes to player
            // https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/VScript_Examples#Adding_attributes_to_player_on_spawn
            if (params.team != 0)
            {
                EntFireByHandle(player, "CallScriptFunction", "PostPlayerSpawn", 0, null, null)
            }
        }
    }
})
