/* 2ich854.as
 * author: Aphelion
 */

#include "1oltmot.as";
 
#include "StandardRespawnCommand.as";
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
    InitClasses( this );
	this.Tag("change class drop inventory");
	
	this.inventoryButtonPos = Vec2f(24.0f, 10.0f);
	
	// CANDLE LIGHT
	this.SetLight( true );
    this.SetLightRadius( 72.0f );
    this.SetLightColor(SColor(255, 255, 240, 171));
	
	// TRADE
	this.set_Vec2f("shop offset", Vec2f(0, 5.0f));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", "Trade");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem( this, "Iron chestplate", "$iron_chestplate$", "iron_chestplate", "Iron chestplate\n\nProtective garment for the Knight\nDefence rating of 30" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_PLATE_IRON_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Steel chestplate", "$steel_chestplate$", "steel_chestplate", "Steel chestplate\n\nProtective garment for the Knight\nDefence rating of 40" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_PLATE_STEEL_COST);
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mythril chestplate", "$mythril_chestplate$", "mythril_chestplate", "Mythril chestplate\n\nProtective garment for the Knight\nDefence rating of 50" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_PLATE_MYTHRIL_COST);
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Adamant chestplate", "$adamant_chestplate$", "adamant_chestplate", "Adamant chestplate\n\nProtective garment for the Knight\nDefence rating of 60" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_PLATE_ADAMANT_COST);
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Golden chestplate", "$gold_chestplate$", "gold_chestplate", "Golden chestplate\n\nProtective garment for the Knight\nDefence rating of 65" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_PLATE_GOLD_COST);
	}
	
	{
		ShopItem@ s = addShopItem( this, "Iron sword", "$iron_sword$", "iron_sword", "Iron sword\n\nA weapon for the Knight\nDamage of 1.25" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_SWORD_IRON_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Steel sword", "$steel_sword$", "steel_sword", "Steel sword\n\nA weapon for the Knight\nDamage of 1.5" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_SWORD_STEEL_COST);
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mace", "$mace$", "mace", "Mace\n\nA weapon for the Knight\nA heavy hitting weapon with a one in four chance to ignore 15 Defence rating" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_UNIQUE_MACE_COST);
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "War Axe", "$war_axe$", "war_axe", "War Axe\n\nA weapon for the Knight\nA powerful slashing weapon with a one in four chance to hit through shields" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_UNIQUE_WAR_AXE_COST);
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Golden sword", "$gold_sword$", "gold_sword", "Golden sword\n\nA weapon for the Knight\nDamage of 1.75" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_SWORD_GOLD_COST);
	}
	
	{
		ShopItem@ s = addShopItem( this, "Iron chainmail", "$iron_chainmail$", "iron_chainmail", "Iron chainmail\n\nProtective garment for the Marksman\nDefence rating of 30" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_CHAIN_IRON_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Steel chainmail", "$steel_chainmail$", "steel_chainmail", "Steel chainmail\n\nProtective garment for the Marksman\nDefence rating of 40" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_CHAIN_STEEL_COST);
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mythril chainmail", "$mythril_chainmail$", "mythril_chainmail", "Mythril chainmail\n\nProtective garment for the Marksman\nDefence rating of 50" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_CHAIN_MYTHRIL_COST);
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Adamant chainmail", "$adamant_chainmail$", "adamant_chainmail", "Adamant chainmail\n\nProtective garment for the Marksman\nDefence rating of 60" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_CHAIN_ADAMANT_COST);
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Musket", "$musket$", "musket", "Musket\n\nA powerful sniping weapon for the Marksman\nRequires round shot" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_WEAPON_MUSKET_COST);
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	
	{
		ShopItem@ s = addShopItem( this, "Iron arrows", "$mat_ironarrows$", "mat_ironarrows", "Iron arrows\n\nAmmunition for the Marksman\nDamage of 1.25" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_ARROW_IRON_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Steel arrows", "$mat_steelarrows$", "mat_steelarrows", "Steel arrows\n\nAmmunition for the Marksman\nDamage of 1.5" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_ARROW_STEEL_COST);
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Piercing arrows", "$mat_piercingarrows$", "mat_piercingarrows", "Piercing arrows\n\nAmmunition for the Marksman\nOne in four chance to ignore 10 Defence rating and hit through shields\nDamage of 1.5" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_ARROW_PIERCING_COST);
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Round shot", "$mat_roundshot$", "mat_roundshot", "Round shot\n\nAmmunition for the Marksman\nRequired for the Hand cannon and Musket" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_AMMO_ROUNDSHOT_COST);
	}
	
	{
		ShopItem@ s = addShopItem( this, "Hand cannon", "$hand_cannon$", "hand_cannon", "Hand cannon\n\nA power siege weapon for the Marksman\nRequires round shot" );
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_WEAPON_HANDCANNON_COST);
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    // button for runner
    // create menu for class change
    if (canChangeClass( this, caller ) && caller.getTeamNum() == this.getTeamNum())
    {
        CBitStream params;
        params.write_u16(caller.getNetworkID());
        caller.CreateGenericButton( "$change_class$", Vec2f(-12.0f, 5.0f), this, SpawnCmd::buildMenu, "Change class", params );
    }
	
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
	else
	{
	    onRespawnCommand( this, cmd, params );
	}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ byBlob )
{
	return this.getTeamNum() == byBlob.getTeamNum();
}
