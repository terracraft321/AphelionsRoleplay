//Archer Include

namespace HandcannoneerParams
{
enum Aim {
    not_aiming = 0,
    readying,
    charging,
    fired,
    no_ammunition
}

const ::s32 ready_time = 21;

const ::s32 shoot_period = 40;
const ::s32 shoot_period_1 = HandcannoneerParams::shoot_period / 3;
const ::s32 shoot_period_2 = 2 * HandcannoneerParams::shoot_period / 3;

const ::s32 fired_time = 7;
const ::f32 shoot_max_vel = 25.0f;
}

//TODO: move vars into handcannoneer params namespace
const f32 handcannoneer_grapple_length = 72.0f;
const f32 handcannoneer_grapple_slack = 16.0f;
const f32 handcannoneer_grapple_throw_speed = 20.0f;

const f32 handcannoneer_grapple_force = 2.0f;
const f32 handcannoneer_grapple_accel_limit = 1.5f;
const f32 handcannoneer_grapple_stiffness = 0.1f;

namespace ShotType
{
enum type
{
    normal,
	count
};
}

shared class HandcannoneerInfo
{
	s8 charge_time;
	u8 charge_state;
	bool has_ammunition;
	
	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	f32 cache_angle;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	HandcannoneerInfo()
	{
		charge_time = 0;
		charge_state = 0;
		has_ammunition = false;
		grappling = false;
	}
};

const string grapple_sync_cmd = "grapple sync";

const string ammunition = "mat_roundshot";

void SyncGrapple( CBlob@ this )
{
	HandcannoneerInfo@ handcannoneer;
	if (!this.get( "handcannoneerInfo", @handcannoneer )) { return; }
	
	CBitStream bt;
	
	bt.write_bool(handcannoneer.grappling);
	if(handcannoneer.grappling)
	{
		bt.write_u16( handcannoneer.grapple_id );
		bt.write_u8( u8(handcannoneer.grapple_ratio*250) );
		bt.write_Vec2f( handcannoneer.grapple_pos );
		bt.write_Vec2f( handcannoneer.grapple_vel );
	}
	
	this.SendCommand( this.getCommandID(grapple_sync_cmd), bt );
}

//TODO: saferead
void HandleGrapple( CBlob@ this, CBitStream@ bt, bool apply )
{
	HandcannoneerInfo@ handcannoneer;
	if (!this.get( "handcannoneerInfo", @handcannoneer )) { return; }
	
	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	Vec2f grapple_pos;
	Vec2f grapple_vel;
	
	grappling = bt.read_bool();
	
	if(grappling)
	{
		grapple_id = bt.read_u16();
		u8 temp = bt.read_u8();
		grapple_ratio = temp / 250.0f;
		grapple_pos = bt.read_Vec2f();
		grapple_vel = bt.read_Vec2f();
	}
	
	if(apply)
	{
		handcannoneer.grappling = grappling;
		if(handcannoneer.grappling)
		{
			handcannoneer.grapple_id = grapple_id;
			handcannoneer.grapple_ratio = grapple_ratio;
			handcannoneer.grapple_pos = grapple_pos;
			handcannoneer.grapple_vel = grapple_vel;
		}
	}
}

bool hasAmmunition( CBlob@ this )
{
	return this.getBlobCount( ammunition ) > 0;
}
