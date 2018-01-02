/* 1c9olrl.as
 * author: Aphelion
 *
 * A loot table script for NPC blobs.
 * 
 * (WIP)
 */

#define SERVER_ONLY
 
// format = {blobs applied to this table}, {loot blobs}, {quantity of loot}, {loot chance}, {loot cap; a number in this array will be selected as the cap}
const string[][][] loot_tables = {
	{  // -- Skeleton
        {"skeleton"}, 
		{"mat_gold", "scroll_returning", "potion_mystery", "potion_swiftness", "grain"}, 
		{"100", "1", "1", "1", "1"},
		{"30", "10", "5", "3", "3"}, 
		{"1"}
	},
	
	{  // -- Zombie
        {"zombie"}, 
		{"mat_gold", "scroll_midas", "scroll_undead", "scroll_guardian", "scroll_miner", "scroll_returning", "scroll_light", "potion_mystery", "potion_feather", "egg"}, 
		{"100", "1", "1", "1", "1", "1", "1", "1", "1", "1"},
		{"60", "40", "20", "20", "20", "5", "7", "5", "3", "3"}, 
		{"1", "2"}
	},
	
	{  // -- Zombie Knight
	    {"zombie_knight"},
		{"mat_gold", "scroll_midas", "scroll_undead", "scroll_guardian", "scroll_miner", "scroll_destruction", "scroll_returning", "potion_mystery", "potion_regeneration", "heart"},
		{"300", "1", "1", "1", "1", "1", "1", "1", "1", "1"},
		{"30", "20", "10", "10", "10", "10", "5", "3", "3", "3"},
		{"1", "2", "3"}
	}
};

void onBlobDie( CRules@ this, CBlob@ blob )
{
    if(blob.getPlayer() is null)
	{
	    string name = blob.getName();
		
	    for(int i = 0; i < loot_tables.length; i++)
		{
		    for(int x = 0; x < loot_tables[i][0].length; x++)
			{
			    if(loot_tables[i][0][x] == name)
				{
		            u8 loot_dropped = 0;
					u8 max_loot_dropped = parseInt(loot_tables[i][4][XORRandom(loot_tables[i][4].length)]);
					
				    for(int n = 0; n < loot_tables[i][1].length; n++)
					{
					    string loot_name = loot_tables[i][1][n];
						
						if(XORRandom(parseInt(loot_tables[i][3][n])) == 0)
						{
						    DropLoot(loot_name, blob.getTeamNum(), blob.getPosition(), parseInt(loot_tables[i][2][n]));
							
							if(loot_dropped++ >= max_loot_dropped)
							    break;
						}
					}
				}
			}
		}
	}
}

void DropLoot( string name, u8 team, Vec2f pos, int quantity)
{
	CBlob@ blob = server_CreateBlob(name, team, pos);
	blob.server_SetQuantity(quantity);
}
