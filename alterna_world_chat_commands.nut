IncludeScript("alterna_world_misc.nut");

class ChatCommandManager {
    global_values = null

    constructor(gv) {
        global_values = gv;
    }

    function ProcessCommand(/*CTFPlayer*/ player, /*String*/ chat_msg) {
        local player_name = NetProps.GetPropString(player, "m_szNetname");

        if (chat_msg.slice(0,1) == "!") {
            DebugPrintToConsole(format("Player %s is initiating a command!", player_name))
            local command_args = split(chat_msg.slice(1), " ")

            if (command_args.len() < 1) {
                PrintToChatWindow(player, "Missing command argument");
                return;
            }

            switch (command_args[0]) {
                case "chips":
                    ListChips(player);
                    return;

                case "debugaddchip":
                    DebugAddChip(player, command_args);
                    return;

                case "debugmaxoutallchips":
                    DebugMaxOutAllChips(player);
                    return;

                default:
                    PrintToChatWindow(player, format("Unknown command '%s'", command_args[0]));
                    return;
            }
        }
    }

    function IsCheatingEnabled() {
        return Convars.GetInt("sv_cheats") == 1;
    }

    function ListChips(/*CTFPlayer*/ player) {
        local player_inventory = global_values.GetPlayerInventory(player);
        local chip_cache = player_inventory.GetCachedChips(player);

        foreach (chip in chip_cache) {
            local chip_description = chip.GetChipDescription();
            local chip_collected = chip.chip_count;
            local chip_max = chip.max_chips;

            PrintToChatWindow(player, format("%s: %i/%i", chip_description, chip_collected, chip_max));
        }
    }

    function DebugAddChip(/*CTFPlayer*/ player, /*List<String>*/ command_args) {
        if (command_args.len() < 2) {
            PrintToChatWindow(player, "Not enough arguments for !debugaddchip");
            PrintToChatWindow(player, "!debugaddchip <internal_chip_name>");
            return;
        }

        if (!IsCheatingEnabled()) {
            PrintToChatWindow(player, "sv_cheats must be set to 1 to use this command");
            return;
        }

        local player_inventory = global_values.GetPlayerInventory(player);
        local chip_cache = player_inventory.GetCachedChips(player);

        local internal_chip_name = command_args[1];
        if (!(internal_chip_name in chip_cache)) {
            PrintToChatWindow(player, format("Unable to find requested chip: '%s'", internal_chip_name));
        }

        local chip = chip_cache[internal_chip_name];
        chip.IncrementChip();

        // Recreate weapon and apply chip upgrades to weapons/player
        player_inventory.ReapplyWeaponsToPlayer(player);
        player_inventory.ApplyChipsUpgradesToPlayer(player);
    }

    function DebugMaxOutAllChips(/*CTFPlayer*/ player) {
        if (!IsCheatingEnabled()) {
            PrintToChatWindow(player, "sv_cheats must be set to 1 to use this command");
            return;
        }

        local player_inventory = global_values.GetPlayerInventory(player);
        local chip_cache = player_inventory.GetCachedChips(player);

        foreach (chip in chip_cache) {
            chip.DebugMaxOutChips();
        }

        // Recreate weapon and apply chip upgrades to weapons/player
        player_inventory.ReapplyWeaponsToPlayer(player);
        player_inventory.ApplyChipsUpgradesToPlayer(player);
    }
}