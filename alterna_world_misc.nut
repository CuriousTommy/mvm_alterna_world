function DebugPrintToConsole(/*String*/ msg) {
    ClientPrint(null, Constants.EHudNotify.HUD_PRINTCONSOLE, msg);
}

function PrintToChatWindow(/*CBasePlayer*/ player, /*String*/ msg) {
    ClientPrint(player, Constants.EHudNotify.HUD_PRINTTALK, msg);
}