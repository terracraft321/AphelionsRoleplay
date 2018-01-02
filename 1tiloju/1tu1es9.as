/* 1tu1es9.as
 * author: Aphelion
 */

void onInit( CBlob@ this )
{
	this.addCommandID("scroll transform zombie");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("scroll transform zombie"), "Revives nearby corpses as Undead", params );
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("scroll transform zombie"))
	{
		bool transformed = false;
		
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), 256.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if    (b.hasTag("dead"))
					{
						ParticleZombieLightning(b.getPosition()); 
						
						string newName = "zombie";
						string name = b.getName();
						if    (name == "zombie" || name == "zombie_knight")
						    name = newName;
						else if(name == "builder" || name == "knight")
						    newName = "zombie";
						else if(name == "archer" || name == "mage")
						    newName = "skeleton";
						
						server_CreateBlob(newName, caller.getTeamNum(), b.getPosition()); 
					    b.server_Die();
						
						transformed = true;
					}
				}
			}
		}
		
		if (transformed)
		{
		    this.getSprite().PlaySound("/Transform");
			this.server_Die();
		}
	}
}
