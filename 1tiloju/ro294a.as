/* ro294a.as
 * author: Aphelion
 * 
 * The script that handles the Furnace side of things.
 */
 
#include "MakeMat.as";
#include "Requirements.as";
#include "ShopCommon.as";

const string cmd_deposit_wood = "deposit wood";
const string cmd_retrieve_bar = "retrieve bar";

const string deposit_mat = "mat_wood";

const int deposit_mat_cap = 500;

const u8 iron_smelt_time = 10;
const u8 gold_smelt_time = 10;
const u8 steel_smelt_time = 20;
const u8 mythril_smelt_time = 30;
const u8 adamant_smelt_time = 40;

void onInit( CSprite@ this )
{
	CSpriteLayer@ furnace = this.addSpriteLayer("furnace", "Furnace.png", 17, 11);
	
	if (furnace !is null)
    {
		furnace.SetOffset(Vec2f(-22.5f, 12.5f));
		
        Animation@ anim = furnace.addAnimation("unlit", 0, false);
        anim.AddFrame(0);
		
        Animation@ anim2 = furnace.addAnimation("lit", 3, true);
        anim2.AddFrame(1);
        anim2.AddFrame(2);
        anim2.AddFrame(3);
		
		furnace.SetRelativeZ(1);
		furnace.SetVisible(true);
    }
}

void onInit( CBlob@ this )
{
    this.addCommandID(cmd_deposit_wood);
    this.addCommandID(cmd_retrieve_bar);

    this.set_bool("furnace_lit", false);
    this.set_u16("furnace_wood", 0);
	this.set_bool("furnace_smelting", false);
	this.set_u8("furnace_timer", 0);
	this.set_string("furnace_bar", "");
	
	this.SetLight(false);
	this.SetLightRadius(96.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	
    this.getSprite().SetEmitSound( "Entities/Industry/Fireplace/CampfireSound.ogg" );
	this.getSprite().SetEmitSoundPaused(true);
	
	this.getCurrentScript().tickFrequency = 30;
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(12.0f, 5.0f));
	this.set_Vec2f("shop menu size", Vec2f(5, 1));	
	this.set_string("shop description", "Smelt");
	this.set_u8("shop icon", 31);
	
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem( this, "Iron Bar", "$mat_ironbars$", "mat_ironbars", "Iron Bar\n\nCan be used to forge equipment\nSmelting duration of 10 seconds" );
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_iron", "Iron", 10 );
	}
	{
		ShopItem@ s = addShopItem( this, "Gold Bar", "$mat_goldbars$", "mat_goldbars", "Gold Bar\n\nCan be used to forge gold blocks and cosmetic equipment\nSmelting duration of 10 seconds" );
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_gold", "Gold", 100 );
	}
	{
		ShopItem@ s = addShopItem( this, "Steel Bar", "$mat_steelbars$", "mat_steelbars", "Steel Bar\n\nCan be used to forge equipment\nSmelting duration of 20 seconds" );
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_coal", "Coal", 10 );
		AddRequirement( s.requirements, "blob", "mat_iron", "Iron", 10 );
		AddRequirement( s.requirements, "tech", "Smithing I", "Smithing I", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Mythril Bar", "$mat_mythrilbars$", "mat_mythrilbars", "Mythril Bar\n\nCan be used to forge equipment\nSmelting duration of 30 seconds" );
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_coal", "Coal", 10 );
		AddRequirement( s.requirements, "blob", "mat_mythril", "Mythril", 10 );
		AddRequirement( s.requirements, "tech", "Smithing II", "Smithing II", 1);
	}
	{
		ShopItem@ s = addShopItem( this, "Adamant Bar", "$mat_adamantbars$", "mat_adamantbars", "Adamant Bar\n\nCan be used to forge equipment\nSmelting duration of 40 seconds" );
		s.spawnNothing = true;
		
		AddRequirement( s.requirements, "blob", "mat_coal", "Coal", 10 );
		AddRequirement( s.requirements, "blob", "mat_adamantite", "Adamantite", 10 );
		AddRequirement( s.requirements, "tech", "Smithing III", "Smithing III", 1);
	}
}

void onTick( CBlob@ this )
{
    const bool lit = isFurnaceLit(this);
	const bool smelting = isSmelting(this) && !isSmeltingComplete(this);
	
    if(lit && getWoodCount(this) < 1)
	{
	    this.set_bool("furnace_lit", false);
	    this.SetLight(false);
		this.getSprite().SetEmitSoundPaused(true);
		
		if(getNet().isClient())
		{
            CSpriteLayer@ furnace = this.getSprite().getSpriteLayer("furnace");
			if(furnace !is null)
			   furnace.SetAnimation("unlit");
		}
	}
	else if(!lit && getWoodCount(this) > 1)
	{
		this.set_bool("furnace_lit", true);
	    this.SetLight(true);
		this.getSprite().SetEmitSoundPaused(false);
		
		if(getNet().isClient())
		{
            CSpriteLayer@ furnace = this.getSprite().getSpriteLayer("furnace");
			if(furnace !is null)
			   furnace.SetAnimation("lit");
		}
	}
	else if(lit && getNet().isServer())
	{
	    decrementWoodCount(this);
	}
	
	if(smelting && isFurnaceLit(this) && getNet().isServer())
	{
	    decrementSmeltTimer(this);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller) && isFurnaceLit(this)
	                                                           && !isSmelting(this));
	
	if(this.isOverlapping(caller))
	{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		
		CButton@ deposit_button = caller.CreateGenericButton("$" + deposit_mat + "$", Vec2f(12.0f, -5.0f), this, this.getCommandID(cmd_deposit_wood), "Deposit wood - " + getWoodCount(this) + "/" + deposit_mat_cap, params);
	    if(deposit_button !is null)
		{
           deposit_button.deleteAfterClick = false;
		   deposit_button.SetEnabled(getWoodCount(this) < deposit_mat_cap && caller.getBlobCount(deposit_mat) > 0);
		}
		
		if(isSmelting(this))
		{
		    if(isSmeltingComplete(this))
			{
				CButton@ retrieve_button = caller.CreateGenericButton(28, Vec2f(12.0f, 5.0f), this, this.getCommandID(cmd_retrieve_bar), "Retrieve bar", params);
			}
			else
			{
				CButton@ retrieve_button = caller.CreateGenericButton(28, Vec2f(12.0f, 5.0f), this, this.getCommandID(cmd_retrieve_bar), "Smelting - " + (isFurnaceLit(this) ? "Time left: " + getSmeltTimeLeft(this) + " seconds" : "Please add wood to the Furnace"), params);
		        retrieve_button.SetEnabled(false);
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    bool isServer = getNet().isServer();
	
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 netID, item;
		
		if(!params.saferead_netid(netID) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		
		this.set_bool("furnace_smelting", true);
        this.set_string("furnace_bar", name);
		this.set_u8("furnace_timer", name == "mat_ironbars" ? iron_smelt_time :
			                         name == "mat_steelbars" ? steel_smelt_time :
									 name == "mat_goldbars" ? gold_smelt_time :
								     name == "mat_mythrilbars" ? mythril_smelt_time :
									 name == "mat_adamantbars" ? adamant_smelt_time :
									    10);
	}
	else if (cmd == this.getCommandID(cmd_retrieve_bar))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if (caller is null) { return; }
		
		if(isServer)
		{
            MakeMat(caller, this.getPosition(), this.get_string("furnace_bar"), 1);
		}
		
		resetSmeltingData(this);
	}
	else if (cmd == this.getCommandID(cmd_deposit_wood))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if (caller is null) { return; }
		
		if(isServer)
		{
	    	int deposit_amount = Maths::Min(deposit_mat_cap - getWoodCount(this), Maths::Min(caller.getBlobCount(deposit_mat), 100));
			
			caller.TakeBlob(deposit_mat, deposit_amount);
			
			this.set_u16("furnace_wood", getWoodCount(this) + deposit_amount);
			this.Sync("furnace_wood", true);
		}
	}
}

void resetSmeltingData( CBlob@ this )
{
    this.set_bool("furnace_smelting", false);
    this.set_string("furnace_bar", "");
	this.set_u8("furnace_timer", 0);
}

bool isFurnaceLit( CBlob@ this )
{
    return this.get_bool("furnace_lit");
}

u16 getWoodCount( CBlob@ this )
{
    return this.get_u16("furnace_wood");
}

void decrementWoodCount( CBlob@ this )
{
    this.set_u16("furnace_wood", getWoodCount(this) - 1);
	this.Sync("furnace_wood", true);
}

bool isSmelting( CBlob@ this )
{
    return this.get_bool("furnace_smelting");
}

bool isSmeltingComplete( CBlob@ this )
{
    return getSmeltTimeLeft(this) <= 0;
}

u8 getSmeltTimeLeft( CBlob@ this )
{
    return this.get_u8("furnace_timer");
}

void decrementSmeltTimer( CBlob@ this )
{
    this.set_u8("furnace_timer", getSmeltTimeLeft(this) - 1);
	this.Sync("furnace_timer", true);
}
