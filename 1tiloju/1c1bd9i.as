/* 1c1bd9i.as
 * author: Aphelion
 *
 * :^)
 */

const u16 EFFECT_DURATION = 10 * 30;

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("activate"))
	{
		CBlob@ carrier = this.getCarriedBlob();
		if (carrier !is null)
		{
		    carrier.server_Heal(1.0f);
			carrier.set_u32("beer_effect_end", getGameTime() + EFFECT_DURATION);
			carrier.AddScript( "/6gsilr.as" );
			
			this.getSprite().PlaySound("/PotionDrink.ogg");
			
			if(getNet().isServer())
			{
			    this.server_Die();
			}
		}
    }
	
}
