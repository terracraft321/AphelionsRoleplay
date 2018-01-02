/* 1m0gpq4.as
 * author: Aphelion
 */

#include "1oltmot.as";

const string[] name = 
{
    // Resources
    "mat_wood",
	"mat_stone",
	"mat_gold",
	"mat_flour",
	
	// Nature
	"grain",
	"leaf",
	
	// Food
	"bread",
	"cooked_fish",
	"burger",
	"cake",
	
	// Potions
	"potion_feather",
	"potion_swiftness",
	"potion_invisibility",
	"potion_waterbreathing",
	"potion_rockskin",
	"potion_regeneration",
	"potion_sapping",
	"potion_mystery",
	
	// Enchanted items
	"scroll_harvest",
	"scroll_buffalo",
	"scroll_earth",
	"scroll_miner",
	"scroll_drought",
	"scroll_guardian",
	"scroll_light",
	"scroll_destruction",
	"scroll_undead",
	"scroll_returning",
	"aura_teleportation",
	
	// Armour
	"iron_chestplate",
	"gold_chestplate",
	"steel_chestplate",
	"mythril_chestplate",
	"adamant_chestplate",
	"iron_chainmail",
	"steel_chainmail",
	"mythril_chainmail",
	"adamant_chainmail",
	
	// Weapons
	"iron_sword",
	"gold_sword",
	"steel_sword",
	"mace",
	"war_axe",
	"musket",
	"hand_cannon",
	"mat_ironarrows",
	"mat_steelarrows",
	"mat_piercingarrows",
	"mat_roundshot",
	
	// Munitions
	"mat_bombs",
	"mat_waterbombs",
	"keg",
	"mine",
	"mat_arrows",
	"mat_waterarrows",
	"mat_bombarrows",
	"mat_energyrunes",
	"mat_miasmarunes",
	"mat_lightningrunes",
	"mat_bombrunes",
	
	// Miscellaneous
	"lantern",
	"bucket",
	"sponge",
	"boulder",
	"beer",
	"egg",
	"drill",
	"chainsaw",
	
	// Noom rewards
	"dragon_chestplate",
	"dragon_sword",
	"armadyl_chainmail",
	"aura_flight",
};

const u16[] value = 
{
    // Resources
    10,
	15,
	50,
	30,
	
	// Nature
	TRADER_GRAIN_COST,
	TRADER_LEAF_COST,
	
	// Food
	TRADER_FOOD_BREAD_COST,
	TRADER_FOOD_COOKED_FISH_COST,
	TRADER_FOOD_BURGER_COST,
	TRADER_FOOD_CAKE_COST,
	
	// Potions
	TRADER_POTION_FEATHER_COST,
	TRADER_POTION_SWIFTNESS_COST,
	TRADER_POTION_INVISIBILITY_COST,
	TRADER_POTION_WATERBREATHING_COST,
	TRADER_POTION_ROCK_SKIN_COST,
	TRADER_POTION_REGENERATION_COST,
	TRADER_POTION_SAPPING_COST,
	TRADER_POTION_MYSTERY_COST,
	
	// Enchanted items
	TRADER_SCROLL_HARVEST_COST,
	TRADER_SCROLL_BUFFALO_COST,
	TRADER_SCROLL_EARTH_COST,
	TRADER_SCROLL_MINER_COST,
	TRADER_SCROLL_DROUGHT_COST,
	TRADER_SCROLL_GUARDIAN_COST,
	TRADER_SCROLL_LIGHT_COST,
	TRADER_SCROLL_DESTRUCTION_COST,
	TRADER_SCROLL_UNDEAD_COST,
	TRADER_SCROLL_RETURNING_COST,
	TRADER_AURA_TELEPORTATION_COST,
	
	// Armour
	TRADER_PLATE_IRON_COST,
	TRADER_PLATE_GOLD_COST,
	TRADER_PLATE_STEEL_COST,
	TRADER_PLATE_MYTHRIL_COST,
	TRADER_PLATE_ADAMANT_COST,
	TRADER_CHAIN_IRON_COST,
	TRADER_CHAIN_STEEL_COST,
	TRADER_CHAIN_MYTHRIL_COST,
	TRADER_CHAIN_ADAMANT_COST,
	
	// Weapons
	TRADER_SWORD_IRON_COST,
	TRADER_SWORD_GOLD_COST,
	TRADER_SWORD_STEEL_COST,
	TRADER_UNIQUE_MACE_COST,
	TRADER_UNIQUE_WAR_AXE_COST,
	TRADER_WEAPON_MUSKET_COST,
	TRADER_WEAPON_HANDCANNON_COST,
	TRADER_ARROW_IRON_COST,
	TRADER_ARROW_STEEL_COST,
	TRADER_ARROW_PIERCING_COST,
	TRADER_AMMO_ROUNDSHOT_COST,
	
	// Munitions
	12,  // bomb
	8,
	30,
	15,  // mine
	5,
	8,
	20,
	5,   // energy runes
	8,   // miasma runes
	12,  // lightning runes
	20,  // bomb runes
	
	// Miscellaneous
	2,
	1,
	1,
	3,
	3,
	12,
	5,
	10,
	
	// Noom rewards
	1000,
	1000,
	1000,
	1000,
};

u16 getItemValue( string item )
{
    for (uint i = 0; i <  name.length; i++)
	{
	    string itemName = name[i];
		if    (itemName == item)
		{
		    return value[i];
		}
	}
	return 30;
}
