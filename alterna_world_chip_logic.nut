// Weapon Class (ex: "tf_weapon_scattergun"):
// https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
// Item Attributes (ex: "damage bonus"):
// https://wiki.teamfortress.com/wiki/List_of_item_attributes

IncludeScript("alterna_world_chip.nut");
IncludeScript("alterna_world_misc.nut")
IncludeScript("alterna_world_weapon.nut");

const ATTRIBUTE_DURATION_FOREVER = -1;

//
// Debug/Proof Of Concept Chip
// Intended for testing out PoC upgrades on a player/weapon
//
class ChipManager_DebugApplyProofOfConcept extends ChipManager {
    function GetInternalChipName() { return "debug_apply_proof_of_concept"; }
    function GetChipDescription()  { return "Debug chip (Should not be included in final release)"; }

    constructor() {
        base.constructor(1);
    }

    function ReplaceWeaponInCustomLoadout(/*CustomLoadout*/ loadout) {
        DebugPrintToConsole("[Debug Chip] ReplaceWeaponInCustomLoadout Called");
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        DebugPrintToConsole("[Debug Chip] ApplyAttributeToWeapon Called");
    }

    function ApplyAttributeToPlayer(/*CTFPlayer*/ player) {
        DebugPrintToConsole("[Debug Chip] ApplyAttributeToPlayer Called");
    }
}

//
// Common Chips (Team Based)
//

class ChipManager_PlayerMaxHealth extends TeamPenaltyChipManager {
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

            case Constants.ETFClass.TF_CLASS_SOLDIER:
                player.AddCustomAttribute("max health additive bonus", 150 * CalculatePercentage(), ATTRIBUTE_DURATION_FOREVER);
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

class ChipManager_PlayerMovementSpeed extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "player_movement_speed"; }
    function GetChipDescription()  { return "Increase movement speed"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 3);
    }

    function ApplyAttributeToPlayer(/*CTFPlayer*/ player) {
        switch (player.GetPlayerClass()) {
            case Constants.ETFClass.TF_CLASS_SOLDIER:
                player.AddCustomAttribute("move speed bonus", 1.0 + (0.5 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER);
                break;

            default:
                player.AddCustomAttribute("move speed bonus", 1.0 + (0.3 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER);
                break;
        }
    }
}

class ChipManager_PlayerJumpHeight extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "player_jump_height"; }
    function GetChipDescription()  { return "Increase jump height"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 3);
    }

    function ApplyAttributeToPlayer(/*CTFPlayer*/ player) {
        switch (player.GetPlayerClass()) {
            default:
                player.AddCustomAttribute("increased jump height", 1.0 + (0.6 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER);
                break;
        }
    }
}

class ChipManager_WeaponPrimarySecondaryDamageIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_primary_secondary_damage_increase"; }
    function GetChipDescription()  { return "Increase damage of primary/secondary weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
            // case "tf_weapon_flamethrower":
            // case "tf_weapon_grenadelauncher":
            // case "tf_weapon_minigun":
            // case "tf_weapon_shotgun_primary":
            // case "tf_weapon_syringegun_medic":
            // case "tf_weapon_sniperrifle":
            // case "tf_weapon_revolver":
                weapon.AddAttribute("damage bonus", 1.0 + (1.0 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;

            case "tf_weapon_rocketlauncher":
                // Nerf the damage bonus
                weapon.AddAttribute("damage bonus", 1.0 + (0.5 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;
        }
    }
}

class ChipManager_WeaponPrimarySecondaryReloadSpeedIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_primary_secondary_reload_speed"; }
    function GetChipDescription()  { return "Increase reload speed of primary/secondary weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
            case "tf_weapon_rocketlauncher":
                weapon.AddAttribute("faster reload rate", 1.0 - (0.6 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;
        }
    }
}

class ChipManager_WeaponPrimarySecondaryFireSpeedIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_primary_secondary_fire_speed"; }
    function GetChipDescription()  { return "Increase fire speed of primary/secondary weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
            case "tf_weapon_rocketlauncher":
                weapon.AddAttribute("fire rate bonus", 1.0 - (0.4 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;
        }
    }
}

class ChipManager_WeaponPrimarySecondaryMaxAmmoIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_primary_secondary_max_ammo"; }
    function GetChipDescription()  { return "Increase max ammo of primary/secondary weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
            case "tf_weapon_rocketlauncher":
                weapon.AddAttribute("maxammo primary increased", 1.0 + (1.5 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;
        }
    }
}

class ChipManager_WeaponPrimarySecondaryClipSizeIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_primary_secondary_clip_size"; }
    function GetChipDescription()  { return "Increase clip size of primary/secondary weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
                weapon.AddAttribute("clip size bonus upgrade", 1.0 + (2.0 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;
            case "tf_weapon_rocketlauncher":
                weapon.AddAttribute("clip size upgrade atomic", (8 * CalculatePercentage()).tointeger(), ATTRIBUTE_DURATION_FOREVER)
        }
    }
}

class ChipManager_WeaponMeleeDamageIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_melee_damage_increase"; }
    function GetChipDescription()  { return "Increase damage of melee weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_bat":
            case "tf_weapon_bat_wood":
            case "tf_weapon_shovel":
                // Should I buff?
                weapon.AddAttribute("damage bonus", 1.0 + (1.0 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;
        }
    }
}

class ChipManager_WeaponMeleeAttackSpeedIncrease extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_melee_attack_speed_increase"; }
    function GetChipDescription()  { return "Increase attack speed of melee weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 4);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        if (weapon_type == CustomLoadoutWeaponType.MELEE) {
            switch (weapon.GetClassname()) {
                case "tf_weapon_shovel":
                    weapon.AddAttribute("melee attack rate bonus", 1.0 - (0.5 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER);
                    break;

                default:
                    weapon.AddAttribute("melee attack rate bonus", 1.0 - (0.4 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER);
                    break;
            }
        }
    }
}

class ChipManager_PlayerAndWeaponHealthRestored extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "player_and_weapon_health_restored"; }
    function GetChipDescription()  { return "Increase health restored by player/weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToPlayer(/*CTFPlayer*/ player) {
        if (player.GetPlayerClass() != Constants.ETFClass.TF_CLASS_MEDIC) {
            local health_regen_amount = 5 * CalculatePercentage();

            local health_regen_minimum = 1;
            if (health_regen_amount < health_regen_minimum) {
                health_regen_amount = health_regen_minimum;
            }

            player.AddCustomAttribute("health regen", health_regen_amount, ATTRIBUTE_DURATION_FOREVER);
        }
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        switch (weapon_type) {
            case CustomLoadoutWeaponType.PRIMARY:
            case CustomLoadoutWeaponType.SECONDARY:
            case CustomLoadoutWeaponType.MELEE:
                weapon.AddAttribute("heal on kill", (25 * CalculatePercentage()).tointeger(), ATTRIBUTE_DURATION_FOREVER)
                break;
        }
    }
}

//
// Common Chips (Individual Based)
//

class ChipManager_WeaponPrimaryMinicritsFromBehind extends ChipManager {
    function GetInternalChipName() { return "weapon_primary_minicrits_from_behind"; }
    function GetChipDescription()  { return "Mini-crits enemies from behind when close it range"; }

    constructor() {
        base.constructor(1);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        if (chip_count < 1) {
            return;
        }

        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
                weapon.AddAttribute("closerange backattack minicrits", 1, ATTRIBUTE_DURATION_FOREVER);
                break;
        }
    }
}

class ChipManager_WeaponMeleeCauseBleeding extends ChipManager {
    function GetInternalChipName() { return "weapon_melee_cause_bleeding"; }
    function GetChipDescription()  { return "Bleed on hit (melee only)"; }

    constructor() {
        base.constructor(3);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
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

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
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

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
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

class ChipManager_WeaponMeleeApplyAtomizerEffect extends ChipManager {
    function GetInternalChipName() { return "weapon_melee_apply_atomizer_effect"; }
    function GetChipDescription()  { return "Apply Atomizer effect to Scout's melee"; }

    constructor() {
        base.constructor(1);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        if (chip_count < 1) {
            return;
        }

        switch (weapon.GetClassname()) {
            case "tf_weapon_bat":
            case "tf_weapon_bat_wood":
                weapon.AddAttribute("air dash count", 1, ATTRIBUTE_DURATION_FOREVER);
        }
    }
}

//
// Soldier only
//

class ChipManager_WeaponReplacementSoldierDisciplinaryAction extends ChipManager {
    function GetInternalChipName() { return "weapon_replacement_soldier_disciplinary_action"; }
    function GetChipDescription()  { return "Unlock the Disciplinary Action (additional chips upgrade the weapon)"; }

    constructor() {
        base.constructor(3);
    }

    function ReplaceWeaponInCustomLoadout(/*CustomLoadout*/ loadout) {
        if (chip_count > 0) {
        // Destroy previous weapon
        loadout.melee_weapon.Destroy();
        // Add new weapon
        loadout.melee_weapon = CreateWeaponGeneric("tf_weapon_shovel", 447);
        // Undo Disciplinary Action nerf
        loadout.melee_weapon.AddAttribute("damage penalty", 1.0, ATTRIBUTE_DURATION_FOREVER)
        }
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        if (chip_count > 1 && weapon.GetClassname() == "tf_weapon_shovel") {
            weapon.AddAttribute("speed_boost_on_hit_enemy", 1, ATTRIBUTE_DURATION_FOREVER);
        }
    }
}

class ChipManager_WeaponPrimaryFasterRocketsWhenBlastJumping extends ChipManager {
    function GetInternalChipName() { return "weapon_primary_faster_rockets_when_blast_jumping"; }
    function GetChipDescription()  { return "Faster rockets when blast jumping"; }

    constructor() {
        base.constructor(1);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        if (chip_count < 1) {
            return;
        }

        switch (weapon.GetClassname()) {
            case "tf_weapon_rocketlauncher":
                weapon.AddAttribute("rocketjump attackrate bonus", 0.35, ATTRIBUTE_DURATION_FOREVER);
        }
    }
}

class ChipManager_WeaponMeleeApplyEqualizerEffect extends ChipManager {
    function GetInternalChipName() { return "weapon_melee_apply_equalizer_effect"; }
    function GetChipDescription()  { return "Apply Equalizer effect to Soldier's melee"; }

    constructor() {
        base.constructor(1);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon, /*CustomLoadoutWeaponType*/ weapon_type) {
        if (chip_count < 1) {
            return;
        }

        switch (weapon.GetClassname()) {
            case "tf_weapon_shovel":
                weapon.AddAttribute("mod shovel damage boost", 1, ATTRIBUTE_DURATION_FOREVER);
        }
    }
}