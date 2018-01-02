/* 3dt6pbk.as
 */

#include "3kemuc.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);
	
    this.getSprite().getConsts().accurateLighting = true;
    
    CShape@ shape = this.getShape();
    shape.SetOffset(Vec2f(0,-3));
    shape.AddPlatformDirection( Vec2f(0,-1), 70, false );
    shape.SetRotationsAllowed( false );
	
	this.Tag("blocks sword");
	
	MakeDamageFrame( this );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	if (!isOpen(this))
	{
		MakeDamageFrame( this );
	}
}

void MakeDamageFrame( CBlob@ this )
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ( (hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool isOpen( CBlob@ this )
{
	return !this.getShape().getConsts().collidable;
}

void setOpen( CBlob@ this, bool open, bool animate )
{
	CSprite@ sprite = this.getSprite();

	if (open)
	{
		sprite.SetZ(-100.0f);
		
		if(animate)
		{
		    sprite.SetAnimation("default");
			sprite.PlaySound("/platform_open.ogg");
			sprite.animation.frame = 4;
		}
		
		this.getShape().getConsts().collidable = false;

		// drop boulder on team platforms
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			CBlob@ blob = this.getTouchingByIndex(step);
			blob.getShape().checkCollisionsAgain = true;
		}
	}
	else
	{
		sprite.SetZ(100.0f);
		
		if(animate)
		{
			//sprite.PlaySound("/platform_close.ogg"); annoying
		    MakeDamageFrame(this);
		}
		
		this.getShape().getConsts().collidable = true;
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.getTeamNum() == this.getTeamNum() || getDisposition(getRules(), this.getTeamNum(), blob.getTeamNum()) == DISPOSITION_ALLIED)
	{
		return !isOpen( this );
	}
	else
	{
		return !opensThis(this, blob) && !isOpen(this);
	}
}

bool opensThis(CBlob@ this, CBlob@ blob)
{
	return blob.isKeyPressed(key_down) || ((blob.getTeamNum() != this.getTeamNum() && getDisposition(getRules(), this.getTeamNum(), blob.getTeamNum()) != DISPOSITION_ALLIED) && !isOpen(this) && blob.isCollidable() && (blob.hasTag("player") || blob.hasTag("vehicle")));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
    if (blob !is null)
    {
        if (opensThis(this, blob))
        {
            setOpen(this, true, this.getTeamNum() != blob.getTeamNum());			
        }
    }
}

void onEndCollision( CBlob@ this, CBlob@ blob )
{
	if (blob !is null)
	{
		bool touching = false;
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			CBlob@ blob = this.getTouchingByIndex(step);
			
			if (blob.isCollidable())
			{
				touching = true;
				break;
			}
		}

		if (!touching)
		{
			setOpen(this, false, true);
		}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}
