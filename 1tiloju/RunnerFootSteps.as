/* RunnerFootSteps.as
 * modified by: Aphelion
 */

#define CLIENT_ONLY

#include "2efidcr.as";
#include "RunnerCommon.as";

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_onground;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater;
	this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
	
    if (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right))
    {
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
			return;
		
		if ((blob.getNetworkID() + getGameTime()) % (moveVars.walkFactor < 1.0f ? 14 : 8) == 0)
		{
		    CMap@ map = blob.getMap();
			
			f32 volume = Maths::Min(0.3f + Maths::Abs(blob.getVelocity().x) * 0.1f, 1.0f);
			TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;
			
			if (map.isTileGrass(tile))
			    this.PlaySound("../Mods/" + RP_NAME + "/Entities/Characters/Sounds/Footsteps/GrassStep" + (1 + XORRandom(5)) + ".ogg", volume);
			else if (map.isTileWood(tile))
				this.PlaySound("../Mods/" + RP_NAME + "/Entities/Characters/Sounds/Footsteps/WoodStep" + (1 + XORRandom(4)) + ".ogg", volume);
			else if (map.isTileCastle(tile))
				this.PlaySound("../Mods/" + RP_NAME + "/Entities/Characters/Sounds/Footsteps/StoneStep" + (1 + XORRandom(5)) + ".ogg", volume);
			else
				this.PlayRandomSound("/EarthStep", volume);
		}
    }
}
