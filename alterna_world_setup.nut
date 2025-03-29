
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
IncludeScript("alterna_world_chip.nut");
IncludeScript("alterna_world_misc.nut");
IncludeScript("alterna_world_player.nut");
IncludeScript("alterna_world_weapon.nut");

// Initalize global variables

chat_command_manager <- ChatCommandManager(this);
shared_chip_table <- SetupSharedChip();
player_inventory_table <- {};

const PLAYER_INVENTORY_KEY_CHIPS = "chips";

function InitPlayerInventory(/*CTFPlayer*/ player, /*String*/ name, /*String*/ steam_id) {
    if (steam_id in player_inventory_table) {
        return;
    }

    DebugPrintToConsole(format("Initalizing player inventory for %s (%s)", steam_id, name));
    local player_inventory = {
        "chips": SetupPlayerChip(shared_chip_table, player)
    };

    player_inventory_table[steam_id] <- player_inventory;
}

::PostPlayerSpawn <- function()
{
    if (!self.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) {
        local player_steam_id = NetProps.GetPropString(self, "m_szNetworkIDString");
        local player_name = NetProps.GetPropString(self, "m_szNetname");

        ApplyDefaultPlayerAttributes(self, player_name);
    }
}

// See following for more details on the events and it's params:
// https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Game_Events

CollectEventsInScope
({
	OnGameEvent_post_inventory_application = function(params)
	{
		local cbaseplayer = GetPlayerFromUserID(params.userid)

        if (cbaseplayer instanceof CTFPlayer && !cbaseplayer.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) {
            local player_name = NetProps.GetPropString(cbaseplayer, "m_szNetname");
            local player_steam_id = NetProps.GetPropString(cbaseplayer, "m_szNetworkIDString");

            DebugPrintToConsole(format("Found non-AI player %s", player_name));

            RemoveAllWeapons(cbaseplayer);
            AssignApprovedWeapons(cbaseplayer);

            // Initialize player specific data
            InitPlayerInventory(cbaseplayer, player_name, player_steam_id);
            local player_inventory = player_inventory_table[player_steam_id][PLAYER_INVENTORY_KEY_CHIPS];

            ApplyChipUpgradeToWeapon(cbaseplayer, player_name, player_inventory);
        }
	}

    OnGameEvent_player_say = function(params)
    {
        local cbaseplayer = GetPlayerFromUserID(params.userid)
        local chat_msg = params.text;
        chat_command_manager.ProcessCommand(cbaseplayer, chat_msg);
    }

    OnGameEvent_player_spawn = function(params)
    {
        local cbaseplayer = GetPlayerFromUserID(params.userid)

        if (cbaseplayer instanceof CTFPlayer && !cbaseplayer.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) {
            // There are scenarios where SteamID3 is not yet available. This forces it to be available.
            // https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Fetching_player_name_or_Steam_ID
            if (cbaseplayer.GetTeam() == 0) {
                SendGlobalGameEvent("player_activate", {userid = params.userid})
            }

            // Initialize player specific data
            local player_name = NetProps.GetPropString(cbaseplayer, "m_szNetname");
            local player_steam_id = NetProps.GetPropString(cbaseplayer, "m_szNetworkIDString");
            InitPlayerInventory(cbaseplayer, player_name, player_steam_id);

            // Workaround for applying attributes to player
            // https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/VScript_Examples#Adding_attributes_to_player_on_spawn
            if (cbaseplayer != null && params.team != 0)
            {
                EntFireByHandle(cbaseplayer, "CallScriptFunction", "PostPlayerSpawn", 0, null, null)
            }
        }
    }
})
