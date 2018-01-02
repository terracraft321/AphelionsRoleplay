/* shts5l.as
 * author: Aphelion
 */

#include "1m0gpq4.as";

#include "30j68o4.as";
#include "MakeMat.as";

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";

shared class Item
{
    
	Item() {}
	
	string itemBlob = "";
	string itemName = "";
	string itemSeller = "";
	
	u16 materialSize = 0;
	u16 quantity = 0;
	u16 price = 0;
	
	bool material = false;
	bool selling = false;
	
	void Serialise( CBitStream@ stream )
	{
	    stream.write_string(itemBlob);
		stream.write_string(itemName);
		stream.write_string(itemSeller);
		stream.write_u16(materialSize);
		stream.write_u16(quantity);
		stream.write_u16(price);
		stream.write_bool(material);
		stream.write_bool(selling);
	}
	
	Item@ Unserialise( CBitStream@ stream )
	{
	    stream.saferead_string(itemBlob);
		stream.saferead_string(itemName);
		stream.saferead_string(itemSeller);
		stream.saferead_u16(materialSize);
		stream.saferead_u16(quantity);
		stream.saferead_u16(price);
		stream.saferead_bool(material);
		stream.saferead_bool(selling);
		return this;
	}
	
	bool valid()
	{
	    return itemBlob != "" && itemName != "" && itemSeller != "";
	}
	
}

const string cmd_purchase_item = "trading post purchase item";
const string cmd_retrieve_item = "trading post retrieve item";
const string cmd_toggle_sale = "trading post toggle sale";
const string cmd_set_item = "trading post set item";
const string cmd_add_item = "trading post add item";

const string item_property = "trading post item data ";

const string[] invalid_items =
{
    "chest_iron",
	"chest_steel",
	"chest_gilded",
	"chest_mythril",
	"chest_adamant",
	
	"builder",
	"archer",
	"musketman",
	"handcannoneer"
	"knight",
	"maceman",
	"axeman",
	"mage",
	
	"spikes",
	"ladder",
	"wooden_door",
	"stone_door",
	"trap_block",
	"wooden_platform",
	"team_platform",
};

const int MIN_PRICE = 1;
const int MAX_PRICE = 1000;
const int MAX_ITEMS = 100;

Item NULL_ITEM = Item();

void onInit( CBlob@ this )
{
	this.addCommandID(cmd_purchase_item);
	this.addCommandID(cmd_retrieve_item);
	this.addCommandID(cmd_toggle_sale);
	this.addCommandID(cmd_set_item);
	this.addCommandID(cmd_add_item);
	
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	// CANDLE LIGHT
	this.SetLight( true );
    this.SetLightRadius( 32.0f );
    this.SetLightColor(SColor(255, 255, 240, 171));
	
	// MENU
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Adjust price");
	this.set_u8("shop icon", 30);
	
	{
		ShopItem@ s = addShopItem(this, "Increase price (1)", "$increase_1$", "increase_1", "Increase price by 1 coin", true);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Increase price (5)", "$increase_5$", "increase_5", "Increase price by 5 coins", true);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Increase price (10)", "$increase_10$", "increase_10", "Increase price by 10 coins", true);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Increase price (50)", "$increase_50$", "increase_50", "Increase price by 50 coins", true);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Reduce price (1)", "$reduce_1$", "reduce_1", "Reduce price by 1 coin", true);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reduce price (5)", "$reduce_5$", "reduce_5", "Reduce price by 5 coins", true);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reduce price (10)", "$reduce_10$", "reduce_10", "Reduce price by 10 coins", true);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reduce price (50)", "$reduce_50$", "reduce_50", "Reduce price by 50 coins", true);
		s.spawnNothing = true;
	}
	
	if (getNet().isServer())
	{
	    setItem(this, NULL_ITEM);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	Item@ item = getItem(this);
    bool seller = isSeller(this, caller);
	string button_text = "Default";
	
	this.set_bool("shop available", seller);
	this.set_Vec2f("shop offset", Vec2f(0.0f, 0.0f));
	this.set_string("shop description", "Adjust price (" + item.price + " coins)");
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	if (!item.valid() && this.getTeamNum() == caller.getTeamNum())
	{
		CBlob@ carried = caller.getCarriedBlob();
		if    (carried is null)
			button_text = "To sell an item, you need to be holding it";
		else
			button_text = "Sell a " + (carried.hasTag("material") ? "stack of " + carried.getInventoryName() :
																	              carried.getInventoryName());
		
		CButton@ button = caller.CreateGenericButton(26, Vec2f(7.5f, 0.0f), this, this.getCommandID(cmd_set_item), button_text, params);
		button.SetEnabled(carried !is null && item.quantity < MAX_ITEMS);
	}
	
	if (seller)
	{
		{
			if (item.quantity > 0)
				button_text = "Retrieve " + (item.material ? ("a stack of " + item.materialSize) : "a") + " " + item.itemName + " (" + item.quantity + " in stock)";
			else
				button_text = "Stop selling";
			
			caller.CreateGenericButton(item.quantity > 0 ? 28 : 9, Vec2f(-7.5f, -4.5f), this, this.getCommandID(cmd_retrieve_item), button_text, params);
		}
		{
			if (item.selling)
				button_text = "Lock shop";
			else
				button_text = "Unlock shop";
			
			caller.CreateGenericButton(item.selling ? 2 : 3, Vec2f(-7.5f, 4.5f), this, this.getCommandID(cmd_toggle_sale), button_text, params);
		}
		{
			button_text = "Stock another " + (item.material ? (" stack of " + item.itemName) :
																			  item.itemName);
			
			CButton@ add_button = caller.CreateGenericButton(26, Vec2f(7.5f, 0.0f), this, this.getCommandID(cmd_add_item), button_text, params);
			add_button.SetEnabled(caller.hasBlob(item.itemBlob, 1) && item.quantity < MAX_ITEMS);
		}
	}
	else
	{
		if (item.selling)
			button_text = "Purchase " + (item.material ? ("a stack of " + item.materialSize) : "a") + " " + item.itemName + " for " + item.price + " coins " +  
						  "(" + item.quantity + " in stock!)";
		else
			button_text = "Nothing for sale at the moment!";
	    //item.selling ? "$" + item.itemBlob + "$" : "$COIN$"
		//26
		CButton@ button = caller.CreateGenericButton(item.selling ? "$" + item.itemBlob + "$" : "$COIN$", Vec2f(0.0f, 0.0f), this, this.getCommandID(cmd_purchase_item), button_text, params);
		button.SetEnabled(item.selling && item.quantity > 0 && item.price <= getCoins(caller));
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream@ params )
{
    if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		
		bool isServer = (getNet().isServer());
		
		u16 netID, item_;
		
		if(!params.saferead_netid(netID) || !params.saferead_netid(item_))
			return;
		
		string name = params.read_string();
		
		CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		bool increase = name.findFirst("increase") != -1;
		int quantity = parseInt(name.split("_")[1]);
		
		Item@ item = getItem(this);
		if   (item.valid() && isSeller(this, caller) && getNet().isServer())
		{
			if (increase)
			    item.price = Maths::Min(MAX_PRICE, item.price + quantity);
			else
			    item.price = Maths::Max(MIN_PRICE, item.price - quantity);
			
			setItem(this, item);
		}
	}
	else if (cmd == this.getCommandID(cmd_set_item))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		CPlayer@ callerPlayer = caller.getPlayer();
		if      (callerPlayer !is null && getNet().isServer())
		{
			Item@ item = Item();
			if  (!item.valid())
			{
				CBlob@ carried = caller.getCarriedBlob();
				if    (carried is null) return;
				
				if(!canSell(carried.getName()))
				{
				    cmdSendMessage(callerPlayer.getUsername(), "You can't sell that!", true);
					return;
				}
				
				if (carried.hasTag("material"))
				{
					item.material = true;
					item.materialSize = carried.maxQuantity;
					
					int quantity = Maths::Floor(carried.getQuantity() / item.materialSize);
					if (quantity >= 1)
					{
						caller.TakeBlob(carried.getName(), item.materialSize);
					}
					else
					{
						cmdSendMessage(callerPlayer.getUsername(), "You need to be holding a full stack of that material to sell it!", true);
						return;
					}
				}
				else
				{
					caller.TakeBlob(carried.getName(), 1);
				}
				
				item.itemBlob = carried.getName();
				item.itemName = carried.getInventoryName();
				item.itemSeller = callerPlayer.getUsername();
				item.quantity = 1;
				item.price = getItemValue(item.itemBlob);
				item.selling = true;
				
				setItem(this, item);
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_add_item))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		CPlayer@ callerPlayer = caller.getPlayer();
		if      (callerPlayer !is null && getNet().isServer())
		{
		    Item@ item = getItem(this);
			if   (item.valid() && item.quantity < MAX_ITEMS)
			{
				if (item.material)
				{
					int quantity = caller.getBlobCount(item.itemBlob);
					if (quantity >= item.materialSize)
					{
						caller.TakeBlob(item.itemBlob, item.materialSize);
					}
					else
					{
						cmdSendMessage(callerPlayer.getUsername(), "You don't have any full stacks of that material in your inventory!", true);
						return;
					}
				}
				else 
				{
					if (caller.hasBlob (item.itemBlob, 1))
					{
						caller.TakeBlob(item.itemBlob, 1);
					}
					else
					{
						cmdSendMessage(callerPlayer.getUsername(), "You don't have any more of that item in your inventory!", true);
						return;
					}
				}
				
				item.quantity += 1;
				
				setItem(this, item);
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_purchase_item))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		CPlayer@ callerPlayer = caller.getPlayer();
		if      (callerPlayer !is null && getNet().isServer())
		{
			Item@ item = getItem(this);
			if   (item.valid() && item.selling && item.quantity > 0)
			{
			    int playerCoins = callerPlayer.getCoins();
				if (playerCoins < item.price)
				{
				    cmdSendMessage(callerPlayer.getUsername(), "You don't have enough coins to purchase that!", true);
					return;
				}
				
				bool sellerPaid = false;
				
				for(uint i = 0; i < getPlayerCount(); i++)
				{
				    CPlayer@ player = getPlayer(i);
					if      (player.getUsername() == item.itemSeller)
					{
				        cmdSendMessage(item.itemSeller, callerPlayer.getUsername() + " has purchased " + (item.material ? "a stack of" : "a") + " " + item.itemName, false);
				        cmdSendMessage(item.itemSeller, "You receive " + item.price + " coins.", false);
						
						player.server_setCoins(player.getCoins() + item.price);
						callerPlayer.server_setCoins(playerCoins - item.price);
						
						sellerPaid = true;
						break;
					}
				}
				
				if (!sellerPaid)
				{
				    cmdSendMessage(callerPlayer.getUsername(), "The seller of that item is currently offline.", true);
					return;
				}
			    
				if (item.material)
				{
					MakeMat(caller, caller.getPosition(), item.itemBlob, item.materialSize);
				}
				else
				{
				    CBlob@ itemBlob = server_CreateBlob(item.itemBlob, caller.getTeamNum(), caller.getPosition());
					if    (itemBlob.canBePutInInventory(caller))
						caller.server_PutInInventory(itemBlob);
					else if (caller.getAttachments() !is null && caller.getAttachments().getAttachmentPointByName("PICKUP") !is null)
						caller.server_Pickup(itemBlob);
				}
				
				item.quantity = item.quantity - 1;
				
				setItem(this, item);
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_retrieve_item))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		CPlayer@ callerPlayer = caller.getPlayer();
		if      (callerPlayer !is null && getNet().isServer())
		{
			Item@ item = getItem(this);
			if   (item.valid() && item.itemSeller == callerPlayer.getUsername())
			{
			    if (item.quantity > 0)
				{
					if (item.material)
					{
						MakeMat(caller, caller.getPosition(), item.itemBlob, item.materialSize);
					}
					else
					{
						CBlob@ itemBlob = server_CreateBlob(item.itemBlob, caller.getTeamNum(), caller.getPosition());
						if    (itemBlob.canBePutInInventory(caller))
							caller.server_PutInInventory(itemBlob);
						else if (caller.getAttachments() !is null && caller.getAttachments().getAttachmentPointByName("PICKUP") !is null)
							caller.server_Pickup(itemBlob);
					}
					
					item.quantity = item.quantity - 1;
					
				    setItem(this, item);
				}
				else
				{
				    setItem(this, NULL_ITEM);
				}
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_toggle_sale))
	{
	    u16 netID;
		
		if(!params.saferead_netid(netID))
		    return;
		
        CBlob@ caller = getBlobByNetworkID(netID);
        if    (caller is null) { return; }
		
		CPlayer@ callerPlayer = caller.getPlayer();
		if      (callerPlayer !is null && getNet().isServer())
		{
			Item@ item = getItem(this);
			if   (item.valid() && isSeller(this, caller))
			{
			    item.selling = !item.selling;
				setItem(this, item);
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

void onDie( CBlob@ this )
{
    Item@ item = getItem(this);
	if   (item.valid() && getNet().isServer())
	{
	    for(uint i = 0; i < item.quantity; i++)
		{
		    CBlob@ itemBlob = server_CreateBlob(item.itemBlob, this.getTeamNum(), this.getPosition());
			itemBlob.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
			
			if (item.material)
			{
			    itemBlob.server_SetQuantity(item.materialSize);
			}
		}
	}
}

Item@ getItem( CBlob@ this )
{
    CRules@ rules = getRules();
	
	CBitStream stream;
	rules.get_CBitStream(item_property + this.getNetworkID(), stream);
	
	Item   item = Item();
	return item.Unserialise(stream);
}

void setItem( CBlob@ this, Item@ item )
{
    CRules@ rules = getRules();
	
	CBitStream stream;
	item.Serialise(stream);
	
	string property = item_property + this.getNetworkID();
    rules.set_CBitStream(property, stream);
	rules.Sync(property, true);
}

bool isSeller( CBlob@ this, CBlob@ blob )
{
    Item@ item = getItem(this);
	if   (item !is null)
	{
		CPlayer@ player = blob.getPlayer();
		return  (player !is null && player.getUsername() == item.itemSeller);
	}
    return false;
}

int getCoins( CBlob@ blob )
{
    CPlayer@ player = blob.getPlayer();
	if (player !is null)
	{
	    return player.getCoins();
	}
	return 0;
}

bool canSell( string itemBlob )
{
    for(uint i = 0; i < invalid_items.length; i++)
	{
	    string invalid = invalid_items[i];
		if    (invalid == itemBlob)
		{
		    return false;
		}
	}
    return true;
}
