// This file will handle forcing a list of approved weapons onto the player

IncludeScript("alterna_world_constants.nut");
IncludeScript("alterna_world_misc.nut");

enum CustomLoadoutWeaponType {
    PRIMARY,
    SECONDARY,
    PDA1,
    PDA2,
    BUILD,
    MELEE
}

class CustomLoadout {
    primary_weapon = null;
    secondary_weapon = null;
    pda1_weapon = null;
    pda2_weapon = null;
    build_weapon = null;
    melee_weapon = null;

    constructor(primary_weapon, secondary_weapon,
        pda1_weapon, pda2_weapon, build_weapon,
        melee_weapon
    ) {
        this.primary_weapon = primary_weapon;
        this.secondary_weapon = secondary_weapon;
        this.pda1_weapon = pda1_weapon;
        this.pda2_weapon = pda2_weapon;
        this.build_weapon = build_weapon;
        this.melee_weapon = melee_weapon;
    }

    function ApplyWeaponsToPlayer(/*CTFPlayer*/ player) {
        if (primary_weapon != null) {
            primary_weapon.SetTeam(player.GetTeam())
            primary_weapon.DispatchSpawn();
            player.Weapon_Equip(primary_weapon);
        }

        if (secondary_weapon != null) {
            secondary_weapon.SetTeam(player.GetTeam())
            secondary_weapon.DispatchSpawn();
            player.Weapon_Equip(secondary_weapon);
        }

        if (pda1_weapon != null) {
            pda1_weapon.SetTeam(player.GetTeam())
            pda1_weapon.DispatchSpawn();
            player.Weapon_Equip(pda1_weapon);
        }

        if (pda2_weapon != null) {
            pda2_weapon.SetTeam(player.GetTeam())
            pda2_weapon.DispatchSpawn();
            player.Weapon_Equip(pda2_weapon);
        }

        if (build_weapon != null) {
            build_weapon.SetTeam(player.GetTeam())
            build_weapon.DispatchSpawn();
            player.Weapon_Equip(build_weapon);
        }

        if (melee_weapon != null) {
            melee_weapon.SetTeam(player.GetTeam())
            melee_weapon.DispatchSpawn();
            player.Weapon_Equip(melee_weapon);
        }
    }

    function SwitchToPrimarySecondaryOrMelee(/*CTFPlayer*/ player) {
        if (primary_weapon != null) {
            player.Weapon_Switch(primary_weapon);
        } else if (secondary_weapon != null) {
            player.Weapon_Switch(secondary_weapon);
        } else if (melee_weapon != null) {
            player.Weapon_Switch(melee_weapon);
        }

        // Otherwise do nothing
    }

    function ApplyChipUpgradeToWeapons(/*ChipManager*/ chip) {
        if (primary_weapon != null) {
            chip.ApplyAttributeToWeapon(primary_weapon, CustomLoadoutWeaponType.PRIMARY);
        }

        if (secondary_weapon != null) {
            chip.ApplyAttributeToWeapon(secondary_weapon, CustomLoadoutWeaponType.SECONDARY);
        }

        if (pda1_weapon != null) {
            chip.ApplyAttributeToWeapon(pda1_weapon, CustomLoadoutWeaponType.PDA1);
        }

        if (pda2_weapon != null) {
            chip.ApplyAttributeToWeapon(pda2_weapon, CustomLoadoutWeaponType.PDA2);
        }

        if (build_weapon != null) {
            chip.ApplyAttributeToWeapon(build_weapon, CustomLoadoutWeaponType.BUILD);
        }

        if (melee_weapon != null) {
            chip.ApplyAttributeToWeapon(melee_weapon, CustomLoadoutWeaponType.MELEE);
        }
    }
}

function CreateCustomLoadoutPrimaryAndMelee(primary_weapon, melee_weapon) /*-> CustomLoadout*/ {
    return CustomLoadout(
        primary_weapon, null, null, null, null, melee_weapon
    );
}

function CreateCustomLoadoutSecondaryAndMelee(secondary_weapon, melee_weapon) /*-> CustomLoadout*/ {
    return CustomLoadout(
        null, secondary_weapon, null, null, null, melee_weapon
    );
}

// The max number of weapons that can be equipped in TF2
const TF2_MAX_WEAPONS = 8;

// Intended to be used for removing the player's loadout weapons
function RemoveAllWeapons(/*CBasePlayer*/ cbaseplayer) {
    for (local weapon_index = 0; weapon_index < TF2_MAX_WEAPONS; weapon_index++) {
        local weapon = NetProps.GetPropEntityArray(cbaseplayer, "m_hMyWeapons", weapon_index)
        if (weapon == null) continue

        if (weapon instanceof CBaseEntity) {
            DebugPrintToConsole(format("Removing weapon %s", weapon.GetClassname()));

            weapon.Destroy();
            NetProps.SetPropEntityArray(cbaseplayer, "m_hMyWeapons", null, weapon_index);
        }
    }
}

// Create any weapon that is provided in the arguments
function CreateWeaponGeneric(/*String*/ weapon_classname, /*Integer*/ weapon_def_id) {
    local weapon = Entities.CreateByClassname(weapon_classname);
    NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", weapon_def_id);
    NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
    NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
    return weapon
}

const OBJ_DISPENSER = 0;
const OBJ_TELEPORTER = 1;
const OBJ_SENTRYGUN = 2;
const OBJ_ATTACHMENT_SAPPER = 3;

function Private_CreateWeaponTfWeaponBuilder(/*String*/ weapon_classname, /*Integer*/ weapon_def_id, /*Constants.ETFClass*/ class_id) {
    local weapon = Entities.CreateByClassname(weapon_classname);
    NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", weapon_def_id);
    NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
    NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
    NetProps.SetPropInt(weapon, "m_iObjectType", 0)
    NetProps.SetPropInt(weapon, "m_iObjectMode", 0)

    if (class_id == Constants.ETFClass.TF_CLASS_ENGINEER) {
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", true, OBJ_DISPENSER)
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", true, OBJ_TELEPORTER)
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", true, OBJ_SENTRYGUN)
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", false, OBJ_ATTACHMENT_SAPPER)

    } else if (class_id == Constants.ETFClass.TF_CLASS_SPY) {
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", false, OBJ_DISPENSER)
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", false, OBJ_TELEPORTER)
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", false, OBJ_SENTRYGUN)
        NetProps.SetPropBoolArray(weapon, "m_aBuildableObjectTypes", true, OBJ_ATTACHMENT_SAPPER)
    }

    return weapon
}

// Weapon IDs:
// https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes

function GenerateDefaultApprovedWeapons() /*-> Table<Constants.ETFTeam,List<Function>>*/ {


    local scout_loadout_default = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_scattergun", 13),
            CreateWeaponGeneric("tf_weapon_bat", 0)
        );
    }
    local approved_scout_loadouts = [
        scout_loadout_default
    ];


    local soldier_loadout_default = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_rocketlauncher", 18),
            CreateWeaponGeneric("tf_weapon_shovel", 6)
        );
    }
    local approved_soldier_loadouts = [
        soldier_loadout_default
    ];


    local pyro_loadout_default = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_flamethrower", 21)
            CreateWeaponGeneric("tf_weapon_fireaxe", 2)
        );
    }
    local pyro_loadout_flaregun = function() {
        return CreateCustomLoadoutSecondaryAndMelee(
            CreateWeaponGeneric("tf_weapon_flaregun", 740)
            CreateWeaponGeneric("tf_weapon_fireaxe", 2)
        );
    }
    local approved_pyro_loadouts = [
        pyro_loadout_default,
        pyro_loadout_flaregun
    ];


    local demoman_loadout_default = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_grenadelauncher", 19),
            CreateWeaponGeneric("tf_weapon_bottle", 1)
        );
    }
    local demoman_loadout_stickybomb = function() {
        return CreateCustomLoadoutSecondaryAndMelee(
            CreateWeaponGeneric("tf_weapon_pipebomblauncher", 20),
            CreateWeaponGeneric("tf_weapon_bottle", 1)
        );
    }
    local approved_demoman_loadouts = [
        demoman_loadout_default,
        demoman_loadout_stickybomb
    ];


    local heavy_loadout_default = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_minigun", 15),
            CreateWeaponGeneric("tf_weapon_fists", 5)
        );
    }
    local approved_heavy_loadouts = [
        heavy_loadout_default
    ];


    local engineer_loadout_default = function() {
        // Create weapons
        local loadouts = CustomLoadout(
            CreateWeaponGeneric("tf_weapon_shotgun_primary", 9),
            null,
            CreateWeaponGeneric("tf_weapon_pda_engineer_build", 25),
            CreateWeaponGeneric("tf_weapon_pda_engineer_destroy", 26),
            Private_CreateWeaponTfWeaponBuilder("tf_weapon_builder", 28, Constants.ETFClass.TF_CLASS_ENGINEER),
            CreateWeaponGeneric("tf_weapon_wrench", 7)
        );

        // Apply default weapon attributes that we don't plan to change
        loadouts.melee_weapon.AddAttribute("mod wrench builds minisentry", 1, ATTRIBUTE_DURATION_FOREVER);

        return loadouts;
    }
    local approved_engineer_loadouts = [
        engineer_loadout_default
    ];


    local medic_loadout_default = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_syringegun_medic", 17),
            CreateWeaponGeneric("tf_weapon_bonesaw", 8)
        );
    }
    local medic_loadout_crossbow = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_crossbow", 305),
            CreateWeaponGeneric("tf_weapon_bonesaw", 8)
        );
    }
    local approved_medic_loadouts = [
        medic_loadout_default,
        medic_loadout_crossbow
    ];


    local sniper_loadout_default = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_sniperrifle", 14),
            CreateWeaponGeneric("tf_weapon_club", 3)
        );
    }
    local sniper_loadout_huntsman = function() {
        return CreateCustomLoadoutPrimaryAndMelee(
            CreateWeaponGeneric("tf_weapon_compound_bow", 56),
            CreateWeaponGeneric("tf_weapon_club", 3)
        );
    }
    local approved_sniper_loadouts = [
        sniper_loadout_default,
        sniper_loadout_huntsman
    ];


    local spy_loadout_default = function() {
        return CustomLoadout(
            null,
            CreateWeaponGeneric("tf_weapon_revolver", 24),
            null,
            CreateWeaponGeneric("tf_weapon_invis", 30),
            null,
            CreateWeaponGeneric("tf_weapon_knife", 4)
        );
    }
    local approved_spy_loadouts = [
        spy_loadout_default
    ];

    local all_approved_weapons = {}
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SCOUT]        <- approved_scout_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SOLDIER]      <- approved_soldier_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_PYRO]         <- approved_pyro_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_DEMOMAN]      <- approved_demoman_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_HEAVYWEAPONS] <- approved_heavy_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_ENGINEER]     <- approved_engineer_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_MEDIC]        <- approved_medic_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SNIPER]       <- approved_sniper_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SPY]          <- approved_spy_loadouts;

    return all_approved_weapons;
}
