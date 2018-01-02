// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";

s32 cost_bomb = 12;
s32 cost_waterbomb = 8;
s32 cost_keg = 30;
s32 cost_mine = 15;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));

	//setup shop items
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", descriptions[1], true);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_bomb);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", descriptions[52], true);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_waterbomb);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", descriptions[20], false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_mine);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", descriptions[4], false);
		AddRequirement(s.requirements, "coin", "", "Coins", cost_keg);
	}
	this.set_string("required class", "knight");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getConfig() == this.get_string("required class")) {
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else {
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound( "/ChaChing.ogg" );
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
