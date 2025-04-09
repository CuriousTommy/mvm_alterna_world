
function CollectEventsInScope_AlternaWorld(events_id, events)
{
	getroottable()[events_id] <- events

	local events_table = getroottable()[events_id]
	foreach (name, callback in events)
        events_table[name] = callback.bindenv(this)

    local cleanup_user_func, cleanup_event = "OnGameEvent_scorestats_accumulated_update"
    if (cleanup_event in events)
        cleanup_user_func = events[cleanup_event].bindenv(this)

    events_table[cleanup_event] <- function(params)
	{
		if (cleanup_user_func) cleanup_user_func(params)
		delete getroottable()[events_id]
	}

    __CollectGameEventCallbacks(events_table)
}

IncludeScript("alterna_world_chat_commands.nut");
IncludeScript("alterna_world_chip_logic.nut");
IncludeScript("alterna_world_chip_organiser.nut");
IncludeScript("alterna_world_chip.nut");
IncludeScript("alterna_world_misc.nut");
IncludeScript("alterna_world_player.nut");
IncludeScript("alterna_world_playerinventory.nut");
IncludeScript("alterna_world_weapon.nut");

class AlernaWorldManager {
    chat_command_manager = null;
    shared_chip_table = null
    player_inventory_table = null;
    loaded_pop_file_when_init = null;

    constructor() {
        chat_command_manager = ChatCommandManager(this);
        shared_chip_table = CreateSharedTeamChip(Convars.GetInt("tf_mvm_defenders_team_size"));
        player_inventory_table = {};
        loaded_pop_file_when_init = GetCurrentLoadedPopFile();
        DebugPrintToConsole(format("loaded_pop_file_when_init = %s", loaded_pop_file_when_init));
    }

    function GetPlayerInventory(/*CTFPlayer*/ player) {
        local steam_id = NetProps.GetPropString(player, "m_szNetworkIDString");

        if (!(steam_id in player_inventory_table)) {
            local name = NetProps.GetPropString(player, "m_szNetname");
            DebugPrintToConsole(format("Initalizing player inventory for %s (%s)", steam_id, name));
            player_inventory_table[steam_id] <- PlayerInventory(player, shared_chip_table);
        }

        return player_inventory_table[steam_id];
    }

    function GetCurrentLoadedPopFile() /*-> String*/ {
        local tf_objective_resource = Entities.FindByClassname(null, "tf_objective_resource");
        return NetProps.GetPropString(tf_objective_resource, "m_iszMvMPopfileName");
    }

    //
    // Event Function
    //

    function EventPostInventoryApplication(params) {
		local player = GetPlayerFromUserID(params.userid)

        if (player instanceof CTFPlayer && !player.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) {
            local player_name = NetProps.GetPropString(player, "m_szNetname");
            local player_inventory = GetPlayerInventory(player);

            DebugPrintToConsole(format("Found non-AI player %s", player_name));

            player_inventory.RemoveWearableFromPlayer(player);
            player_inventory.ReapplyWeaponsToPlayer(player);
        }
    }

    function EventPlayerSay(params) {
        local player = GetPlayerFromUserID(params.userid)
        local chat_msg = params.text;
        chat_command_manager.ProcessCommand(player, chat_msg);
    }

    function EventPlayerSpawn(params) {
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

    //
    // EntFire Functions
    //

    function EntFirePostPlayerSpawn(player) {
        ApplyDefaultPlayerAttributes(player);

        local player_inventory = GetPlayerInventory(player);
        player_inventory.ApplyChipsUpgradesToPlayer(player);
    }
}

function IsAlternaWorldManagerInitialized() {
    return "alterna_world_manager_instance" in getroottable()
}

// https://discord.com/channels/415522947789488129/862709081209569310/1357548081041772554
// only init the manager if one does not exist already
if (!IsAlternaWorldManagerInitialized()) {
    // To make sure our upgrades presist between a sucessful wave,
    // we need to store the manager in the root table.
    DebugPrintToConsole("Alterna World Manager instance not found, creating one.");
    ::alterna_world_manager_instance <- AlernaWorldManager();
}

// See following for more details on the events and it's params:
// https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Game_Events

::PostPlayerSpawn <- function() {
    if (IsAlternaWorldManagerInitialized()) {
        ::alterna_world_manager_instance.EntFirePostPlayerSpawn(self)
    }
}

CollectEventsInScope_AlternaWorld("alterna_world_events",
{
	OnGameEvent_post_inventory_application = function(params) {
        if (IsAlternaWorldManagerInitialized()) {
            ::alterna_world_manager_instance.EventPostInventoryApplication(params)
        }
    }

    OnGameEvent_player_say = function(params) {
        if (IsAlternaWorldManagerInitialized()) {
            ::alterna_world_manager_instance.EventPlayerSay(params)
        }
    }
    OnGameEvent_player_spawn = function(params) {
        if (IsAlternaWorldManagerInitialized()) {
            ::alterna_world_manager_instance.EventPlayerSpawn(params)
        }
    }

    // https://discord.com/channels/415522947789488129/862709081209569310/1357556662235566202
    // https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Game_Events#scorestats_accumulated_update
    OnGameEvent_recalculate_holidays = function(params) {
        if (GetRoundState() == Constants.ERoundState.GR_STATE_PREROUND) {
            local currently_loaded_popfile = ::alterna_world_manager_instance.GetCurrentLoadedPopFile();
            local prior_popfile = ::alterna_world_manager_instance.loaded_pop_file_when_init;
            if (currently_loaded_popfile != prior_popfile) {
                DebugPrintToConsole("Mission change detected. Removing traces of Alterna World...");
                delete ::alterna_world_events
                delete ::alterna_world_manager_instance
            }
        }
    }
})
