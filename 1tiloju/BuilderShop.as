﻿// Builder Workshop

#include "1oltmot.as";

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
	{	 
		ShopItem@ s = addShopItem( this, "Lantern", "$lantern$", "lantern", descriptions[9], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LANTERN );
	}
	{
		ShopItem@ s = addShopItem( this, "Bucket", "$bucket$", "bucket", descriptions[36], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BUCKET );
	}
	{
		ShopItem@ s = addShopItem( this, "Sponge", "$sponge$", "sponge", descriptions[53], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SPONGE );
	}
	{
		ShopItem@ s = addShopItem( this, "Boulder", "$boulder$", "boulder", descriptions[17], false );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 35 );
	}
	{
		ShopItem@ s = addShopItem( this, "Trampoline", "$trampoline$", "trampoline", descriptions[30], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_TRAMPOLINE );
	}
	{
		ShopItem@ s = addShopItem( this, "Crate", "$crate$", "crate", descriptions[18], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CRATE );
	}
	{	 
		ShopItem@ s = addShopItem( this, "Saw", "$saw$", "saw", descriptions[12], false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SAW * 2 );
	}
	{
		ShopItem@ s = addShopItem( this, "Chainsaw", "$chainsaw$", "chainsaw", "A chainsaw for cutting down trees and other... things.", false );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", WORKSHOP_CHAINSAW_WOOD_COST );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", WORKSHOP_CHAINSAW_STONE_COST );
	}
	{
		ShopItem@ s = addShopItem( this, "Drill", "$drill$", "drill", descriptions[43], false );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_DRILL );
	}
	this.set_string("required class", "builder");
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
