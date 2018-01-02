/* 32ikht4.as
 * author: Aphelion
 */

void onInit( CBlob@ this )
{
	this.addCommandID("scroll harvest");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("scroll harvest"), "Transports nearby farming goods into a single pile", params );
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("scroll harvest"))
	{
		bool harvested = false;
		
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if (caller !is null)
		{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					string name = b.getName();
					if (name == "grain" || name == "leaf")
					{
						b.setPosition(caller.getPosition());
						harvested = true;
					}
				}
			}
		}
		
		if (harvested)
		{
		    this.getSprite().PlaySound("/LightHarp");
			this.server_Die();
		}
	}
}
