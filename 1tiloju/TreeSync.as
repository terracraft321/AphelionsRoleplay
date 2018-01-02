
#include "TreeCommon.as"
#include "FireCommon.as";
#include "Help.as";

f32 segment_length = 14.0f;

void InitVars( CBlob@ this )
{
    TreeSegment[] segments;
    this.set("TreeSegments", segments);

	AddIconToken( "$Tree$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 1 );
	AddIconToken( "$Axe$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 13 );

	SetHelp( this, "help action2", "builder", "$Axe$$Tree$Chop tree    $RMB$", "", 3 ); 
	SetHelp( this, "help jump", "archer", "$Tree$Climb tree    $KEY_W$", "", 2 );
}

void InitTree( CBlob@ this, TreeVars@ vars )
{
    this.server_SetHealth(1.0f);
    this.set_s16( burn_duration , 1024 ); //burn down
	this.Tag("tree");
	
    CShape@ shape = this.getShape();
    ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;
	
	this.SetFacingLeft(XORRandom(300) > 150);

	Vec2f pos = this.getPosition();
	
	//prevent building overlap
	CMap@ map = this.getMap();
    const f32 radius = map.tilesize/2.0f;
	map.server_AddSector( Vec2f(pos.x - radius, pos.y - radius), Vec2f(pos.x + radius, pos.y + radius), "no build", "", this.getNetworkID() );

    if (this.hasTag("startbig"))
    {
        int height = vars.max_height;
        int i = 0;

        while (i < height + 6)
        {
            vars.last_grew_time = getGameTime() - vars.growth_time;
            DoGrow( this, vars );
            i++;
        }

		this.getCurrentScript().tickFrequency = 0;
    }
    else if (this.exists("height"))
    {
        // recreate growth
        u8 height = this.get_u8("height");
					   
        while (vars.height < height)
        {
            vars.last_grew_time = getGameTime() - vars.growth_time;
            DoGrow( this, vars );
			height++;
        }

        if (height > 1)
        {
            DoGrow( this, vars );
            DoGrow( this, vars );
            DoGrow( this, vars );
            DoGrow( this, vars );
            DoGrow( this, vars );
            DoGrow( this, vars );
        }

		this.getCurrentScript().tickFrequency = 0;
    }
}

void onTick( CBlob@ this )
{
    this.getSprite().SetZ( 50.0f ); // push to foreground

    if (!DoCollapseWhenBelow(this, 0.0f)) // if not collapsing
    {
        TreeVars@ vars;
        this.get("TreeVars", @vars);

        if(vars !is null && (getGameTime() - vars.last_grew_time >= vars.growth_time))
        {
            vars.last_grew_time = getGameTime();
            DoGrow( this, vars );
        }
    }
}

bool treeBreakableTile ( CMap@ map, TileType t )
{
	return map.isTileWood(t) || map.isTileCastle(t);
}

void DoGrow( CBlob@ this, TreeVars@ vars )
{
    if (vars.height < vars.max_height)
    {
		bool raycast = false;
		bool unbreakable = false;
		bool killtwo = false;
		
		Vec2f pos = this.getPosition();
		Vec2f partpos = pos + Vec2f( 0, -segment_length*(f32(vars.height)) );
		Vec2f endpos = partpos;

		CMap@ map = this.getMap();
		if (map !is null)
		{
			raycast = map.rayCastSolid(pos, partpos, endpos);
			if(raycast)
			{
				unbreakable = !treeBreakableTile(map, map.getTile(endpos).type );
				if(!unbreakable && (partpos - endpos).Length() > 4.0f)
				{
					unbreakable = !treeBreakableTile(map, map.getTile(endpos + Vec2f(0,-8)).type );
					killtwo = true;
				}
			}
		}
		
		if(unbreakable)
		{
			if (vars.height > 2)
			{
				//truncate growth and continue
				vars.max_height = vars.height;
			}
			else
			{
				//stop growth for now, if it becomes clear we can continue
				return;
			}
		}
		else
		{
			if(raycast && map !is null)
			{
				map.server_DestroyTile(endpos, 100.0f, this);
				if(killtwo)
				{
					map.server_DestroyTile(endpos + Vec2f(0,-8), 100.0f, this);
				}
			}
			
			vars.height++;
			addSegment(this, vars.height);
			
		}
    }

    CMap@ map = getMap();
    Vec2f pos = this.getPosition();
    f32 radius = map.tilesize/2.0f;
							
    if (map !is null/* && getNet().isServer()*/)
    {
        CMap::Sector@ sector_nobuild = map.getSectorAtPosition( pos, "no build" );
        CMap::Sector@ sector_tree = map.getSectorAtPosition( pos, "tree" );

        if (sector_nobuild is null)
        {
            @sector_nobuild = map.server_AddSector( Vec2f(pos.x - radius, pos.y - radius), Vec2f(pos.x + radius, pos.y + radius), "no build", "", this.getNetworkID() );
        }

        if (sector_tree is null)
        {
            @sector_tree = map.server_AddSector( Vec2f(pos.x - radius, pos.y - radius), Vec2f(pos.x + radius, pos.y + radius), "tree", "", this.getNetworkID() );
        }

		if (sector_nobuild !is null && sector_tree !is null)
		{
			sector_nobuild.upperleft.y = sector_tree.upperleft.y = sector_nobuild.lowerright.y - (vars.height * segment_length);
			//printf("gtowe " + vars.height * segment_length );
		}
    }

    GrowSegments( this, vars );
    GrowSprite( this.getSprite(), vars );
    vars.grown_times++;
	
	if ( vars.grown_times >= 15)
		this.getCurrentScript().tickFrequency = 0;

	this.set_u8("height", vars.height);
}

void addSegment( CBlob@ this, s32 height )
{
    TreeSegment segment;
    segment.grown_times = 0;
    segment.gotsprites = false;
    segment.height = height;
    segment.flip = (height + this.getNetworkID()) % 2 == 0;
    segment.length = segment_length;
    TreeSegment@ tip = getLastSegment(this);

    if (tip !is null)
    {
        segment.start_pos = tip.end_pos;
        segment.angle = tip.angle;
    }
    else //first segment
    {
        segment.start_pos = Vec2f(0,0);
        segment.angle = 0;
    }

    segment.end_pos = segment.start_pos + Vec2f(0,-segment.length).RotateBy(segment.angle,Vec2f(0,0));
    this.push("TreeSegments", segment);
    this.server_Heal(0.777f);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    this.Damage( damage, hitterBlob );
	
    // Tree collapse
    bool dir = velocity.x < 0.0f;
    this.set_bool("cut_down_fall_side", dir);

    if (this.getHealth() <= 0.0f)
    {							   		
        DoCollapseWhenBelow(this, 0.0f );
    }
    return 0.0f;
}
