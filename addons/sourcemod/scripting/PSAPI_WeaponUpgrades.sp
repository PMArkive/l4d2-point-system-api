

#include <ps_api>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
	name        = "Weapon Upgrades Module --> Point System API",
	author      = "Eyal282",
	description = "Explosive ammo and etc.",
	version     = PLUGIN_VERSION,
	url         = ""
};

ConVar g_cvExplosiveAmmoCost;
ConVar g_cvIncendiaryAmmoCost;
ConVar g_cvLaserPointerCost;

public void OnPluginStart()
{
	AutoExecConfig_SetFile("PointSystemAPI_WeaponUpgrades");

	g_cvExplosiveAmmoCost  = AutoExecConfig_CreateConVar("l4d2_points_exammo_cost", "8");
	g_cvIncendiaryAmmoCost = AutoExecConfig_CreateConVar("l4d2_points_incammo_cost", "5");
	g_cvLaserPointerCost   = AutoExecConfig_CreateConVar("l4d2_points_laser_pointer_cost", "0");

	CreateProducts();

	// This makes an internal call to AutoExecConfig with the given configfile
	AutoExecConfig_ExecuteFile();

	// Cleaning should be done at the end
	AutoExecConfig_CleanFile();
}

public void OnConfigsExecuted()
{
	CreateProducts();
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "PointSystemAPI"))
	{
		CreateProducts();
	}
}

// This forward should be used to give the product to a target player. This is after the delay, and after not refunding the product. Called instantly after PointSystemAPI_OnBuyProductPost
// sAliases contain the original alias list, to compare your own alias as an identifier.
public Action PointSystemAPI_OnShouldGiveProduct(int buyer, const char[] sInfo, const char[] sAliases, const char[] sName, int target, float fCost, float fDelay, float fCooldown)
{
	if (strncmp(sInfo, "upgrade_add", 11) == 0)
	{
		PSAPI_ExecuteCheatCommand(target, sInfo);
	}

	return Plugin_Continue;
}

public void CreateProducts()
{
	int iCategory = PSAPI_CreateCategory(-1, "weapon upgrades", "Weapon Upgrades", BUYFLAG_SURVIVOR | BUYFLAG_ALIVE);

	PSAPI_CreateProduct(iCategory, GetConVarFloat(g_cvExplosiveAmmoCost), "Explosive Ammo", "Bullets stagger all Infected but the Tank", "exammo expammo", "upgrade_add EXPLOSIVE_AMMO", 0.0, 0.0,
	                    BUYFLAG_SURVIVOR | BUYFLAG_ALIVE | BUYFLAG_PINNED | BUYFLAG_TEAM);

	PSAPI_CreateProduct(iCategory, GetConVarFloat(g_cvIncendiaryAmmoCost), "Incendiary Ammo", "Bullets set Infected on fire", "incammo inammo fireammo", "upgrade_add INCENDIARY_AMMO", 0.0, 0.0,
	                    BUYFLAG_SURVIVOR | BUYFLAG_ALIVE | BUYFLAG_PINNED | BUYFLAG_BOTTEAM);

	PSAPI_CreateProduct(iCategory, GetConVarFloat(g_cvLaserPointerCost), "Laser Sight", "Makes your weapon more accurate", "laser", "upgrade_add LASER_SIGHT", 0.0, 0.0,
	                    BUYFLAG_SURVIVOR | BUYFLAG_ALIVE | BUYFLAG_PINNED | BUYFLAG_BOTTEAM);
}

stock void SetPlayerAlive(int client, bool alive)
{
	if (alive) SetEntProp(client, Prop_Data, "m_isAlive", alive);
}

stock bool IsPlayerGhost(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isGhost"));
}

stock void SetPlayerGhost(int client, bool ghost)
{
	SetEntProp(client, Prop_Send, "m_isGhost", ghost);
}

stock void SetPlayerLifeState(int client, bool ready)
{
	SetEntProp(client, Prop_Send, "m_lifeState", ready);
}

stock int GetEntityHealth(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iHealth");
}
stock int GetEntityMaxHealth(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_iMaxHealth");
}

stock void HealEntity(int entity, int amount)
{
	SetEntityHealth(entity, GetEntityHealth(entity) + amount);

	if (GetEntityHealth(entity) > GetEntityMaxHealth(entity))
		SetEntityHealth(entity, GetEntityMaxHealth(entity));
}