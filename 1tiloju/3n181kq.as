/* 3n181kq.as
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
	
	// TRADE
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Trade");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem( this, "Potion of Feather", "$potion_feather$", "potion_feather", "Allows you to move gracefully\nEffect lasts for 30 seconds");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_FEATHER_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Swiftness", "$potion_swiftness$", "potion_swiftness", "Allows you to move faster\nEffect lasts for 50 seconds");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_SWIFTNESS_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Invisibility", "$potion_invisibility$", "potion_invisibility", "Makes you Invisible\nEffect lasts for 20 seconds");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_INVISIBILITY_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Water Breathing", "$potion_waterbreathing$", "potion_waterbreathing", "Lets you breathe underwater\nEffect lasts for 20 seconds");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_WATERBREATHING_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Rock Skin", "$potion_rockskin$", "potion_rockskin", "Reduces incoming damage by 30%\nEffect lasts for 15 seconds");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_ROCK_SKIN_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Regeneration", "$potion_regeneration$", "potion_regeneration", "Heals 1 $heart$ every 3 seconds\nEffect lasts for 20 seconds");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_REGENERATION_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Sapping", "$potion_sapping$", "potion_sapping", "Heal for 30% of the damage you inflict\nEffect lasts for 15 seconds");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_SAPPING_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Mystery", "$potion_mystery$", "potion_mystery", "Myssterryy...");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_POTION_MYSTERY_COST);
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
