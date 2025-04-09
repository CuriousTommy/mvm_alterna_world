IncludeScript("alterna_world_chip.nut");
IncludeScript("alterna_world_misc.nut");

class PlayerInventory {
    // A combination of shared and player specific chips (not recommended to directly access)
    cached_chips = null;
    // TODO: Maybe add a cached_available_chips?

    // Reference to shared chips
    shared_chips = null;
    // Chips from all classes that would only apply to one player
    player_chips = null;

    // The selected loadout
    player_selected_weapon_loadout = null;
    // Weapons for all classes
    player_weapons = null;

    // If a player changes class, we need a way to track that and update cached_chips
    player_prior_class = null;
    // (Untested) If a player changes team, we need to track that and update cached_chips
    player_prior_team = null;

    constructor(/*CTFPlayer*/ player, /*Table<Constants.ETFTeam,Table<String,ChipManager>>*/ shared_chips) {
        this.shared_chips = shared_chips;
        this.player_chips = CreatePlayerChip();

        this.player_weapons = GenerateDefaultApprovedWeapons();
        this.player_selected_weapon_loadout = Private_GenerateDefaultSelectedLoadout();

        ForceUpdateCachedChips(player);
    }

    function Private_GenerateDefaultSelectedLoadout() {
        local default_loadout_selection = {};
        default_loadout_selection[Constants.ETFClass.TF_CLASS_SCOUT]        <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_SOLDIER]      <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_PYRO]         <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_DEMOMAN]      <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_HEAVYWEAPONS] <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_ENGINEER]     <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_MEDIC]        <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_SNIPER]       <- 0;
        default_loadout_selection[Constants.ETFClass.TF_CLASS_SPY]          <- 0;
        return default_loadout_selection;
    }

    function Private_UpdateCachedChips(/*CTFPlayer*/ player) {
        local player_current_team = player.GetTeam();
        local player_current_class = player.GetPlayerClass();
        if (player_prior_team == player_current_team || player_prior_class == player_current_class) {
            // If no changes to the player's class or team, no updates needed
            return;
        }

        cached_chips = {}

        // Copy over the shared chips to our cache
        foreach(chip_key,chip_value in shared_chips[player_current_team]) {
            cached_chips[chip_key] <- chip_value;
        }

        // Copy over the player specific chips (based on the class they choose)
        local selected_loadout = player_selected_weapon_loadout[player_current_class];
        foreach(chip_key,chip_value in player_chips[player_current_class][selected_loadout]) {
            cached_chips[chip_key] <- chip_value;
        }
    }

    function ForceUpdateCachedChips(/*CTFPlayer*/ player) {
        this.player_prior_class = -1;
        this.player_prior_team = -1;
        Private_UpdateCachedChips(player)
    }

    // Don't directly access cached_chips! It may be out of date.
    function GetCachedChips(/*CTFPlayer*/ player) {
        Private_UpdateCachedChips(player);
        return cached_chips;
    }

    function CycleLoadout(/*CTFPlayer*/ player) /*-> Boolean*/ {
        local player_class = player.GetPlayerClass();
        local max_loadouts = player_weapons[player_class].len();

        local current_loadout_selection = player_selected_weapon_loadout[player_class];
        local new_loadout_selection = current_loadout_selection + 1;
        if (new_loadout_selection >= max_loadouts) {
            new_loadout_selection = 0;
        }

        if (new_loadout_selection != current_loadout_selection) {
            player_selected_weapon_loadout[player_class] = new_loadout_selection;
            ForceUpdateCachedChips(player);
            return true;
        }

        return false;
    }

    // I haven't figure out a way to reapply a wearable to a player.
    function RemoveWearableFromPlayer(/*CTFPlayer*/ player) {
        local wearable = player.FirstMoveChild()
        while (wearable != null) {
            local current_wearable = wearable;
            wearable = wearable.NextMovePeer()

            switch (current_wearable.GetClassname()) {
                case "tf_wearable":
                case "tf_wearable_demoshield":
                case "tf_wearable_razorback":
                    DebugPrintToConsole(format("Removing wearable %s", current_wearable.GetModelName()));
                    current_wearable.Destroy();
                    break;
            }
        }
    }

    function Private_GetSelectedWeaponLoadout(/*CTFPlayer*/ player) {
        local player_class = player.GetPlayerClass();
        local selected_loadout = player_selected_weapon_loadout[player_class];
        return player_weapons[player_class][selected_loadout]();
    }

    function ReapplyWeaponsToPlayer(/*CTFPlayer*/ player) {
        local cached_chips = GetCachedChips(player);

        // Remove all existing weapons attached to the player
        RemoveAllWeapons(player);

        // Create default weapon loadout for player
        local weapon_loadout = Private_GetSelectedWeaponLoadout(player);

        // Let chips overwrite default loadout
        foreach (chips in cached_chips) {
            chips.ReplaceWeaponInCustomLoadout(weapon_loadout);
        }

        // Apply & switch to weapon loadout
        weapon_loadout.ApplyWeaponsToPlayer(player);
        weapon_loadout.SwitchToPrimarySecondaryOrMelee(player);

        // Apply chip upgrades to weapon
        foreach (chip in cached_chips) {
            weapon_loadout.ApplyChipUpgradeToWeapons(chip);
        }
    }

    function ApplyChipsUpgradesToPlayer(/*CTFPlayer*/ player) {
        local cached_chips = GetCachedChips(player);
        foreach (chip in cached_chips) {
            chip.ApplyAttributeToPlayer(player);
        }
    }
}