// The Barrier seperating the Heavenly Citadel from the Land

bool barrier_set = false;

bool shouldBarrier( CRules@ this )
{
	return true; // always
}

void onTick( CRules@ this )
{
	if ( shouldBarrier(this) )
	{
		if(!barrier_set)
		{
			barrier_set = true;
			addBarrier();
		}
		
		f32 x1, x2, y1, y2;
		getBarrierPositions( x1, x2, y1, y2 );
		const f32 middle = x1+(x2-x1)*0.5f;

		CBlob@[] blobsInBox;
		if (getMap().getBlobsInBox( Vec2f(x1,y1), Vec2f(x2,y2), @blobsInBox ))
		{
			for (uint i = 0; i < blobsInBox.length; i++)
			{
				CBlob@ b = blobsInBox[i];
				if (b.getTeamNum() != 4)
					b.AddForce(Vec2f(0, 3000));
			}
		}
	}
	else
	{
		if(barrier_set)
		{
			removeBarrier();
			barrier_set = false;
		}
	}
}

void Reset( CRules@ this )
{
	barrier_set = false;
}

void onRestart( CRules@ this )
{
	Reset( this );
}		

void onInit( CRules@ this )
{
	Reset( this );
}

void onRender( CRules@ this )
{
	if (shouldBarrier( this ))
	{
		f32 x1, x2, y1, y2;
		getBarrierPositions( x1, x2, y1, y2 );
		GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(Vec2f( x1, y1 )), getDriver().getScreenPosFromWorldPos(Vec2f( x2, y2)), SColor( 50, 235, 0, 0 ) ); 
	}
}

void getBarrierPositions( f32 &out x1, f32 &out x2, f32 &out y1, f32 &out y2 )
{
	CMap@ map = getMap();
	
	x1 = 0;
	x2 =  map.tilemapwidth * map.tilesize;
	y1 = 45 * map.tilesize;
	y2 = 55 * map.tilesize;
	
	//y1 = ((map.tilemapheight * map.tilesize) / 2) - 300;
	//y2 = ((map.tilemapheight * map.tilesize) / 2) - 150;
}

/**
 * Adding the barrier sector to the map
 */
void addBarrier()
{
	CMap@ map = getMap();
	
	f32 x1, x2, y1, y2;
	getBarrierPositions( x1, x2, y1, y2 );
	
	Vec2f ul(x1,y1);
	Vec2f lr(x2,y2);
	
	if(map.getSectorAtPosition( (ul + lr) * 0.5, "barrier" ) is null)
		map.server_AddSector( Vec2f(x1, y1), Vec2f(x2, y2), "barrier" );
}

/**
 * Removing the barrier sector from the map
 */
void removeBarrier()
{
	CMap@ map = getMap();
	
	f32 x1, x2, y1, y2;
	getBarrierPositions( x1, x2, y1, y2 );
	
	Vec2f ul(x1,y1);
	Vec2f lr(x2,y2);
	
	map.RemoveSectorsAtPosition( (ul + lr) * 0.5 , "barrier" );
}
