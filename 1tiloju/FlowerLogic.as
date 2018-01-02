// Flowers logic

void onInit( CBlob@ this )
{
    this.SetFacingLeft(XORRandom(2) == 0);
	
	this.getSprite().SetZ(10.0f);
}
