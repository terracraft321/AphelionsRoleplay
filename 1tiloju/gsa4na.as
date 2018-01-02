#define SERVER_ONLY

const f32 heal_rate = 0.1f; // 0.2 hearts per second

void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
	CMap@ map = getMap();
	
	Vec2f pos = this.getPosition();
	float dayTime = map.getDayTime();
	if  ((dayTime >= 0.15f && dayTime <= 0.85f) && (map.getTile(this.getPosition()).type == CMap::tile_empty || (pos.y < map.tilemapheight * map.tilesize * 0.80f &&
		                                                                                                        !map.rayCastSolid(pos, Vec2f(pos.x, pos.y - 100.0f)))))
	{
	    this.server_Heal(heal_rate / 4);
	    return;
	}
	
	this.server_Heal(heal_rate);
}
