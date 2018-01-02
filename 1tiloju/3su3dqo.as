/* 3su3dqo.as
 * author: Aphelion
 */

#include "2efidcr.as";

#include "37vdq0n.as";
#include "3jt3pus.as";

#include "15g7tkm.as"
#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "3t0evcr.as";
#include "37vdq0n.as";

void onInit( CBlob@ this )
{
	MusketmanInfo musketman;	  
	this.set("musketmanInfo", @musketman);

    this.set_s8( "charge_time", 0 );
    this.set_u8( "charge_state", MusketmanParams::not_aiming );
    this.set_bool( "has_ammunition", false );
    this.set_f32("gib health", -3.0f);
    this.Tag("player");
    this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));
	
    //no spinning
    this.getShape().SetRotationsAllowed(false);
    this.getSprite().SetEmitSound( "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Musketman/MusketLoad.ogg" );
    this.addCommandID("shoot musket");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

    this.addCommandID(grapple_sync_cmd);

	SetHelp( this, "help self hide", "musketman", "Hide    $KEY_S$", "", 1 );
	SetHelp( this, "help self action2", "musketman", "$Grapple$ Grappling hook    $RMB$", "", 3 );

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer( CBlob@ this, CPlayer@ player )
{
	if (player !is null){
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16,16));
	}
}

void onTick( CBlob@ this )
{
	MusketmanInfo@ musketman;
	if (!this.get( "musketmanInfo", @musketman )) {
		return;
	}

	if(getKnocked(this) > 0)
	{
		musketman.grappling = false;
		musketman.charge_state = 0;
		musketman.charge_time = 0;
		return;
	}

	CSprite@ sprite = this.getSprite();
    u8 charge_state = musketman.charge_state;
	Vec2f pos = this.getPosition();
	
	s32 shoot_period = MusketmanParams::shoot_period * getMarksmanFireTimeModifier(this.getTeamNum());
	s32 shoot_period_1 =     shoot_period / 3;
	s32 shoot_period_2 = 2 * shoot_period / 3;
	
	const bool right_click = this.isKeyJustPressed( key_action2 );
	if (right_click)
	{
		// cancel charging
		if (charge_state != MusketmanParams::not_aiming)
		{
			charge_state = MusketmanParams::not_aiming;
			musketman.charge_time = 0;
			sprite.SetEmitSoundPaused( true );
			sprite.PlaySound("PopIn.ogg");
		}
		else if (canSend(this)) //otherwise grapple
		{
			musketman.grappling = true;
			musketman.grapple_id = 0xffff;
			musketman.grapple_pos = pos;

			musketman.grapple_ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			// more intuitive aiming (compensates for gravity and cursor position)
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{	
				musketman.grapple_vel = direction * musketman_grapple_throw_speed;
			}
			else
				{
				musketman.grapple_vel = Vec2f_zero;
			}

			SyncGrapple( this );
		}

		musketman.charge_state = charge_state;
	}

	if (musketman.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if(!this.isKeyPressed(key_action2))
		{
			if(canSend(this))
			{
				musketman.grappling = false;
				SyncGrapple( this );
			}
		}
		else
		{
			const f32 musketman_grapple_length_ = musketman_grapple_length * getMarksmanGrappleLengthModifier(this.getTeamNum());
			const f32 musketman_grapple_range = musketman_grapple_length_ * musketman.grapple_ratio;
			const f32 musketman_grapple_force_limit = this.getMass() * musketman_grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if( musketman.grapple_ratio > 0.2f)
				musketman.grapple_ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = musketman.grapple_pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - musketman_grapple_range;
				if(offdist > 0)
				{
					offset = force * Maths::Min(8.0f,offdist * musketman_grapple_stiffness);
					force *= Maths::Min(musketman_grapple_force_limit, Maths::Max(0.0f, offdist + musketman_grapple_slack) * musketman_grapple_force);
				}
				else
				{
					force.Set(0,0);
				}
			}

			//left map? close grapple
			if(musketman.grapple_pos.x < map.tilesize || musketman.grapple_pos.x > (map.tilemapwidth-1)*map.tilesize)
			{
				if(canSend(this))
				{
					SyncGrapple( this );
					musketman.grappling = false;
				}
			}
			else if(musketman.grapple_id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(musketman.grapple_pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0,1);

				musketman.grapple_vel = (musketman.grapple_vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = musketman.grapple_pos + musketman.grapple_vel;
				next -= offset;

				Vec2f dir = next - musketman.grapple_pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while(delta > 0 && !found) //fake raycast
				{
					if(delta > step)
					{
						musketman.grapple_pos += dir * step;
					}
					else
					{
						musketman.grapple_pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, musketman, map, dist, musketman_grapple_length_);
				}

			}
			else //stuck -> pull towards pos
			{
				CBlob@ b = null;
				if(musketman.grapple_id != 0)
				{
					@b = getBlobByNetworkID( musketman.grapple_id );
					if(b is null)
					{
						musketman.grapple_id = 0;
					}
				}

				if(b !is null)
				{
					musketman.grapple_pos = b.getPosition();
					if( b.isKeyJustPressed(key_action1) ||
						b.isKeyJustPressed(key_action2) ||
						this.isKeyPressed(key_use) )
					{
						if(canSend(this))
						{
							SyncGrapple( this );
							musketman.grappling = false;
						}
					}
				}
				else if( shouldReleaseGrapple(this, musketman, map) )
				{
					if(canSend(this))
					{
						SyncGrapple( this );
						musketman.grappling = false;
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

	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;
	
	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get( "moveVars", @moveVars )) {
		return;
	}

	bool ismyplayer = this.isMyPlayer();
	bool hasammunition = musketman.has_ammunition;
	s8 charge_time = musketman.charge_time;
	const bool pressed_action2 = this.isKeyPressed( key_action2 );

	if ((getGameTime()+this.getNetworkID())%10 == 0)
	{
		hasammunition = hasAmmunition( this );
	}
	
	this.set_bool( "has_ammunition", hasammunition );
	this.Sync("has_ammunition", false);
	
	if (this.isKeyPressed(key_action1))
	{
		moveVars.walkFactor *= 0.70f;
		moveVars.canVault = false;
		
		const bool just_action1 = this.isKeyJustPressed(key_action1);
		
		if ((just_action1 || this.wasKeyPressed(key_action2) && !pressed_action2) &&
			(charge_state == MusketmanParams::not_aiming || charge_state == MusketmanParams::fired))
		{
			charge_state = MusketmanParams::readying;
			hasammunition = hasAmmunition( this );
			
			charge_time = 0;
			
			if (!hasammunition)
			{
				charge_state = MusketmanParams::no_ammunition;
				
				if (ismyplayer && !this.wasKeyPressed(key_action1)) { // playing annoying no ammo sound
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
				}
			}
			else
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused( false );
				
				if (!ismyplayer) { // lower the volume of other players charging  - ooo good idea
					sprite.SetEmitSoundVolume( 0.5f );
				}
			}
		}
		else if (charge_state == MusketmanParams::readying)
		{
			charge_time++;
			
			if(charge_time > MusketmanParams::ready_time)
			{
				sprite.SetEmitSoundPaused( true );
				
				charge_time = 1;
				charge_state = MusketmanParams::charging;
			}
		}
		else if (charge_state == MusketmanParams::charging)
		{
			if (charge_time < shoot_period)
			    charge_time++;
		}
		else if (charge_state == MusketmanParams::no_ammunition)
		{
			if(charge_time < MusketmanParams::ready_time)
			   charge_time++;
		}
	}
	else
	{
		if (charge_state == MusketmanParams::charging)
		{
			if (charge_time >= shoot_period)
			{
				ClientFire( this, charge_time, hasammunition );
			}
		}
		
		charge_state = MusketmanParams::not_aiming;
		charge_time = 0;
	}

	// safe disable bomb light
	if (this.wasKeyPressed(key_action1) && !this.isKeyPressed(key_action1) )
	{
		BombFuseOff( this );
	}

	// my player!
    if ( ismyplayer )
    {
		getCamera().mousecamstyle = 2;

		// set cursor
		if (!getHUD().hasButtons()) 
		{
			int frame = 0;
			if (musketman.charge_state == MusketmanParams::readying)
				frame = 1 + float(musketman.charge_time) / float(shoot_period + MusketmanParams::ready_time) * 7;
			else if (musketman.charge_state == MusketmanParams::charging) 
			{
				if (musketman.charge_time <= shoot_period) 
					frame = Maths::Min(int(float(MusketmanParams::ready_time + musketman.charge_time) / float(shoot_period) * 7), 9);
				else
					frame = 9;
			}
			getHUD().SetCursorFrame( frame );
		}

		// activate/throw
        if (this.isKeyJustPressed(key_action3))
        {
			client_SendThrowOrActivateCommand( this );
        }
    }

	musketman.charge_time = charge_time;
	musketman.charge_state = charge_state;
	musketman.has_ammunition = hasammunition;
}

bool checkGrappleStep(CBlob@ this, MusketmanInfo@ musketman, CMap@ map, const f32 dist, const f32 len)
{
	if(map.getSectorAtPosition( musketman.grapple_pos, "barrier" ) !is null) //red barrier
	{
		if(canSend(this))
		{
			musketman.grappling = false;
			SyncGrapple( this );
		}
	}
	else if( grappleHitMap(musketman, map, dist) )
	{
		musketman.grapple_id = 0;

		musketman.grapple_ratio = Maths::Max(0.2, Maths::Min( musketman.grapple_ratio, dist / len ) );

		if(canSend(this)) SyncGrapple( this );

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(musketman.grapple_pos);
		if (b !is null)
		{
			if(b is this)
			{
				//can't grapple self if not reeled in
				if(musketman.grapple_ratio > 0.5f)
					return false;

				if(canSend(this))
				{
					musketman.grappling = false;
					SyncGrapple( this );
				}

				return true;
			}
			else if(b.isCollidable() && b.getShape().isStatic())
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				musketman.grapple_id = b.getNetworkID();
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

bool grappleHitMap(MusketmanInfo@ musketman, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(musketman.grapple_pos + Vec2f(0,-3)) ||			//fake quad
			map.isTileSolid(musketman.grapple_pos + Vec2f(3,0)) ||
			map.isTileSolid(musketman.grapple_pos + Vec2f(-3,0))||
			map.isTileSolid(musketman.grapple_pos + Vec2f(0,3)) ||
			(dist > 10.0f && map.getSectorAtPosition( musketman.grapple_pos, "tree" ) !is null); //tree stick
}

bool shouldReleaseGrapple(CBlob@ this, MusketmanInfo@ musketman, CMap@ map)
{
	return !grappleHitMap(musketman,map) || this.isKeyPressed(key_use);
}

bool canSend( CBlob@ this )
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void ClientFire(CBlob@ this, const s8 charge_time, const bool hasammunition )
{
	//time to fire!
	if (hasammunition && canSend(this) ) // client-logic
	{
		ShootBullet( this, this.getPosition() + Vec2f(0.0f, -2.0f), this.getAimPos() + Vec2f(0.0f, -2.0f), MusketmanParams::shoot_max_vel );
	}
}

void ShootBullet( CBlob @this, Vec2f arrowPos, Vec2f aimpos, f32 arrowspeed )
{
    if (canSend(this))
	{ // player or bot
		Vec2f arrowVel = (aimpos- arrowPos);
		arrowVel.Normalize();
		arrowVel *= arrowspeed;
		
		CBitStream params;
		params.write_Vec2f( arrowPos );
		params.write_Vec2f( arrowVel );

		this.SendCommand( this.getCommandID("shoot musket"), params );
	}
}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shoot musket"))
    {
        Vec2f arrowPos = params.read_Vec2f();
        Vec2f arrowVel = params.read_Vec2f();
		
		MusketmanInfo@ musketman;
		if (!this.get( "musketmanInfo", @musketman )) {
			return;
		}

		// return to normal arrow - server didnt have this synced
		if (!hasAmmunition(this)) {
			return;
		}

        if (getNet().isServer())
        {
            CBlob@ bullet = server_CreateBlob( "bullet" );
            if (bullet !is null)
            {
				bullet.IgnoreCollisionWhileOverlapped( this );
                bullet.SetDamageOwnerPlayer( this.getPlayer() );
				bullet.server_setTeamNum( this.getTeamNum() );
				bullet.setPosition( arrowPos );
                bullet.setVelocity( arrowVel );
				bullet.getShape().setDrag( bullet.getShape().getDrag() * 2.0f );
            }
        }
		shotParticles(arrowPos, arrowVel.Angle());

        this.getSprite().PlaySound("../Mods/" + RP_NAME + "/Entities/Characters/Classes/Musketman/MusketFire" + (1 + XORRandom(3)) + ".ogg");
        this.TakeBlob( ammunition, 1 );
    }
    else if( cmd == this.getCommandID(grapple_sync_cmd) )
    {
		HandleGrapple( this, params, !canSend(this) );
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

Random _shotrandom(0x15125); //clientside

void shotParticles(Vec2f pos, float angle)
{
	Vec2f shot_vel = Vec2f(0.5f,0);
	shot_vel.RotateBy(-angle);

	//smoke
	for(int i = 0; i < 5; i++)
	{
		//random velocity direction
		Vec2f vel(0.1f + _shotrandom.NextFloat()*0.2f, 0);
		vel.RotateBy(_shotrandom.NextFloat() * 360.0f);
		vel += shot_vel * i;

		CParticle@ p = ParticleAnimated( "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Musketman/muzzle_smoke.png",
												  pos, vel,
												  _shotrandom.NextFloat() * 360.0f, //angle
												  1.0f, //scale
												  5+_shotrandom.NextRanged(4), //animtime
												  0.0f, //gravity
												  true ); //selflit
		if(p !is null)
			p.Z = 110.0f;
	}
}
