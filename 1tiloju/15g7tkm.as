//Archer Include

namespace MusketmanParams
{
enum Aim {
    not_aiming = 0,
    readying,
    charging,
    fired,
    no_ammunition
}

const ::s32 ready_time = 21;

const ::s32 shoot_period = 60;
const ::s32 shoot_period_1 = MusketmanParams::shoot_period / 3;
const ::s32 shoot_period_2 = 2 * MusketmanParams::shoot_period / 3;

const ::s32 fired_time = 7;
const ::f32 shoot_max_vel = 25.0f;
}

//TODO: move vars into musketman params namespace
const f32 musketman_grapple_length = 72.0f;
const f32 musketman_grapple_slack = 16.0f;
const f32 musketman_grapple_throw_speed = 20.0f;

const f32 musketman_grapple_force = 2.0f;
const f32 musketman_grapple_accel_limit = 1.5f;
const f32 musketman_grapple_stiffness = 0.1f;

namespace ShotType
{
enum type
{
    normal,
	count
};
}

shared class MusketmanInfo
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

	MusketmanInfo()
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
	MusketmanInfo@ musketman;
	if (!this.get( "musketmanInfo", @musketman )) { return; }
	
	CBitStream bt;
	
	bt.write_bool(musketman.grappling);
	if(musketman.grappling)
	{
		bt.write_u16( musketman.grapple_id );
		bt.write_u8( u8(musketman.grapple_ratio*250) );
		bt.write_Vec2f( musketman.grapple_pos );
		bt.write_Vec2f( musketman.grapple_vel );
	}
	
	this.SendCommand( this.getCommandID(grapple_sync_cmd), bt );
}

//TODO: saferead
void HandleGrapple( CBlob@ this, CBitStream@ bt, bool apply )
{
	MusketmanInfo@ musketman;
	if (!this.get( "musketmanInfo", @musketman )) { return; }
	
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
		musketman.grappling = grappling;
		if(musketman.grappling)
		{
			musketman.grapple_id = grapple_id;
			musketman.grapple_ratio = grapple_ratio;
			musketman.grapple_pos = grapple_pos;
			musketman.grapple_vel = grapple_vel;
		}
	}
}

bool hasAmmunition( CBlob@ this )
{
	return this.getBlobCount( ammunition ) > 0;
}
