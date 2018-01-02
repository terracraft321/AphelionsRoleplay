/* 3k094h5.as
 * author: Aphelion
 */

void onInit( CBlob@ this )
{
	this.addCommandID("scroll teleport to base");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("scroll teleport to base"), "Teleports you to your team base", params);
	button.SetEnabled(this.isAttachedTo(caller));
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("scroll teleport to base"))
	{
		this.getSprite().PlaySound("/Teleport");
		
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
            CBlob@[] bases;
            getBlobsByName("base", @bases);
			
			for(uint i = 0; i < bases.length; i++)
			{
			    if(bases[i].getTeamNum() == caller.getTeamNum())
				{
					caller.setPosition(bases[i].getPosition());
					caller.setVelocity( Vec2f_zero );			  
					caller.getShape().PutOnGround();
					caller.Untag("dungeon");
					
					Sound::Play("Respawn.ogg", bases[i].getPosition());
					break;
				}
			}
		}
		
		this.server_Die();
	}
}
