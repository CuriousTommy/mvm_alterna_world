// Item Attributes (ex: "damage bonus"):
// https://wiki.teamfortress.com/wiki/List_of_item_attributes

const ATTRIBUTE_DURATION_FOREVER = -1;

IncludeScript("alterna_world_misc.nut");

function ApplyDefaultPlayerAttributes(/*CTFPlayer*/ player) {
    local player_name = NetProps.GetPropString(self, "m_szNetname");
    DebugPrintToConsole(format("Applying default attributes to %s", player_name));

    // Increase Max health for debugging
    player.AddCustomAttribute("max health additive bonus", 1000, ATTRIBUTE_DURATION_FOREVER);

    // For all classes


    // For specific classes
    switch (player.GetPlayerClass()) {
        case Constants.ETFClass.TF_CLASS_SCOUT:
            break;

        case Constants.ETFClass.TF_CLASS_SOLDIER:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        case Constants.ETFClass.TF_CLASS_PYRO:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        case Constants.ETFClass.TF_CLASS_DEMOMAN:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        case Constants.ETFClass.TF_CLASS_HEAVYWEAPONS:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        case Constants.ETFClass.TF_CLASS_ENGINEER:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        case Constants.ETFClass.TF_CLASS_MEDIC:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        case Constants.ETFClass.TF_CLASS_SNIPER:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        case Constants.ETFClass.TF_CLASS_SPY:
            player.AddCustomAttribute("parachute attribute", 1, ATTRIBUTE_DURATION_FOREVER);
            break;

        default:
            break;
    }
}