//common tunnel functionality

bool getTunnels( CBlob@ this, CBlob@[]@ tunnels )
{
	CBlob@[] list;
	getBlobsByTag("portal", @list);
	
	const u8 teamNum = this.getTeamNum();
	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum())
		{
			tunnels.push_back( blob );
		}
	}
	return tunnels.length > 0;
}
