#define PLUGIN_AUTHOR "Lawyn"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

public Plugin myinfo = 
{
	name = "[NEVERGO] Hours",
	author = PLUGIN_AUTHOR,
	description = "Hours count plugin by Lawyn#5015",
	version = PLUGIN_VERSION,
	url = "https://nevergo.ro"
};

#define DB_NAME "hours"
#define DB_TABLE "hours_table"
#define PREFIX " \x01[SM] \x01"

new DB;

int g_iOre[MAXPLAYERS + 1];
int g_iMinute[MAXPLAYERS + 1];
int g_iSecunde[MAXPLAYERS + 1];

public void OnPluginStart()
{
	CreateTimer(1.0, oretimer, _, TIMER_REPEAT);
	ConnectDB();
	CreateConVar( "sm_hours_enable", "1", "Enable or disable hours plugin", FCVAR_PLUGIN );
	CreateConVar( "sm_hours_menu", "0", "Set 0 for display hours in chat or 1 to display into a menu", FCVAR_PLUGIN );
	RegConsoleCmd("sm_hours", Command_hours); // ENG Version
	RegConsoleCmd("sm_ore", Command_hours); // RO Version
}

public Action Command_hours(int client, int args)
{
	if(IsPluginEnabled())
	{
		if(!IsMenuEnabled())
		{
			if(args == 0)
			{
				PrintToChat(client, "%s You have \x09%i \x01%s, \x09%i \x01minute%s and \x09%i \x01second%s played on this server!", PREFIX, GetDBOre(client), (GetDBOre(client) == 1) ? "hour":"hours", GetDBMin(client), (GetDBMin(client) == 1)?"":"s", GetDBSec(client), (GetDBSec(client) == 1)?"":"s");
			}
			else if(args == 1)
			{
				char arg1[64];
				GetCmdArg(1, arg1, sizeof(arg1));
				int target = FindTarget(client, arg1, true, false);
				if(target == -1)
				{
					PrintToChat(client, "%s Target is not available!", PREFIX);
					return Plugin_Handled;
				}
				PrintToChat(client, "%s You have \x09%i \x01%s, \x09%i \x01minute%s and \x09%i \x01second%s played on this server!", PREFIX, GetDBOre(target), (GetDBOre(target) == 1) ? "hour":"hours", GetDBMin(target), (GetDBMin(target) == 1)?"":"s", GetDBSec(target), (GetDBSec(target) == 1)?"":"s");
			}
			else
			{
				PrintToChat(client, "%s Use: \x09sm_hours <client>", PREFIX);
			}
		}
		else
		{
			char orefm[256], minfm[256], secfm[256];
			if(args == 0)
			{
				Format(orefm, sizeof(orefm), "Hours played: %i", GetDBOre(client));
				Format(minfm, sizeof(minfm), "Minutes played: %i", GetDBMin(client));
				Format(secfm, sizeof(secfm), "Seconds played: %i", GetDBSec(client));
				Menu menu = new Menu(menu_ore);
				menu.SetTitle("Played time");
				menu.AddItem("", orefm, ITEMDRAW_DISABLED);
				menu.AddItem("", minfm, ITEMDRAW_DISABLED);
				menu.AddItem("", secfm, ITEMDRAW_DISABLED);
				menu.Display(client, MENU_TIME_FOREVER);
			}
			else if(args == 1)
			{
				char arg1[64];
				GetCmdArg(1, arg1, sizeof(arg1));
				int target = FindTarget(client, arg1, true, false);
				if(target == -1)
				{
					PrintToChat(client, "%s Target is not available!", PREFIX);
					return Plugin_Handled;
				}
				Format(orefm, sizeof(orefm), "Hours played: %i", GetDBOre(client));
				Format(minfm, sizeof(minfm), "Minutes played: %i", GetDBMin(client));
				Format(secfm, sizeof(secfm), "Seconds played: %i", GetDBSec(client));
				Menu menu = new Menu(menu_ore);
				menu.SetTitle("%N Played time", target);
				menu.AddItem("", orefm, ITEMDRAW_DISABLED);
				menu.AddItem("", minfm, ITEMDRAW_DISABLED);
				menu.AddItem("", secfm, ITEMDRAW_DISABLED);
				menu.Display(client, MENU_TIME_FOREVER);
			}
			else
			{
				PrintToChat(client, "%s Use: \x09sm_hours <client>", PREFIX);
			}
		}
	}
	else
	{
		PrintToChat(client, "%s Plugin is disabled!", PREFIX);
	}
}

public int menu_ore(Menu menu, MenuAction action, int client, int pos)
{
	switch (action) { case MenuAction_End: { delete menu; } }
}

public Action oretimer(Handle timer)
{
	if(IsPluginEnabled())
	{
		for (new i = 1; i < MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				g_iSecunde[i] += 1;
				if(g_iSecunde[i] >= 60)
				{
					g_iSecunde[i] = 0;
					g_iMinute[i] += 1;
				}
				if(g_iMinute[i] >= 60)
				{
					g_iMinute[i] = 0;
					g_iOre[i] += 1;
				}
				WriteDB(i, g_iOre[i], g_iMinute[i], g_iSecunde[i])
			}
		}
	}
}

void WriteDB(int client, int ore, int minute, int secunde)
{
	char steamid[64];
	char nick[MAX_NAME_LENGTH];
	GetClientAuthString(client, steamid, sizeof(steamid));
	GetClientName(client, nick, sizeof(nick));
	new String:query[256];
	Format(query, sizeof(query), "SELECT steamid FROM %s WHERE steamid='%s'", DB_TABLE, steamid) 
	new Handle:hQuery = SQL_Query(DB, query); 
	if(hQuery != INVALID_HANDLE)
	{
		if(!SQL_FetchRow(hQuery))
		{
			Format(query, sizeof(query), "INSERT INTO %s(name, steamid, ore, minute, secunde) VALUES('%s', '%s', '%i', '%i', '%i')", DB_TABLE, nick, steamid, ore, minute, secunde);
			hQuery = SQL_Query(DB, query);
		}
		else
		{
			Format(query, sizeof(query), "UPDATE %s SET ore='%i', minute='%i', secunde='%i' WHERE steamid='%s'", DB_TABLE, ore, minute, secunde, steamid);
			hQuery = SQL_Query(DB, query);
		}
	}
}

int GetDBOre(int client)
{
	char steamid[64];
	GetClientAuthString(client, steamid, sizeof(steamid));
	char qwe[256];
	Format(qwe, sizeof(qwe), "SELECT ore FROM %s WHERE steamid='%s'", DB_TABLE, steamid);
	Handle asd = SQL_Query(DB, qwe);
	if(asd != INVALID_HANDLE)
	{
		if(SQL_FetchRow(asd))
		{
			int ore = SQL_FetchInt(asd, 0);
			return ore;
		}
	}
	return -1;
}

int GetDBMin(int client)
{
	char steamid[64];
	GetClientAuthString(client, steamid, sizeof(steamid));
	char qwe[256];
	Format(qwe, sizeof(qwe), "SELECT minute FROM %s WHERE steamid='%s'", DB_TABLE, steamid);
	Handle asd = SQL_Query(DB, qwe);
	if(asd != INVALID_HANDLE)
	{
		if(SQL_FetchRow(asd))
		{
			int min = SQL_FetchInt(asd, 0);
			return min;
		}
	}
	return -1;
}
int GetDBSec(int client)
{
	char steamid[64];
	GetClientAuthString(client, steamid, sizeof(steamid));
	char qwe[256];
	Format(qwe, sizeof(qwe), "SELECT secunde FROM %s WHERE steamid='%s'", DB_TABLE, steamid);
	Handle asd = SQL_Query(DB, qwe);
	if(asd != INVALID_HANDLE)
	{
		if(SQL_FetchRow(asd))
		{
			int sec = SQL_FetchInt(asd, 0);
			return sec
		}
	}
	return -1;
}

void ConnectDB()
{
	new String:error[128];
	DB = SQL_Connect(DB_NAME, true, error, sizeof(error));
	if(DB == INVALID_HANDLE) 
	{
		PrintToServer("Connection to database %s error: %s", DB_NAME, error);
		CloseHandle(DB);
	}
	else 
	{
		PrintToServer("Connection successfully to %s database", DB_NAME);
		char connstring[256];
		Format(connstring, sizeof(connstring), "CREATE TABLE IF NOT EXISTS %s (name TEXT, steamid TEXT, ore INTEGER, minute INTEGER, secunde INTEGER);", DB_TABLE);
		new quer = SQL_FastQuery(DB, connstring); 
		if(quer == false)
		{
			new String:error[256];
			SQL_GetError(quer, error, sizeof(error));
			PrintToServer("Problem with %s table: %s", DB_TABLE, error)
		}
	}
}

bool IsMenuEnabled()
{
	if(GetConVarInt(FindConVar("sm_hours_menu")) == 1)
	{
		return true;
	}
	return false;
}

bool IsPluginEnabled()
{
	if(GetConVarInt(FindConVar("sm_hours_enable")) == 1)
	{
		return true;
	}
	return false;
}
