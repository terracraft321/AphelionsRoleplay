/* fq7ehj.as
 * author: Aphelion
 */

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));	
	this.set_string("shop description", "Construct");
	this.set_u8("shop icon", 12);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Transport Tunnel", "$tunnel$", "tunnel", descriptions[34] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
	{
		ShopItem@ s = addShopItem( this, "Storage Cache", "$storage$", "storage", descriptions[60] );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem( this, "Library", "$library$", "library", "A place for researching technologies." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Kitchen", "$kitchen$", "kitchen", "A place for making food and potions." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 150 );
	}
	{
		ShopItem@ s = addShopItem( this, "Market", "$market$", "market", "Buys and sells general goods." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 40 );
	}
	{
		ShopItem@ s = addShopItem( this, "Trading Post", "$trading_post$", "trading_post", "Sell your items." );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 200 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Farming Shop", "$farmingshop$", "farmingshop", "Sells seeds and farming goods." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 20 );
	}
	{
		ShopItem@ s = addShopItem( this, "Enchanter", "$enchanter$", "enchanter", "Sells scrolls, tomes, and spell tablets." );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 100 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 20 );
	}
	{
		ShopItem@ s = addShopItem( this, "Apothecary", "$apothecary$", "apothecary", "Sells potions and potion ingredients." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50 );
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 20 );
	}
	/*{
		ShopItem@ s = addShopItem( this, "Pet Shop", "$petshop$", "petshop", "Sells pets." );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
	}*/
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", true);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("shop made item"))
	{
		this.Tag("shop disabled"); //no double-builds
		
		CBlob@ caller = getBlobByNetworkID( params.read_netid() );
		CBlob@ item = getBlobByNetworkID( params.read_netid() );
		if (item !is null && caller !is null)
		{
			this.getSprite().PlaySound("/Construct.ogg" ); 
			this.getSprite().getVars().gibbed = true;
			this.server_Die();
		}
	}
}
