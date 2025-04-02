// Weapon Class (ex: "tf_weapon_scattergun"):
// https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
// Item Attributes (ex: "damage bonus"):
// https://wiki.teamfortress.com/wiki/List_of_item_attributes

IncludeScript("alterna_world_chip.nut");
IncludeScript("alterna_world_weapon.nut");

const ATTRIBUTE_DURATION_FOREVER = -1;

//
// Common Chips (Team Based)
//

class ChipManager_PlayerMaxHealthUpgrade extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "player_max_health"; }
    function GetChipDescription()  { return "Increase the max health"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToPlayer(/*CTFPlayer*/ player) {
        switch (player.GetPlayerClass()) {
            case Constants.ETFClass.TF_CLASS_SCOUT:
                player.AddCustomAttribute("max health additive bonus", 175 * CalculatePercentage(), ATTRIBUTE_DURATION_FOREVER);
                break;

            default:
                player.AddCustomAttribute("max health additive bonus", 1000, ATTRIBUTE_DURATION_FOREVER);
                break;
        }
    }
}

class ChipManager_PlayerAmmoMetalRegen extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "player_ammo_metal_regen"; }
    function GetChipDescription()  { return "Regenerate ammo & metal"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToPlayer(/*CTFPlayer*/ player) {
        local regen_ammo_percentage_increase = 0.25 * CalculatePercentage();
        local regen_metal_amount_increase = 100 * CalculatePercentage();

        local regen_ammo_percentage_minimum = 0.01;
        if (regen_ammo_percentage_increase < regen_ammo_percentage_minimum) {
            regen_ammo_percentage_increase = regen_ammo_percentage_minimum;

        }

        local regen_metal_amount_minimum = 1;
        if (regen_metal_amount_increase < regen_metal_amount_minimum) {
            regen_metal_amount_increase = regen_metal_amount_minimum;
        }

        player.AddCustomAttribute("ammo regen", regen_ammo_percentage_increase, ATTRIBUTE_DURATION_FOREVER);
        if (player.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER) {
            player.AddCustomAttribute("metal regen", regen_metal_amount_increase.tointeger(), ATTRIBUTE_DURATION_FOREVER);
        }
    }
}

class ChipManager_WeaponPrimarySecondaryDamageIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_primary_secondary_damage_increase"; }
    function GetChipDescription()  { return "Increase damage of primary/secondary weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
            // case "tf_weapon_rocketlauncher":
            // case "tf_weapon_flamethrower":
            // case "tf_weapon_grenadelauncher":
            // case "tf_weapon_minigun":
            // case "tf_weapon_shotgun_primary":
            // case "tf_weapon_syringegun_medic":
            // case "tf_weapon_sniperrifle":
            // case "tf_weapon_revolver":
                weapon.AddAttribute("damage bonus", 1.0 + (1.0 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;
        }
    }
}

//
// Common Chips (Individual Based)
//

class ChipManager_WeaponMeleeCauseBleeding extends ChipManager {
    function GetInternalChipName() { return "weapon_melee_cause_bleeding"; }
    function GetChipDescription()  { return "Bleed on hit (melee only)"; }

    constructor() {
        base.constructor(3);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_bat":
            case "tf_weapon_bat_wood":
                weapon.AddAttribute("bleeding duration", (15 * CalculatePercentage()).tointeger(), ATTRIBUTE_DURATION_FOREVER);
                break;
        }
    }
}

class ChipManager_WeaponMeleeCauseMarkForDeath extends ChipManager {
    function GetInternalChipName() { return "weapon_melee_cause_mark_for_death"; }
    function GetChipDescription()  { return "Mark for death (melee only)"; }

    constructor() {
        base.constructor(1);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon) {
        if (chip_count < 1) {
            return;
        }

        switch (weapon.GetClassname()) {
            case "tf_weapon_bat":
            case "tf_weapon_bat_wood":
                weapon.AddAttribute("mark for death", 1, ATTRIBUTE_DURATION_FOREVER);
        }
    }
}

//
// Scout only
//

class ChipManager_WeaponReplacementScoutSandman extends ChipManager {
    function GetInternalChipName() { return "weapon_replacement_scout_sandman"; }
    function GetChipDescription()  { return "Unlock the Sandman (additional chips upgrade the weapon)"; }

    constructor() {
        base.constructor(3);
    }

    function ReplaceWeaponInCustomLoadout(/*CustomLoadout*/ loadout) {
        if (chip_count > 0) {
            // Destroy previous weapon
            loadout.melee_weapon.Destroy();
            // Add new weapon
            loadout.melee_weapon = CreateWeaponGeneric("tf_weapon_bat_wood", 44);
            // Undo Sandman nerf
            loadout.melee_weapon.AddAttribute("max health additive penalty", 0, ATTRIBUTE_DURATION_FOREVER)
        }
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon) {
        if (weapon.GetClassname() == "tf_weapon_bat_wood") {
            switch (chip_count) {
                case 2:
                    weapon.AddAttribute("effect bar recharge rate increased", 1.0 - 0.45, ATTRIBUTE_DURATION_FOREVER);
                    weapon.AddAttribute("maxammo grenades1 increased", 3.0, -1);
                    break;
                case 3:
                    weapon.AddAttribute("effect bar recharge rate increased", 1.0 - 0.9, ATTRIBUTE_DURATION_FOREVER);
                    weapon.AddAttribute("maxammo grenades1 increased", 5.0, -1);
                    break;
            }
        }
    }
}