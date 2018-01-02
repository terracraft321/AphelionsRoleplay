/* 2kkehp9.as
 * author: Aphelion
 */

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "3t0evcr.as";

void onInit( CBlob@ this )
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 2));	
	this.set_string("shop description", "Cook");
	this.set_u8("shop icon", 12);
	
	{
		ShopItem@ s = addShopItem( this, "Bread", "$bread$", "bread", "Delicious crunchy whole-wheat bread\nHeals 1 $heart$");
		
		AddRequirement( s.requirements, "blob", "mat_flour", "Flour", 10);
	}
	{
		ShopItem@ s = addShopItem( this, "Cooked Fish", "$cooked_fish$", "cooked_fish", "A cooked fish on a stick\nHeals 1 $heart$");
		
		AddRequirement( s.requirements, "blob", "fishy", "Fish", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Burger", "$burger$", "burger", "A very fishy hamburger\nHeals 2 $heart$");
		
		AddRequirement( s.requirements, "blob", "mat_flour", "Flour", 10);
		AddRequirement( s.requirements, "blob", "leaf", "Leaf", 1);
		AddRequirement( s.requirements, "blob", "fishy", "Fish", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Cake", "$cake$", "cake", "A delicious cake\nHeals 3 $heart$");
		
		AddRequirement( s.requirements, "blob", "mat_flour", "Flour", 20);
		AddRequirement( s.requirements, "blob", "egg", "Egg", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Golden Burger", "$golden_burger$", "golden_burger", "A supreme golden burger, it's very golden\nHeals 4 $heart$");
		
		AddRequirement( s.requirements, "blob", "burger", "Burger", 1);
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 10);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Rock Skin", "$potion_rockskin$", "potion_rockskin", "Reduces incoming damage by 30%\nEffect lasts for 15 seconds");
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	
	{
		ShopItem@ s = addShopItem( this, "Potion of Feather", "$potion_feather$", "potion_feather", "Allows you to move gracefully\nEffect lasts for 50 seconds");
		
		AddRequirement( s.requirements, "blob", "leaf", "Leaf", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Swiftness", "$potion_swiftness$", "potion_swiftness", "Allows you to move faster\nEffect lasts for 30 seconds");
		
		AddRequirement( s.requirements, "blob", "egg", "Egg", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Invisibility", "$potion_invisibility$", "potion_invisibility", "Makes you Invisible\nEffect lasts for 20 seconds");
		
		AddRequirement( s.requirements, "blob", "grain", "Grain", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Water Breathing", "$potion_waterbreathing$", "potion_waterbreathing", "Lets you breathe underwater\nEffect lasts for 20 seconds");
		
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 10);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Regeneration", "$potion_regeneration$", "potion_regeneration", "Heals 1/2 $heart$ every 2 seconds\nEffect lasts for 20 seconds");
		
		AddRequirement( s.requirements, "blob", "heart", "Heart", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Potion of Sapping", "$potion_sapping$", "potion_sapping", "Heal for 30% of damage you inflict\nEffect lasts for 15 seconds");
		
		AddRequirement( s.requirements, "blob", "egg", "Egg", 1);
		AddRequirement( s.requirements, "blob", "heart", "Heart", 1);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/Cook");
	}
}
