/* 3qsjmgb.as
 * author: Aphelion
 */

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

void onDie( CBlob@ this )
{
	if (getNet().isServer())
	{
		if (this.hasTag("has grain"))
		{
		    int amount = 1 + XORRandom(4);
			for (int i = 1; i <= amount; i++)
			{
				CBlob@ grain = server_CreateBlob("grain", this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
				if    (grain !is null)
					   grain.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
			}
		}
	}
}
