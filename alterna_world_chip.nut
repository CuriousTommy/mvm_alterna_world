
// This section is inspired by how Octo Expansion handles
// upgrading the player/weapons.
//
// If you are not familiar with Splatoon's Octo Expansion game mode:
// https://splatoonwiki.org/wiki/Color_chip#Types_of_color_chips



// Intended for upgrades that are applied to a single player
class ChipManager {
    // The number of chips a Player/Team currently have
    chip_count =  null;
    // The max amount of chips allowed
    max_chips = null;

    constructor(/*int*/ max) {
        chip_count = 0;
        max_chips = max;
    }

    // Method for subclass to overload
    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon) {}

    // Method for subclass to overload
    function ApplyAttributeToPlayer(/*CTFPlayer*/ player) {}

    function AvailableChipSlots() {
        return max_chips - chip_count;
    }

    function IncrementChip() {
        chip_count++;
        if (chip_count > max_chips) { chip_count = max_chips; }
    }

    function DebugMaxOutChips() {
        chip_count = max_chips;
    }

    function CalculatePercentage() /*-> Float*/ {
        return chip_count.tofloat() / max_chips.tofloat();
    }

    // Method for subclass to overload
    function GetInternalChipName() /*-> String*/ {}

    // Method for subclass to overload
    function GetChipDescription() /*-> String*/ {}
}

// Intended for upgrades that are applied to the whole team.
// I want to make it a little harder to max out a chip collection
// in a non-solo run.
class TeamPenaltyChipManager extends ChipManager {
    constructor(/*Integer*/ max_team_size, /*Integer*/ max_chips) {
        local chip_increase_penality = ((max_team_size * 2) / 3).tointeger();
        if (chip_increase_penality < 1) { chip_increase_penality = 1; }

        base.constructor(chip_increase_penality*max_chips);
    }
}

// Weapon Class (ex: "tf_weapon_scattergun"):
// https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
// Item Attributes (ex: "damage bonus"):
// https://wiki.teamfortress.com/wiki/List_of_item_attributes

const ATTRIBUTE_DURATION_FOREVER = -1;

class ChipManager_WeaponDamagePrimarySecondary extends TeamPenaltyChipManager {
    function GetInternalChipName() { return "weapon_damage_primary_secondary"; }
    function GetChipDescription()  { return "Increase Damage of Primary & Secondary Weapon"; }

    constructor(/*Integer*/ max_team_size) {
        base.constructor(max_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
            case "tf_weapon_rocketlauncher":
            case "tf_weapon_flamethrower":
            case "tf_weapon_grenadelauncher":
            case "tf_weapon_minigun":
            case "tf_weapon_shotgun_primary":
            case "tf_weapon_syringegun_medic":
            case "tf_weapon_sniperrifle":
            case "tf_weapon_revolver":
                weapon.AddAttribute("damage bonus", 1.0 + (1.0 * CalculatePercentage()), ATTRIBUTE_DURATION_FOREVER)
                break;

            default:
                break;
        }
    }
}


function Private_AssignChipToTable(/*Table<String,ChipManager>*/ chip_table, /*ChipManager*/ chip_value) {
    local chip_key = chip_value.GetInternalChipName();
    chip_table[chip_key] <- chip_value;
}

function Private_CreateSharedChipForTeam(/*Integer*/ max_team_size) /*-> Table<String,ChipManager>*/ {
    local shared_chips_for_team = {}

    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponDamagePrimarySecondary(max_team_size));

    return shared_chips_for_team;
}

function CreateSharedTeamChip(/*Integer*/ max_team_size) /*-> Table<Constants.ETFTeam,Table<String,ChipManager>>*/ {
    local red_team_chips = Private_CreateSharedChipForTeam(max_team_size);
    local blue_team_chips = Private_CreateSharedChipForTeam(max_team_size);

    local shared_chips = {}
    shared_chips[Constants.ETFTeam.TF_TEAM_RED] <- red_team_chips;
    shared_chips[Constants.ETFTeam.TF_TEAM_BLUE] <- blue_team_chips;

    return shared_chips;
}

function CreatePlayerChip() /*-> Table<Constants.ETFClass,Table<String,ChipManager>>*/ {
    local scout_only_chips = {};
    local solider_only_chips = {};
    local pyro_only_chips = {};
    local demoman_only_chips = {};
    local heavyweapons_only_chips = {};
    local engineer_only_chips = {};
    local medic_only_chips = {};
    local sniper_only_chips = {};
    local spy_only_chips = {};

    local player_chips = {};
    player_chips[Constants.ETFClass.TF_CLASS_SCOUT]        <- scout_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_SOLDIER]      <- solider_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_PYRO]         <- pyro_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_DEMOMAN]      <- demoman_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_HEAVYWEAPONS] <- heavyweapons_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_ENGINEER]     <- engineer_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_MEDIC]        <- medic_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_SNIPER]       <- sniper_only_chips;
    player_chips[Constants.ETFClass.TF_CLASS_SPY]          <- spy_only_chips;

    return player_chips;
}