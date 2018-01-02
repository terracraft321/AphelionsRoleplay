/* 18fdmt.as
 * author: Aphelion
 */
 
#include "3kemuc.as"; 
 
#include "37ak1f0.as";
#include "5ggqoj.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "BombCommon.as";
#include "SplashWater.as";
#include "TeamStructureNear.as";
#include "Knocked.as";

const f32 SPLASH_DAMAGE = 2.0f;

//blob functions
void onInit( CBlob@ this )
{
	ShapeConsts@ consts = this.getShape().getConsts();
    consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	
	this.server_SetTimeToDie( 20 );
	this.Tag("projectile");

	SetupBomb( this, 120, 36.0f, SPLASH_DAMAGE, 36.0f, 0.4f, true );
	this.set_u8("custom_hitter", Hitters::cannonball);
}

void onTick( CBlob@ this )
{
	CShape@ shape = this.getShape();

    if (!this.hasTag("collided")) //we haven't hit anything yet!
    {
        f32 angle = (this.getVelocity()).Angle();
        Pierce( this ); //map
        this.setAngleDegrees(-angle);
		if (shape.vellen > 0.0001f)
		{
			if (shape.vellen > 13.5f)
				shape.SetGravityScale( 0.1f );
			else
				shape.SetGravityScale( Maths::Min( 1.0f, 1.0f/(shape.vellen*0.1f) ) );
		}	   		
    }
    else
    {
    	this.setVelocity(Vec2f(0, 0));
    	this.server_Die();
    }
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
    {
		if (!solid && !blob.hasTag("flesh") && !isTeamFriendly(this.getTeamNum(), blob.getTeamNum()))
			return;
		
		Vec2f initVelocity = this.getOldVelocity();
		
		CannonballHitBlob( this, point1, initVelocity, blob );
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("projectile"))
	{
		return false;
	}

	bool check = !isTeamFriendly(this.getTeamNum(), blob.getTeamNum());
	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (this.getShape().isStatic() ||
			this.hasTag("collided") ||
			blob.hasTag("dead") )
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return 0.0f;
	}
    return damage;
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (this !is hitBlob && customData == Hitters::cannonball)
	{
		// affect players velocity
		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if       (speed > HandcannoneerParams::shoot_max_vel * 0.5f)
		{	
			f32 force = 0.1f * Maths::Sqrt(hitBlob.getMass() + 1);

			hitBlob.AddForce( velocity * force );

			// stun
			if (speed > HandcannoneerParams::shoot_max_vel * 0.845f && hitBlob.hasTag("player"))
			{
				SetKnocked( hitBlob, 30 );
				Sound::Play("/Stun", hitBlob.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);	
			}
		}
	}
}

void Pierce( CBlob @this )
{
    CMap@ map = this.getMap();
	Vec2f end;

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, this.getPosition(), end))
	{
		CannonballHitMap( this, end, this.getOldVelocity() );
	}
}

void CannonballHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, CBlob@ hitBlob )
{
    if (hitBlob !is null)
    {
		// check if shielded
		const bool hitShield = (hitBlob.hasTag("shielded") && blockAttack(hitBlob, velocity, 0.0f));
		
		// play sound
		if (!hitShield)
		{
			if (hitBlob.hasTag("flesh"))
			{
				this.getSprite().PlaySound( "CannonballHitFlesh.ogg" );
			}
			else
			{
				this.getSprite().PlaySound( "CannonballHitGround.ogg" );
			}
		}

	    CannonballHit(this, worldPoint, velocity);
    }
}

void CannonballHitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity )
{
	CMap@ map = getMap();
    TileType tile = map.getTile( worldPoint ).type;
	
	if (map.isTileCastle(tile))
	    this.getSprite().PlaySound( "CannonballHitStone" + (1 + XORRandom(3)) + ".ogg" );
	else
		this.getSprite().PlaySound( "CannonballHitGround.ogg" );

	CannonballHit(this, worldPoint, velocity);
}

void CannonballHit( CBlob@ this, Vec2f pos, Vec2f velocity )
{
	f32 radius = this.getRadius();
	f32 angle = velocity.Angle();

	this.set_u8( "angle", Maths::get256DegreesFrom360(angle) );

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= (1.5f * radius);
	Vec2f lock = pos - norm;
	this.set_Vec2f( "lock", lock );

	this.Sync("lock",true);
	this.Sync("angle",true);

	this.setVelocity(Vec2f(0,0));
	this.setPosition(lock);

	this.Tag("collided");

	if(!this.hasTag("dead"))
	{
		this.Tag("dead");
		this.doTickScripts = false;
		this.server_Die();
	}
}

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
    if (!getNet().isServer())
        return;

    // merge arrow into mat_arrows
    for (int i = 0; i < inventoryBlob.getInventory().getItemsCount(); i++)
    {
        CBlob @blob = inventoryBlob.getInventory().getItem(i);

        if (blob !is this && blob.getName() == "mat_roundshot")
        {
            blob.server_SetQuantity( blob.getQuantity() + 1 );
            this.server_Die();
            return;
        }
    }

    // mat_arrows not found
    // make arrow into mat_arrows
    CBlob@ mat = server_CreateBlob( "mat_roundshot" );
    if    (mat !is null)
    {
        inventoryBlob.server_PutInInventory( mat );
        mat.server_SetQuantity(1);
        this.server_Die();
    }
}
