IncludeScript("alterna_world_misc.nut");

class ChatCommandManager {
    global_values = null

    constructor(gv) {
        global_values = gv;
    }

    function ProcessCommand(/*CTFPlayer*/ player, /*String*/ chat_msg) {
        local player_name = NetProps.GetPropString(player, "m_szNetname");
        local player_steam_id = NetProps.GetPropString(player, "m_szNetworkIDString");

        if (chat_msg.slice(0,1) == "!") {
            DebugPrintToConsole(format("Player %s is initiating a command!", player_name))
            local command_args = split(chat_msg.slice(1), " ")

            if (command_args.len() < 1) {
                PrintToChatWindow(player, "Missing command argument");
                return;
            }

            switch (command_args[0]) {
                case "chips":
                    ListChips(player, player_steam_id);
                    return;

                case "debugaddchip":
                    AddChip(player, player_steam_id, command_args);
                    return;

                default:
                    PrintToChatWindow(player, format("Unknown command '%s'", command_args[0]));
                    return;
            }
        }
    }

    function ListChips(/*CTFPlayer*/ player, /*String*/ player_steam_id) {
        local player_chips_table =  global_values.player_inventory_table[player_steam_id]["chips"];

        foreach (chip in player_chips_table) {
            local chip_description = chip.GetChipDescription();
            local chip_collected = chip.chip_count;
            local chip_max = chip.max_chips;

            PrintToChatWindow(player, format("%s: %i/%i", chip_description, chip_collected, chip_max));
        }
    }

    function AddChip(/*CTFPlayer*/ player, /*String*/ player_steam_id, /*List<String>*/ command_args) {
        if (command_args.len() < 2) {
            PrintToChatWindow(player, "Not enough arguments for !debugaddchip");
            PrintToChatWindow(player, "!debugaddchip <internal_chip_name>");
            return;
        }

        local player_chips_table =  global_values.player_inventory_table[player_steam_id]["chips"];
        local internal_chip_name = command_args[1];
        if (!(internal_chip_name in player_chips_table)) {
            PrintToChatWindow(player, format("Unable to find requested chip: '%s'", internal_chip_name));
        }

        local chip = player_chips_table[internal_chip_name];
        chip.IncrementChip();

        // Force game to reload weapon for current player
        local player_manager = Entities.FindByClassname(null, "tf_player_manager");
        local uid =  NetProps.GetPropIntArray(player_manager, "m_iUserID", player.entindex());
        SendGlobalGameEvent("post_inventory_application", { userid = uid });
    }
}