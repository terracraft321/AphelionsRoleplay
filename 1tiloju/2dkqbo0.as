/* 2dkqbo0.as
 * author: Aphelion
 *
 * Special thanks to FunCTF
 */

#include "2efidcr.as";

#include "MakeMat.as";
#include "37vdq0n.as";

const string cmd_add_grain = "mill add grain";
const string cmd_take_flour = "mill take flour";

const string timer_property = "mill timer";
const string grain_stored_property = "mill grain stored";
const string flour_stored_property = "mill flour stored";
const string grinding_property = "mill grinding";

const int GRAIN_CAPACITY = 10;
const int TICKS_PER_GRAIN = 10;
const int FLOUR_PER_GRAIN = 10;

void onInit( CBlob@ this )
{
	this.addCommandID(cmd_add_grain);
	this.addCommandID(cmd_take_flour);

	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.inventoryButtonPos = Vec2f(-12.0f, 0.0f);
	
    this.getSprite().SetEmitSound( "../Mods/" + RP_NAME + "/Entities/Industry/RP/Mill/MillGrind.ogg" );
	this.getSprite().SetEmitSoundPaused(true);

	this.getCurrentScript().tickFrequency = 29;
}

void onTick( CBlob@ this )
{
	if (getNet().isServer())
	{
	    u8 grain_stored = getGrainStored(this);
		if(grain_stored > 0)
		{
		    if (isGrinding(this))
			{
			    setTimer(this, getTimer(this) - 1);
				
				if (getTimer(this) <= 0)
				{
				    setGrainStored(this, getGrainStored(this) - 1);
					setFlourStored(this, getFlourStored(this) + 1);
					
					if (getGrainStored(this) > 0)
					    setTimer(this, Maths::Floor(TICKS_PER_GRAIN * getMillGrindTimeModifier(this.getTeamNum())));
					else
					    setGrinding(this, false);
				}
			}
			else
			{
				setTimer(this, Maths::Floor(TICKS_PER_GRAIN * getMillGrindTimeModifier(this.getTeamNum())));
			    setGrinding(this, true);
			}
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
    
    const bool grinding = isGrinding(blob);
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
    if (cmd == this.getCommandID(cmd_add_grain))
	{
		u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		u8  grain_amount = Maths::Min(caller.getBlobCount("grain"), getRemainingCapacity(this));
		if (grain_amount > 0)
		{
			caller.TakeBlob("grain", grain_amount);
			
			setGrainStored(this, getGrainStored(this) + grain_amount);
		}
	}
    else if(cmd == this.getCommandID(cmd_take_flour))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		u16 flour_stored = getFlourStored(this);
		if (flour_stored > 0 && getNet().isServer())
		{
		    MakeMat(caller, this.getPosition(), "mat_flour", flour_stored * FLOUR_PER_GRAIN);
			setFlourStored(this, 0);
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	string deposit_text = "Add grain (" + getGrainStored(this) + "/" + GRAIN_CAPACITY + ")";
	string retrieve_text = "Take flour (" + getFlourStored(this) * FLOUR_PER_GRAIN + ") - " + (getTimer(this) > 0 ? "Producing in: " + getTimer(this) + " seconds" :
	                                                                                                                "Add grain to begin producing flour");
	
	CButton@ deposit_button = caller.CreateGenericButton("$grain$", Vec2f(-5.0f, 0.0f), this, this.getCommandID(cmd_add_grain), deposit_text, params);
	deposit_button.SetEnabled(getRemainingCapacity(this) > 0 && caller.getBlobCount("grain") > 0);
	
	CButton@ retrieve_button = caller.CreateGenericButton(28, Vec2f(5.0f, 0.0f), this, this.getCommandID(cmd_take_flour), retrieve_text, params);
	retrieve_button.SetEnabled(getFlourStored(this) > 0);
}

u8 getRemainingCapacity( CBlob@ this )
{
    return GRAIN_CAPACITY - getGrainStored(this);
}

void setGrainStored( CBlob@ this, u8 stored )
{
    this.set_u8(grain_stored_property, stored);
	this.Sync(grain_stored_property, true);
}

u8 getGrainStored( CBlob@ this )
{
	return this.get_u8(grain_stored_property);
}

void setFlourStored( CBlob@ this, u16 stored )
{
    this.set_u16(flour_stored_property, stored);
	this.Sync(flour_stored_property, true);
}

u16 getFlourStored( CBlob@ this )
{
	return this.get_u16(flour_stored_property);
}

void setTimer( CBlob@ this, u16 time )
{
    this.set_u16(timer_property, time);
	this.Sync(timer_property, true);
}

u16 getTimer( CBlob@ this )
{
    return this.get_u16(timer_property);
}

void setGrinding( CBlob@ this, bool grinding )
{
    if (grinding)
	    this.Tag(grinding_property);
	else
		this.Untag(grinding_property);
	
	this.Sync(grinding_property, true);
}

bool isGrinding( CBlob@ this )
{
    return this.hasTag(grinding_property);
}
