//mage HUD

#include "222fdt8.as";
#include "ActorHUDStartPos.as";

const string iconsFilename = "Entities/Characters/Mage/MageIcons.png";
const int slotsSize = 10;

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors( CBlob@ this )
{
	// set cursor
	if (getHUD().hasButtons())
		getHUD().SetDefaultCursor();
	else
	{
		// set cursor 
		getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32,32));
		getHUD().SetCursorOffset( Vec2f(-32, -32) );
		// frame set in logic
	}
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	ManageCursors( blob );

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD( blob, tl );	  

	// Draw coins
	const int coins = player !is null ? player.getCoins() : 0;
	
	DrawCoinsOnHUD( blob, coins, tl, slotsSize-2 );
}
