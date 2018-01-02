﻿// Tunnel

#include "3kemuc.as";

#include "WARCosts.as";
#include "TunnelCommon.as";

void onInit( CBlob@ this )
{
	this.set_TileType("background tile", CMap::tile_castle_back);
}

void onInit( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer( "planks", this.getFilename() , 24, 24, blob.getTeamNum(), blob.getSkinNum() );
	if(planks !is null)
	{
		Animation@ anim = planks.addAnimation( "default", 3, true );
		anim.AddFrame(5);
		planks.SetOffset(Vec2f(0,0));
		planks.SetRelativeZ( 10 );
	}

	this.getCurrentScript().tickFrequency = 45; // opt
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ planks = this.getSpriteLayer( "planks" );
	if(planks is null) return;

	CBlob@[] list;
	if(getTunnels(this.getBlob(), list))
	{
		planks.SetVisible(false);
	}
	else
	{
		planks.SetVisible(true);
	}
}
