// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 20;
const s32 cost_ballista = 40;
const s32 cost_ballista_ammo = 8;
const s32 cost_ballista_ammo_upgrade_gold = 60;
const s32 cost_balloon = 30;

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	//this.getSprite().getConsts().accurateLighting = true;
	

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken( "$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32,8), 1 );
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(7,2));	
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem( this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + descriptions[5], false, true );
		s.crate_icon = 4;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_catapult );
	}
	{
		ShopItem@ s = addShopItem( this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + descriptions[6], false, true );
		s.crate_icon = 5;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_ballista );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Bomb Bolt Upgrade", "$vehicleshop_upgradebolts$", "upgradebolts", "For Ballista\nTurns its piercing bolts into a shaped explosive charge.", false );
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", cost_ballista_ammo_upgrade_gold );
		AddRequirement( s.requirements, "not tech", "bomb ammo", "Bomb Bolt", 1 );
	}
	{
		ShopItem@ s = addShopItem( this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false );
		s.crate_icon = 5;
		AddRequirement( s.requirements, "coin", "", "Coins", cost_ballista_ammo );
	}
	{
		ShopItem@ s = addShopItem( this, "Hot Air Balloon", "$bomber$", "balloon", "A fragile Hot Air Balloon, good for exploration.", false, true );
		s.crate_icon = 5;
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 500);
		AddRequirement( s.requirements, "coin", "", "Coins", cost_balloon);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound( "/ChaChing.ogg" );
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) {
			return;
		}
		string name = params.read_string();
		{
			if(name == "upgradebolts") {
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
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
