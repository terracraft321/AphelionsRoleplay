/* 18kn24n.as
 * author: Aphelion
 * 
 * The script that handles the powers given to the Mage by Auras.
 */

#include "37vdq0n.as";
#include "3jt3pus.as";
#include "222fdt8.as";

#include "RunnerCommon.as";	
#include "Knocked.as";
#include "TeamColour.as";

void onInit( CBlob@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick( CBlob@ this )
{
	MageInfo@ mage;
	if (!this.get( "mageInfo", @mage ))
		return;

	if(getKnocked(this) > 0)
	{
	    if(mage.power_active)
	    {
	    	TogglePower(this, mage.power_type, false);
	    }
		return;
	}

	const bool right_click = this.isKeyPressed(key_action2);
	const string aura = getEquipmentSlotItem(this, SLOT_ARMOUR);

	if(mage.power_active)
		if(!right_click || getGameTime() >= mage.power_expire)
			TogglePower(this, mage.power_type, false);
		else
			PowerEffect(this, mage.power_type);
	else if(right_click)
	    if((getGameTime() - (mage.powers_end[getPowerIndex(this, aura)] + getPowerCooldown(this, aura))) > 0)
			TogglePower(this, aura, true);
		else if(getNet().isClient() && this.isMyPlayer() && this.isKeyJustPressed(key_action2))
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
}

void TogglePower( CBlob@ this, string aura, bool enable )
{
	MageInfo@ mage;
	if (!this.get( "mageInfo", @mage ))
		return;
	
	if(aura == "aura_default")
	{
		ParticleZombieLightning(this.getPosition());

		this.getSprite().PlaySound("Invisible.ogg");
		this.getSprite().SetVisible(!enable);
	}

    // Aura of Teleportation
	else if(aura == "aura_teleportation")
	{
		if(enable)
		{
			CMap@ map = getMap();
			Vec2f target = this.getAimPos();
			
			//bool barrier = target.y <= (((map.tilemapheight * map.tilesize) / 2) - 150);
			bool barrier = target.y <= 55 * map.tilesize;
        	if (!barrier && !map.rayCastSolid(this.getPosition(), target))
        	{
				ParticleZombieLightning(this.getPosition());
				
				this.setPosition(target);
	        	this.setVelocity(Vec2f_zero);
				
				ParticleZombieLightning(target);
        	}
        	else
        	{
        		if(getNet().isClient() && this.isMyPlayer() && this.isKeyJustPressed(key_action2))
        		{
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
        		}
        		return;
        	}
		}
	}
	
	// Aura of Telekinesis
	/*else if(aura == "aura_telekinesis")
	{
        if(enable)
		{
			CMap@ map = getMap();
			Vec2f target = this.getAimPos();
			
			bool barrier = target.y <= (((map.tilemapheight * map.tilesize) / 2) - 150);
        	if (!barrier && !map.rayCastSolid(this.getPosition(), target))
        	{
				CBlob@[] nearBlobs;
    			getMap().getBlobsInRadius(target, 48.0f, @nearBlobs);
				
				u8  items = 0;
				for (uint i = 0; i < nearBlobs.length; i++)
				{
				    CBlob@ item = nearBlobs[i];
					if    (item !is null)
					{
					    string name = item.getName();
						if    (item.hasTag("material") || (name == "chicken" || name == "grain" || name == "leaf" || 
						                                   name.find("potion") != -1 ||  name.find("scroll") != -1 || 
						                                   name.find("chestplate") != -1 || name.find("chainmail") != -1 || name.find("aura") != -1 || 
														   name.find("sword") != -1 || name.find("bow") != -1 || name.find("staff") != -1))
						{
							ParticleZombieLightning(item.getPosition());
							
						    item.setPosition(this.getPosition());
							
							ParticleZombieLightning(this.getPosition());
							
							items++;
						}	   
					}
				}
				
				if (items == 0)
				{
					if (getNet().isClient() && this.isMyPlayer() && this.isKeyJustPressed(key_action2))
					{
						Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
					}
					return;
				}
        	}
        	else
        	{
        		if (getNet().isClient() && this.isMyPlayer() && this.isKeyJustPressed(key_action2))
        		{
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
        		}
        		return;
        	}
		}
	}*/

    // Aura of Returning
	/*else if(aura == "aura_returning")
	{
        if(enable)
		{
			ParticleZombieLightning(this.getPosition());
			
			this.getSprite().PlaySound("/Teleport");
			
            CBlob@[] bases;
            getBlobsByName("base", @bases);
			
			for(uint i = 0; i < bases.length; i++)
			{
			    if(bases[i].getTeamNum() == this.getTeamNum())
				{
					ParticleZombieLightning(bases[i].getPosition());
					
					this.setPosition(bases[i].getPosition());
					this.setVelocity( Vec2f_zero );			  
					this.getShape().PutOnGround();
					this.Untag("dungeon");
					
					Sound::Play("Respawn.ogg", bases[i].getPosition());
					break;
				}
			}
		}
	}*/

	if(enable)
	{
		mage.power_active = true;
		mage.power_type = aura;
		mage.power_expire = getGameTime() + getPowerDuration(this, aura);
	}
	else
	{
		mage.power_active = false;
		mage.powers_end[getPowerIndex(this, aura)] = getGameTime();
	}
}

void PowerEffect( CBlob@ this, string aura )
{
    // nothing
}

u8 getPowerIndex( CBlob@ this, string aura )
{
	return aura == "aura_default" ? 0 :
	       aura == "aura_teleportation" ? 1 :
	        0;
}

f32 getPowerDuration( CBlob@ this, string aura )
{
	f32 durationSeconds = aura == "aura_default" ? 20 :
	                      aura == "aura_teleportation" ? 0 :
	                        10;

	return durationSeconds * 30;
}

f32 getPowerCooldown( CBlob@ this, string aura )
{
	f32 cooldownSeconds = aura == "aura_default" ? 10 :
	                      aura == "aura_teleportation" ? 30 :
	                        30;

	return (cooldownSeconds * 30) * getMageAbilityCooldownModifier(this.getTeamNum());
}
