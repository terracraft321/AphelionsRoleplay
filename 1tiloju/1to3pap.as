// 1to3pap.as
// @author Aphelion
// If you want to use this you must ask me. I can be contacted on the KAG forums.

#include "AnimalConsts.as";

const uint COLOR = 0xFF7affa0;

void onInit(CSprite@ this)
{
	this.getBlob().set_u8("colour", COLOR);
    this.ReloadSprites(COLOR, 0);
}

void onInit(CBlob@ this)
{
    // force no team
	this.server_setTeamNum(-1);
	
	// free movement
	this.getShape().SetGravityScale(0.0f);
	
	// light
	this.SetLight(false);
    this.SetLightRadius(24.0f);
    this.SetLightColor(SColor(200, 249, 215, 126));
	
	this.Tag("flesh");
	
	this.getCurrentScript().tickFrequency = 2 * 30;
}

void onTick(CBlob@ this)
{
    f32 time = getMap().getDayTime();
	if(time >= 0.85 || time <= 0.15)
	{
	    if(this.getLightRadius() < 12.0f)
		{
		    this.SetLightRadius(12.0f);
		}
		else if(this.getLightRadius() < 24.0f)
		{
		    this.SetLightRadius(24.0f);
		}
	    this.SetLight(true);
	    this.getSprite().SetVisible(true);
	}
	else
	{
	    if(this.getLightRadius() == 24.0f)
		{
		    this.SetLightRadius(12.0f);
		}
		else if(this.getLightRadius() == 12.0f)
		{
		    this.SetLightRadius(0.0f);
		}
		else
		{
		    this.SetLight(false);
	        this.getSprite().SetVisible(false);
		}
	}
	
	if(this.isInWater())
	{
	    this.server_Die();
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
