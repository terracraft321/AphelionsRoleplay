// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";
#include "DoorCommon.as";

int openRecursion = 0;

bool oldTrapBehaviour(CBlob@ this)
{
	return getRules().hasTag("old trap blocks");
}

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
    this.getSprite().getConsts().accurateLighting = true;

	this.set_bool("open", false);
	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	this.set_TileType("background tile", CMap::tile_castle_back);

	MakeDamageFrame(this);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 0;
}

void onTick(CBlob@ this)
{
	bool touching = false;
	const uint count = this.getTouchingCount();
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (opensThis(this, blob))
		{
			setOpen(this, true);
			this.getShape().checkCollisionsAgain = true;
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (!isOpen(this))
	{
		MakeDamageFrame(this);
	}
}

void MakeDamageFrame(CBlob@ this)
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ((hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open)
{
	CSprite@ sprite = this.getSprite();

	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.animation.frame = 3;
		this.getShape().getConsts().collidable = false;
		this.getShape().checkCollisionsAgain = true;
	}
	else
	{
		sprite.SetZ(100.0f);
		MakeDamageFrame(this);
		this.getShape().getConsts().collidable = true;
	}

	//TODO: fix flags sync and hitting
	//SetSolidFlag(this, !open);

	if (this.getTouchingCount() <= 1 && openRecursion < 5)
	{
		SetBlockAbove(this, open);
		openRecursion++;
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (!opensThis(this, blob))
	{
		return !isOpen(this);
	}
	else
	{
		return !opensThis(this, blob) && !isOpen(this);
	}
}

bool opensThis(CBlob@ this, CBlob@ blob)
{
	return !oldTrapBehaviour(this) && canOpenDoor(this, blob) || //allow teamies to use it like a door
		   (!isTeamFriendly(this.getTeamNum(), blob.getTeamNum()) &&
	        !isOpen(this) && blob.isCollidable() &&
	        (blob.hasTag("player") || blob.hasTag("vehicle")));
}

bool mightOpenThis(CBlob@ this, CBlob@ blob)
{
	return !oldTrapBehaviour(this) && (isTeamFriendly(this.getTeamNum(), blob.getTeamNum()));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (opensThis(this, blob))
	{
		openRecursion = 0;
		setOpen(this, true);
	}
	else if(mightOpenThis(this, blob))
	{
		this.getCurrentScript().tickFrequency = 1;
	}
}

void onEndCollision(CBlob@ this, CBlob@ blob)
{
	if (blob is null) return;

	bool touching = false;
	const uint count = this.getTouchingCount();
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			touching = true;
			break;
		}
	}

	if (!touching)
	{
		setOpen(this, false);
		this.getCurrentScript().tickFrequency = 0;
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void SetBlockAbove(CBlob@ this, const bool open)
{
	CBlob@ blobAbove = getMap().getBlobAtPosition(this.getPosition() + Vec2f(0, -8));
	if (blobAbove is null || blobAbove.getName() != "trap_block") return;

	setOpen(blobAbove, open);
}
