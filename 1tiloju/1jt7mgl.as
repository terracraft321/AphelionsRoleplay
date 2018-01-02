/* PotionOfMystery.as
 * author: Aphelion
 */

#include "Hitters.as";

const u8 POTION_SWIFTNESS = 0;
const u8 POTION_FEATHER = 1;
const u8 POTION_REGENERATION = 2;
const u8 POTION_ROCK_SKIN = 3;
const u8 POTION_INVISIBILITY = 4;
const u8 POTION_WATERBREATHING = 5;
const u8 POTION_SAPPING = 6;
const u8 MYSTERIOUS_DEATH = 7;

void onInit( CBlob@ this )
{
	if(getNet().isServer())
	{
		this.set_u16("mysterious_duration", (5 + XORRandom(50)) * 30);
		this.set_u8("mysterious_action", XORRandom(8));
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("activate"))
	{
		CBlob@ carrier = this.getCarriedBlob();
		if    (carrier !is null)
		{
            u16 effect_duration = this.get_u16("mysterious_duration");
			
            switch(this.get_u8("mysterious_action"))
            {
            	case POTION_SWIFTNESS:
            		carrier.set_u32("potion_swiftness_end", getGameTime() + effect_duration);
			        carrier.AddScript( "/20vhvkp.as" );
            		break;
				
            	case POTION_FEATHER:
            		carrier.set_u32("potion_feather_end", getGameTime() + effect_duration);
			        carrier.AddScript( "/324s12q.as" );
            		break;
				
            	case POTION_REGENERATION:
			        carrier.set_u32("potion_regeneration_end", getGameTime() + effect_duration);
			        carrier.AddScript( "/3dbrveu.as" );
            		break;
				
            	case POTION_ROCK_SKIN:
			        carrier.set_u32("potion_rockskin_end", getGameTime() + effect_duration);
			        carrier.AddScript( "/13ph5km.as" );
            		break;
				
            	case POTION_INVISIBILITY:
			        carrier.set_u32("potion_invisibility_end", getGameTime() + effect_duration);
			        carrier.AddScript( "/3kl2kdv.as" );
            		break;
					
            	case POTION_WATERBREATHING:
			        carrier.set_u32("potion_waterbreathing_end", getGameTime() + effect_duration);
			        carrier.AddScript( "/14e7cem.as" );
            		break;
					
            	case POTION_SAPPING:
			        carrier.set_u32("potion_sapping_end", getGameTime() + effect_duration);
			        carrier.AddScript( "/5v0c35.as" );
            		break;
				
            	case MYSTERIOUS_DEATH:
            		carrier.server_Hit(carrier, carrier.getPosition(), Vec2f(0, 0), Maths::Min(carrier.getInitialHealth(), 10.0f), Hitters::fall, true);
            		break;
            }
			
			this.getSprite().PlaySound("/PotionDrink.ogg");
			
			if(getNet().isServer())
			{
			    this.server_Die();
			}
		}
    }
	
}
