// 33t7g3j.as

#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.server_setTeamNum(-1);
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
    this.animation.frame = (netID % this.animation.getFramesCount());
    this.SetFacingLeft( ((netID % 13) % 2) == 0 );
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{	
	return blob !is null && blob.hasTag("flesh");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(doesCollideWithBlob(this, blob))
	{
	    this.server_Hit(blob, blob.getPosition(), blob.getVelocity() * -1, 1.0f, Hitters::spikes, true);
    }
}
