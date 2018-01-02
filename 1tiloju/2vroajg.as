/* 2vroajg.as
 * author: Aphelion
 */

#include "MakeMat.as";
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
    this.getSprite().getConsts().accurateLighting = true;  
	
    this.Tag("place norotate");
	this.Tag("blocks sword");
	this.Tag("blocks water");
	
	this.server_setTeamNum(-1);
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;		 
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if(damage <= 0.0f) return damage;
	
	sparks(worldPoint, velocity.Angle(), damage, 5, SColor( 255, 255, 214, 125));
	MakeMat(hitterBlob, worldPoint, "mat_gold", 10 * damage);
    return damage;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
