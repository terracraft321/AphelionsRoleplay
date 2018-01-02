// 2lolrnb.as
// @author Aphelion
// If you want to use this you must ask me. I can be contacted on the KAG forums.

#define SERVER_ONLY

const uint MIN_FIREFLIES = 10;

void onTick(CRules@ this)
{
	if (getGameTime() % 89 != 0) return;
	if (XORRandom(512) < 256) return; //50% chance of actually doing anything
	
	CMap@ map = getMap();
	
    const f32 time = map.getDayTime();
	
	if (time >= 0.85 || time <= 0.15) // No spawning in the day
	{
		CBlob@[] fireflies;
		getBlobsByName( "firefly", @fireflies );
		
		if (fireflies.length < MIN_FIREFLIES)
		{
			f32 x = (f32((getGameTime() * 997) % map.tilemapwidth) + 0.5f) * map.tilesize;
			
			Vec2f top = Vec2f(x, map.tilesize);
			Vec2f bottom = Vec2f(x, map.tilemapheight * map.tilesize);
			Vec2f end;
			
			if (map.rayCastSolid(top, bottom, end))
			{
				f32 y = end.y;
				int i = 0;
				while(i ++ < 3)
				{
					Vec2f pos = Vec2f(x, y - i * map.tilesize);
					
					if (!map.isInWater(pos) && !map.isTileSolid(map.getTile(pos)))
					{
						server_CreateBlob( "firefly", -1, pos );
						break;
					}
				}
			}
		}
	}
}
