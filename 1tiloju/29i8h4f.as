/* TriangleBlock.as
 * author: Aphelion
 */
 
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
    this.getSprite().getConsts().accurateLighting = true;  
	
	this.Tag("blocks sword");
	this.Tag("blocks water");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;		 
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
