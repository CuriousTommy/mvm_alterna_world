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
function Private_CreateWeaponGeneric(ctfplayer, weapon_classname, weapon_def_id) {
    local weapon = Entities.CreateByClassname(weapon_classname);
    NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", weapon_def_id);
    NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
    NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
    weapon.SetTeam(ctfplayer.GetTeam())
    return weapon
}

function Private_CreateApprovedWeapons( /*CTFPlayer*/ ctfplayer, /*Array<CEconEntity>*/ weapon_list) {
    if (ctfplayer.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SCOUT) {
        local primary_weapon = Private_CreateWeaponGeneric(ctfplayer, "tf_weapon_scattergun", 13);
        local melee_weapon = Private_CreateWeaponGeneric(ctfplayer, "tf_weapon_bat", 0);

        weapon_list.append(primary_weapon);
        weapon_list.append(melee_weapon);
    } else if (ctfplayer.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER) {
        local primary_weapon = Private_CreateWeaponGeneric(ctfplayer, "tf_weapon_shotgun_primary", 9);
        local pda_create = Private_CreateWeaponGeneric(ctfplayer, "tf_weapon_pda_engineer_build", 25);
        local pda_destroy = Private_CreateWeaponGeneric(ctfplayer, "tf_weapon_pda_engineer_destroy", 26);
        local melee_weapon = Private_CreateWeaponGeneric(ctfplayer, "tf_weapon_wrench", 7);

        // melee_weapon.AddAttribute("mod wrench builds minisentry", 1, -1);

        weapon_list.append(primary_weapon);
        weapon_list.append(pda_create);
        weapon_list.append(pda_destroy);
        weapon_list.append(melee_weapon);
    }
}

// All classes will be forced to their stock weapons
function AssignApprovedWeapons(/*CTFPlayer*/ ctfplayer) {
    local weapon_list = [];

    Private_CreateApprovedWeapons(ctfplayer, weapon_list);

    if (weapon_list.len() > 0) {
        for (local weapon_index = 0; weapon_index < weapon_list.len(); weapon_index++) {
            local current_weapon = weapon_list[weapon_index];
            DebugPrintToConsole(format("Equiping weapon %s", current_weapon.GetClassname()));

            current_weapon.DispatchSpawn()
            ctfplayer.Weapon_Equip(current_weapon);
        }

        // Always switch to the first weapon in the list
        ctfplayer.Weapon_Switch(weapon_list[0]);
    }
}

function ApplyChipUpgradeToWeapon(/*CBasePlayer*/ cbaseplayer, /*String*/ player_name, /*Table<String,ChipManager>*/ chips) {
    for (local weapon_index = 0; weapon_index < TF2_MAX_WEAPONS; weapon_index++) {
        local weapon = NetProps.GetPropEntityArray(cbaseplayer, "m_hMyWeapons", weapon_index)
        if (weapon == null) continue

        if (weapon instanceof CEconEntity) {
            DebugPrintToConsole(format("Applying chip upgrades to %s's %s", player_name, weapon.GetClassname()));
            foreach (chip in chips) {
                chip.ApplyAttributeToWeapon(weapon);
            }
        }
    }
}