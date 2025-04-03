IncludeScript("alterna_world_chip_logic.nut");

function Private_AssignChipToTable(/*Table<String,ChipManager>*/ chip_table, /*ChipManager*/ chip_value) {
    local chip_key = chip_value.GetInternalChipName();
    chip_table[chip_key] <- chip_value;
}

function Private_CreateSharedChipForTeam(/*Integer*/ max_team_size) /*-> Table<String,ChipManager>*/ {
    local shared_chips_for_team = {}

    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerMaxHealth(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerAmmoMetalRegen(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerMovementSpeed(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerJumpHeight(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryDamageIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryReloadSpeedIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryFireSpeedIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryMaxAmmoIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryClipSizeIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponMeleeDamageIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponMeleeAttackSpeedIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerAndWeaponHealthRestored(max_team_size));

    return shared_chips_for_team;
}

function CreateSharedTeamChip(/*Integer*/ max_team_size) /*-> Table<Constants.ETFTeam,Table<String,ChipManager>>*/ {
    local red_team_chips = Private_CreateSharedChipForTeam(max_team_size);
    local blue_team_chips = Private_CreateSharedChipForTeam(max_team_size);

    local shared_chips = {}
    shared_chips[Constants.ETFTeam.TF_TEAM_RED]  <- red_team_chips;
    shared_chips[Constants.ETFTeam.TF_TEAM_BLUE] <- blue_team_chips;

    return shared_chips;
}

function CreatePlayerChip() /*-> Table<Constants.ETFClass,Table<String,ChipManager>>*/ {
    local scout_only_chips = {};
    Private_AssignChipToTable(scout_only_chips, ChipManager_WeaponReplacementScoutSandman());
    Private_AssignChipToTable(scout_only_chips, ChipManager_WeaponPrimaryMinicritsFromBehind());
    Private_AssignChipToTable(scout_only_chips, ChipManager_WeaponMeleeCauseBleeding());
    Private_AssignChipToTable(scout_only_chips, ChipManager_WeaponMeleeCauseMarkForDeath());
    Private_AssignChipToTable(scout_only_chips, ChipManager_WeaponMeleeApplyAtomizerEffect());

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