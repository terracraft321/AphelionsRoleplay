/* 336vmdr.as
 * author: Aphelion
 * 
 * The script that handles the Anvil side of things.
 */

#include "Requirements.as"
#include "ShopCommon.as";

void onInit( CBlob@ this )
{
	this.getSprite().SetZ(-49); //background
	
    CShape@ shape = this.getShape();
	shape.getConsts().mapCollisions = false;
	shape.SetStatic(true);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0.0f, -5.0f));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", "Smith");
	this.set_u8("shop icon", 15);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Iron chestplate", "$iron_chestplate$", "iron_chestplate", "Iron chestplate\n\nProtective garment for the Knight\nDefence rating of 30" );
		AddRequirement( s.requirements, "blob", "mat_ironbars", "Iron bars", 4);
	}
	{
		ShopItem@ s = addShopItem( this, "Steel chestplate", "$steel_chestplate$", "steel_chestplate", "Steel chestplate\n\nProtective garment for the Knight\nDefence rating of 40" );
		AddRequirement( s.requirements, "blob", "mat_steelbars", "Steel bars", 4 );
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mythril chestplate", "$mythril_chestplate$", "mythril_chestplate", "Mythril chestplate\n\nProtective garment for the Knight\nDefence rating of 50" );
		AddRequirement( s.requirements, "blob", "mat_mythrilbars", "Mythril bars", 4 );
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Adamant chestplate", "$adamant_chestplate$", "adamant_chestplate", "Adamant chestplate\n\nProtective garment for the Knight\nDefence rating of 60" );
		AddRequirement( s.requirements, "blob", "mat_adamantbars", "Adamant bars", 4 );
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Golden chestplate", "$gold_chestplate$", "gold_chestplate", "Golden chestplate\n\nProtective garment for the Knight\nDefence rating of 65" );
		AddRequirement( s.requirements, "blob", "mat_goldbars", "Gold bars", 16 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Iron sword", "$iron_sword$", "iron_sword", "Iron sword\n\nA weapon for the Knight\nDamage rating of 1.25" );
		AddRequirement( s.requirements, "blob", "mat_ironbars", "Iron bars", 2 );
	}
	{
		ShopItem@ s = addShopItem( this, "Steel sword", "$steel_sword$", "steel_sword", "Steel sword\n\nA weapon for the Knight\nDamage rating of 1.5" );
		AddRequirement( s.requirements, "blob", "mat_steelbars", "Steel bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mace", "$mace$", "mace", "Mace\n\nA weapon for the Knight\nA heavy hitting weapon with a one in four chance to ignore 15 Defence rating" );
		AddRequirement( s.requirements, "blob", "mat_mythrilbars", "Mythril bars", 1 );
		AddRequirement( s.requirements, "blob", "mat_ironbars", "Iron bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "War Axe", "$war_axe$", "war_axe", "War Axe\n\nA weapon for the Knight\nA powerful slashing weapon with a one in four chance to hit through shields" );
		AddRequirement( s.requirements, "blob", "mat_adamantbars", "Adamant bars", 1 );
		AddRequirement( s.requirements, "blob", "mat_steelbars", "Steel bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Golden sword", "$gold_sword$", "gold_sword", "Golden sword\n\nA weapon for the Knight\nDamage rating of 1.75" );
		AddRequirement( s.requirements, "blob", "mat_goldbars", "Gold bars", 8 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Iron chainmail", "$iron_chainmail$", "iron_chainmail", "Iron chainmail\n\nProtective garment for the Marksman\nDefence rating of 20" );
		AddRequirement( s.requirements, "blob", "mat_ironbars", "Iron bars", 2 );
	}
	{
		ShopItem@ s = addShopItem( this, "Steel chainmail", "$steel_chainmail$", "steel_chainmail", "Steel chainmail\n\nProtective garment for the Marksman\nDefence rating of 30" );
		AddRequirement( s.requirements, "blob", "mat_steelbars", "Steel bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mythril chainmail", "$mythril_chainmail$", "mythril_chainmail", "Mythril chainmail\n\nProtective garment for the Marksman\nDefence rating of 40" );
		AddRequirement( s.requirements, "blob", "mat_mythrilbars", "Mythril bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Adamant chainmail", "$adamant_chainmail$", "adamant_chainmail", "Adamant chainmail\n\nProtective garment for the Marksman\nDefence rating of 50" );
		AddRequirement( s.requirements, "blob", "mat_adamantbars", "Adamant bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Musket", "$musket$", "musket", "Musket\n\nA powerful sniping weapon for the Marksman\nRequires round shot" );
		AddRequirement( s.requirements, "blob", "mat_steelbars", "Mythril bars", 1 );
		AddRequirement( s.requirements, "blob", "mat_ironbars", "Iron bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	
	{
		ShopItem@ s = addShopItem( this, "Iron arrows", "$mat_ironarrows$", "mat_ironarrows", "Iron arrows\n\nAmmunition for the Marksman\nDamage of 1.25" );
		AddRequirement( s.requirements, "blob", "mat_arrows", "Arrows", 30 );
		AddRequirement( s.requirements, "blob", "mat_ironbars", "Iron bars", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Steel arrows", "$mat_steelarrows$", "mat_steelarrows", "Steel arrows\n\nAmmunition for the Marksman\nDamage of 1.5" );
		AddRequirement( s.requirements, "blob", "mat_arrows", "Arrows", 30 );
		AddRequirement( s.requirements, "blob", "mat_steelbars", "Steel bars", 1 );
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Piercing arrows", "$mat_piercingarrows$", "mat_piercingarrows", "Piercing arrows\n\nAmmunition for the Marksman\nOne in four chance to ignore 10 Defence rating and hit through shields\nDamage of 1.5" );
		AddRequirement( s.requirements, "blob", "mat_arrows", "Arrows", 15 );
		AddRequirement( s.requirements, "blob", "mat_mythrilbars", "Mythril bars", 1 );
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Round shot", "$mat_roundshot$", "mat_roundshot", "Round shot\n\nAmmunition for the Marksman\nRequired for the Hand cannon and Musket" );
		AddRequirement( s.requirements, "blob", "mat_ironbars", "Iron bars", 1 );
	}
	
	{
		ShopItem@ s = addShopItem( this, "Hand cannon", "$hand_cannon$", "hand_cannon", "Hand cannon\n\nA powerful siege weapon for the Marksman\nRequires round shot" );
		AddRequirement( s.requirements, "blob", "mat_adamantbars", "Adamant bars", 1 );
		AddRequirement( s.requirements, "blob", "mat_steelbars", "Steel bars", 2 );
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", true);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound( "/Anvil.ogg" );
	}
}
