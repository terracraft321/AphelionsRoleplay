/* 324s12q.as
 * author: Aphelion
 */

void onTick( CBlob@ this )
{
    if (getGameTime() >= this.get_u32("potion_feather_end") || this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
	else
	{
	    this.AddForce(Vec2f(0, -6.0f));
	}
}
