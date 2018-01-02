// REQUIRES:
//
//      onRespawnCommand() to be called in onCommand()
//
//  implementation of:
//
//      bool canChangeClass( CBlob@ this, CBlob @caller )
//
// Tag: "change class sack inventory" - if you want players to have previous items stored in sack on class change
// Tag: "change class store inventory" - if you want players to store previous items in this respawn blob

#include "ClassSelectMenu.as";

void InitRespawnCommand( CBlob@ this )
{
	this.addCommandID("class menu");
}

bool isInRadius( CBlob@ this, CBlob @caller )
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 2.0f + caller.getRadius());
}

bool canChangeClass( CBlob@ this, CBlob @caller )
{
	return this.isOverlapping(caller) || this.getName() == "base"; // hack
}

// default classes
void InitClasses( CBlob@ this )
{
	AddIconToken( "$builder_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 8 );
	AddIconToken( "$knight_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 12 );
	AddIconToken( "$archer_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 16 );
	AddIconToken( "$mage_class_icon$", "GUI/ClassIcons.png", Vec2f(32, 32), 5);
	AddIconToken( "$change_class$", "GUI/InteractionIcons.png", Vec2f(32,32), 12, 2 );
	addPlayerClass( this, "Builder", "$builder_class_icon$", "builder", "" );
	addPlayerClass( this, "Knight", "$knight_class_icon$", "knight", "" );
	addPlayerClass( this, "Marksman", "$archer_class_icon$", "archer", "" );
	addPlayerClass( this, "Mage", "$mage_class_icon$", "mage", "" );
}

void BuildRespawnMenuFor( CBlob@ this, CBlob @caller )
{
	PlayerClass[]@ classes;
    this.get( "playerclasses", @classes );

    if (caller !is null && caller.isMyPlayer() && classes !is null)
    {
        CGridMenu@ menu = CreateGridMenu( caller.getScreenPos() + Vec2f(24.0f, caller.getRadius() * 1.0f + 48.0f), this, Vec2f(classes.length * CLASS_BUTTON_SIZE,CLASS_BUTTON_SIZE), "Change class" );
        if        (menu !is null)
        {
            addClassesToMenu(this, menu, caller.getNetworkID());
        }
    }
}

void onRespawnCommand( CBlob@ this, u8 cmd, CBitStream @params )
{

	switch( cmd )
    {
    case SpawnCmd::buildMenu:
    {
        {
            // build menu for them
            CBlob@ caller = getBlobByNetworkID( params.read_u16() );
            BuildRespawnMenuFor( this, caller );
        }
    }
    break;

    case SpawnCmd::changeClass:
    {
        if (getNet().isServer() )
        {
            // build menu for them
            CBlob@ caller = getBlobByNetworkID( params.read_u16() );
            if    (caller !is null && canChangeClass( this, caller ))
            {
                string classconfig = params.read_string();
                CBlob @newBlob = server_CreateBlob( classconfig, caller.getTeamNum(), this.getRespawnPosition() );

                if (newBlob !is null)
                {
					// drop equipment
                    string armour_item = getEquipmentSlotItem(caller, 0);
					string weapon_item = getEquipmentSlotItem(caller, 1);
	                
	                if(!isDefaultItem(armour_item))
	                    server_CreateBlob(armour_item, caller.getTeamNum(), caller.getPosition());
	                if(!isDefaultItem(weapon_item))
	                    server_CreateBlob(weapon_item, caller.getTeamNum(), caller.getPosition());
						
                    // copy health and inventory
                    // make sack
                    CInventory @inv = caller.getInventory();

                    if (inv !is null)
                    {
						if (this.hasTag("change class drop inventory"))
						{
							while (inv.getItemsCount() > 0)
                            {
                                CBlob @item = inv.getItem(0);
                                caller.server_PutOutInventory( item );
							}
						}
						else if (this.hasTag("change class store inventory"))
						{		
							if (this.getInventory() !is null) {
								caller.MoveInventoryTo( this );
							}
							else // find a storage
							{	   
								PutInvInStorage( caller );
							}
						}
						else
                        {
                            // keep inventory if possible
                            caller.MoveInventoryTo( newBlob );
                        }
                    }
					
                    // set health to be same ratio
                    float healthratio = caller.getHealth() / caller.getInitialHealth();
                    newBlob.server_SetHealth( newBlob.getInitialHealth() * healthratio );
					
                    // plug the soul
                    newBlob.server_SetPlayer( caller.getPlayer() );
                    newBlob.setPosition( caller.getPosition() );
					
                    // no extra immunity after class change
                    if(caller.exists("spawn immunity time"))
                    {
                        newBlob.set_u32("spawn immunity time", caller.get_u32("spawn immunity time"));
                        newBlob.Sync("spawn immunity time", true);
                    }

                    caller.Tag("switch class");
                    caller.server_SetPlayer( null );
                    caller.server_Die();
                }
            }
        }
    }
    break;
    }

	//params.SetBitIndex( index );
}

void PutInvInStorage( CBlob@ blob )
{
	CBlob@[] storages;
	if (getBlobsByTag( "storage", @storages ))
		for (uint step = 0; step < storages.length; ++step)
		{
			CBlob@ storage = storages[step];
			if (storage.getTeamNum() == blob.getTeamNum())
			{																
				blob.MoveInventoryTo( storage );
				return;
			}
		}
}

bool isDefaultItem( string name )
{
    return name.findFirst("default") != -1;
}

string getEquipmentSlotItem( CBlob@ this, u8 slot )
{
    return this.get_string("equip_slot_" + slot);
}

