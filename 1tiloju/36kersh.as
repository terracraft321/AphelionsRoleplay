/* 36kersh.as
 * author: Aphelion
 */

#include "38p58pt.as";

const f32 hearDistance = 512.0f;
bool notified = false;

bool onClientProcessChat( CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player )
{
	CPlayer@ localPlayer = getLocalPlayer();

	if (player is null || localPlayer is null) return true;

	if(!notified && localPlayer is player)
	{
		sendMessage(player, SColor(255, 255, 0, 0), "NOTE: To display your message out of character and to all players regardless of their location, type // before the message. Otherwise your chat will only be displayed to nearby players.");
	    notified = true;
	}
    
    if (player.getTeamNum() > 10)
    {
		textOut = "[OOC] " + textIn;
		return true;
    }

	if (textIn.substr(0, 2) == "//")
	{
		textOut = "[OOC] " + textIn.split("//")[1];
		return true;
	}

    if (localPlayer.getTeamNum() > 10)
    {
    	return true;
    }
	
	CBlob@ chatBlob = player.getBlob();

	if (chatBlob is null)
	{
		sendMessage(player, "You can't speak when you're dead!");
		return false;
	}

	CBlob@ localBlob = localPlayer.getBlob();

	if (localBlob is chatBlob)
	{
		return true;
	}
	
	f32 distance = 9999.0f;

	if (localBlob !is null && chatBlob !is null)
	{
		distance = localBlob.getDistanceTo(chatBlob);
	}

	if (distance < hearDistance)
	{
		return true;
	}
	else if (localPlayer.getUsername() == "Aphelion" || localPlayer.getUsername() == "Perihelion371") // localPlayer.isAdmin() ?
	{
		textOut = "[SPY] " + textIn;
		return true;
	}

	return false;
}
