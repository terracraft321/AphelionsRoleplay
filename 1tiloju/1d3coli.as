/* 1d3coli.as
 * author: Aphelion
 */

#include "StandardRespawnCommand.as";

const Vec2f classButtonPos(-15.0f, 5.0f);

void onInit( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
	
    string filename = CFileMatcher("/Base.png").getFirst();
    const int blob_team = blob.getTeamNum();
    const int blob_skin = blob.getSkinNum();

    this.SetZ( -50.0f ); // push to background
	
	// Undead base
	if (blob.getTeamNum() == 5)
	{
		filename = CFileMatcher("/UndeadBase.png").getFirst();

		if (this.getFilename() != filename)
		{
			this.ReloadSprite(filename, this.getConsts().frameWidth, this.getConsts().frameHeight,
	                                    this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		}
	}
	
    // Tower sprites
    {
        Vec2f cap_offset = Vec2f(0, -24);
        Vec2f flag_offset = Vec2f(-4, -24);

        CSpriteLayer@ tower_cap = this.addSpriteLayer( "tower_cap", filename , 32, 32, blob_team, blob_skin );

        if (tower_cap !is null)
        {
            Animation@ anim = tower_cap.addAnimation( "default", 0, false );
            anim.AddFrame(16);

            tower_cap.SetOffset(cap_offset + Vec2f(0.0f, -16.0f));
            tower_cap.SetRelativeZ(-10.0);
        }

        CSpriteLayer@ tower = this.addSpriteLayer( "tower", filename , 32, 32, blob_team, blob_skin );

        if (tower !is null)
        {
            Animation@ anim = tower.addAnimation( "default", 0, false );
            anim.AddFrame(17);

            tower.SetOffset(cap_offset + Vec2f(0.0f, 16.0f));
            tower.SetRelativeZ(-10.0);
        }

        CSpriteLayer@ tower_flagpole = this.addSpriteLayer( "tower_flagpole", "Entities/Special/CTF/CTF_Flag.png", 16, 32, blob_team, blob_skin );

        if (tower_flagpole !is null)
        {
            Animation@ anim = tower_flagpole.addAnimation( "default", 0, false );
            anim.AddFrame(3);

            tower_flagpole.SetOffset(cap_offset + flag_offset + Vec2f(16.0f, -16.0f));
            tower_flagpole.SetRelativeZ(-10.0);
        }

        CSpriteLayer@ tower_flag = this.addSpriteLayer( "tower_flag", "Entities/Special/CTF/CTF_Flag.png", 32, 16, blob_team, blob_skin );

        if (tower_flag !is null)
        {
            Animation@ anim = tower_flag.addAnimation( "default", 3, true );
            anim.AddFrame(0);
            anim.AddFrame(2);
            anim.AddFrame(4);
            anim.AddFrame(6);

            tower_flag.SetOffset(cap_offset + flag_offset + Vec2f(28.0f, -20));
            tower_flag.SetRelativeZ(-11.0);
        }
    }
}

void onInit( CBlob@ this )
{
    this.CreateRespawnPoint("base", Vec2f(-48.0f, 16.0f));
	
    InitClasses( this );
	
	this.Tag("change class drop inventory");
    this.Tag("respawn");
	
    this.getShape().SetStatic(true);
    this.getShape().getConsts().mapCollisions = false;
	this.getSprite().getConsts().accurateLighting = true;
    
    // minimap
    this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
    
	this.inventoryButtonPos.Set(0.0f, 10.0f);
	
	// add no build sectors
	AddSectors(this);
    
	// configure portal
    if (this.getTeamNum() == 5)
	{
	    this.set_Vec2f("teleport button pos", Vec2f(12.0f, 5.0f));
	    this.Tag("portal");
		
		// LIGHT
		this.SetLight(true);
		this.SetLightRadius(96.0f);
		this.SetLightColor(SColor(255, 255, 0, 0));
	}
	
    // add bed
	else
	{
	    SpawnBed(this);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream@ params )
{
	onRespawnCommand( this, cmd, params );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    if (caller.getDistanceTo(this) < 48.0f && caller.getTeamNum() == this.getTeamNum())
    {
        CBitStream params;
        params.write_u16(caller.getNetworkID());
        caller.CreateGenericButton( "$change_class$", classButtonPos, this, SpawnCmd::buildMenu, "Change class", params );
    }
}

void AddSectors( CBlob@ this )
{
	CMap@ map = this.getMap();
	const f32 tilesize = map.tilesize;
    Vec2f pos = this.getPosition();
    
    const f32 sign = this.isFacingLeft() ? -1.0f : 1.0f;
    
	Vec2f ul = Vec2f(pos.x - sign * 6 * tilesize, pos.y - 1 * tilesize);
	Vec2f lr = Vec2f(pos.x + sign * 5 * tilesize, pos.y + 3 * tilesize);
	if (sign < 0.0f)
	{
		f32 tmp = ul.x;
		ul.x = lr.x;
		lr.x = tmp;
	}
    map.server_AddSector( ul, lr, "no build", "", this.getNetworkID() );
            
    ul = Vec2f(pos.x - sign * 5 * tilesize, pos.y - 2 * tilesize);
	lr = Vec2f(pos.x - sign * 2 * tilesize, pos.y - 1 * tilesize);
	if (sign < 0.0f)
	{
		f32 tmp = ul.x;
		ul.x = lr.x;
		lr.x = tmp;
	}
    map.server_AddSector( ul, lr, "no build", "", this.getNetworkID() );
            
	ul = Vec2f(pos.x - sign * 2 * tilesize, pos.y - 8 * tilesize);
	lr = Vec2f(pos.x + sign * 2 * tilesize, pos.y - 1 * tilesize);
	if (sign < 0.0f)
	{
		f32 tmp = ul.x;
		ul.x = lr.x;
		lr.x = tmp;
	}
    map.server_AddSector( ul, lr, "no build", "", this.getNetworkID() ); // Tower
}

void SpawnBed( CBlob@ this )
{
    server_CreateBlob( "bed", this.getTeamNum(), this.getPosition() + Vec2f(24.0f, 20.0f));
}

bool isInventoryAccessible( CBlob@ this, CBlob@ byBlob )
{
    return this.getTeamNum() == byBlob.getTeamNum() || getGameTime() < getRules().get_u32("lost_war_" + this.getTeamNum() + "_" + byBlob.getTeamNum());
}
