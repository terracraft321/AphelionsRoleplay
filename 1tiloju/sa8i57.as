/* sa8i57.as
 * author: Aphelion
 */

#define CLIENT_ONLY

#include "TeamMenu.as";

const u16 REDISPLAY_INTERVAL = 3 * 30;

void onTick( CRules@ this )
{
    CPlayer@ player = getLocalPlayer();
	if      (player !is null && player.getTeamNum() == 255)
	{
	    if((getGameTime() % REDISPLAY_INTERVAL) == 0)
		{
            getHUD().ClearMenus();
			
		    ShowTeamMenu(this);
		}
	}
}
