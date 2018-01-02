/* 3dbrveu.as
 * author: Aphelion
 */

const u16 HEAL_FREQUENCY = 2 * 30;

const f32 heal_amount = 0.5f;

void onTick( CBlob@ this )
{
	const u32 gametime = getGameTime();
	
    if (gametime >= this.get_u32("potion_regeneration_end") || this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
	else
	{
	    if(getNet().isServer() && (gametime % HEAL_FREQUENCY) == 0)
		{
		    this.server_Heal(heal_amount);
		}
	}
}
