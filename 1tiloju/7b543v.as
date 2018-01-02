// 7b543v.as

void onInit( CSprite@ this )
{
	CBlob@ blob = this.getBlob();

	u16 netID = blob.getNetworkID();
    this.animation.frame = (netID % this.animation.getFramesCount());
    this.SetFacingLeft(((netID % 13) % 2) == 0);
	this.SetZ(10.0f);
}

void onDie( CBlob@ this )
{
	if (getNet().isServer())
	{
        server_DropCoins(this.getPosition(), XORRandom(10));

        int num = XORRandom(100);
    	if (num < 7)
    	{
    		server_CreateBlob("pig", this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
	        server_DropCoins(this.getPosition(), 10 + XORRandom(20));
    	}
	}
}
