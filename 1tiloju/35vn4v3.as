/* 35vn4v3.as
 * modified by: Aphelion
 */

#include "34lnvk0.as";

#include "ev5l4b.as";
#include "2ji1a4n.as";

void onInit( CBlob@ this )
{
	if(this.hasTag("instant_grow"))
	   this.set_u8(grown_amount, growth_max);
	else if(!this.exists(grown_amount))
		this.set_u8(grown_amount, 0);

	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
	if (getNet().isServer())
	{
		CMap@ map = getMap();
		Vec2f pos = this.getPosition();

		if (!this.hasTag(growth_factor_light))
		{
		    bool light = false;
		    	
			float dayTime = map.getDayTime();
			if   (dayTime >= 0.15f && dayTime <= 0.85f)
			{
			    light = true;
			}
			else
			{
				CBlob@[] nearBlobs;
    			getMap().getBlobsInRadius(this.getPosition(), 96.0f, @nearBlobs);

    			for(int i = 0; i < nearBlobs.length; i++)
    			{
    				CBlob@ nearBlob = nearBlobs[i];
    				if    (nearBlob.getName() == "lantern")
    				{
    					light = true;
    					break;
    				}
    			}
			}

			if(light)
			{
				this.Tag(growth_factor_light);
			}
		}

		if (!this.hasTag(growth_factor_buddy))
		{
			bool partner = false;

			CBlob@[] nearBlobs;
    		getMap().getBlobsInRadius(this.getPosition(), 64.0f, @nearBlobs);

    		for(int i = 0; i < nearBlobs.length; i++)
    		{
    			CBlob@ nearBlob = nearBlobs[i];
    			if    (nearBlob.getName() == "grain_plant" && nearBlob !is this)
    			{
    				partner = true;
    				break;
    			}
    		}

			if(partner)
			{
				this.Tag(growth_factor_buddy);
			}
		}

		if (!this.hasTag(growth_factor_overcrowded))
		{
			bool overcrowded = false;

			CBlob@[] nearBlobs;
    		getMap().getBlobsInRadius(this.getPosition(), 64.0f, @nearBlobs);

    		int grain_total = 0;
    		for(int i = 0; i < nearBlobs.length; i++)
    		{
    			CBlob@ nearBlob = nearBlobs[i];
    			if    (nearBlob.getName() == "grain_plant" && nearBlob !is this)
    			{
    				if (grain_total++ > 5)
    				{
    					overcrowded = true;
    					break;
    				}
    			}
    		}

			if (overcrowded)
			{
				this.Tag(growth_factor_overcrowded);
			}
		}
	    
		u8 amount = this.get_u8(grown_amount);
		if(amount >= growth_max)
		{
			this.Tag(grown_tag);
			this.Sync(grown_tag, true);

			this.getCurrentScript().runFlags |= Script::remove_after_this;
		}
		else if (canGrowAt(this, pos + Vec2f(0.0f, 6.0f)))
		{
			u8 season = getSeason(getRules());

			f32 growthFactor = season == Seasons::SPRING ? 0.75f :
			                   season == Seasons::AUTUMN ? 1.50f :
			                   season == Seasons::WINTER ? 2.00f :
			                   1.00f;

			bool receivedLight = this.hasTag(growth_factor_light);
			if  (receivedLight)
			    growthFactor *= 0.80f;

			bool nearbyPartner = this.hasTag(growth_factor_buddy);
			if  (nearbyPartner)
			    growthFactor *= 0.80f;
			
			bool areaOvercrowded = this.hasTag(growth_factor_overcrowded);
			if  (areaOvercrowded)
			    growthFactor *= 2.00f;

			u8 chance = this.get_u8(growth_chance) * growthFactor; // lower is better
			if (XORRandom(chance) == 0)
			{
				amount++;

				this.set_u8(grown_amount, amount);
				this.Sync(grown_amount, true);

				// remove factors after every growth
				this.Untag(growth_factor_light);
				this.Untag(growth_factor_buddy);
				this.Untag(growth_factor_overcrowded);
			}
		}
		else //have been unrooted and not grown! ungrow!
		{
			this.set_u8(grown_amount, 0); //TODO maybe remove, griefable
		}
	}
}
