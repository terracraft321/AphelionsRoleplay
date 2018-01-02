//Archer Include

namespace CrossbowmanParams
{
enum Aim {
    not_aiming = 0,
    readying,
    charging,
    fired,
    no_arrows,
	stabbing,
	legolas_ready,
	legolas_charging
}

const ::s32 ready_time = 21;

const ::s32 shoot_period = 40;
const ::s32 shoot_period_1 = CrossbowmanParams::shoot_period/3;
const ::s32 shoot_period_2 = 2*CrossbowmanParams::shoot_period/3;
const ::s32 legolas_period = CrossbowmanParams::shoot_period*3;

const ::s32 fired_time = 7;
const ::f32 shoot_max_vel = 21.9875f;

const ::s32 legolas_charge_time = 5;
const ::s32 legolas_arrows_count = 1;
const ::s32 legolas_arrows_volley = 3;
const ::s32 legolas_arrows_deviation = 2;
const ::s32 legolas_time = 60;
}

//TODO: move vars into crossbowman params namespace
const f32 crossbowman_grapple_length = 72.0f;
const f32 crossbowman_grapple_slack = 16.0f;
const f32 crossbowman_grapple_throw_speed = 20.0f;

const f32 crossbowman_grapple_force = 2.0f;
const f32 crossbowman_grapple_accel_limit = 1.5f;
const f32 crossbowman_grapple_stiffness = 0.1f;

namespace ArrowType
{
enum type
{
    normal = 0,
	normal_iron,
	normal_steel,
	normal_piercing,
    fire,
	bomb,
	water,
	count
};
}

shared class CrossbowmanInfo
{
	s8 charge_time;
	u8 charge_state;
	bool has_arrow;
	u8 stab_delay;
	u8 fletch_cooldown;
	u8 arrow_type;

	u8 legolas_arrows;
	u8 legolas_time;
	
	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	f32 cache_angle;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	CrossbowmanInfo()
	{
		charge_time = 0;
		charge_state = 0;
		has_arrow = false;
		stab_delay = 0;
		fletch_cooldown = 0;
		arrow_type = ArrowType::normal;
		grappling = false;
	}
};

const string grapple_sync_cmd = "grapple sync";

void SyncGrapple( CBlob@ this )
{
	CrossbowmanInfo@ crossbowman;
	if (!this.get( "crossbowmanInfo", @crossbowman )) { return; }
	
	CBitStream bt;
	
	bt.write_bool(crossbowman.grappling);
	if(crossbowman.grappling)
	{
		bt.write_u16( crossbowman.grapple_id );
		bt.write_u8( u8(crossbowman.grapple_ratio*250) );
		bt.write_Vec2f( crossbowman.grapple_pos );
		bt.write_Vec2f( crossbowman.grapple_vel );
	}
	
	this.SendCommand( this.getCommandID(grapple_sync_cmd), bt );
}

//TODO: saferead
void HandleGrapple( CBlob@ this, CBitStream@ bt, bool apply )
{
	CrossbowmanInfo@ crossbowman;
	if (!this.get( "crossbowmanInfo", @crossbowman )) { return; }
	
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
		crossbowman.grappling = grappling;
		if(crossbowman.grappling)
		{
			crossbowman.grapple_id = grapple_id;
			crossbowman.grapple_ratio = grapple_ratio;
			crossbowman.grapple_pos = grapple_pos;
			crossbowman.grapple_vel = grapple_vel;
		}
	}
}

const string[] arrowTypeNames = { "mat_arrows",
                                  "mat_ironarrows",
								  "mat_steelarrows",
								  "mat_piercingarrows",
								  "mat_firearrows",
								  "mat_bombarrows",
								  "mat_waterarrows"
                                };

const string[] arrowNames = { "Copper arrows",
                              "Iron arrows",
							  "Steel arrows",
							  "Piercing arrows",
                              "Fire arrows",
							  "Bomb arrow",
							  "Water arrows"
                            };

const string[] arrowIcons = { "$Arrow$",
                              "$IronArrow$",
							  "$SteelArrow$",
							  "$MythrilArrow$",
							  "$FireArrow$",
							  "$BombArrow$",
							  "$WaterArrow$"
};

bool hasArrows( CBlob@ this )
{
	CrossbowmanInfo@ crossbowman;
	if (!this.get( "crossbowmanInfo", @crossbowman )) {
		return false;

	}
	if (crossbowman.arrow_type >= 0 && crossbowman.arrow_type < arrowTypeNames.length) {
		return this.getBlobCount( arrowTypeNames[crossbowman.arrow_type] ) > 0;
	}

	return false;
}

bool hasArrows( CBlob@ this, u8 arrowType )
{
	return this.getBlobCount( arrowTypeNames[arrowType] ) > 0;
}

void SetArrowType( CBlob@ this, const u8 type )
{
	CrossbowmanInfo@ crossbowman;
	if (!this.get( "crossbowmanInfo", @crossbowman )) {
		return;

	}		  	
	crossbowman.arrow_type = type;
}

u8 getArrowType( CBlob@ this )
{
	CrossbowmanInfo@ crossbowman;
	if (!this.get( "crossbowmanInfo", @crossbowman )) {
		return 0;

	}						 
	return crossbowman.arrow_type;
}

bool isArrowTypeNormal( u8 arrowType )
{
    return arrowType == ArrowType::normal ||
	       arrowType == ArrowType::normal_iron ||
		   arrowType == ArrowType::normal_steel ||
		   arrowType == ArrowType::normal_piercing;
}
