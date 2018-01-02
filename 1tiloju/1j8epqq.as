/* 1j8epqq.as
 * author: Aphelion
 */

#include "1oltmot.as";

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	// CANDLE LIGHT
	this.SetLight( true );
    this.SetLightRadius( 64.0f );
    this.SetLightColor(SColor(255, 255, 240, 171));
	
	// TRADE
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 3));
	this.set_string("shop description", "Trade");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Buy wood", "$mat_wood$", "mat_wood", "Buy 250 wood for 10 coins", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy stone", "$mat_stone$", "mat_stone", "Buy 250 stone for 15 coins", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy gold", "$mat_gold$", "mat_gold", "Buy 250 gold for 50 coins");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Buy flour", "$mat_flour$", "mat_flour", "Buy 100 flour for 30 coins");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Sell wood", "$mat_wood$", "coins-5", "Sell 250 wood for 5 coins", true);
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell stone", "$mat_stone$", "coins-8", "Sell 250 stone for 8 coins", true);
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell gold", "$mat_gold$", "coins-10", "Sell 50 gold for 10 coins", true);
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell flour", "$mat_flour$", "coins-15", "Sell 50 flour for 15 coins", true);
		s.spawnNothing = true;
		
		AddRequirement(s.requirements, "blob", "mat_flour", "Flour", 50);
	}
	
	{
		ShopItem@ s = addShopItem( this, "Bread", "$bread$", "bread", "Delicious crunchy whole-wheat bread\nHeals 1 $heart$");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_FOOD_BREAD_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Cooked Fish", "$cooked_fish$", "cooked_fish", "A cooked fishy on a stick\nHeals 1 $heart$");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_FOOD_COOKED_FISH_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Burger", "$burger$", "burger", "A very fishy hamburger\nHeals 2 $heart$");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_FOOD_BURGER_COST);
	}
	{
		ShopItem@ s = addShopItem( this, "Cake", "$cake$", "cake", "A delicious cake\nHeals 3 $heart$");
		
		AddRequirement( s.requirements, "coin", "", "Coins", TRADER_FOOD_CAKE_COST);
	}
	
	this.getCurrentScript().tickFrequency = 300;
}

void onTick(CBlob@ this)
{
    if(XORRandom(512) < 128)
	{
	    this.getSprite().PlaySound("/TraderSayHello", 0.5f);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		
		bool isServer = (getNet().isServer());
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		{
		    if(name.findFirst("coins-") != -1)
			{
			    CBlob@ callerBlob = getBlobByNetworkID(caller);
				
				if (isServer && callerBlob !is null)
				{
			        CPlayer@ callerPlayer = callerBlob.getPlayer();
					
					if(callerPlayer !is null)
					   callerPlayer.server_setCoins( callerPlayer.getCoins() + parseInt(name.split("-")[1]) );
				}
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
