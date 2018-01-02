// Keg logic
#include "Hitters.as";
#include "5ggqoj.as";

void onInit(CBlob@ this)
{
	this.Tag("bomberman_style");
	this.set_f32("map_bomberman_width", 24.0f);
	this.set_f32("explosive_radius", 64.0f);
	this.set_f32("explosive_damage", 10.0f);
	this.set_u8("custom_hitter", Hitters::keg);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 72.0f);
	this.set_f32("map_damage_ratio", 0.8f);
	this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 180.0f);  // 180.0f
	this.Tag("medium weight");

	this.set_u16("_keg_carrier_id", 0xffff);

	CSpriteLayer@ fuse = this.getSprite().addSpriteLayer("fuse", "Keg.png" , 16, 16, 0, 0);

	if (fuse !is null)
	{
		fuse.addAnimation("default", 0, false);
		int[] frames = {8, 9, 10, 11, 12, 13};
		fuse.animation.AddFrames(frames);
		fuse.SetOffset(Vec2f(3, -4));
	}
}

//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.animation.frame = (this.animation.getFramesCount()) * (1.0f - (blob.getHealth() / blob.getInitialHealth()));

	s32 timer = blob.get_s32("explosion_timer") - getGameTime();

	if (timer < 0)
	{
		return;
	}

	CSpriteLayer@ fuse = this.getSpriteLayer("fuse");

	if (fuse !is null)
	{
		fuse.animation.frame = 1 + (fuse.animation.getFramesCount() - 1) * (1.0f - ((timer + 5) / f32(blob.get_f32("keg_time"))));
	}

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		this.set_u16("_keg_carrier_id", attached.getNetworkID());
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (getNet().isServer() &&
	        !isExplosionHitter(customData) &&
	        (hitterBlob is null || hitterBlob.getTeamNum() != this.getTeamNum()))
	{
		u16 id = this.get_u16("_keg_carrier_id");
		if (id != 0xffff)
		{
			CBlob@ carrier = getBlobByNetworkID(id);
			if (carrier !is null)
			{
				this.server_DetachFrom(carrier);
			}
		}
	}

	switch (customData)
	{
		case Hitters::sword:
		case Hitters::axe:
		case Hitters::arrow:
			damage *= 0.25f; //quarter damage from these
			break;
		default:
			damage *= 0.5f; //half damage from everything else
	}

	return damage;
}
