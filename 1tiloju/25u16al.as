/* 25u16al.as
 * author: Aphelion
 */

#include "38p58pt.as";

const string dungeon_open_property = "dungeon_open";
const string dungeon_cleared_property = "dungeon_cleared";

void onRestart( CRules@ this )
{
    if (getNet().isServer())
	{
		this.set_bool(dungeon_open_property, false);
		this.set_bool(dungeon_cleared_property, false);

		this.Sync(dungeon_open_property, true);
		this.Sync(dungeon_cleared_property, true);
	}
}
 
void onBlobDie( CRules@ this, CBlob@ blob )
{
    string name = blob.getName();
	if    (name == "noom")
	{
		sendMessage("The evil necromancer, Noom, has been defeated!");
		
		if (getNet().isServer())
		{
			CBlob@[] doors;
			getBlobsByName("dungeon_door", @doors);
			
			for(uint i = 0; i < doors.length; i++)
			{
				doors[i].server_setTeamNum(255); // open
			}
			
			this.set_bool(dungeon_cleared_property, true);
			this.Sync(dungeon_cleared_property, true);
		}
	}
	else if(name == "zombie_portal")
	{
		if (getNet().isServer())
		{
			CBlob@[] portals;
			getBlobsByName("zombie_portal", @portals);
			
			this.set_bool(dungeon_open_property, portals.length == 0);
			this.Sync(dungeon_open_property, true);
		}
	}
}

bool isDungeonOpen( CRules@ this )
{
    return this.get_bool(dungeon_open_property);
}

bool isBossDefeated( CRules@ this )
{
    return this.get_bool(dungeon_cleared_property);
}
