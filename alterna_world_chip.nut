
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

    function IncrementChip() {
        chip_count++;
        if (chip_count > max_chips) { chip_count = max_chips; }
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
class MvmTeamChipManager extends ChipManager {
    constructor(/*Integer*/ tf_mvm_defenders_team_size, /*int*/ max) {
        local chip_increase_penality = (tf_mvm_defenders_team_size * (2 / 3)).tointeger();
        if (chip_increase_penality < 1) { chip_increase_penality = 1; }

        base.constructor(max*chip_increase_penality);
    }
}

// Weapon Class (ex: "tf_weapon_scattergun"):
// https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
// Item Attributes (ex: "damage bonus"):
// https://wiki.teamfortress.com/wiki/List_of_item_attributes

const ATTRIBUTE_DURATION_FOREVER = -1;

class ChipManager_WeaponDamagePrimarySecondary extends MvmTeamChipManager {
    function GetInternalChipName() { return "weapon_damage_primary_secondary"; }
    function GetChipDescription()  { return "Increase Damage of Primary & Secondary Weapon"; }

    constructor(/*Integer*/ tf_mvm_defenders_team_size) {
        base.constructor(tf_mvm_defenders_team_size, 5);
    }

    function ApplyAttributeToWeapon(/*CEconEntity*/ weapon) {
        switch (weapon.GetClassname()) {
            case "tf_weapon_scattergun":
            case "tf_weapon_shotgun_primary":
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

function SetupSharedChip() /*-> Table<String,ChipManager>*/ {
    local tf_mvm_defenders_team_size = Convars.GetInt("tf_mvm_defenders_team_size");
    local chip_table = {}

    Private_AssignChipToTable(chip_table, ChipManager_WeaponDamagePrimarySecondary(tf_mvm_defenders_team_size));

    return chip_table;
}

function SetupPlayerChip( /*Table<String,ChipManager>*/ shared_chip, /*CTFPlayer*/ player) /*-> Table<String,ChipManager>*/ {
    local player_chip_table = {};

    // We will add-on the global chip table to our player chip table
    foreach(key,value in shared_chip) {
        player_chip_table[key] <- value;
    }

    // TODO: Add player specific chips

    return player_chip_table;
}