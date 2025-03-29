
function DebugPrintToConsole(msg) {
    ClientPrint(null, Constants.EHudNotify.HUD_PRINTCONSOLE, msg);
}

const MAX_WEAPONS = 9;

function RemoveAllWeapons(cbaseplayer) {
    for (local weapon_index = 0; weapon_index < MAX_WEAPONS; weapon_index++) {
        local weapon = NetProps.GetPropEntityArray(cbaseplayer, "m_hMyWeapons", weapon_index)
        if (weapon == null) continue

        if (weapon instanceof CBaseEntity) {
            DebugPrintToConsole(format("Removing weapon %s", weapon.GetClassname()));

            weapon.Destroy();
            NetProps.SetPropEntityArray(cbaseplayer, "m_hMyWeapons", null, weapon_index);
        }
    }
}

function CreateApprovedWeaponGeneric(ctfplayer, weapon_classname, weapon_def_id) {
    local weapon = Entities.CreateByClassname(weapon_classname);
    NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", weapon_def_id);
    NetProps.SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
    NetProps.SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
    weapon.SetTeam(ctfplayer.GetTeam())
    return weapon
}

// All classes with have their stock weapons
function AssignApprovedWeapons(ctfplayer) {
    local weapon_list = [];

    if (ctfplayer.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SCOUT) {
        local primary_weapon = CreateApprovedWeaponGeneric(ctfplayer, "tf_weapon_scattergun", 13); // 808
        local melee_weapon = CreateApprovedWeaponGeneric(ctfplayer, "tf_weapon_bat", 0); // 30667

        weapon_list.append(primary_weapon);
        weapon_list.append(melee_weapon);
    } else if (ctfplayer.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER) {
        local primary_weapon = CreateApprovedWeaponGeneric(ctfplayer, "tf_weapon_shotgun_primary", 9);
        // local pda_create = CreateApprovedWeaponGeneric(ctfplayer, "tf_weapon_pda_engineer_build", 25);
        // local pda_destroy = CreateApprovedWeaponGeneric(ctfplayer, "tf_weapon_pda_engineer_destroy", 26);
        local melee_weapon = CreateApprovedWeaponGeneric(ctfplayer, "tf_weapon_wrench", 7);

        weapon_list.append(primary_weapon);
        // weapon_list.append(pda_create);
        // weapon_list.append(pda_destroy);
        weapon_list.append(melee_weapon);
    }

    if (weapon_list.len() > 0) {
        for (local weapon_index = 0; weapon_index < weapon_list.len(); weapon_index++) {
            local current_weapon = weapon_list[weapon_index];
            DebugPrintToConsole(format("Equiping weapon %s", current_weapon.GetClassname()));

            current_weapon.DispatchSpawn()
            ctfplayer.Weapon_Equip(current_weapon);
        }

        // The first weapon in the list will
        ctfplayer.Weapon_Switch(weapon_list[0]);
    }
}

const ATTRIBUTE_DURATION_FOREVER = -1;

function ApplyChipUpgrades(ctfplayer) {
    for (local weapon_index = 0; weapon_index < MAX_WEAPONS; weapon_index++) {
        local weapon = NetProps.GetPropEntityArray(ctfplayer, "m_hMyWeapons", weapon_index)
        if (weapon == null) continue

        if (weapon instanceof CBaseEntity) {
            weapon.AddAttribute("damage bonus", 5, ATTRIBUTE_DURATION_FOREVER)
        }
    }
}

function Setup() {
    local MAX_PLAYERS_ALLOWED = MaxClients().tointeger();
    for (local player_index = 1; player_index <= MAX_PLAYERS_ALLOWED; player_index++) {
        local cbaseplayer = PlayerInstanceFromIndex(player_index);
        if (cbaseplayer == null) continue

        if (cbaseplayer instanceof CTFPlayer) {
            if (!cbaseplayer.IsBotOfType(Constants.EBotType.TF_BOT_TYPE)) {
                local player_name = NetProps.GetPropString(cbaseplayer, "m_szNetname")
                DebugPrintToConsole(format("Found non-AI player %s", player_name));

                RemoveAllWeapons(cbaseplayer);
                AssignApprovedWeapons(cbaseplayer);
                ApplyChipUpgrades(cbaseplayer)
            }
        }
    }
}

Setup();
