/* 1tu0g3.as
 * author: Aphelion
 */

#include "3kemuc.as";

void onInit(CBlob@ this)
{
	this.addCommandID("scroll guardian");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("scroll guardian"), "Heals nearby allies", params );
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("scroll guardian"))
	{
	    bool healed = false;
		
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if    (caller !is null)
		{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 256.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					if (b.hasTag("player") && !b.hasTag("dead") && b.getHealth() != b.getInitialHealth() && isTeamFriendly(caller.getTeamNum(), b.getTeamNum()))
					{
						b.server_Heal(b.getInitialHealth());
						healed = true;
					}
				}
			}
		}
		
		if (healed)
		{
		    this.getSprite().PlaySound("/LightHarp");
			this.server_Die();
		}
	}
}
