/* 1su6vcr.as
 * author: Aphelion
 */

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

const s32 cost_energyrune = 5;
const s32 cost_miasmarune = 8;
const s32 cost_lightningrune = 12;
const s32 cost_bombrune = 20;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 1));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	
	// CLASS
	this.set_Vec2f("class offset", Vec2f(-12, 0));
	
	{
		ShopItem@ s = addShopItem( this, "Energy runes", "$mat_energyrunes$", "mat_energyrunes", "Inflicts a small amount of damage over a wide area", true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_energyrune );
	}
	{
		ShopItem@ s = addShopItem( this, "Miasma runes", "$mat_miasmarunes$", "mat_miasmarunes", "Dazzles victims with toxic gas", true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_miasmarune );
	}
	{
		ShopItem@ s = addShopItem( this, "Lightning runes", "$mat_lightningrunes$", "mat_lightningrunes", "Inflicts a large amount of damage over a small area while stunning victims", true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_lightningrune );
	}
	{
		ShopItem@ s = addShopItem( this, "Bomb runes", "$mat_bombrunes$", "mat_bombrunes", "Deals a large amount of damage to structures", true );
		AddRequirement( s.requirements, "coin", "", "Coins", cost_bombrune );
	}
	this.set_string("required class", "mage");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getConfig() == this.get_string("required class")) {
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else {
		this.set_Vec2f("shop offset", Vec2f(12, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound("/ChaChing.ogg");
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
