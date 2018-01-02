/* 2riebao.as
 * author: Aphelion
 */

#include "1oltmot.as";

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "3js8kmj.as";

void onInit( CBlob@ this )
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// TRADE
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));	
	this.set_string("shop description", "Trade");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem( this, "Grain seed", "$grain$", "grain_plant", "Grain seed\n\nFor growing Grain that can be milled into flour");
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SEED_GRAIN_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Bush seed", "$bush$", "bush", "Bush seed\n\nFor growing a pleasant looking Bush");
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SEED_BUSH_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Cactus seed", "$cactus$", "cactus", "Cactus seed\n\nFor growing a prickly Cactus");
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SEED_CACTUS_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Grain", "$grain$", "grain", "Grain\n\nWonderful grain!");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_GRAIN_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Oak seed", "$tree_bushy$", "tree_bushy", "Oak seed\n\nFor growing a mighty Oak Tree");
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SEED_TREE_BUSHY_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Pine seed", "$tree_pine$", "tree_pine", "Pine seed\n\nFor growing a mighty Pine Tree");
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SEED_TREE_PINE_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Elder seed", "$tree_redwood$", "tree_redwood", "Elder seed\n\nFor growing a legendary Elder Tree");
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_SEED_TREE_REDWOOD_COST);
	}
	{
		ShopItem@ s = addShopItem(this, "Leaf", "$leaf$", "leaf", "Leaf\n\nA leaf that can be eaten or used some other way");
		AddRequirement(s.requirements, "coin", "", "Coins", TRADER_LEAF_COST);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("shop made item"))
	{
		bool isServer = (getNet().isServer());
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		if    (name != "grain" && name != "leaf" && isServer)
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if    (callerBlob !is null)
			{
		    	CBlob@ seed = server_MakeSeed(callerBlob.getPosition(), name);
				if    (seed !is null)
				{
			    	if (seed.canBePutInInventory(callerBlob))
					{
						callerBlob.server_PutInInventory(seed);
					}
					else if (callerBlob.getAttachments() !is null && callerBlob.getAttachments().getAttachmentPointByName("PICKUP") !is null)
					{
						callerBlob.server_Pickup(seed);
			    	}
				}
			}
		}
	}
}
