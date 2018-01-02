/* 14e7cem.as
 * author: Aphelion
 */

void onTick( CBlob@ this )
{
    if (getGameTime() >= this.get_u32("potion_waterbreathing_end") || this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
	else
	{
	    this.set_s8("air_count", 60);
	}
}
