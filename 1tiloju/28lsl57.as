/* 28lsl57.as
 * author: Aphelion
 *
 * The script for an Ore deposit. Handles the respawning and mining logic.
 */
 
#include "3eao5se.as";

#include "Hitters.as";
#include "MakeMat.as";
#include "ParticleSparks.as";
 
const u16 RESPAWN_TIME = 300 * 30;
const f32 YIELD_PROBABILITY = 0.50f;

void onInit( CSprite@ sprite )
{
    sprite.SetZ(-50);
    sprite.SetFacingLeft(((sprite.getBlob().getNetworkID() % 13) % 2) == 0);
}

void onTick( CSprite@ sprite )
{
    if(isDepleted(sprite.getBlob()))
	    sprite.animation.frame = 1;
	else
	    sprite.animation.frame = 0;
}

void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	shape.SetStatic(true);
	shape.SetGravityScale(0.0f);
	
	this.set_u32("depleteRespawnTime", 0);
	
	this.getCurrentScript().tickFrequency = 33;
}

void onTick( CBlob@ this )
{
    if(getNet().isServer())
	{
	    const u32 time = getGameTime();
		const u32 depleteRespawnTime = this.get_u32("depleteRespawnTime");
        const bool depleted = isDepleted(this);
	    
		if(depleted)
		{
	        if(depleteRespawnTime == 0)
			{
	            this.set_u32("depleteRespawnTime", getGameTime() + RESPAWN_TIME);
			}
	        else if(time >= depleteRespawnTime)
			{
	            this.server_SetHealth(this.getInitialHealth());
				this.set_u32("depleteRespawnTime", 0);
			}
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if(damage <= 0.0f) return damage;
	
	if(isDepleted(this) || customData != Hitters::builder)
	{
	    if(getNet().isClient())
		{
			this.getSprite().PlaySound("/metal_stone.ogg");
			sparks(worldPoint, velocity.Angle(), damage);
		}
	    return 0.0f;
	}
	else if(getNet().isServer())
	{
	    const bool humans = raceIs(hitterBlob, RACE_HUMANS);
	    const bool dwarves = raceIs(hitterBlob, RACE_DWARVES);
	    const bool elves = raceIs(hitterBlob, RACE_ELVES);
	    const bool orcs = raceIs(hitterBlob, RACE_ORCS);
		const bool angels = raceIs(hitterBlob, RACE_ANGELS);
		
        this.Damage(damage, hitterBlob);
		
        bool yield_ore = (orcs || angels) ? XORRandom(1024) / 1024.0f < (YIELD_PROBABILITY * 1.5) :
                                            XORRandom(1024) / 1024.0f <  YIELD_PROBABILITY;
		if  (yield_ore)
		{
		    MakeMat(hitterBlob, worldPoint, "mat_coal", 2 * damage);
		}
		else
		{
		    MakeMat(hitterBlob, worldPoint, "mat_stone", (dwarves || angels) ? 6 * damage : humans ? 5 * damage : 4 * damage);
		}
	}
    return damage;
}

bool isDepleted( CBlob@ this )
{
    return this.getHealth() <= 1.0f;
}
