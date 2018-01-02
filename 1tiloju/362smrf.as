/* 362smrf.as
 * author: Aphelion
 *
 * The GUI script of the Roleplay Equipment system by Aphelion
 */

#include "3jt3pus.as";

#include "upmpi5.as";

enum EquipCmd
{
    cmd_equip = 60,
    cmd_equip_reserved = 99
};

void onInit( CBlob@ this )
{
	Equipment[] equipment;
	{
		Equipment[]@ temp;
		if( !this.get(equipment_property, @temp))
		{
			addCommonEquipment(this, equipment);
			this.set(equipment_property, equipment);
		}
	}
	
	if(!this.hasTag("equipment swap"))
	{
		this.set_string("equip_slot_" + SLOT_ARMOUR, getDefaultEquipment(this, SLOT_ARMOUR));
		this.set_string("equip_slot_" + SLOT_WEAPON, getDefaultEquipment(this, SLOT_WEAPON));
	}
	this.Untag("equipment swap");
	
	this.getCurrentScript().removeIfTag = "dead";
}

Vec2f getEquipmentMenuSize( CBlob@ this )
{
    if(isClassTypeKnight(this))
	    return Vec2f(7, 2);
    if(isClassTypeMarksman(this))
	    return Vec2f(6, 2);
	else
		return Vec2f(3, 2);
}

void MakeEquipmentMenu( CBlob@ this, CGridMenu @invmenu )
{
    CInventory@ inv = this.getInventory();
	
    Equipment[]@ equipment;
    this.get(equipment_property, @equipment);

    if (equipment !is null)
    {
        f32 fl = equipment.length;
		Vec2f menu_size = getEquipmentMenuSize(this);
        Vec2f pos( invmenu.getUpperLeftPosition().x + 0.5f*(invmenu.getLowerRightPosition().x - invmenu.getUpperLeftPosition().x),
                   invmenu.getUpperLeftPosition().y - 90 * menu_size.y - 50 );
        CGridMenu@ menu = CreateGridMenu( pos, this, menu_size, "Equipment" );

        if (menu !is null)
        {
			menu.deleteAfterClick = false;

            for (uint i = 0; i < equipment.length; i++)
            {
                Equipment@ e = equipment[i];
				
                CGridButton @button = menu.AddButton(e.icon, "\n"+e.description, cmd_equip + i);
                if (button !is null)
                {
					button.selectOneOnClick = true;
                    CBitStream missing;

                    if (getEquipmentSlotItem(this, e.slot) == e.name)
                    {
                        button.hoverText = e.description + "\n" + getButtonRequirementsText( e.reqs, false );
					    button.SetSelected(1);
                    }
                    else if (hasRequirements( inv, e.reqs, missing ))
					{
                        button.hoverText = e.description + "\n" + getButtonRequirementsText( e.reqs, false );
                    }
                    else
                    {
                        button.hoverText = e.description + "\n" + getButtonRequirementsText( missing, true );
                        button.SetEnabled(false);
                    }
                }
            }
        }
    }
}

void onCreateInventoryMenu( CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu )
{
    MakeEquipmentMenu(this, gridmenu);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (this.hasTag("switch class")) return;
	
	if (cmd >= cmd_equip && cmd < cmd_equip_reserved)
	{
		if(getNet().isServer())
		{
	    	CInventory@ inv = this.getInventory();
			
        	Equipment[]@ equipment;
        	this.get(equipment_property, @equipment);
			
        	uint i = cmd - cmd_equip;
			
        	if (equipment !is null && i >= 0 && i < equipment.length)
        	{
            	Equipment@ e = equipment[i];
				//printf("Equip called for " + e.name);
				
				string slot_item = getEquipmentSlotItem(this, e.slot);
				bool tookReqs = false;
				
				if (e.name == slot_item)
				    return;
				
				CBitStream missing;
				if(e.reqs !is null && hasRequirements(inv, e.reqs, missing))
				{
					server_TakeRequirements(inv, e.reqs);
					tookReqs = true;
				}
				
				if(!tookReqs)
			    	return;
		    
				if (!isDefaultItem(slot_item))
				{	
					CBlob@ blob = server_CreateBlob(slot_item, this.getTeamNum(), this.getPosition());
					
			    	if (blob !is null)
					{
						if (blob.canBePutInInventory(this))
							this.server_PutInInventory(blob);
						else
							if (blob.getAttachments() !is null && blob.getAttachments().getAttachmentPointByName("PICKUP") !is null)
								this.server_Pickup(blob);
					}
				}
			    setEquipmentSlotItem(this, e.name, e.slot);
			    
			    // If swapping armour or to a different kind of weapon it'll be necessary to swap to a new blob.
				if (e.swapBlob || this.getName() != e.swapToBlob)
			    {
                    CBlob@ newBlob = server_CreateBlob(e.swapBlob ? e.swapToBlob : this.getName(), this.getTeamNum(), this.getPosition());
                    
                    if (newBlob !is null)
                    {
                        this.MoveInventoryTo(newBlob);
                        
                        // set health to be same ratio
                        float healthratio = this.getHealth() / this.getInitialHealth();
                        newBlob.server_SetHealth( newBlob.getInitialHealth() * healthratio );
					
					    // transfer equipment data
					    transferEquipmentData(this, newBlob);
						
						// hacky fix
						if(this.hasTag("dungeon"))
						{
						    newBlob.Tag("dungeon");
						}
						
                        // plug the soul
						newBlob.Tag("equipment swap");
                        newBlob.server_SetPlayer(this.getPlayer());
                        newBlob.setPosition(this.getPosition());
					    
                        // no extra immunity after class change
                        if(this.exists("spawn immunity time"))
                        {
                            newBlob.set_u32("spawn immunity time", this.get_u32("spawn immunity time"));
                            newBlob.Sync("spawn immunity time", true);
                        }
                        
                        this.Tag("switch class");
                        this.server_SetPlayer( null );
                        this.server_Die();
                    }
			    }
	    	}
		}
	}
}

void onDie(CBlob@ this)
{
    if (this.hasTag("switch class") || this.hasTag("equipment dropped")) return;
	
	// flag to fix saw duping
	this.Tag("equipment dropped");
	
    string weapon_item = getEquipmentSlotItem(this, SLOT_WEAPON);
    string armour_item = getEquipmentSlotItem(this, SLOT_ARMOUR);
	
	if(!isDefaultItem(armour_item) && (isSpecialItem(armour_item) || XORRandom(1024) / 1024.0f < drop_armour_probability))
	    server_CreateBlob(armour_item, this.getTeamNum(), this.getPosition());
	if(!isDefaultItem(weapon_item) && (isSpecialItem(weapon_item) || XORRandom(1024) / 1024.0f < drop_weapon_probability))
	    server_CreateBlob(weapon_item, this.getTeamNum(), this.getPosition());
	
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
