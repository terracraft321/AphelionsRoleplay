/* 389omug.as
 */

#include "StandardControlsCommon.as";

const string cmd_rest = "bed rest";

const f32 heal_amount = 0.25f;
const u8 heal_rate = 30;

void onInit( CBlob@ this )
{		 	
	this.getShape().getConsts().mapCollisions = false;

	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null) {
		bed.SetKeysToTake( key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3 | key_pickup | key_inventory );
		bed.SetMouseTaken(true);
	}

	this.addCommandID(cmd_rest);
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ bed = this.addSpriteLayer("bed", 32, 16);
	if (bed !is null)
	{
		{
			bed.addAnimation("default", 0, false);
			int[] frames = {2, 3};
			bed.animation.AddFrames(frames);
		}
	}

	CSpriteLayer@ zzz = this.addSpriteLayer("zzz", 8, 8);
	if (zzz !is null)
    {
		{
			zzz.addAnimation("default", 15, true);
			int[] frames = {0, 1, 2, 2, 3};
			zzz.animation.AddFrames(frames);
		}
		zzz.SetOffset(Vec2f(-3, -6));
		zzz.SetLighting(false);
		zzz.SetVisible(false);
	}

	this.SetEmitSound("MigrantSleep.ogg");
	this.SetEmitSoundPaused(true);
	this.SetEmitSoundVolume(0.5f);
}

void onTick(CBlob@ this)
{
	bool isServer = getNet().isServer();
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null) {
		CBlob@ patient = bed.getOccupied();
		if (patient !is null) {
			if (bed.isKeyJustPressed(key_up)) {
				if (isServer) {
					patient.server_DetachFrom(this);
				}
			}
			else if (getGameTime() % heal_rate == 0) {
				if (requiresTreatment(patient)) {
					if (patient.isMyPlayer()) {
						Sound::Play("Heart.ogg", patient.getPosition());
					}
					if (isServer) {
						patient.server_Heal(heal_amount);
					}
				}
				else {
					if (isServer) {
						patient.server_DetachFrom(this);
					}
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller) && bedAvailable(this) && requiresTreatment(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton(29, Vec2f(0.0f, -3.0f), this, this.getCommandID(cmd_rest), "Rest", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = (getNet().isServer());

	if (cmd == this.getCommandID(cmd_rest))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller !is null)
		{
			AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
			if (bed !is null && bedAvailable(this)) {
				CBlob@ carried = caller.getCarriedBlob();
				if (isServer) {
					if (carried !is null) {
						if (!caller.server_PutInInventory(carried)) {
							carried.server_DetachFrom(caller);
						}
					}
					this.server_AttachTo(caller, "BED");
				}
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	attached.getShape().getConsts().collidable = false;
	attached.SetFacingLeft(true);
	attached.AddScript("WakeOnHit.as");

	CSprite@ attached_sprite = attached.getSprite();
	if (attached_sprite !is null && getNet().isClient())
	{
		attached_sprite.SetVisible(false);
		attached_sprite.PlaySound("GetInVehicle.ogg");
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		updateLayer(sprite, "bed", 1, true, false);
		updateLayer(sprite, "zzz", 0, true, false);

		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();

		if (getNet().isClient())
		{
			CSpriteLayer@ bed_head = sprite.addSpriteLayer("bed head", "Entities/Characters/Sprites/Heads.png", 16, 16, attached.getTeamNum(), attached.getSkinNum());
			if (bed_head !is null)
			{
				Animation@ anim = bed_head.addAnimation("default", 0, false);
				anim.AddFrame(2);

				bed_head.SetAnimation(anim);
				bed_head.SetFacingLeft(true);
				bed_head.RotateBy(80, Vec2f_zero);
				bed_head.SetRelativeZ(2);
				bed_head.SetOffset(Vec2f(1, 2));
				bed_head.SetVisible(true);
			}
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	detached.getShape().getConsts().collidable = true;
	detached.AddForce(Vec2f(0, -20));
	detached.RemoveScript("WakeOnHit.as");

	CSprite@ detached_sprite = detached.getSprite();
	if (detached_sprite !is null) {
		detached_sprite.SetVisible(true);
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null) {
		updateLayer(sprite, "bed", 0, true, false);
		updateLayer(sprite, "zzz", 0, false, false);
		updateLayer(sprite, "bed head", 0, false, true);

		sprite.SetEmitSoundPaused(true);
	}
}

void updateLayer(CSprite@ sprite, string name, int index, bool visible, bool remove)
{
	if (sprite !is null) {
		CSpriteLayer@ layer = sprite.getSpriteLayer(name);
		if (layer !is null) {
			if (remove == true) {
				sprite.RemoveSpriteLayer(name);
				return;
			}
			else {
				layer.SetFrameIndex(index);
				layer.SetVisible(visible);
			}
		}
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null) {
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null) {
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}

bool bedAvailable(CBlob@ this)
{
	AttachmentPoint@ bed = this.getAttachments().getAttachmentPointByName("BED");
	if (bed !is null) {
		CBlob@ patient = bed.getOccupied();
		if (patient !is null) {
			return false;
		}
	}
	return true;
}

bool requiresTreatment(CBlob@ caller)
{
	return caller.getHealth() < caller.getInitialHealth();
}
