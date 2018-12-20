#include <sourcemod>
#include <colorvariables>

public Plugin info = {
    name="WarnPlugin",
    author="Olle Thunberg",
	description = "Warn a player and add it to the database.",
	version = "1.0",
	url = "http://www.sourcemod.net/"
}
ConVar sm_use_sql = null;

public void OnPluginStart(){

    sm_use_sql = CreateConVar("sm_use_sql", "0", "Is the plugin using SQL? IT SHOULD NOT UNLESS CONFIGURED SPECIAL.");

    CSetPrefix("SmWarn"); // Set plugin chat prefix to "KillInfo" (will be used in every print function)
    RegAdminCmd("sm_warn", sm_warn, ADMFLAG_KICK);
    PrintToServer("Warn plugin running..");
    AutoExecConfig(true, "SmWarn");


}

public Action:sm_warn(int client, int args){

    char arg1[128], arg2[128];
    char query[255];
    char warned[64];

    GetCmdArg(1, arg1, sizeof(arg1));
    GetCmdArg(2, arg2, sizeof(arg2));


    int warnedTarget = FindTarget(client, arg1);
    
    if(warnedTarget == -1){
        ReplyToCommand(client, "Couldn't find the user. Did you type correctly?");
        return Plugin_Handled;
    }
    
    GetClientAuthString(warnedTarget, warned, 255);

    ReplaceString(warned, 255, "_1:", "_0:");
    CPrintToChat(warnedTarget, "{red}You recieved a {gold}WARNING {red}: {darkblue}%s , after 3 warnings you will get banned.", arg2); 
    CPrintToChat(client, "{red}Warning sent!");

    int useSQL = GetConVarInt(sm_use_sql);
    if(useSQL == 0){
        return Plugin_Handled;
    }else {
        Format(query, sizeof(query), "UPDATE users SET warnings = warnings + 1 WHERE steamid = '%s'", warned);

        new String:Error[255];
        new Handle:db = SQL_DefConnect(Error, sizeof(Error));
        
        if(db == null){
            PrintToServer("Failed to connect to database: %s", Error);
        }else {
            if(!SQL_FastQuery(db, query)){
                char error[255];
                SQL_GetError(db, error, sizeof(error));
                PrintToServer("Failed to query (error: %s)", error);
            }
        }
    }
    
    return Plugin_Handled;

}