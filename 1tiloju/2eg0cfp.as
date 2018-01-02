// Builder animations

#include "2efidcr.as";
#include "3eao5se.as";

#include "8s73in.as";
#include "1028jcn.as";
#include "1e3u3b0.as"
#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";

const string skin_tag = "skin disabled";

void onInit( CSprite@ this )
{
    Reload(this);
    
	this.getCurrentScript().runFlags |= Script::tick_not_infire;
}

void Reload( CSprite@ this )
{
	string tex = this.getBlob().getSexNum() == 0 ?
		"Entities/Characters/Builder/BuilderMale.png" :
		"Entities/Characters/Builder/BuilderFemale.png";
	
	if(raceIs(this.getBlob(), RACE_DWARVES))
	    tex = this.getBlob().getSexNum() == 0 ? "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/DwarfBuilderMale.png" :
		                                        "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/DwarfBuilderFemale.png";
	else if(raceIs(this.getBlob(), RACE_ELVES))
	    tex = this.getBlob().getSexNum() == 0 ? "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/ElfBuilderMale.png" :
		                                        "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/ElfBuilderFemale.png";
	else if(raceIs(this.getBlob(), RACE_ORCS))
	    tex = this.getBlob().getSexNum() == 0 ? "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/OrcBuilderMale.png" :
		                                        "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/OrcBuilderFemale.png";
	else if(raceIs(this.getBlob(), RACE_UNDEAD))
	    tex = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/UndeadBuilder.png";
	
	const string texname = tex;
	
	this.ReloadSprite(texname);
}

void onTick( CSprite@ this )
{
    // store some vars for ease and speed
    CBlob@ blob = this.getBlob();
	
	// HAX
	CPlayer@ player = blob.getPlayer();
	if      (player !is null)
    {
	    string username = isSpoofing(getRules(), player) ? getSpoofedPlayer(getRules(), player) : player.getUsername();
		string skin_path = getSkinPath(blob, player, username);
		if    (skin_path != "")
		{
		    if (isSkinEnabled(blob, username))
			    this.ReloadSprite(skin_path);
			else
			    Reload(this);
		}
	}

	if (blob.hasTag("dead"))
    {
        this.SetAnimation("dead");
		Vec2f vel = blob.getVelocity();

        if (vel.y < -1.0f) {
            this.SetFrameIndex( 0 );
        }
        else if (vel.y > 1.0f) {
            this.SetFrameIndex( 2 );
        }
        else {
            this.SetFrameIndex( 1 );
        }		 
        return;
    }

    // animations

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);
	
	if (!blob.hasTag(burning_tag)) //give way to burning anim
    {
		const bool left = blob.isKeyPressed(key_left);
		const bool right = blob.isKeyPressed(key_right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
		Vec2f pos = blob.getPosition();

		RunnerMoveVars@ moveVars;
		if (!blob.get( "moveVars", @moveVars )) {
			return;	
		}

        if (knocked > 0)
        {
            if (inair) {
                this.SetAnimation("knocked_air");
            }
            else {
                this.SetAnimation("knocked");
            }
        }
        else if (blob.hasTag( "seated" ))
        {
            this.SetAnimation("crouch");
        }
        else if (action2 || (this.isAnimation("strike") && !this.isAnimationEnded()) )
        {
            this.SetAnimation("strike");
        }
        else if (action1  || (this.isAnimation("build") && !this.isAnimationEnded()))
        {
            this.SetAnimation("build");
        }
        else if (inair)
        {
			RunnerMoveVars@ moveVars;
			if (!blob.get( "moveVars", @moveVars )) {
				return;
			}
			Vec2f vel = blob.getVelocity();
			f32 vy = vel.y;
			if (vy < -0.0f && moveVars.walljumped)
			{
				this.SetAnimation("run");
			}
			else
			{
				this.SetAnimation("fall");
				this.animation.timer = 0;

				if (vy < -1.5 ) {
					this.animation.frame = 0;
				}
				else if (vy > 1.5 ) {
					this.animation.frame = 2;
				}
				else {
					this.animation.frame = 1;
				}
			}
        }
        else if ((left || right) ||
                 (blob.isOnLadder() && (up || down) ) )
        {
            this.SetAnimation("run");
        }
        else
        {
			// get the angle of aiming with mouse
			Vec2f aimpos = blob.getAimPos();
			Vec2f vec = aimpos - pos;
			f32 angle = vec.Angle();
			int direction;

			if ((angle > 330 && angle < 361) || (angle > -1 && angle < 30) ||
				(angle > 150 && angle < 210)) {
					direction = 0;
			}
			else if (aimpos.y < pos.y) {
				direction = -1;
			}
			else {
				direction = 1;			
			}
			
			defaultIdleAnim(this, blob, direction);
        }
    }
    
    //set the attack head

	if (knocked > 0)
	{
		blob.Tag("dead head");
	}
    else if (action2 || blob.isInFlames())
    {
        blob.Tag("attack head");
        blob.Untag("dead head");
    }
    else
    {
        blob.Untag("attack head");
        blob.Untag("dead head");
    }
}

void DrawCursorAt( Vec2f pos, string& in filename )
{
    Vec2f aligned = getDriver().getScreenPosFromWorldPos( getMap().getAlignedWorldPos( pos ) );
    GUI::DrawIcon( filename, aligned, getCamera().targetDistance * getDriver().getResolutionScaleFactor() );
}

// render cursors

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    if (!blob.isMyPlayer()) {
        return;			      }					  
    if (getHUD().hasButtons()) {
        return;
    }

    // draw tile cursor

    if (blob.isKeyPressed(key_action1) || this.isAnimation("strike"))
    {
        Vec2f pos = blob.getPosition();
        Vec2f vector = blob.getAimPos() - pos;
        Vec2f normal = vector;
        normal.Normalize();
        f32 aimLength = vector.getLength();
        f32 angle = vector.Angle();
        f32 attack_distance = blob.getRadius() + blob.get_f32( "pickaxe_distance" );
        f32 attack_power = 0.5f;
        Vec2f attackVel(1.0f, 0.0f);
        attackVel.RotateBy( angle );
        CMap@ map = blob.getMap();
        HitData@ hitdata;
        blob.get("hitdata", @hitdata);
        CBlob@ hitBlob = hitdata.blobID > 0 ? getBlobByNetworkID( hitdata.blobID ) : null;

        if (hitBlob !is null) // blob hit
        {
            if (!hitBlob.hasTag("flesh")) {
                hitBlob.RenderForHUD( RenderStyle::outline );
            }
        }
        else // map hit
        {
            DrawCursorAt( hitdata.tilepos, cursorTexture );
        }
    }
}

void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Body     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 0, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 1, 0, Vec2f (16,16), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ), 2, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
    CParticle@ Sword    = makeGibParticle( "Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ), 3, 0, Vec2f (16,16), 2.0f, 0, "Sounds/material_drop.ogg", team );
}

string getSkinPath( CBlob@ blob, CPlayer@ player, string username )
{
    string skin_path = "";
    
	// -- ADMIN
	if (username == "Aphelion")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Nus.png";
	else if (username == "kaggit")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Dominar.png";
	else if (username == "yamin")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Yeshmin.png";
	else if (username == "Skyx97")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/SpaceRabbit.png";
	else if (username == "Alpha-Penguin")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Penguin.png";
	else if (username == "MadRaccoon")
		skin_path = blob.getTeamNum() == 5 ? "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/ZombieRaccoon.png" :
		                                     "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Raccoon.png";
	else if (username == "stabborazz")
		skin_path = blob.getSexNum() == 0 ? "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Ultimate.png" :
		                                    "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/ImpureEvil.png";
	else if(username == "Sohkyo" || username == "Duke_Jordan" || username == "Chukka")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/DukeBackpack.png";
	else if (username == "zhuum")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/ElderlyZhuum.png";
	else if (username == "PinXviiN")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/PinTin.png";
	else if (username == "king-george")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Gentlesir.png";
	else if (username == "de_licious")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/TrueFox.png";
	else if (username == "DeathSmurfxD")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/DeMinion.png";
	else if (username == "WuppieF")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/WuppiePuppie.png";
	else if (username == "Sasquash")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Sasquish.png";
	
	// -- SPONSOR
	else if (username == "Jonohargreaves")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Sponsor/Guy.png";
	else if (username == "Dilandau")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Sponsor/Fairy.png";
	else if (username == "pmattep99")
		skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Sponsor/Blob.png";
	else if (isSponsor(player))
	    skin_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Builder/Sprites/Special/Sponsor/Claus.png";
	
	return skin_path;
}

bool isSkinEnabled( CBlob@ blob, string username )
{
    return !blob.hasTag(skin_tag) && (blob.getTeamNum() != RACE_UNDEAD || username == "MadRaccoon");
}
