/* 24ena9k.as
 * author: Aphelion
 */

#include "30j68o4.as";
#include "GameplayEvents.as";

const string cmd_enter_dungeon = "enter dungeon";

void onTick( CSprite@ this )
{
    if(isDungeonOpen(getRules()))
	   this.animation.frame = 1;
}

void onInit( CBlob@ this )
{
	this.addCommandID(cmd_enter_dungeon);
	
	this.set_TileType("background tile", CMap::tile_castle_back);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton(8, Vec2f_zero, this, this.getCommandID(cmd_enter_dungeon), "Enter the dungeon", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID(cmd_enter_dungeon))
	{
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		
		if (caller !is null)
		{
		    if(isDungeonOpen(getRules()) || caller.getTeamNum() == 5)
			{
				if (caller.getName() == "builder")
				    sendMessage(caller.getPlayer(), "Noom's dungeon is no place for a builder.");
				else if (caller.getCarriedBlob() !is null)
				    sendMessage(caller.getPlayer(), "You'll need to let go of what you're carrying in order to enter the dungeon.");
				else
				{
				    sendMessage(caller.getPlayer(), "You enter the dungeon...");
					
				    // to the dungeon!
					Enter(this, caller);
				}
			}
			else
			{
			    sendMessage(caller.getPlayer(), "The gate is shut, but you are able to make out an inscription on one of the Pillars.");
				sendMessage(caller.getPlayer(), "It says: 'Once they have no way out, the gate shall open so that you might vanquish them all'");
			}
		}
	}
}

void Enter( CBlob@ this, CBlob@ caller )
{
	CBlob@[] exits;
	getBlobsByName( "dungeon_exit", @exits );
	
	if (exits.length > 0)
	{
		caller.setPosition(exits[0].getPosition());
		caller.setVelocity(Vec2f_zero);			  
		caller.getShape().PutOnGround();
		caller.Tag("dungeon");
		
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

bool isDungeonOpen( CRules@ rules )
{
    return rules.get_bool("dungeon_open");
}
