/* 1of3ol7.as
 * author: Aphelion
 */

#define CLIENT_ONLY;

#include "2efidcr.as";

void onInit( CRules@ this )
{
    printf("Adding icon tokens...");
	
	// -- BLOCK ICONS
	
	AddIconToken( "$triangle$", "Entities/Structures/RP/Triangle/Triangle.png", Vec2f(8, 8), 0 );
	AddIconToken( "$wooden_triangle$", "Entities/Structures/RP/Triangle/WoodenTriangle.png", Vec2f(8, 8), 0 );
	AddIconToken( "$team_platform$", "Entities/Structures/RP/TeamPlatform/TeamPlatform.png", Vec2f(8, 8), 0 );
	AddIconToken( "$wooden_spikes$", "Entities/Structures/RP/WoodenSpikes/WoodenSpkes.png", Vec2f(8, 8), 0 );
	AddIconToken( "$stone_workshop$", "Entities/Industry/" + RP_NAME + "/StoneWorkshop/StoneWorkshop.png", Vec2f(16, 16), 3 );
	//AddIconToken( "$steel_block$", "Entities/Structures/RP/SteelBlock/SteelBlock.png", Vec2f(8, 8), 0 );
	//AddIconToken( "$gold_block$", "Entities/Structures/RP/GoldBlock/GoldBlock.png", Vec2f(8, 8), 0 );
	AddIconToken( "$large_building$", "Entities/Industry/" + RP_NAME + "/LargeBuilding/LargeBuilding.png", Vec2f(32, 32), 3 );
	
	// -- RESEARCH ICONS
	
	// - BUILDER
	AddIconToken( "$tech_builder_smithing_1$", "TechIcons.png", Vec2f(16, 16), 0);
	AddIconToken( "$tech_builder_smithing_2$", "TechIcons.png", Vec2f(16, 16), 1);
	AddIconToken( "$tech_builder_smithing_3$", "TechIcons.png", Vec2f(16, 16), 2);
	AddIconToken( "$tech_builder_machinery_1$", "TechIcons.png", Vec2f(16, 16), 3);
	AddIconToken( "$tech_builder_machinery_2$", "TechIcons.png", Vec2f(16, 16), 4);
	AddIconToken( "$tech_builder_machinery_3$", "TechIcons.png", Vec2f(16, 16), 5);
	AddIconToken( "$tech_builder_mastery$", "TechIcons.png", Vec2f(16, 16), 6);
	
	// - KNIGHT
	AddIconToken( "$tech_knight_endurance_1$", "TechIcons.png", Vec2f(16, 16), 7);
	AddIconToken( "$tech_knight_endurance_2$", "TechIcons.png", Vec2f(16, 16), 8);
	AddIconToken( "$tech_knight_endurance_3$", "TechIcons.png", Vec2f(16, 16), 9);
	AddIconToken( "$tech_knight_shield_gliding_1$", "TechIcons.png", Vec2f(16, 16), 10);
	AddIconToken( "$tech_knight_shield_gliding_2$", "TechIcons.png", Vec2f(16, 16), 11);
	AddIconToken( "$tech_knight_shield_gliding_3$", "TechIcons.png", Vec2f(16, 16), 12);
	AddIconToken( "$tech_knight_mastery$", "TechIcons.png", Vec2f(16, 16), 13);
	
	// - MARKSMAN
	AddIconToken( "$tech_marksman_marksmanship_1$", "TechIcons.png", Vec2f(16, 16), 14);
	AddIconToken( "$tech_marksman_marksmanship_2$", "TechIcons.png", Vec2f(16, 16), 15);
	AddIconToken( "$tech_marksman_marksmanship_3$", "TechIcons.png", Vec2f(16, 16), 16);
	AddIconToken( "$tech_marksman_grappling_1$", "TechIcons.png", Vec2f(16, 16), 17);
	AddIconToken( "$tech_marksman_grappling_2$", "TechIcons.png", Vec2f(16, 16), 18);
	AddIconToken( "$tech_marksman_grappling_3$", "TechIcons.png", Vec2f(16, 16), 19);
	AddIconToken( "$tech_marksman_mastery$", "TechIcons.png", Vec2f(16, 16), 20);
	
	// - MAGE
	AddIconToken( "$tech_mage_wizardry_1$", "TechIcons.png", Vec2f(16, 16), 21);
	AddIconToken( "$tech_mage_wizardry_2$", "TechIcons.png", Vec2f(16, 16), 22);
	AddIconToken( "$tech_mage_wizardry_3$", "TechIcons.png", Vec2f(16, 16), 23);
	AddIconToken( "$tech_mage_willpower_1$", "TechIcons.png", Vec2f(16, 16), 24);
	AddIconToken( "$tech_mage_willpower_2$", "TechIcons.png", Vec2f(16, 16), 25);
	AddIconToken( "$tech_mage_willpower_3$", "TechIcons.png", Vec2f(16, 16), 26);
	AddIconToken( "$tech_mage_mastery$", "TechIcons.png", Vec2f(16, 16), 27);

    // -- EQUIPMENT ICONS
	
	// - KNIGHT
	AddIconToken("$copper_chestplate$", "Entities/Items/" + RP_NAME + "/Armour/Knight/CopperChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$iron_chestplate$", "Entities/Items/" + RP_NAME + "/Armour/Knight/IronChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$gold_chestplate$", "Entities/Items/" + RP_NAME + "/Armour/Knight/GoldChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$steel_chestplate$", "Entities/Items/" + RP_NAME + "/Armour/Knight/SteelChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$mythril_chestplate$", "Entities/Items/Armour/Knight/MythrilChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$adamant_chestplate$", "Entities/Items/Armour/Knight/AdamantChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$dragon_chestplate$", "Entities/Items/Armour/Knight/DragonChestplate.png", Vec2f(16, 16), 0);
	
	AddIconToken("$copper_sword$", "Entities/Items/" + RP_NAME + "/Weapons/Knight/CopperSword.png", Vec2f(16, 16), 0);
	AddIconToken("$iron_sword$", "Entities/Items/" + RP_NAME + "/Weapons/Knight/IronSword.png", Vec2f(16, 16), 0);
	AddIconToken("$gold_sword$", "Entities/Items/" + RP_NAME + "/Weapons/Knight/GoldSword.png", Vec2f(16, 16), 0);
	AddIconToken("$steel_sword$", "Entities/Items/" + RP_NAME + "/Weapons/Knight/SteelSword.png", Vec2f(16, 16), 0);
	AddIconToken("$dragon_sword$", "Entities/Items/" + RP_NAME + "/Weapons/Knight/DragonSword.png", Vec2f(16, 16), 0);
	AddIconToken("$mace$", "Entities/Items/" + RP_NAME + "/Weapons/Knight/Mace.png", Vec2f(16, 16), 0);
	AddIconToken("$war_axe$", "Entities/Items/" + RP_NAME + "/Weapons/Knight/WarAxe.png", Vec2f(16, 16), 0);
	
	// - ARCHER
	AddIconToken("$no_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/NoChainmail.png", Vec2f(16, 16), 0);
	AddIconToken("$iron_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/IronChainmail.png", Vec2f(16, 16), 0);
	AddIconToken("$steel_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/SteelChainmail.png", Vec2f(16, 16), 0);
	AddIconToken("$adamant_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/AdamantChainmail.png", Vec2f(16, 16), 0);
	AddIconToken("$armadyl_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/ArmadylChainmail.png", Vec2f(16, 16), 0);
		
	AddIconToken("$composite_bow$", "Entities/Items/" + RP_NAME + "/Weapons/CompositeBow/CompositeBow.png", Vec2f(16, 16), 0);
	AddIconToken("$crossbow$", "Entities/Items/" + RP_NAME + "/Weapons/Crossbow/Crossbow.png", Vec2f(16, 16), 0);
	AddIconToken("$hand_cannon$", "Entities/Items/" + RP_NAME + "/Weapons/Handcannon/Handcannon.png", Vec2f(16, 16), 0);
	
	// - MAGE
	AddIconToken("$aura_default$", "Entities/Items/" + RP_NAME + "/Auras/Aura.png", Vec2f(16, 16), 0);
	AddIconToken("$aura_shadow$", "Entities/Items/" + RP_NAME + "/Auras/Aura.png", Vec2f(16, 16), 1);
	AddIconToken("$aura_teleportation$", "Entities/Items/" + RP_NAME + "/Auras/Aura.png", Vec2f(16, 16), 2);
	AddIconToken("$aura_flight$", "Entities/Items/" + RP_NAME + "/Auras/Aura.png", Vec2f(16, 16), 3);
		
    AddIconToken("$staff$", "Entities/Items/" + RP_NAME + "/Weapons/Staff/Staff.png", Vec2f(16, 16), 0);
	
	// -- PRODUCTION ICONS
	
	// - BLACKSMITH WORKSHOP, FURNACE
    AddIconToken( "$mat_ironbars$", "Entities/Materials/Materials.png", Vec2f(16, 16), 88);
    AddIconToken( "$mat_steelbars$", "Entities/Materials/Materials.png", Vec2f(16, 16), 89);
   	AddIconToken( "$mat_goldbars$", "Entities/Materials/Materials.png", Vec2f(16, 16), 90);
    AddIconToken( "$mat_mythrilbars$", "Entities/Materials/Materials.png", Vec2f(16, 16), 91);
    AddIconToken( "$mat_adamantbars$", "Entities/Materials/Materials.png", Vec2f(16, 16), 92);
	
	// - BLACKSMITH WORKSHOP, ANVIL
	AddIconToken("$iron_chestplate$", "Entities/Items/" + RP_NAME + "/Armour/Knight/IronChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$steel_chestplate$", "Entities/Items/" + RP_NAME + "/Armour/Knight/SteelChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$mythril_chestplate$", "Entities/Items/Armour/Knight/MythrilChestplate.png", Vec2f(16, 16), 0);
	AddIconToken("$adamant_chestplate$", "Entities/Items/Armour/Knight/AdamantChestplate.png", Vec2f(16, 16), 0);
		
	AddIconToken("$iron_sword$", "Entities/Items/" + RP_NAME + "/Weapons/IronSword/IronSword.png", Vec2f(16, 16), 0);
    AddIconToken("$steel_sword$", "Entities/Items/" + RP_NAME + "/Weapons/SteelSword/SteelSword.png", Vec2f(16, 16), 0);
	AddIconToken("$mythril_sword$", "Entities/Items/" + RP_NAME + "/Weapons/MythrilSword/MythrilSword.png", Vec2f(16, 16), 0);
	AddIconToken("$adamant_sword$", "Entities/Items/" + RP_NAME + "/Weapons/AdamantSword/AdamantSword.png", Vec2f(16, 16), 0);
	
	AddIconToken("$iron_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/IronChainmail.png", Vec2f(16, 16), 0);
	AddIconToken("$steel_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/SteelChainmail.png", Vec2f(16, 16), 0);
	AddIconToken("$mythril_chainmail$", "Entities/Items/" + RP_NAME + "/Armour/Marksman/MythrilChainmail.png", Vec2f(16, 16), 0);
	AddIconToken("$hand_cannon$", "Entities/Items/" + RP_NAME + "/Weapons/Marksman/Handcannon.png", Vec2f(16, 16), 0);
	AddIconToken("$musket$", "Entities/Items/" + RP_NAME + "/Weapons/Marksman/Musket.png", Vec2f(16, 16), 0);
	
	AddIconToken("$mat_ironarrows$", "Entities/Materials/Materials.png", Vec2f(16, 16), 120);
	AddIconToken("$mat_steelarrows$", "Entities/Materials/Materials.png", Vec2f(16, 16), 121);
	AddIconToken("$mat_piercingarrows$", "Entities/Materials/Materials.png", Vec2f(16, 16), 122);
	AddIconToken("$mat_roundshot$", "Entities/Materials/Materials.png", Vec2f(16, 16), 152);
	
    // -- SHOP ICONS

	AddIconToken("$mill$", "Entities/Industry/" + RP_NAME + "/Mill/Mill.png", Vec2f(40, 24), 0);
	AddIconToken("$mageshop$", "Entities/Industry/" + RP_NAME + "/MageShop/MageShop.png", Vec2f(40, 24), 0);
	AddIconToken("$library$", "Entities/Industry/" + RP_NAME + "/Library/Library.png", Vec2f(40, 24), 0);
	AddIconToken("$kitchen$", "Entities/Industry/" + RP_NAME + "/Kitchen/Kitchen.png", Vec2f(40, 24), 0);
	AddIconToken("$market$", "Entities/Industry/" + RP_NAME + "/Market/Market.png", Vec2f(40, 24), 0);
	AddIconToken("$trading_post$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPost.png", Vec2f(40, 24), 0);
	AddIconToken("$farmingshop$", "Entities/Industry/" + RP_NAME + "/FarmingShop/FarmingShop.png", Vec2f(40, 24), 0);
	AddIconToken("$enchanter$", "Entities/Industry/" + RP_NAME + "/Enchanter/Enchanter.png", Vec2f(40, 24), 0);
	AddIconToken("$apothecary$", "Entities/Industry/" + RP_NAME + "/Apothecary/Apothecary.png", Vec2f(40, 24), 0);
	
	AddIconToken("$blacksmithworkshop$", "Entities/Industry/" + RP_NAME + "/BlacksmithWorkshop/BlacksmithWorkshop.png", Vec2f(80, 48), 0);
	AddIconToken("$armoury$", "Entities/Industry/" + RP_NAME + "/Armoury/Armoury.png", Vec2f(80, 48), 0);
	
	// - BUILDER SHOP
   	AddIconToken("$chainsaw$", "Entities/Industry/" + RP_NAME + "/Chainsaw/Chainsaw.png", Vec2f(32, 16), 0);
	
	// -- TRADING POST
	AddIconToken("$increase_1$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 7);
	AddIconToken("$increase_5$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 19);
	AddIconToken("$increase_10$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 11);
	AddIconToken("$increase_50$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 15);
	AddIconToken("$increase_1$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 7);
	AddIconToken("$reduce_1$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 6);
	AddIconToken("$reduce_5$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 18);
	AddIconToken("$reduce_10$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 10);
	AddIconToken("$reduce_50$", "Entities/Industry/" + RP_NAME + "/TradingPost/TradingPostIcons.png", Vec2f(16, 16), 14);
	
	// - MAGE SHOP
   	AddIconToken("$mat_energyrunes$", "Entities/Materials/Materials.png", Vec2f(16, 16), 32);
    AddIconToken("$mat_miasmarunes$", "Entities/Materials/Materials.png", Vec2f(16, 16), 33);
    AddIconToken("$mat_lightningrunes$", "Entities/Materials/Materials.png", Vec2f(16, 16), 34);
    AddIconToken("$mat_bombrunes$", "Entities/Materials/Materials.png", Vec2f(16, 16), 35);
	
	// -- ITEMS
	AddIconToken("$mat_flour$", "Entities/Materials/Materials.png", Vec2f(16, 16), 160);

	AddIconToken("$bush$", "Entities/Natural/Bushes/Bush.png", Vec2f(24, 24), 5);
	AddIconToken("$cactus$", "Entities/Natural/Bushes/Cactus.png", Vec2f(24, 24), 0);
	
	AddIconToken("$grain$", "Entities/Natural/Farming/Grain/Grain.png", Vec2f(8, 8), 0);
	AddIconToken("$flour$", "Entities/Items/" + RP_NAME + "/Flour/Flour.png", Vec2f(8, 8), 0);
	AddIconToken("$leaf$", "Entities/Natural/Bushes/Leaf.png", Vec2f(8, 8), 0);
	
	AddIconToken("$bread$", "Entities/Items/Food/Food.png", Vec2f(16, 16), 4);
	AddIconToken("$cooked_fish$", "Entities/Items/Food/Food.png", Vec2f(16, 16), 1);
	AddIconToken("$cake$", "Entities/Items/Food/Food.png", Vec2f(16, 16), 5);
	AddIconToken("$burger$", "Entities/Items/Food/Food.png", Vec2f(16, 16), 6);
	AddIconToken("$golden_burger$", "Entities/Items/Food/Food.png", Vec2f(16, 16), 7);
	
	AddIconToken("$potion_swiftness$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 4);
	AddIconToken("$potion_feather$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 9);
	AddIconToken("$potion_invisibility$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 3);
	AddIconToken("$potion_regeneration$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 6);
	AddIconToken("$potion_rockskin$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 8);
	AddIconToken("$potion_waterbreathing$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 5);
	AddIconToken("$potion_sapping$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 1);
	AddIconToken("$potion_mystery$", "Entities/Items/" + RP_NAME + "/Consumables/Potions/Potions.png", Vec2f(8, 8), 7);
	
	AddIconToken("$scroll_harvest$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 5);
	AddIconToken("$scroll_miner$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 26);
	AddIconToken("$scroll_earth$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 24);
	AddIconToken("$scroll_drought$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 27);
	AddIconToken("$scroll_buffalo$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 13);
	AddIconToken("$scroll_guardian$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 6);
	AddIconToken("$scroll_light$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 4);
	AddIconToken("$scroll_destruction$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 14);
	AddIconToken("$scroll_undead$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 2);
	AddIconToken("$scroll_returning$", "Entities/Items/" + RP_NAME + "/Scrolls/Scroll.png", Vec2f(16, 16), 9);
	
	AddIconToken("$tome_telekinesis$", "Entities/Items/" + RP_NAME + "/Auras/Aura.png", Vec2f(16, 16), 1);
	AddIconToken("$tome_returning$", "Entities/Items/" + RP_NAME + "/Auras/Aura.png", Vec2f(16, 16), 2);
	AddIconToken("$tome_teleportation$", "Entities/Items/" + RP_NAME + "/Auras/Aura.png", Vec2f(16, 16), 3);
    
	// ---
	
	printf("Icon tokens complete");
}
