// 106d12b.as
// @author Aphelion
// If you want to use this you must ask me. I can be contacted on the KAG forums.

bool escape_water_right = false;

void onInit( CMovement@ this )
{
	this.getCurrentScript().removeIfTag	= "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	escape_water_right = XORRandom(512) < 256;
}

void onTick( CMovement@ this )
{
    CBlob@ blob = this.getBlob();
	if(!blob.getSprite().isVisible())
	    return;
	
	f32 x_force = 0.0f;
	f32 y_force = 0.0f;
	
	if(blob.isInWater())
	{
	    x_force += escape_water_right ? 1.0f : -1.0f;
	    y_force -= 3.0f;
	}
	else
	{
	    x_force = XORRandom(512) < 256 ? 0.0f + (XORRandom(5) * 0.10) : (-0.0f) - (XORRandom(5) * 0.10);
	    y_force = XORRandom(512) < 128 ? 0.0f + (XORRandom(5) * 0.10) : (-0.0f) - (XORRandom(10) * 0.10);
	}
	
	// Oh, firefly, oh firefly, never fly too high.
	if(blob.getPosition().y < 250.0f)
	{
	    y_force += 0.5f;
	}
	
	blob.AddForce(Vec2f(x_force, y_force) * blob.getMass());
}
