/* 2rv6gjs.as
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
	
	// LANTERN LIGHT
	this.SetLight( true );
    this.SetLightRadius( 64.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(7, 4));
	this.set_string("shop description", "Research");
	this.set_u8("shop icon", 23);
	
	float costModifier = this.getTeamNum() == 5 ? 0.4f : 0.8f;
	
	{
		ShopItem@ s = addShopItem( this, "Builder - Smithing I", "$tech_builder_smithing_1$", "Smithing I", "Advancements in Smithing allow Blacksmiths to work with Steel");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 14 * costModifier);
		AddRequirement( s.requirements, "not tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Builder - Smithing II", "$tech_builder_smithing_2$", "Smithing II", "Further advancements in Smithing allow Blacksmiths to work with Mythril");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 1000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 43 * costModifier);
		AddRequirement( s.requirements, "not tech", "Smithing II", "Smithing II", 1);
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Builder - Smithing III", "$tech_builder_smithing_3$", "Smithing III", "Mastery of Smithing allow Blacksmiths to work with Adamant");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 2000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 120 * costModifier);
		AddRequirement( s.requirements, "not tech", "Smithing III", "Smithing III", 1);
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Builder - Machinery I", "$tech_builder_machinery_1$", "Machinery I", "Builder machinery is upgraded to Steel\n\nIncreases saw efficiency, maximum chainsaw/drill heat, and reduces the time it takes to grind grain");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 15 * costModifier);
		AddRequirement( s.requirements, "not tech", "Machinery I", "Machinery I", 1);
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Builder - Machinery II", "$tech_builder_machinery_2$", "Machinery II", "Builder machinery is upgraded to Mythril\n\nIncreases saw efficiency, maximum chainsaw/drill heat, and reduces the time it takes to grind grain");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 40 * costModifier);
		AddRequirement( s.requirements, "not tech", "Machinery II", "Machinery II", 1);
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
		AddRequirement( s.requirements, "tech", "Machinery I", "Machinery I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Builder - Machinery III", "$tech_builder_machinery_3$", "Machinery III", "Builder machinery is upgraded to Adamant\n\nIncreases saw efficiency, maximum chainsaw/drill heat, and reduces the time it takes to grind grain");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 1000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 105 * costModifier);
		AddRequirement( s.requirements, "not tech", "Machinery III", "Machinery III", 1);
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
		AddRequirement( s.requirements, "tech", "Machinery II", "Machinery II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Dwarven Sappers", "$tech_builder_mastery$", "Dwarven Sappers", "Unique Dwarf Tech\n\nDwarven Sappers are well armoured and resilient\n\nBuilders resist half of incoming damage");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 3000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 205 * costModifier);
		AddRequirement( s.requirements, "not tech", "Dwarven Sappers", "Dwarven Sappers", 1);
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
		AddRequirement( s.requirements, "tech", "Machinery III", "Machinery III", 1);
		AddRequirement( s.requirements, "team", "1", "Dwarves", 1);
	}

	{
		ShopItem@ s = addShopItem( this, "Knight - Endurance I", "$tech_knight_endurance_1$", "Endurance I", "Special training teaches Knights to endure the weight of armour\n\nReduces encumbrance caused by armour");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "coin", "", "Coins", 30 * costModifier);
		AddRequirement( s.requirements, "not tech", "Endurance I", "Endurance I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Knight - Endurance II", "$tech_knight_endurance_2$", "Endurance II", "Additional training teaches Knights to endure the weight of armour\n\nReduces encumbrance caused by armour");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "coin", "", "Coins", 75 * costModifier);
		AddRequirement( s.requirements, "not tech", "Endurance II", "Endurance II", 1);
		AddRequirement( s.requirements, "tech", "Endurance I", "Endurance I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Knight - Endurance III", "$tech_knight_endurance_3$", "Endurance III", "Mastery of Endurance allows Knights to overcome the effect of armour on movement\n\nRemoves encumbrance caused by armour");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "coin", "", "Coins", 185 * costModifier);
		AddRequirement( s.requirements, "not tech", "Endurance III", "Endurance III", 1);
		AddRequirement( s.requirements, "tech", "Endurance II", "Endurance II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Knight - Shield Gliding I", "$tech_knight_shield_gliding_1$", "Shield Gliding I", "Special teachings allow Knights to glide for longer durations\n\nIncreases the duration a Knight can shield glide");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "coin", "", "Coins", 23 * costModifier);
		AddRequirement( s.requirements, "not tech", "Shield Gliding I", "Shield Gliding I", 1);
		AddRequirement( s.requirements, "tech", "Endurance I", "Endurance I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Knight - Shield Gliding II", "$tech_knight_shield_gliding_2$", "Shield Gliding II", "Additional teachings allow Knights to glide for longer durations\n\nIncreases the duration a Knight can shield glide");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "coin", "", "Coins", 56 * costModifier);
		AddRequirement( s.requirements, "not tech", "Shield Gliding II", "Shield Gliding II", 1);
		AddRequirement( s.requirements, "tech", "Endurance II", "Endurance II", 1);
		AddRequirement( s.requirements, "tech", "Shield Gliding I", "Shield Gliding I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Knight - Shield Gliding III", "$tech_knight_shield_gliding_3$", "Shield Gliding III", "Mastery of Shield Gliding allows Knights to glide for long periods of time\n\nIncreases the duration a Knight can shield glide");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "coin", "", "Coins", 138 * costModifier);
		AddRequirement( s.requirements, "not tech", "Shield Gliding III", "Shield Gliding III", 1);
		AddRequirement( s.requirements, "tech", "Endurance III", "Endurance III", 1);
		AddRequirement( s.requirements, "tech", "Shield Gliding II", "Shield Gliding II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Orc Elite Knights", "$tech_knight_mastery$", "Orc Elite Knights", "Unique Orc Tech\n\nTrue mastery of Endurance and Shield Gliding\n\nOrc Elite Knights are able to run faster and jump higher");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "coin", "", "Coins", 300 * costModifier);
		AddRequirement( s.requirements, "not tech", "Orc Elite Knights", "Orc Elite Knights", 1);
		AddRequirement( s.requirements, "tech", "Endurance III", "Endurance III", 1);
		AddRequirement( s.requirements, "tech", "Shield Gliding III", "Shield Gliding III", 1);
		AddRequirement( s.requirements, "team", "3", "Orcs", 1);
	}

	{
		ShopItem@ s = addShopItem( this, "Marksman - Marksmanship I", "$tech_marksman_marksmanship_1$", "Marksmanship I", "Special teachings allow Marksmen to fire faster\n\nIncreases the fire speed of bows");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 20 * costModifier);
		AddRequirement( s.requirements, "not tech", "Marksmanship I", "Marksmanship I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Marksman - Marksmanship II", "$tech_marksman_marksmanship_2$", "Marksmanship II", "Additional teachings Marksmen to fire much faster\n\nIncreases the fire speed of bows");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 55 * costModifier);
		AddRequirement( s.requirements, "not tech", "Marksmanship II", "Marksmanship II", 1);
		AddRequirement( s.requirements, "tech", "Marksmanship I", "Marksmanship I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Marksman - Marksmanship III", "$tech_marksman_marksmanship_3$", "Marksmanship III", "Mastery of Marksmanship allows Marksmen to fire extremely fast\n\nIncreases the fire speed of bows");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 145 * costModifier);
		AddRequirement( s.requirements, "not tech", "Marksmanship III", "Marksmanship III", 1);
		AddRequirement( s.requirements, "tech", "Marksmanship II", "Marksmanship II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Marksman - Grappling I", "$tech_marksman_grappling_1$", "Grappling I", "Special training allows Marksmen to grapple at longer distances\n\nIncreases grapple length");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 250 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 18 * costModifier);
		AddRequirement( s.requirements, "not tech", "Grappling I", "Grappling I", 1);
		AddRequirement( s.requirements, "tech", "Marksmanship I", "Marksmanship I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Marksman - Grappling II", "$tech_marksman_grappling_2$", "Grappling II", "Additional training allows Marksmen to grapple at longer distances\n\nIncreases grapple length");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 46 * costModifier);
		AddRequirement( s.requirements, "not tech", "Grappling II", "Grappling II", 1);
		AddRequirement( s.requirements, "tech", "Marksmanship II", "Marksmanship II", 1);
		AddRequirement( s.requirements, "tech", "Grappling I", "Grappling I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Marksman - Grappling III", "$tech_marksman_grappling_3$", "Grappling III", "Mastery of Grappling allows Marksmen to grapple at longer distances\n\nIncreases grapple length");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 118 * costModifier);
		AddRequirement( s.requirements, "not tech", "Grappling III", "Grappling III", 1);
		AddRequirement( s.requirements, "tech", "Marksmanship III", "Marksmanship III", 1);
		AddRequirement( s.requirements, "tech", "Grappling II", "Grappling II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Elven Master Marksmen", "$tech_marksman_mastery$", "Elven Master Marksmen", "Unique Elf Tech\n\nTrue mastery of Marksmanship and Grappling\n\nElven Master Marksmen are agile with both the bow and grapple");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 3000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 240 * costModifier);
		AddRequirement( s.requirements, "not tech", "Elven Master Marksmen", "Elven Master Marksmen", 1);
		AddRequirement( s.requirements, "tech", "Marksmanship III", "Marksmanship III", 1);
		AddRequirement( s.requirements, "tech", "Grappling III", "Grappling III", 1);
		AddRequirement( s.requirements, "team", "2", "Elves", 1);
	}

	{
		ShopItem@ s = addShopItem( this, "Mage - Wizardry I", "$tech_mage_wizardry_1$", "Wizardry I", "Special teachings allow spells casted by Mages to have a greater area of effect\n\nIncreases spell area of effect");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 250 * costModifier);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 17 * costModifier);
		AddRequirement( s.requirements, "not tech", "Wizardry I", "Wizardry I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mage - Wizardry II", "$tech_mage_wizardry_2$", "Wizardry II", "Additional teachings allow spells casted by Mages to have a greater area of effect\n\nIncreases spell area of effect");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 * costModifier);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 49 * costModifier);
		AddRequirement( s.requirements, "not tech", "Wizardry II", "Wizardry II", 1);
		AddRequirement( s.requirements, "tech", "Wizardry I", "Wizardry I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mage - Wizardry III", "$tech_mage_wizardry_3$", "Wizardry III", "Mastery of Wizardry allows spells casted by Mages to have a huge area of effect\n\nIncreases spell area of effect");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1000 * costModifier);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 1000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 133 * costModifier);
		AddRequirement( s.requirements, "not tech", "Wizardry III", "Wizardry III", 1);
		AddRequirement( s.requirements, "tech", "Wizardry II", "Wizardry II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mage - Willpower I", "$tech_mage_willpower_1$", "Willpower I", "Special training allows Mages to recharge their abilities faster\n\nReduces ability cooldown time");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 250 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 18 * costModifier);
		AddRequirement( s.requirements, "not tech", "Willpower I", "Willpower I", 1);
		AddRequirement( s.requirements, "tech", "Wizardry I", "Wizardry I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mage - Willpower II", "$tech_mage_willpower_2$", "Willpower II", "Further training allows Mages to recharge their abilities faster\n\nReduces ability cooldown time");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 250 * costModifier);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 250 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 43 * costModifier);
		AddRequirement( s.requirements, "not tech", "Willpower II", "Willpower II", 1);
		AddRequirement( s.requirements, "tech", "Wizardry II", "Wizardry II", 1);
		AddRequirement( s.requirements, "tech", "Willpower I", "Willpower I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mage - Willpower III", "$tech_mage_willpower_3$", "Willpower III", "Mastery of Willpower allows Mages to recharge their abilities much faster\n\nReduces ability cooldown time");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500 * costModifier);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 500 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 112 * costModifier);
		AddRequirement( s.requirements, "not tech", "Willpower III", "Willpower III", 1);
		AddRequirement( s.requirements, "tech", "Wizardry III", "Wizardry III", 1);
		AddRequirement( s.requirements, "tech", "Willpower II", "Willpower II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Human Archmages", "$tech_mage_mastery$", "Human Archmages", "Unique Human Tech\n\nTrue mastery of Wizardry and Willpower\n\nHuman Archmages are able to recharge their abilities at lightning speed and use spells with a lethal area of impact");
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 2000 * costModifier);
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 1000 * costModifier);
		AddRequirement( s.requirements, "coin", "", "Coins", 228 * costModifier);
		AddRequirement( s.requirements, "not tech", "Human Archmages", "Human Archmages", 1);
		AddRequirement( s.requirements, "tech", "Wizardry III", "Wizardry III", 1);
		AddRequirement( s.requirements, "tech", "Willpower III", "Willpower III", 1);
		AddRequirement( s.requirements, "team", "0", "Humans", 1);
	}
	
	this.set_string("required class", "builder");
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ lantern = this.addSpriteLayer( "lantern", "Lantern.png" , 8, 8, blob.getTeamNum(), blob.getSkinNum() );
	
	if (lantern !is null)
    {
	    lantern.SetRelativeZ(50);
		lantern.SetOffset(Vec2f(9, -5));
		
        Animation@ anim = lantern.addAnimation( "default", 3, true );
        anim.AddFrame(0);
        anim.AddFrame(1);
        anim.AddFrame(2);
    }
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.getTeamNum() == caller.getTeamNum() && this.isOverlapping(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		bool isServer = (getNet().isServer());
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if    (callerBlob is null)
				return;

		    setTechResearched(name, callerBlob.getTeamNum());
		}
	}
}
