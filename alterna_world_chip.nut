
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

    // Method for subclass to overload
    function ReplaceWeaponInCustomLoadout(/*CustomLoadout*/ loadout) {}

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
