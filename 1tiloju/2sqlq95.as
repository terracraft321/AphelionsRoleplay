/* 2sqlq95.as
 * author: Aphelion
 */

#include "30j68o4.as";

const string cmd_exit_dungeon = "exit dungeon";

void onInit( CBlob@ this )
{
	this.addCommandID(cmd_exit_dungeon);
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getCurrentScript().tickFrequency = 20;
}

void onTick( CBlob@ this )
{
	CBlob@[] nearBlobs;
    getMap().getBlobsInRadius(this.getPosition(), 64.0f, @nearBlobs);
	
	for (uint i = 0; i < nearBlobs.length; i++)
    {
		CBlob@ nearBlob = nearBlobs[i];
		if    (nearBlob !is null)
	    {
            string name = nearBlob.getName();
            if    (name == "builder" || name == "crate")
            {
			    nearBlob.server_Die(); // bye bye			
			}			
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton(8, Vec2f_zero, this, this.getCommandID(cmd_exit_dungeon), "Exit the dungeon", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID(cmd_exit_dungeon))
	{
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		
		if (caller !is null)
		{
			sendMessage(caller.getPlayer(), "You exit the dungeon...");
			
			// away we go!
			CBlob@[] entrances;
			getBlobsByName( "dungeon_entrance", @entrances );
			
			if (entrances.length > 0)
			{
				// move caller
				caller.setPosition(entrances[0].getPosition());
				caller.setVelocity(Vec2f_zero);			  
				caller.getShape().PutOnGround();
				caller.Untag("dungeon");
				
				if (caller.isMyPlayer())
				{
					Sound::Play( "Travel.ogg" );
				}
				else
				{
					Sound::Play( "Travel.ogg", this.getPosition() );
					Sound::Play( "Travel.ogg", caller.getPosition() );
				}
			}
		}
	}
}
