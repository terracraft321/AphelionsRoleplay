/* 2dkqbo0.as
 * author: Aphelion
 *
 * Special thanks to FunCTF
 */

#include "MakeMat.as";

const string cmd_produce_flour = "mill produce flour";
const string cmd_retrieve_flour = "mill retrieve flour";

const int TIME_PER_GRAIN = 10;
const int FLOUR_PER_GRAIN = 10;

void onInit( CBlob@ this )
{
	this.addCommandID(cmd_produce_flour);
	this.addCommandID(cmd_retrieve_flour);

	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.inventoryButtonPos = Vec2f(-12.0f, 0.0f);

    this.getSprite().SetEmitSound( "../Mods/" + RP_NAME + "/Entities/Industry/RP/Mill/MillGrind.ogg" );
	this.getSprite().SetEmitSoundPaused(true);

	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
	if(getNet().isServer())
	{
		if(isGrinding(this) && !isGrindingComplete(this))
		{
			decrementGrindingTimer(this);
		}
    }
}

void onInit( CSprite@ this )
{
	CSpriteLayer@ windmill = this.addSpriteLayer( "windmill", "Windmill.png", 33, 33 );
	if (windmill !is null)
	{
		windmill.SetRelativeZ(1.0f);
		windmill.SetOffset(Vec2f(9.0, -8.0));
		windmill.RotateBy(XORRandom(90), Vec2f_zero);
	}
}

void onTick( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
    
    const bool grinding = isGrinding(blob) && !isGrindingComplete(blob);
    if        (grinding)
	{
		this.SetEmitSoundPaused(false);
		this.SetAnimation("grinding");

		CSpriteLayer@ windmill = this.getSpriteLayer("windmill");
		if (windmill !is null && grinding)
		{
			windmill.RotateBy(2.3435, Vec2f_zero);
		}
	}
	else
	{
		this.SetEmitSoundPaused(true);
		this.SetAnimation("inactive");
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID(cmd_produce_flour))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;

		if(!isGrinding(this))
		{
			int amount = getGrainAmount(this);

			this.TakeBlob("grain", amount);

			this.Tag("grinding");
			this.set_u8("grinding_amount", amount);
			this.set_u16("grinding_timer", TIME_PER_GRAIN * amount);
		}
	}
    else if(cmd == this.getCommandID(cmd_retrieve_flour))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }

        if(isGrindingComplete(this))
        {
			if(getNet().isServer())
			{
            	MakeMat(caller, this.getPosition(), "mat_flour", FLOUR_PER_GRAIN * this.get_u8("grinding_amount"));
			}
		
        	this.Untag("grinding");
        	this.set_u8("grinding_amount", 0);
	    	this.set_u16("grinding_timer", 0);
        }
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	if(isGrinding(this))
    {
		if(isGrindingComplete(this))
		{
			CButton@ retrieve_button = caller.CreateGenericButton( 28, Vec2f(5.0f, 0.0f), this, this.getCommandID(cmd_retrieve_flour), "Retrieve flour", params);
		}
		else
		{
			CButton@ retrieve_button = caller.CreateGenericButton( "$mat_flour$", Vec2f(5.0f, 0.0f), this, this.getCommandID(cmd_produce_flour), "Producing flour - Time left: " + getGrindingTimeLeft(this) + " seconds", params);
			if (retrieve_button !is null)
           		retrieve_button.SetEnabled(false);
        }
	}
	else
	{
		CButton@ produce_button = caller.CreateGenericButton( "$mat_flour$", Vec2f(5.0f, 0.0f), this, this.getCommandID(cmd_produce_flour), "Produce flour", params);
		if(produce_button !is null)
           produce_button.SetEnabled(getGrainAmount(this) > 0);
	}
}

int getGrainAmount( CBlob@ this )
{
	return this.getBlobCount("grain");
}

bool isGrinding( CBlob@ this )
{
    return this.hasTag("grinding");
}

bool isGrindingComplete( CBlob@ this )
{
    return getGrindingTimeLeft(this) <= 0;
}

u16 getGrindingTimeLeft( CBlob@ this )
{
    return this.get_u16("grinding_timer");
}

void decrementGrindingTimer( CBlob@ this )
{
    this.set_u16("grinding_timer", getGrindingTimeLeft(this) - 1);
	this.Sync("grinding_timer", true);
}
