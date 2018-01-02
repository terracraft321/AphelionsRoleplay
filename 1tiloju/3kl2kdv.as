/* 3kl2kdv.as
 * author: Aphelion
 */

void onTick( CBlob@ this )
{
    if (getGameTime() >= this.get_u32("potion_invisibility_end") || this.hasTag("dead"))
    {
	    this.getSprite().SetVisible(true);
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
	else
	{
	    this.getSprite().SetVisible(false);
	}
}
