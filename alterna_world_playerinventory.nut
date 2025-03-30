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
        ForceUpdateCachedChips(player);

        this.player_weapons = GenerateApprovedWeapons();
        this.player_selected_weapon_loadout = 0;
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
        foreach(chip_key,chip_value in player_chips[player_current_class]) {
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

    function Private_GetSelectedWeaponLoadout(/*CTFPlayer*/ player) {
        local weapon_loadout_list = player_weapons[player.GetPlayerClass()];
        if (player_selected_weapon_loadout >= weapon_loadout_list.len()) {
            // If the selected weapon loadout number exceed the number of available
            // loadouts, set it back to the default loadout (0)
            player_selected_weapon_loadout = 0;
        }

        return weapon_loadout_list[player_selected_weapon_loadout]();
    }

    // All classes will be forced to their stock weapons
    function ReapplyWeaponsToPlayer(/*CTFPlayer*/ player) {
        // Remove all existing weapons attached to the player
        RemoveAllWeapons(player);

        // Create and apply a weapon loadout to the player
        local weapon_loadout = Private_GetSelectedWeaponLoadout(player);
        foreach (weapon in weapon_loadout) {
            DebugPrintToConsole(format("Equiping weapon %s", weapon.GetClassname()));

            weapon.SetTeam(player.GetTeam())
            weapon.DispatchSpawn();

            player.Weapon_Equip(weapon);
        }

        // Always switch to the first weapon in the list (if it is not empty)
        if (weapon_loadout.len() > 0) {
            player.Weapon_Switch(weapon_loadout[0]);
        }

        // Apply chip upgrades to the weapon
        Private_ApplyChipsUpgradesToWeapons(player, weapon_loadout);
    }

    function Private_ApplyChipsUpgradesToWeapons( /*CTFPlayer*/ player, /*List<>*/ weapon_loadout) {
        local cached_chips = GetCachedChips(player);
        foreach (chip in cached_chips) {
            foreach (weapon in weapon_loadout) {
                chip.ApplyAttributeToWeapon(weapon);
            }
        }
    }

    function ApplyChipsUpgradesToPlayer(/*CTFPlayer*/ player) {
        local cached_chips = GetCachedChips(player);
        foreach (chip in cached_chips) {
            chip.ApplyAttributeToPlayer(player);
        }
    }
}