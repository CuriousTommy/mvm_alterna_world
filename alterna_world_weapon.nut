// This file will handle forcing a list of approved weapons onto the player

IncludeScript("alterna_world_misc.nut");

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
function Private_CreateWeaponGeneric(/*String*/ weapon_classname, /*Integer*/ weapon_def_id) {
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

function GenerateApprovedWeapons() /*-> Table<Constants.ETFTeam,List<Function>>*/ {


    local scout_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_scattergun", 13),
            Private_CreateWeaponGeneric("tf_weapon_bat", 0)
        ];
    }
    local approved_scout_loadouts = [
        scout_loadout_default
    ];


    local solider_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_rocketlauncher", 18)
            Private_CreateWeaponGeneric("tf_weapon_shovel", 6)
        ];
    }
    local approved_solider_loadouts = [
        solider_loadout_default
    ];


    local pyro_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_flamethrower", 21)
            Private_CreateWeaponGeneric("tf_weapon_fireaxe", 2)
        ];
    }
    local pyro_loadout_dragonsfury = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_rocketlauncher_fireball", 1178)
            Private_CreateWeaponGeneric("tf_weapon_fireaxe", 2)
        ];
    }
    local approved_pyro_loadouts = [
        pyro_loadout_default,
        pyro_loadout_dragonsfury
    ];


    local demoman_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_grenadelauncher", 19),
            Private_CreateWeaponGeneric("tf_weapon_bottle", 1)
        ];
    }
    local demoman_loadout_stickybomb = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_pipebomblauncher", 20),
            Private_CreateWeaponGeneric("tf_weapon_bottle", 1)
        ];
    }
    local approved_demoman_loadouts = [
        demoman_loadout_default,
        demoman_loadout_stickybomb
    ];


    local heavy_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_minigun", 15),
            Private_CreateWeaponGeneric("tf_weapon_fists", 5)
        ];
    }
    local approved_heavy_loadouts = [
        heavy_loadout_default
    ];


    local engineer_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_shotgun_primary", 9),
            Private_CreateWeaponGeneric("tf_weapon_pda_engineer_build", 25),
            Private_CreateWeaponGeneric("tf_weapon_pda_engineer_destroy", 26),
            Private_CreateWeaponTfWeaponBuilder("tf_weapon_builder", 28, Constants.ETFClass.TF_CLASS_ENGINEER),
            Private_CreateWeaponGeneric("tf_weapon_wrench", 7)
        ];
    }
    local approved_engineer_loadouts = [
        engineer_loadout_default
    ];


    local medic_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_syringegun_medic", 17),
            Private_CreateWeaponGeneric("tf_weapon_bonesaw", 8),
        ];
    }
    local medic_loadout_crossbow = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_crossbow", 305),
            Private_CreateWeaponGeneric("tf_weapon_bonesaw", 8),
        ];
    }
    local approved_medic_loadouts = [
        medic_loadout_default,
        medic_loadout_crossbow
    ];


    local sniper_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_sniperrifle", 14),
            Private_CreateWeaponGeneric("tf_weapon_club", 3),
        ];
    }
    local approved_sniper_loadouts = [
        sniper_loadout_default
    ];


    local spy_loadout_default = function() {
        return [
            Private_CreateWeaponGeneric("tf_weapon_revolver", 24),
            Private_CreateWeaponGeneric("tf_weapon_invis", 30),
            Private_CreateWeaponGeneric("tf_weapon_knife", 4),
        ];
    }
    local approved_spy_loadouts = [
        spy_loadout_default
    ];

    local all_approved_weapons = {}
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SCOUT] <- approved_scout_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SOLDIER] <- approved_solider_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_PYRO] <- approved_pyro_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_DEMOMAN] <- approved_demoman_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_HEAVYWEAPONS] <- approved_heavy_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_ENGINEER] <- approved_engineer_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_MEDIC] <- approved_medic_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SNIPER] <- approved_sniper_loadouts;
    all_approved_weapons[Constants.ETFClass.TF_CLASS_SPY] <- approved_spy_loadouts;

    return all_approved_weapons;
}
