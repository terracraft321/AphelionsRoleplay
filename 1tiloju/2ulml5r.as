/* 2ulml5r.as
 * author: Aphelion
 */

#include "2efidcr.as";

#include "37vdq0n.as";
#include "3jt3pus.as";

#include "37vi6sg.as"
#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";

const int FLETCH_COOLDOWN = 45;
const int PICKUP_COOLDOWN = 15;
const int fletch_num_arrows = 1;
const int STAB_DELAY = 10;
const int STAB_TIME = 22;

void onInit( CBlob@ this )
{
	CrossbowmanInfo crossbowman;
	this.set("crossbowmanInfo", @crossbowman);

	this.set_s8( "charge_time", 0 );
	this.set_u8( "charge_state", CrossbowmanParams::not_aiming );
	this.set_bool( "has_arrow", false );
	this.set_f32("gib health", -3.0f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
    this.getSprite().SetEmitSound("../Mods/" + RP_NAME + "/Entities/Characters/Classes/Crossbowman/CrossbowPull.ogg");
	this.addCommandID("shoot arrow");
	this.addCommandID("pickup arrow");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.addCommandID(grapple_sync_cmd);

	SetHelp( this, "help self hide", "crossbowman", "Hide    $KEY_S$", "", 1 );
	SetHelp( this, "help self action2", "crossbowman", "$Grapple$ Grappling hook    $RMB$", "", 3 );

	//add a command ID for each arrow type
	for (uint i = 0; i < arrowTypeNames.length; i++)
	{
		this.addCommandID( "pick " + arrowTypeNames[i]);
	}	

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer( CBlob@ this, CPlayer@ player )
{
	if (player !is null){
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16,16));
	}
}

void ManageGrapple( CBlob@ this, CrossbowmanInfo@ crossbowman )
{
	CSprite@ sprite = this.getSprite();
	u8 charge_state = crossbowman.charge_state;
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed( key_action2 );
	if (right_click)
	{
		// cancel charging
		if (charge_state != CrossbowmanParams::not_aiming)
		{
			charge_state = CrossbowmanParams::not_aiming;
			crossbowman.charge_time = 0;
			sprite.SetEmitSoundPaused( true );
			sprite.PlaySound("PopIn.ogg");
		}
		else if (canSend(this)) //otherwise grapple
		{
			crossbowman.grappling = true;
			crossbowman.grapple_id = 0xffff;
			crossbowman.grapple_pos = pos;

			crossbowman.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			// more intuitive aiming (compensates for gravity and cursor position)
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{	
				crossbowman.grapple_vel = direction * crossbowman_grapple_throw_speed;
			}
			else
				{
				crossbowman.grapple_vel = Vec2f_zero;
			}

			SyncGrapple( this );
		}

		crossbowman.charge_state = charge_state;
	}

	if (crossbowman.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if(!this.isKeyPressed(key_action2))
		{
			if(canSend(this))
			{
				crossbowman.grappling = false;
				SyncGrapple( this );
			}
		}
		else
		{
		    const f32 crossbowman_grapple_length_ = crossbowman_grapple_length * getMarksmanGrappleLengthModifier(this.getTeamNum());
			const f32 crossbowman_grapple_range = crossbowman_grapple_length_ * crossbowman.grapple_ratio;
			const f32 crossbowman_grapple_force_limit = this.getMass() * crossbowman_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if( crossbowman.grapple_ratio > 0.2f)
				crossbowman.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = crossbowman.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - crossbowman_grapple_range;
				if(offdist > 0)
				{
					offset = force * Maths::Min(8.0f,offdist * crossbowman_grapple_stiffness);
					force *= Maths::Min(crossbowman_grapple_force_limit, Maths::Max(0.0f, offdist + crossbowman_grapple_slack) * crossbowman_grapple_force);
				}
				else
				{
					force.Set(0,0);
				}
			}

			//left map? close grapple
			if(crossbowman.grapple_pos.x < map.tilesize || crossbowman.grapple_pos.x > (map.tilemapwidth-1)*map.tilesize)
			{
				if(canSend(this))
				{
					SyncGrapple( this );
					crossbowman.grappling = false;
				}
			}
			else if(crossbowman.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(crossbowman.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0,1);

				crossbowman.grapple_vel = (crossbowman.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = crossbowman.grapple_pos + crossbowman.grapple_vel;
				next -= offset;

				Vec2f dir = next - crossbowman.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while(delta > 0 && !found) //fake raycast
				{
					if(delta > step)
					{
						crossbowman.grapple_pos += dir * step;
					}
					else
					{
						crossbowman.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, crossbowman, map, dist, crossbowman_grapple_length_);
				}

			}
			else //stuck -> pull towards pos
			{

				//wallrun/jump reset to make getting over things easier
				//at the top of grapple
				if(this.isOnWall()) //on wall
				{
					//close to the grapple point
					//not too far above
					//and moving downwards
					Vec2f dif = pos - crossbowman.grapple_pos;
					if(this.getVelocity().y > 0 &&
						dif.y > -10.0f &&
						dif.Length() < 24.0f)
					{
						//need move vars
						RunnerMoveVars@ moveVars;
					    if (this.get( "moveVars", @moveVars ))
					    {
					        moveVars.walljumped_side = Walljump::NONE;
							moveVars.wallrun_start = pos.y;
							moveVars.wallrun_current = pos.y;
					    }
					}
				}

				CBlob@ b = null;
				if(crossbowman.grapple_id != 0)
				{
					@b = getBlobByNetworkID( crossbowman.grapple_id );
					if(b is null)
					{
						crossbowman.grapple_id = 0;
					}
				}

				if(b !is null)
				{
					crossbowman.grapple_pos = b.getPosition();
					if( b.isKeyJustPressed(key_action1) ||
						b.isKeyJustPressed(key_action2) ||
						this.isKeyPressed(key_use) )
					{
						if(canSend(this))
						{
							SyncGrapple( this );
							crossbowman.grappling = false;
						}
					}
				}
				else if( shouldReleaseGrapple(this, crossbowman, map) )
				{
					if(canSend(this))
					{
						SyncGrapple( this );
						crossbowman.grappling = false;
					}
				} 

				this.AddForce(force);
				Vec2f target = (this.getPosition() + offset);
				if( !map.rayCastSolid(this.getPosition(),target) )
				{
					this.setPosition(target);
				}

				if(b !is null)
					b.AddForce(-force * (b.getMass() / this.getMass()));

			}
		}

	}
}

void ManageBow( CBlob@ this, CrossbowmanInfo@ crossbowman, RunnerMoveVars@ moveVars )
{
	CSprite@ sprite = this.getSprite();
	bool ismyplayer = this.isMyPlayer();
	bool hasarrow = crossbowman.has_arrow;
	s8 charge_time = crossbowman.charge_time;
	u8 charge_state = crossbowman.charge_state;
	const bool pressed_action2 = this.isKeyPressed( key_action2 );
	Vec2f pos = this.getPosition();

	s32 shoot_period = CrossbowmanParams::shoot_period * getMarksmanFireTimeModifier(this.getTeamNum());
	s32 shoot_period_1 =     shoot_period / 3;
	s32 shoot_period_2 = 2 * shoot_period / 3;
	s32 legolas_period =     shoot_period * 3;
	
	if(ismyplayer)
	{
		if ((getGameTime()+this.getNetworkID())%10 == 0)
		{
			hasarrow = hasArrows( this );

			if (!hasarrow)
			{
				// set back to default
				for (uint i = 0; i < ArrowType::count; i++)
				{
					hasarrow = hasArrows( this, i );
					if (hasarrow)
					{
						crossbowman.arrow_type = i;
						break;
					}
				}
			}
		}

		this.set_bool( "has_arrow", hasarrow );
		this.Sync("has_arrow", false);

		crossbowman.stab_delay = 0;
	}

	if (charge_state == CrossbowmanParams::legolas_charging) // fast arrows
	{
		if (!hasarrow)
		{
			charge_state = CrossbowmanParams::not_aiming;
			charge_time = 0;
		}
		else
		{
			charge_time++;

			if (charge_time >= shoot_period-1)
			{
				charge_state = CrossbowmanParams::legolas_ready;
			}
		}
	}
	else
	if (charge_state == CrossbowmanParams::legolas_ready) // fast arrows
	{
		moveVars.walkFactor *= 0.70f;
		
		crossbowman.legolas_time--;
		if (!hasarrow || crossbowman.legolas_time == 0)
		{
			bool pressed = this.isKeyPressed(key_action1);
			charge_state = pressed ? CrossbowmanParams::readying : CrossbowmanParams::not_aiming;
			charge_time = 0;
			//didn't fire
			if (crossbowman.legolas_arrows == CrossbowmanParams::legolas_arrows_count)
			{
				Sound::Play("/Stun", pos, 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
				SetKnocked(this, 15);
			}
			else if(pressed)
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused( false );
			}
		}
		else if (this.isKeyJustPressed(key_action1) ||
					(crossbowman.legolas_arrows == CrossbowmanParams::legolas_arrows_count &&
						!this.isKeyPressed(key_action1) &&
						this.wasKeyPressed(key_action1)) )
		{
			ClientFire( this, charge_time, hasarrow, crossbowman.arrow_type, true, shoot_period_1, shoot_period_2 );
			charge_state = CrossbowmanParams::legolas_charging;
			charge_time = shoot_period - CrossbowmanParams::legolas_charge_time;
			Sound::Play("FastBowPull.ogg", pos);
			crossbowman.legolas_arrows--;

			if (crossbowman.legolas_arrows == 0)
			{
				charge_state = CrossbowmanParams::readying;
				charge_time = 5;

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused( false );
			}
		}

	}
	else if (this.isKeyPressed(key_action1))
	{
		moveVars.walkFactor *= 0.70f;
		moveVars.canVault = false;

		const bool just_action1 = this.isKeyJustPressed(key_action1);

	//	printf("charge_state " + charge_state );

		if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
			(charge_state == CrossbowmanParams::not_aiming || charge_state == CrossbowmanParams::fired))
		{
			charge_state = CrossbowmanParams::readying;
			hasarrow = hasArrows( this );

			if(ismyplayer)
			{
				this.set_bool( "has_arrow", hasarrow );
				this.Sync("has_arrow", false);
			}

			charge_time = 0;

			if (!hasarrow)
			{
				charge_state = CrossbowmanParams::no_arrows;

				if (ismyplayer && !this.wasKeyPressed(key_action1)) { // playing annoying no ammo sound
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
				}

				// set back to default
				crossbowman.arrow_type = ArrowType::normal;
			}
			else
			{
				if (ismyplayer)
				{
					if (just_action1)
					{
						const u8 type = crossbowman.arrow_type;

						if (type == ArrowType::water)
						{
							sprite.PlayRandomSound( "/WaterBubble" );
						}
						else if (type == ArrowType::fire)
						{
							sprite.PlaySound( "SparkleShort.ogg" );
						}
					}
				}

				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused( false );

				if (!ismyplayer) { // lower the volume of other players charging  - ooo good idea
					sprite.SetEmitSoundVolume( 0.5f );
				}
			}
		}
		else if (charge_state == CrossbowmanParams::readying)
		{
			charge_time++;

			if(charge_time > CrossbowmanParams::ready_time)
			{
				charge_time = 1;
				charge_state = CrossbowmanParams::charging;
			}
		}
		else if (charge_state == CrossbowmanParams::charging)
		{
			charge_time++;

			if(charge_time >= CrossbowmanParams::legolas_period)
			{ 
				// Legolas state

				Sound::Play("AnimeSword.ogg", pos, ismyplayer ? 1.3f : 0.7f );
				Sound::Play("FastBowPull.ogg", pos);
				charge_state = CrossbowmanParams::legolas_charging;
				charge_time = shoot_period - CrossbowmanParams::legolas_charge_time;

				crossbowman.legolas_arrows = CrossbowmanParams::legolas_arrows_count;
				crossbowman.legolas_time = CrossbowmanParams::legolas_time;
			}

			if(charge_time >= shoot_period)
				sprite.SetEmitSoundPaused( true );
		}
		else if (charge_state == CrossbowmanParams::no_arrows)
		{
			if(charge_time < CrossbowmanParams::ready_time) {
				charge_time++;
			}
		}
	}
	else
	{
		if (charge_state > CrossbowmanParams::readying)
		{
			if (charge_state < CrossbowmanParams::fired)
			{
				ClientFire( this, charge_time, hasarrow, crossbowman.arrow_type, false, shoot_period_1, shoot_period_2 );

				charge_time = CrossbowmanParams::fired_time;
				charge_state = CrossbowmanParams::fired;
			}
			else //fired..
			{
				charge_time--;

				if (charge_time <= 0) {
					charge_state = CrossbowmanParams::not_aiming;
					charge_time = 0;
				}
			}
		}
		else {
			charge_state = CrossbowmanParams::not_aiming;    //set to not aiming either way
			charge_time = 0;
		}

		sprite.SetEmitSoundPaused( true );
	}

	// safe disable bomb light

	if (this.wasKeyPressed(key_action1) && !this.isKeyPressed(key_action1) )
	{
		const u8 type = crossbowman.arrow_type;
		if (type == ArrowType::bomb) {
			BombFuseOff( this );
		}
	}

	// my player!

    if ( ismyplayer )
    {
		// set cursor

		if (!getHUD().hasButtons()) 
		{
			int frame = 0;
		//	print("crossbowman.charge_time " + crossbowman.charge_time + " / " + shoot_period );
			if (crossbowman.charge_state == CrossbowmanParams::readying) {
				frame = 1 + float(crossbowman.charge_time)/float(shoot_period + CrossbowmanParams::ready_time) * 7;
			}
			else if (crossbowman.charge_state == CrossbowmanParams::charging) 
				{
					if (crossbowman.charge_time <= shoot_period) { 
						frame = Maths::Min(int(float(CrossbowmanParams::ready_time + crossbowman.charge_time)/float(shoot_period) * 7), 9);
					}
					else
						frame = 9;
				}
				else if (crossbowman.charge_state == CrossbowmanParams::legolas_ready){
						frame = 10;
				}
				else if (crossbowman.charge_state == CrossbowmanParams::legolas_charging){
					frame = 9;
				}
			getHUD().SetCursorFrame( frame );
		}

		// activate/throw

        if (this.isKeyJustPressed(key_action3))
        {
			client_SendThrowOrActivateCommand( this );
        }

		// pick up arrow

		if (crossbowman.fletch_cooldown > 0) {
			crossbowman.fletch_cooldown--;
		}

		// pickup from ground

        if (crossbowman.fletch_cooldown == 0 && this.isKeyPressed(key_action2))
        {
            if (getPickupArrow( this ) !is null) // pickup arrow from ground
            {
                this.SendCommand( this.getCommandID("pickup arrow") );
				crossbowman.fletch_cooldown = PICKUP_COOLDOWN;
            }
        }
    }

	crossbowman.charge_time = charge_time;
	crossbowman.charge_state = charge_state;
	crossbowman.has_arrow = hasarrow;

}

void onTick( CBlob@ this )
{
    CrossbowmanInfo@ crossbowman;
	if (!this.get( "crossbowmanInfo", @crossbowman )) {
		return;
	}

	if(getKnocked(this) > 0)
	{
		crossbowman.grappling = false;
		crossbowman.charge_state = 0;
		crossbowman.charge_time = 0;
		return;
	}

	ManageGrapple( this, crossbowman );

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;

	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get( "moveVars", @moveVars )) {
		return;
	}

	ManageBow( this, crossbowman, moveVars );
}

bool checkGrappleStep(CBlob@ this, CrossbowmanInfo@ crossbowman, CMap@ map, const f32 dist, const f32 len)
{
	if(map.getSectorAtPosition( crossbowman.grapple_pos, "barrier" ) !is null) //red barrier
	{
		if(canSend(this))
		{
			crossbowman.grappling = false;
			SyncGrapple( this );
		}
	}
	else if( grappleHitMap(crossbowman, map, dist) )
	{
		crossbowman.grapple_id = 0;

		crossbowman.grapple_ratio = Maths::Max(0.2, Maths::Min( crossbowman.grapple_ratio, dist / len) );

		if(canSend(this)) SyncGrapple( this );

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(crossbowman.grapple_pos);
		if (b !is null)
		{
			if(b is this)
			{
				//can't grapple self if not reeled in
				if(crossbowman.grapple_ratio > 0.5f)
					return false;

				if(canSend(this))
				{
					crossbowman.grappling = false;
					SyncGrapple( this );
				}

				return true;
			}
			else if(b.isCollidable() && b.getShape().isStatic())
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				crossbowman.grapple_ratio = Maths::Max(0.2, Maths::Min( crossbowman.grapple_ratio, b.getDistanceTo(this) / len ) );

				crossbowman.grapple_id = b.getNetworkID();
				if(canSend(this))
				{
					SyncGrapple( this );
				}

				return true;
			}
		}
	}

	return false;
}

bool grappleHitMap(CrossbowmanInfo@ crossbowman, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(crossbowman.grapple_pos + Vec2f(0,-3)) ||			//fake quad
			map.isTileSolid(crossbowman.grapple_pos + Vec2f(3,0)) ||
			map.isTileSolid(crossbowman.grapple_pos + Vec2f(-3,0))||
			map.isTileSolid(crossbowman.grapple_pos + Vec2f(0,3)) ||
			(dist > 10.0f && map.getSectorAtPosition( crossbowman.grapple_pos, "tree" ) !is null); //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, CrossbowmanInfo@ crossbowman, CMap@ map)
{
	return !grappleHitMap(crossbowman,map) || this.isKeyPressed(key_use);
}

bool canSend( CBlob@ this )
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire( CBlob@ this, const s8 charge_time, const bool hasarrow, const u8 arrow_type, const bool legolas, const s32 shoot_period_1, const s32 shoot_period_2 )
{
	//time to fire!
	if (hasarrow && canSend(this) ) // client-logic
	{
		f32 arrowspeed;
		if (charge_time < CrossbowmanParams::ready_time/2+shoot_period_1)
			arrowspeed = CrossbowmanParams::shoot_max_vel * (1.0f/3.0f);
		else if (charge_time < CrossbowmanParams::ready_time/2+shoot_period_2)
			arrowspeed = CrossbowmanParams::shoot_max_vel * (4.0f/5.0f);
		else
			arrowspeed = CrossbowmanParams::shoot_max_vel;

		ShootArrow( this, this.getPosition() + Vec2f(0.0f,-2.0f), this.getAimPos() + Vec2f(0.0f,-2.0f), arrowspeed, arrow_type, legolas );
	}
}

void ShootArrow( CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed, const u8 arrow_type, const bool legolas = true )
{
    if (canSend(this))
	{ // player or bot
		Vec2f arrowVel = (aimpos- arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		//print("arrowspeed " + arrowspeed);
		CBitStream params;
		params.write_Vec2f( arrowPos );
		params.write_Vec2f( arrowVel );
		params.write_u8( arrow_type );
		params.write_bool( legolas );

		this.SendCommand( this.getCommandID("shoot arrow"), params );
	}
}

CBlob@ getPickupArrow( CBlob@ this )
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius()*1.5f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "arrow")
			{
				return b;
			}
		}
	}
    return null;
}

bool canPickSpriteArrow( CBlob@ this, bool takeout )
{
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius( this.getPosition(), this.getRadius()*1.5f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			{
				CSprite@ sprite = b.getSprite();
				if (sprite.getSpriteLayer("arrow") !is null)
				{
					if (takeout)
						sprite.RemoveSpriteLayer("arrow");
					return true;
				}
			}
		}
	}
	return false;
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit( "arrow" );
	if (arrow !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", arrowType );
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped( this );
		arrow.SetDamageOwnerPlayer( this.getPlayer() );
		arrow.server_setTeamNum( this.getTeamNum() );
		arrow.setPosition( arrowPos );
		arrow.setVelocity( arrowVel );
		arrow.getShape().setDrag( arrow.getShape().getDrag() * 1.33f );
	}
	return arrow;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shoot arrow"))
	{
		Vec2f arrowPos = params.read_Vec2f();
		Vec2f arrowVel = params.read_Vec2f();
		u8 arrowType = params.read_u8();
		bool legolas = params.read_bool();

		CrossbowmanInfo@ crossbowman;
		if (!this.get( "crossbowmanInfo", @crossbowman ))
		{
			return;
		}

		crossbowman.arrow_type = arrowType;

		// return to normal arrow - server didnt have this synced
		if (!hasArrows( this, arrowType ))
		{
			return;
		}

		if(legolas)
		{
			int r = 0;
			for( int i = 0; i < CrossbowmanParams::legolas_arrows_volley; i++)
			{
				if (getNet().isServer())
				{
					CBlob@ arrow = CreateArrow(this, arrowPos, arrowVel, arrowType);
					if(i > 0 && arrow !is null)
					{
						arrow.Tag("shotgunned");
					}
				}
				this.TakeBlob( arrowTypeNames[ arrowType ], 1 );

				//don't keep firing if we're out of arrows
				if(!hasArrows( this, arrowType ))
					break;

				r = r > 0 ? -(r+1) : (-r) + 1;

				arrowVel = arrowVel.RotateBy(CrossbowmanParams::legolas_arrows_deviation * r,Vec2f());
				if(i == 0)
				{
					arrowVel *= 0.9f;
				}
			}
            this.getSprite().PlaySound("../Mods/" + RP_NAME + "/Entities/Characters/Classes/Crossbowman/CrossbowFire.ogg", 1.5f, 1.0f);
		}
		else
		{
			if (getNet().isServer())
			{
				CreateArrow(this, arrowPos, arrowVel, arrowType);
			}
            
            this.getSprite().PlaySound("../Mods/" + RP_NAME + "/Entities/Characters/Classes/Crossbowman/CrossbowFire.ogg", 1.0f, 1.0f);
			this.TakeBlob( arrowTypeNames[ arrowType ], 1 );	
		}

		crossbowman.fletch_cooldown = FLETCH_COOLDOWN; // just don't allow shoot + make arrow
	}
	else if (cmd == this.getCommandID("pickup arrow"))
	{
		CBlob@ arrow = getPickupArrow( this );
		bool spriteArrow = canPickSpriteArrow( this, false );
		if (arrow !is null || spriteArrow)
		{
			if(arrow !is null)
			{
				CrossbowmanInfo@ crossbowman;
				if (!this.get( "crossbowmanInfo", @crossbowman )) {
					return;
				}
				const u8 arrowType = crossbowman.arrow_type;
				if(arrowType == ArrowType::bomb)
				{
					arrow.set_u16("follow", 0); //this is already synced, its in command.
					arrow.setPosition(this.getPosition());
					return;
				}
			}

			CBlob@ mat_arrows = server_CreateBlob( "mat_arrows", this.getTeamNum(), this.getPosition() );
			if (mat_arrows !is null)
			{
				mat_arrows.server_SetQuantity(fletch_num_arrows);
				mat_arrows.Tag("do not set materials");
				this.server_PutInInventory( mat_arrows );

				if (arrow !is null) {
					arrow.server_Die();
				}
				else{
					canPickSpriteArrow( this, true );
				}
			}
			this.getSprite().PlaySound( "Entities/Items/Projectiles/Sounds/ArrowHitGround.ogg" );
		}
	}
	else if( cmd == this.getCommandID(grapple_sync_cmd) )
	{
		HandleGrapple( this, params, !canSend(this) );
	}
	else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle arrows
		CrossbowmanInfo@ crossbowman;
		if (!this.get( "crossbowmanInfo", @crossbowman ))
		{
			return;
		}
		u8 type = crossbowman.arrow_type;

		int count = 0;
		while (count < arrowTypeNames.length)
		{
			type++;
			count++;
			if (type >= arrowTypeNames.length)
			{
				type = 0;
			}
			if (this.getBlobCount( arrowTypeNames[type] ) > 0)
			{
				crossbowman.arrow_type = type;
				if (this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else
	{
		CrossbowmanInfo@ crossbowman;
		if (!this.get( "crossbowmanInfo", @crossbowman ))
		{
			return;
		}
		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (cmd == this.getCommandID( "pick " + arrowTypeNames[i]))
			{
				crossbowman.arrow_type = i;
				break;
			}
		}
	}
}

// arrow pick menu
void onCreateInventoryMenu( CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu )
{
	if (arrowTypeNames.length == 0) {
		return;
	}

    this.ClearGridMenusExceptInventory();
    Vec2f pos( gridmenu.getUpperLeftPosition().x + 0.5f*(gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
               gridmenu.getUpperLeftPosition().y - 32 * 1 - 2*24 );
    CGridMenu@ menu = CreateGridMenu( pos, this, Vec2f( arrowTypeNames.length, 2 ), "Current arrow" );

	CrossbowmanInfo@ crossbowman;
	if (!this.get( "crossbowmanInfo", @crossbowman )) {
		return;
	}
	const u8 arrowSel = crossbowman.arrow_type;

    if (menu !is null)
    {
		menu.deleteAfterClick = false;

        for (uint i = 0; i < arrowTypeNames.length; i++)
        {
            string matname = arrowTypeNames[i];
            CGridButton @button = menu.AddButton( arrowIcons[i], arrowNames[i], this.getCommandID( "pick " + matname) );

            if (button !is null)
            {
				bool enabled = this.getBlobCount( arrowTypeNames[i] ) > 0;
                button.SetEnabled( enabled );
				button.selectOneOnClick = true;

                if (arrowSel == i) {
                    button.SetSelected(1);
                }
			}
        }
    }
}

// auto-switch to appropriate arrow when picked up
void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	string itemname = blob.getName();
	if (this.isMyPlayer())
	{
		for (uint j = 0; j < arrowTypeNames.length; j++)
		{
			if (itemname == arrowTypeNames[j])
			{
				SetHelp( this, "help self action", "crossbowman", "$arrow$Fire arrow   $KEY_HOLD$$LMB$", "", 3 );
				if (j > 0 && this.getInventory().getItemsCount() > 1) {
					SetHelp( this, "help inventory", "crossbowman", "$Help_Arrow1$$Swap$$Help_Arrow2$         $KEY_TAP$$KEY_F$", "", 2 );
				}
				break;
			}
		}
	}

	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0)
	{
		CrossbowmanInfo@ crossbowman;
		if (!this.get( "crossbowmanInfo", @crossbowman )) {
			return;
		}

		for (uint i = 0; i < arrowTypeNames.length; i++)
		{
			if (itemname == arrowTypeNames[i]) {
				crossbowman.arrow_type = i;
			}
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (hitBlob.getName() == "magic_orb" && hitBlob.getTeamNum() == this.getTeamNum())
		return 0.0f;
	
	// the damage modifier
	float modifier = getDamageModifier(this, customData);
	
	CPlayer@ player = this.getPlayer();
	if      (player !is null && player.getUsername() == "Aphelion")
	    return (damage * modifier) * 0.75f;
	
	CPlayer@ hitterPlayer = hitBlob.getPlayer();
	if      (hitterPlayer !is null && hitterPlayer.getUsername() == "Aphelion")
	    return (damage * modifier) * 1.25f;
	
	return damage * modifier;
}
