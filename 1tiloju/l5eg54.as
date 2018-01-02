/* l5eg54.as
 * author: Aphelion
 */

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	this.inventoryButtonPos = Vec2f(-24.0f, 10.0f);
	
	// Add the necessary and hacky Anvil required for the 2-in-1 shop
	CBlob@ anvil = server_CreateBlob( "anvil", this.getTeamNum(), this.getPosition() + Vec2f(0.0f, 16.0f));
	this.set("blacksmith_anvil", @anvil);
	
	// BRAZIER LIGHT
	this.SetLight( true );
    this.SetLightRadius( 96.0f );
    this.SetLightColor(SColor(255, 255, 240, 171));
}

bool isInventoryAccessible( CBlob@ this, CBlob@ byBlob )
{
	return this.getTeamNum() == byBlob.getTeamNum();
}

void onDie( CBlob@ this )
{
    CBlob@ anvil;
	this.get("blacksmith_anvil", @anvil);
	
	if(anvil !is null)
	   anvil.server_Die();
}
