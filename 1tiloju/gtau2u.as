/* gtau2u.as
 * author: Aphelion
 * 
 * Script for disallowing access without having defeated Noom and preventing pickup.
 */

#include "25u16al.as";

bool isInventoryAccessible( CBlob@ this, CBlob@ byBlob )
{
	return isBossDefeated(getRules());
}

void onRemoveFromInventory( CBlob@ this, CBlob@ blob )
{
    if (getNet().isServer() && !isBossDefeated(getRules()))
	{
	    this.server_PutInInventory(blob);
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}
