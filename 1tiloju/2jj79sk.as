/* 2jj79sk.as
 * author: Aphelion
 */

#include "3kemuc.as";

void onInit(CBlob@ this)
{
	this.addCommandID("scroll transform lantern");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("scroll transform lantern"), "Transforms nearby corpses into your very own personal Lanterns", params );
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("scroll transform lantern"))
	{
	    bool transformed = false;
		
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if    (caller !is null)
		{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 256.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					if (b.hasTag("dead"))
					{
						server_CreateBlob("lantern", caller.getTeamNum(), b.getPosition()); 
					    b.server_Die();
						
						transformed = true;
					}
				}
			}
		}
		
		if (transformed)
		{
		    this.getSprite().PlaySound("/LightHarp");
			this.server_Die();
		}
	}
}
