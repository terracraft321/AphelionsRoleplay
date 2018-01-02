/* 13ph5km.as
 * author: Aphelion
 */

const f32 damage_modifier = 0.7f;

void onTick( CBlob@ this )
{
    if (getGameTime() >= this.get_u32("potion_rockskin_end") || this.hasTag("dead"))
    {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	f32 currentHealth = this.getHealth();
	if (currentHealth < oldHealth)
	{
		this.server_Heal((oldHealth - currentHealth ) * damage_modifier);
    }
}
