/**
 * No Block Plugin
 * Allows players to pass through each other and optionally disables collision for nades.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define PLUGIN_NAME "No Block"
#define PLUGIN_VERSION "1.0.4"

#define COLLISION_GROUP_NONE 0
#define COLLISION_GROUP_PLAYER 5
#define COLLISION_GROUP_WEAPON 11
#define COLLISION_GROUP_PROJECTILE 2
#define COLLISION_GROUP_PASSABLE 8

public Plugin myinfo = 
{
    name = PLUGIN_NAME,
    author = "camthegeek",
    description = "Allows players to pass through each other and optionally disables collision for nades.",
    version = PLUGIN_VERSION,
    url = "https://github.com/camthegeek/cssource_noblock"
};

ConVar g_CvarNoBlock;
ConVar g_CvarNoBlockNades;

public void OnPluginStart()
{
    g_CvarNoBlock = CreateConVar("sm_noblock", "1", "Enable/Disable player no block", FCVAR_NOTIFY);
    g_CvarNoBlockNades = CreateConVar("sm_noblock_nades", "1", "Enable/Disable nade no block", FCVAR_NOTIFY);
    
    HookConVarChange(g_CvarNoBlock, OnNoBlockChanged);
    HookConVarChange(g_CvarNoBlockNades, OnNoBlockNadesChanged);
    
    LogMessage("Plugin %s v%s loaded", PLUGIN_NAME, PLUGIN_VERSION);
    
    // Hook all existing clients
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            OnClientPutInServer(i);
        }
    }
    
    if (g_CvarNoBlock.BoolValue)
    {
        EnableNoBlock();
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_SpawnPost, OnPlayerSpawnPost);
}

public void OnPlayerSpawnPost(int client)
{
    if (g_CvarNoBlock.BoolValue && IsValidClient(client))
    {
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 2);
    }
}

public void OnNoBlockChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    if (StrEqual(newValue, "1"))
    {
        EnableNoBlock();
    }
    else
    {
        DisableNoBlock();
    }
}

public void OnNoBlockNadesChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    if (StrEqual(newValue, "1"))
    {
        EnableNoBlockNades();
    }
    else
    {
        DisableNoBlockNades();
    }
}

void EnableNoBlock()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            SetEntProp(i, Prop_Data, "m_CollisionGroup", 2);
        }
    }
}

void DisableNoBlock()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            SetEntProp(i, Prop_Data, "m_CollisionGroup", 5);
        }
    }
}

void EnableNoBlockNades()
{
    int entity = -1;
    char classnames[][] = {
        "hegrenade_projectile",
        "flashbang_projectile",
        "smokegrenade_projectile"
    };
    
    for (int i = 0; i < sizeof(classnames); i++)
    {
        while ((entity = FindEntityByClassname(entity, classnames[i])) != -1)
        {
            SetEntProp(entity, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PASSABLE);
            SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
            SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
        }
    }
}

void DisableNoBlockNades()
{
    int entity = -1;
    char classnames[][] = {
        "hegrenade_projectile",
        "flashbang_projectile",
        "smokegrenade_projectile"
    };
    
    for (int i = 0; i < sizeof(classnames); i++)
    {
        while ((entity = FindEntityByClassname(entity, classnames[i])) != -1)
        {
            SetEntProp(entity, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_NONE);
            SetEntProp(entity, Prop_Send, "m_usSolidFlags", 0);
            SetEntProp(entity, Prop_Send, "m_nSolidType", 2); // SOLID_BBOX
        }
    }
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (!g_CvarNoBlockNades.BoolValue)
        return;
        
    if (StrEqual(classname, "hegrenade_projectile") ||
        StrEqual(classname, "flashbang_projectile") ||
        StrEqual(classname, "smokegrenade_projectile"))
    {
        SDKHook(entity, SDKHook_Spawn, OnNadeSpawn);
        SDKHook(entity, SDKHook_SpawnPost, OnNadeSpawnPost);
    }
}

public Action OnNadeSpawn(int entity)
{
    if (!IsValidEntity(entity))
        return Plugin_Continue;

    SetEntProp(entity, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PASSABLE);
    SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4); // FSOLID_NOT_SOLID
    SetEntProp(entity, Prop_Send, "m_nSolidType", 0);   // SOLID_NONE
    
    return Plugin_Continue;
}

public void OnNadeSpawnPost(int entity)
{
    if (!IsValidEntity(entity))
        return;

    SetEntProp(entity, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PASSABLE);
    SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4); // FSOLID_NOT_SOLID
    SetEntProp(entity, Prop_Send, "m_nSolidType", 0);   // SOLID_NONE
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}