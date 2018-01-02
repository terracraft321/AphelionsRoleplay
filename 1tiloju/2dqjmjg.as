/* 2dqjmjg.as
 * author: Skinney & Strathos
 * author: Aphelion
 */

#include "AnimalConsts.as";

int g_nextOinkTime = 0;

//sprite
void onInit(CSprite@ this)
{
    this.ReloadSprites(0,0);
}

void onTick( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
    
    if (!blob.hasTag("dead"))
    {
		f32 x = Maths::Abs(blob.getVelocity().x);
		if (x > 0.02f)
			this.SetAnimation("walk");
		else if(this.isAnimationEnded())
			this.SetAnimation("idle");
		
		if (getGameTime() > g_nextOinkTime) 
	    {
		    this.PlaySound( "/PigOink" + (1 + XORRandom(3)) + ".ogg" );
		    g_nextOinkTime = getGameTime() + ((10 + XORRandom(23)) * 30);
	    }
	}
	else
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

//blob
void onInit( CBlob@ this )
{
	this.getSprite().PlaySound("/PigOink" + (1 + XORRandom(3)) + ".ogg");

	//brain
	this.set_u8(personality_property, SCARED_BIT);
	this.getBrain().server_SetActive( true );
	this.set_f32(target_searchrad_property, 30.0f);
	this.set_f32(terr_rad_property, 75.0f);
	this.set_u8(target_lose_random,14);
	
	//for steaks
	this.set_u8("number of steaks", 1 + XORRandom(2)); // 1-2
	
	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);	  	
	this.Tag("flesh");

	this.getShape().SetOffset(Vec2f(0,6));
	
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 480.0f;
	
	// movement
	AnimalVars@ vars;
	if (!this.get( "vars", @vars ))
		return;
	vars.walkForce.Set(10.0f, -0.1f);
	vars.runForce.Set(20.0f, -1.0f);
	vars.slowForce.Set(5.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -20.0f);
	vars.maxVelocity = 2.2f;
}

void onTick( CBlob@ this )
{
	f32 x = this.getVelocity().x;		
	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft( x < 0 );
	}
	else
	{
		if (this.isKeyPressed(key_left)) {
			this.SetFacingLeft( true );
		}
		if (this.isKeyPressed(key_right)) {
			this.SetFacingLeft( false );
		}
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !blob.hasTag("flesh");
}
