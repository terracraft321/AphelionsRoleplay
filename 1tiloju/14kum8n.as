/* 14kum8n.as
 * author: Aphelion
 *
 * The script that places random loot into the Chest.
 */
 
const string[][][] chest_loot_tables = {
	
	{  // -- Iron Chest --
	   //
	   // May contain:
	   // - Steel bars
	   // - Iron bars
	   // - Coal
	   // - Iron
	   // - Stone
	   // - Bread
	   // - Cooked Fish
	   // - Potion of Swiftness
	   // - Potion of Feather
	   // - Scroll of Light
	   // - Scroll of Harvest
	   // ---
	   
	    {"chest_iron"},
		{"mat_steelbars",
		 "mat_ironbars",
		 "mat_coal",
		 "mat_iron",
		 "mat_iron",
		 "mat_wood",
		 "mat_stone",
		 "bread",
		 "cooked_fish",
		 "potion_swiftness",
		 "potion_feather",
		 "scroll_light",
		 "scroll_harvest"},
		{"1-3",
		 "3-5",
		 "5-20",
		 "10-30",
		 "10-20",
		 "50-500",
		 "30-250",
		 "1-3",
		 "1-3",
		 "1-2",
		 "1-3",
		 "1",
		 "1"},
		{"5",
		 "4",
		 "3",
		 "3",
		 "3",
		 "2",
		 "2",
		 "3",
		 "4",
		 "4",
		 "3",
		 "3",
		 "1"},
		{"3"}
	},
	
	{  // -- Steel Chest --
	   //
	   // May contain:
	   // - Gold bars
	   // - Steel bars
	   // - Gold
	   // - Coal
	   // - Wood
	   // - Stone
	   // - Cooked Fish
	   // - Cake
	   // - Potion of Rock Skin
	   // - Potion of Invisibility
	   // - Scroll of the Buffalo
	   // - Scroll of Returning
	   // ---
	   
	    {"chest_steel"},
		{"mat_goldbars",
		 "mat_steelbars",
		 "mat_gold",
		 "mat_coal",
		 "mat_wood",
		 "mat_stone",
		 "mat_stone",
		 "cooked_fish",
		 "cake",
		 "potion_rockskin",
		 "potion_invisibility",
		 "scroll_buffalo",
		 "scroll_returning"},
		{"1-4",
		 "1-5",
		 "100-250",
		 "10-30",
		 "30-500",
		 "30-500",
		 "100-250",
		 "1-4",
		 "1-3",
		 "1-3",
		 "1-3",
		 "1",
		 "1-2"},
		{"5",
		 "4",
		 "3",
		 "3",
		 "3",
		 "3",
		 "3",
		 "2",
		 "3",
		 "2",
		 "3",
		 "1",
		 "4"},
		{"4"}
	},
	
	{  // -- Gilded Chest --
	   //
	   // May contain:
	   // - Mythril bars
	   // - Gold bars
	   // - Mythril
	   // - Gold
	   // - Cake
	   // - Golden Burger
	   // - Potion of Regeneration
	   // - Scroll of Time
	   // - Scroll of the Guardian
	   // - Scroll of Midas
	   // ---
	   
	    {"chest_gilded"},
		{"mat_mythrilbars",
		 "mat_goldbars",
		 "mat_mythril",
		 "mat_gold",
		 "mat_wood",
		 "mat_stone",
		 "cake",
		 "burger",
		 "golden_burger",
		 "potion_regeneration",
		 "scroll_miner",
		 "scroll_guardian",
		 "scroll_midas"},
		{"1-4",
		 "2-7",
		 "10-20",
		 "100-500",
		 "100-500",
		 "100-250",
		 "1-5",
		 "1-4",
		 "2-3",
		 "3-4",
		 "1",
		 "1",
		 "1"},
		{"6",
		 "5",
		 "4",
		 "4",
		 "3",
		 "3",
		 "3",
		 "2",
		 "3",
		 "2",
		 "4",
		 "3",
		 "15"},
		{"5"}
	},
	
	{  // -- Mythril Chest --
	   //
	   // May contain:
	   // - Adamant bars
	   // - Mythril bars
	   // - Gold bars
	   // - Adamantite
	   // - Mythril
	   // - Coal
	   // - Cake
	   // - Burger
	   // - Potion of Regeneration
	   // - Potion of Mystery
	   // - Scroll of Drought
	   // - Scroll of the Undead
	   // ---
	   
	    {"chest_mythril"},
		{"mat_adamantbars",
		 "mat_mythrilbars",
		 "mat_goldbars",
		 "mat_adamantite",
		 "mat_mythril",
		 "mat_gold",
		 "mat_coal",
		 "cake",
		 "burger",
		 "potion_regeneration",
		 "potion_mystery",
		 "scroll_drought",
		 "scroll_undead"},
		{"1-3",
		 "2-4",
		 "2-6",
		 "1-20",
		 "1-30",
		 "1-500",
		 "1-40",
		 "3-5",
		 "3-5",
		 "1-3",
		 "1-3",
		 "1",
		 "1"},
		{"5",
		 "4",
		 "4",
		 "4",
		 "4",
		 "3",
		 "3",
		 "1",
		 "2",
		 "3",
		 "2",
		 "6",
		 "7"},
		{"7"}
	},
	
	{  // -- Adamant Chest --
	   //
	   // May contain:
	   // - Adamant bars
	   // - Mythril bars
	   // - Gold bars
	   // - Adamantite
	   // - Mythril
	   // - Coal
	   // - Wood
	   // - Stone
	   // - Gold
	   // - Cake
	   // - Burger
	   // - Potion of Mystery
	   // - Scroll of Destruction
	   // - Tome of Teleportation
	   // ---
	    {"chest_adamant"},
		{"mat_adamantbars",
		 "mat_mythrilbars",
		 "mat_goldbars",
		 "mat_adamantite",
		 "mat_mythril",
		 "mat_coal",
		 "mat_coal",
		 "mat_wood",
		 "mat_wood",
		 "mat_stone",
		 "mat_stone",
		 "mat_gold",
		 "cake",
		 "burger",
		 "potion_mystery",
		 "scroll_destruction",
		 "aura_teleportation"},
		{"1-5",
		 "2-3",
		 "1-5",
		 "5-20",
		 "10-20",
		 "1-40",
		 "10-20",
		 "1-1000",
		 "250-750",
		 "1-500",
		 "100-300",
		 "1-500",
		 "1-3",
		 "1-3",
		 "1-3",
		 "1",
		 "1-2"},
		{"5",
		 "4",
		 "3",
		 "4",
		 "3",
		 "2",
		 "2",
		 "1",
		 "1",
		 "1",
		 "1",
		 "3",
		 "1",
		 "2",
		 "2",
		 "6",
		 "3"},
		{"7"}
	},
	
	{  // -- Dungeon Chest
	    {"chest_dungeon"},
		{"mat_adamantbars",
		 "mat_mythrilbars",
		 "mat_goldbars",
		 "mat_adamantite",
		 "mat_mythril",
		 "mat_coal",
		 "mat_coal",
		 "mat_wood",
		 "mat_wood",
		 "mat_stone",
		 "mat_stone",
		 "mat_gold",
		 "cake",
		 "burger",
		 "potion_mystery",
		 "scroll_destruction",
		 "aura_teleportation"},
		{"1-5",
		 "2-3",
		 "1-5",
		 "5-20",
		 "10-20",
		 "1-40",
		 "10-20",
		 "1-1000",
		 "250-750",
		 "1-500",
		 "100-300",
		 "1-500",
		 "1-3",
		 "1-3",
		 "1-3",
		 "1",
		 "1-2"},
		{"4",
		 "3",
		 "2",
		 "3",
		 "2",
		 "1",
		 "1",
		 "1",
		 "1",
		 "1",
		 "1",
		 "1",
		 "1",
		 "1",
		 "1",
		 "5",
		 "2"},
		{"15"}
	},
	
	{  // -- Noom's Chest
	    {"chest_noom"},
		{"dragon_chestplate",
		 "dragon_sword",
		 "armadyl_chainmail",
		 "aura_flight",
		 "steel_sword",
		 "steel_chestplate",
		 "adamant_chestplate",
		 "hand_cannon",
		 "musket",
		 "musket",
		 "mat_roundshot",
		 "mat_roundshot",
		 "scroll_returning",
		 "mat_gold"},
		{"1",
		 "1",
		 "1",
		 "1",
		 "3",
		 "2",
		 "1",
		 "1",
		 "1",
		 "1",
		 "30",
		 "30",
		 "5",
		 "2500"},
		{"0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0",
		 "0"},
		{"30"}
	}
};

void onInit( CBlob@ this )
{
	this.getSprite().SetZ(-50); //background
	this.Tag("heavy weight");
}

void onTick( CBlob@ this )
{
	if (this.getTickSinceCreated() == 10)
	{
		if(getNet().isServer())
		{
		    addLoot(this);
        }
	}
}

void addLoot( CBlob@ this )
{
	string name = this.getName();
	
	for(int i = 0; i < chest_loot_tables.length; i++)
	{
		for(int x = 0; x < chest_loot_tables[i][0].length; x++)
		{
			if(chest_loot_tables[i][0][x] == name)
			{
		        u8 loot_count = 0;
				u8 loot_max = parseInt(chest_loot_tables[i][4][XORRandom(chest_loot_tables[i][4].length)]);
				
			    for(int n = 0; n < chest_loot_tables[i][1].length; n++)
				{
					string loot_name = chest_loot_tables[i][1][n];
					
					//printf("name: " + name + " loot name " + loot_name);
					if(XORRandom(parseInt(chest_loot_tables[i][3][n])) == 0)
					{
					    string loot_quantity = chest_loot_tables[i][2][n];
						if    (loot_quantity.find("-") != -1)
						{
							int min = parseInt(loot_quantity.split("-")[0]);
							int max = parseInt(loot_quantity.split("-")[1]);
							
							addItem(this, loot_name, XORRandom(max - min) + min);
						}
						else
						{
							addItem(this, loot_name, parseInt(loot_quantity));
						}
					    
						if(loot_count++ >= loot_max)
							break;
					}
				}
			}
		}
	}
}

void addItem( CBlob@ this, string name, int quantity )
{
    CBlob@ item = server_CreateBlob(name, -1, this.getPosition());
	if    (item !is null)
    {
	    item.server_SetQuantity(quantity);
	    this.server_PutInInventory(item);
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (this.getTeamNum() == 5 || attached.getTeamNum() == 5)
	{
	    this.server_setTeamNum( attached.getTeamNum() );
	}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ byBlob )
{
	bool accessible = this.getTeamNum() == 5 || this.getTeamNum() == byBlob.getTeamNum() || getGameTime() < getRules().get_u32("lost_war_" + this.getTeamNum() + "_" + byBlob.getTeamNum());
    
	return accessible && this.getDistanceTo(byBlob) < 48.0f;
}
