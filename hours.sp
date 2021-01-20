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
		
	}
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
