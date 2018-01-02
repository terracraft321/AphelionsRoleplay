/* 6gsilr.as
 * author: Aphelion
 */
 
#include "EmotesCommon.as";

void onTick( CBlob@ this )
{
    if (getGameTime() >= this.get_u32("beer_effect_end") || this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
	else
	{
	    set_emote(this, Emotes::derp);
	}
}
