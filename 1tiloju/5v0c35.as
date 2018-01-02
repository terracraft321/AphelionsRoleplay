/* 5v0c35.as
 * author: Aphelion
 */

const f32 SAP_PERCENTAGE = 0.30f;

void onTick( CBlob@ this )
{
    if (getGameTime() >= this.get_u32("potion_sapping_end") || this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
    if(hitBlob !is null && hitBlob.hasTag("flesh") && damage > 0.0f)
	{
	    this.server_Heal(damage * SAP_PERCENTAGE);
	}
}
