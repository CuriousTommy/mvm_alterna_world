IncludeScript("alterna_world_chip_logic.nut");

function Private_AssignChipToTable(/*Table<String,ChipManager>*/ chip_table, /*ChipManager*/ chip_value) {
    local chip_key = chip_value.GetInternalChipName();
    chip_table[chip_key] <- chip_value;
}

function Private_AssignAllChipsToTable(/*Table<String,ChipManager>*/ chip_table_reference, /*Table<String,ChipManager>*/ chip_table_append) {
    foreach (key,value in chip_table_reference) {
        chip_table_append[key] <- value;
    }
}

function Private_CreateSharedChipForTeam(/*Integer*/ max_team_size) /*-> Table<String,ChipManager>*/ {
    local shared_chips_for_team = {}

    // For testing only
    // Private_AssignChipToTable(shared_chips_for_team, ChipManager_DebugApplyProofOfConcept());

    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerBuildingMaxHealth(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerAmmoMetalRegen(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerMovementSpeed(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_PlayerJumpHeight(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryBuildingDamageIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryReloadSpeedIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryBuildingFireSpeedIncrease(max_team_size));
    Private_AssignChipToTable(shared_chips_for_team, ChipManager_WeaponPrimarySecondaryMaxAmmoMetalIncrease(max_team_size));
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

function CreatePlayerChip() /*-> Table<Constants.ETFClass,List<Table<String,ChipManager>>>*/ {
    local scout_only_chips_defaultloadout = {};
    Private_AssignChipToTable(scout_only_chips_defaultloadout, ChipManager_WeaponReplacementScoutSandman());
    Private_AssignChipToTable(scout_only_chips_defaultloadout, ChipManager_WeaponPrimaryMinicritsFromBehind());
    Private_AssignChipToTable(scout_only_chips_defaultloadout, ChipManager_WeaponMeleeCauseBleeding());
    Private_AssignChipToTable(scout_only_chips_defaultloadout, ChipManager_WeaponMeleeCauseMarkForDeath());
    Private_AssignChipToTable(scout_only_chips_defaultloadout, ChipManager_WeaponMeleeApplyAtomizerEffect());


    local soldier_only_chips_defaultloadout = {};
    Private_AssignChipToTable(soldier_only_chips_defaultloadout, ChipManager_WeaponReplacementSoldierDisciplinaryAction());
    Private_AssignChipToTable(soldier_only_chips_defaultloadout, ChipManager_WeaponPrimaryFasterRocketsWhenBlastJumping());
    Private_AssignChipToTable(soldier_only_chips_defaultloadout, ChipManager_WeaponMeleeApplyEqualizerEffect());


    local pyro_only_chips_shared = {};
    Private_AssignChipToTable(pyro_only_chips_shared, ChipManager_WeaponAnyIncreaseAfterburnDamageAndDuration());
    Private_AssignChipToTable(pyro_only_chips_shared, ChipManager_WeaponMeleeIgniteOnHit());
    local pyro_only_chips_defaultloadout = {};
    Private_AssignAllChipsToTable(pyro_only_chips_shared, pyro_only_chips_defaultloadout);
    Private_AssignChipToTable(pyro_only_chips_defaultloadout, ChipManager_WeaponPrimaryIncreaseFireRange());
    local pyro_only_chips_flaregun = {};
    Private_AssignAllChipsToTable(pyro_only_chips_shared, pyro_only_chips_flaregun);


    local demoman_only_chips_shared = {};
    Private_AssignChipToTable(demoman_only_chips_shared, ChipManager_WeaponMeleeMinicritsOnKill());
    Private_AssignChipToTable(demoman_only_chips_shared, ChipManager_WeaponReplacementDemomanScotsmansSkullcutter());
    local demoman_only_chips_defaultloadout = {};
    Private_AssignAllChipsToTable(demoman_only_chips_shared, demoman_only_chips_defaultloadout);
    local demoman_only_chips_pipebomb = {};
    Private_AssignAllChipsToTable(demoman_only_chips_shared, demoman_only_chips_pipebomb);
    Private_AssignChipToTable(demoman_only_chips_pipebomb, ChipManager_WeaponSecondaryReduceChargeTime());
    Private_AssignChipToTable(demoman_only_chips_pipebomb, ChipManager_WeaponSecondaryIncreaseMaxStickybombsOut());


    local heavyweapons_only_chips_defaultloadout = {};
    Private_AssignChipToTable(heavyweapons_only_chips_defaultloadout, ChipManager_WeaponPrimaryApplyHuoLongHeaterAttributes());
    Private_AssignChipToTable(heavyweapons_only_chips_defaultloadout, ChipManager_WeaponPrimaryIncreaseMoveSpeedWhileAiming());
    Private_AssignChipToTable(heavyweapons_only_chips_defaultloadout, ChipManager_WeaponPrimaryReduceSpinupTime());
    Private_AssignChipToTable(heavyweapons_only_chips_defaultloadout, ChipManager_WeaponMeleeMinicritsOnKill());
    Private_AssignChipToTable(heavyweapons_only_chips_defaultloadout, ChipManager_WeaponMeleeSpeedBoostOnHit());

    local engineer_only_chips_defaultloadout = {};
    Private_AssignChipToTable(engineer_only_chips_defaultloadout, ChipManager_WeaponReplacementEngineerFrontierJustice());
    Private_AssignChipToTable(engineer_only_chips_defaultloadout, ChipManager_WeaponPrimaryPickupWeaponsFromADistance());
    Private_AssignChipToTable(engineer_only_chips_defaultloadout, ChipManager_WeaponPda1IncreaseNumberOfDisposableSentries());
    Private_AssignChipToTable(engineer_only_chips_defaultloadout, ChipManager_WeaponPda1IncreaseSentryAndDispensorRange());
    Private_AssignChipToTable(engineer_only_chips_defaultloadout, ChipManager_WeaponPda1FasterSentryDeploy());
    Private_AssignChipToTable(engineer_only_chips_defaultloadout, ChipManager_WeaponMeleeCauseBleeding());

    local medic_only_chips_shared = {};
    Private_AssignChipToTable(medic_only_chips_shared, ChipManager_WeaponMeleeCauseBleeding());
    Private_AssignChipToTable(medic_only_chips_shared, ChipManager_WeaponMeleeVictimLosesMedigunChargeOnHit());
    Private_AssignChipToTable(medic_only_chips_shared, ChipManager_WeaponMeleeHitAllPlayerConnectedWithMedigun());
    local medic_only_chips_defaultloadout = {};
    Private_AssignAllChipsToTable(medic_only_chips_shared, medic_only_chips_defaultloadout);
    Private_AssignChipToTable(medic_only_chips_defaultloadout, ChipManager_WeaponPrimaryMadMilk());
    local medic_only_chips_crossbow = {};
    Private_AssignAllChipsToTable(medic_only_chips_shared, medic_only_chips_crossbow);


    local sniper_only_chips_shared = {};
    local sniper_only_chips_defaultloadout = {};
    Private_AssignAllChipsToTable(sniper_only_chips_shared, sniper_only_chips_defaultloadout);
    local sniper_only_chips_huntsman = {};
    Private_AssignAllChipsToTable(sniper_only_chips_shared, sniper_only_chips_huntsman);


    local spy_only_chips_defaultloadout = {};


    local player_chips = {};
    player_chips[Constants.ETFClass.TF_CLASS_SCOUT] <- [
        scout_only_chips_defaultloadout
    ];
    player_chips[Constants.ETFClass.TF_CLASS_SOLDIER] <- [
        soldier_only_chips_defaultloadout
    ];
    player_chips[Constants.ETFClass.TF_CLASS_PYRO] <- [
        pyro_only_chips_defaultloadout,
        pyro_only_chips_flaregun
    ];
    player_chips[Constants.ETFClass.TF_CLASS_DEMOMAN] <- [
        demoman_only_chips_defaultloadout,
        demoman_only_chips_pipebomb
    ];
    player_chips[Constants.ETFClass.TF_CLASS_HEAVYWEAPONS] <- [
        heavyweapons_only_chips_defaultloadout
    ];
    player_chips[Constants.ETFClass.TF_CLASS_ENGINEER] <- [
        engineer_only_chips_defaultloadout
    ];
    player_chips[Constants.ETFClass.TF_CLASS_MEDIC] <- [
        medic_only_chips_defaultloadout,
        medic_only_chips_crossbow
    ];
    player_chips[Constants.ETFClass.TF_CLASS_SNIPER] <- [
        sniper_only_chips_defaultloadout,
        sniper_only_chips_huntsman
    ];
    player_chips[Constants.ETFClass.TF_CLASS_SPY] <- [
        spy_only_chips_defaultloadout
    ];

    return player_chips;
}