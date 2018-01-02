/* 38grga2.as
 * author: Aphelion
 */

#include "3kemuc.as";

#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.addCommandID("scroll destruction");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("scroll destruction"), "Destroys nearby enemies", params );
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("scroll destruction"))
	{
	    bool hit = false;
		
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 256.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					if (b.hasTag("flesh") && isTeamEnemy(caller.getTeamNum(), b.getTeamNum()))
					{
						ParticleZombieLightning(b.getPosition()); 
						
						if (b.getTeamNum() == 5)
						{
						    b.server_Heal(4.0f);
						}
						else
						{
						    caller.server_Hit(b, b.getPosition(), Vec2f(0, -100), 4.0f, Hitters::suddengib, true);
						}
						
						hit = true;
					}
				}
			}
		}
		
		if (hit)
		{
		    this.getSprite().PlaySound("/DarkHarp");
			this.server_Die();
		}
	}
}
