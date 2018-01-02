/* 1q7e47a.as
 * author: Aphelion
 *
 * The script that handles flying mechanics of wings.
 */
 
#include "3eao5se.as";

#include "3jt3pus.as";
 
const f32 wing_force_x = 5.0f;
const f32 wing_force_y = -30.0f;

void onInit( CSprite@ this )
{
    string wings_sprite = getEquipmentSlotItem(this.getBlob(), SLOT_ARMOUR) == "dragon_chestplate" ? "DragonWings.png" : "AngelWings.png";
	
    CSpriteLayer@ wings = this.addSpriteLayer("wings", wings_sprite, 64, 64, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	
	if (wings !is null)
	{
        Animation@ anim = wings.addAnimation( "default", 0, false );
        anim.AddFrame(0);
		
        Animation@ fly = wings.addAnimation( "fly", 3, true );
        fly.AddFrame(1);
        fly.AddFrame(2);
        fly.AddFrame(3);
        fly.AddFrame(4);
		
        Animation@ glide = wings.addAnimation( "glide", 6, true );
        glide.AddFrame(1);
        glide.AddFrame(2);
        glide.AddFrame(3);
        glide.AddFrame(4);
		
		wings.SetRelativeZ(-10.0f);
	    wings.SetVisible(false);
	}
}

void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    CSpriteLayer@ wings = this.getSpriteLayer("wings");
	
	if (blob.hasTag("dead"))
    {
		this.RemoveSpriteLayer("wings");
		return;
	}
	else if(!blob.hasTag("skin disabled"))
	{
	    CPlayer@ player = blob.getPlayer();
		if      (player !is null)
		{
		    string username = player.getUsername();
			if    (username == "zhuum")
			{
			    string new_path = "TeamDragonWings.png";
				
			    if (wings.getFilename() != new_path)
			        wings.ReloadSprite(new_path, 64, 64, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
			}
		}
	}
	
	if (wings !is null)
	{
        if (hasWings(blob))
	    {
	        wings.SetVisible(true);
	        
            if (isInAir(blob))
	        {
	            if(blob.isKeyPressed(key_up))
			    {
			        wings.SetAnimation("fly");
			    }
				else if(!blob.isKeyPressed(key_down))
				{
				    wings.SetAnimation("glide");
				}
				else
				{
	            	wings.SetAnimation("default");
				}
	        }
			else
			{
	            wings.SetAnimation("default");
			}
	    }
	    else
	    {
	        wings.SetVisible(false);
	    }
	}
}

void onInit( CBlob@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_not_onladder;
	this.getCurrentScript().runFlags |= Script::tick_not_onground;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick( CBlob@ this )
{
	if (hasWings(this))
    {
	    if (this.isKeyPressed(key_up))
		{
		    Vec2f vel = this.getVelocity();
			if   (vel.y > 0)
			{
				this.setVelocity(Vec2f(vel.x, vel.y - 1));
			}
			
	        this.AddForce(Vec2f(this.isKeyPressed(key_left) ? -wing_force_x : this.isKeyPressed(key_right) ? wing_force_x : 0.0f, wing_force_y));
		}
		else if(!this.isKeyPressed(key_down))
		{
		    this.AddForce(Vec2f(0.0f, wing_force_y / 2));
		}
	}
}

bool isInAir( CBlob@ this )
{
    return !this.isOnGround() && !this.isOnLadder();
}

bool hasWings( CBlob@ this )
{
    CPlayer@ player = this.getPlayer();
	if      (player !is null && this.getTeamNum() != RACE_UNDEAD)
	{
	    string username = player.getUsername();
		if   ((username == "Aphelion" || username == "zhuum") && !this.hasTag("skin disabled"))
		    return true;
	}
	
    return this.getTeamNum() == RACE_ANGELS || getEquipmentSlotItem(this, SLOT_ARMOUR) == "dragon_chestplate" ||
	                                           getEquipmentSlotItem(this, SLOT_ARMOUR) == "armadyl_chainmail" ||
											   getEquipmentSlotItem(this, SLOT_ARMOUR) == "aura_flight";
}
