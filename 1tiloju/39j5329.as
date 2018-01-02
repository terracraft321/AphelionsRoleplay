/* 39j5329.as
 * author: Aphelion
 */

#include "1oltmot.as";

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	// ORB LIGHT
	this.SetLight( true );
    this.SetLightRadius( 72.0f );
    this.SetLightColor(SColor(255, 65, 73, 240));
	
	// TRADE
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 2));
	this.set_string("shop description", "Trade");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Scroll of Harvest", "$scroll_harvest$", "scroll_harvest", "Transports nearby farming goods into a single pile");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_HARVEST_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of the Guardian", "$scroll_guardian$", "scroll_guardian", "Heals nearby allies");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_GUARDIAN_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of Light", "$scroll_light$", "scroll_light", "Transforms nearby corpses into your very own personal lanterns");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_LIGHT_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of the Undead", "$scroll_undead$", "scroll_undead", "Revives nearby corpses as Undead");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_UNDEAD_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of Destruction", "$scroll_destruction$", "scroll_destruction", "Damages nearby enemies");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_DESTRUCTION_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of the Buffalo", "$scroll_buffalo$", "scroll_buffalo", "Transforms a nearby chicken into a Bison");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_BUFFALO_COST);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Scroll of Returning", "$scroll_returning$", "scroll_returning", "Teleports you to your team base");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_RETURNING_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of Earth", "$scroll_earth$", "scroll_earth", "Use this to turn all dirt walls in the area into dirt");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_EARTH_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of the Miner", "$scroll_miner$", "scroll_miner", "Use this to turn all stone in the area into thickstone");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_MINER_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Scroll of Drought", "$scroll_drought$", "scroll_drought", "Use this to dry up an orb of water");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SCROLL_DROUGHT_COST);
	}
	//{
	//	ShopItem@ s = addShopItem(this, "Aura of Shadow", "$aura_shadow$", "aura_shadow", "Defence rating of 30\nBecome invisible for up to 20 seconds\n\nFor the Wizard's staff");
	//	AddRequirement(s.requirements, "coin", "", "Coins", TRADER_AURA_SHADOW_COST);
	//}
	//{
	//	ShopItem@ s = addShopItem(this, "Tome of Returning", "$tome_returning$", "tome_returning", "Returns you to your base\n\nFor the Wizard's staff");
	//	AddRequirement(s.requirements, "coin", "", "Coins", TRADER_TOME_RETURNING_COST);
	//}
	{
		ShopItem@ s = addShopItem(this, "Aura of Teleportation", "$aura_teleportation$", "aura_teleportation", "Defence rating of 40\nTeleport to somewhere nearby\n\nFor the Wizard's staff");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_AURA_TELEPORTATION_COST);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}
