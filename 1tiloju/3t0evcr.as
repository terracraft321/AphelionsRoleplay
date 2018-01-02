/* 3t0evcr.as
 * author: Aphelion
 */

#include "Requirements_Tech.as";

bool isTechResearched(string name, u8 team)
{
    CRules@ rules = getRules();
	if     (rules !is null)
	{
	    return HasFakeTech(getRules(), name, team);
	}
	return false;
}

void setTechResearched(string name, u8 team)
{
    CRules@ rules = getRules();
	if     (rules !is null)
	{
		GiveFakeTech(getRules(), name, team);
		
		CPlayer@ player = getLocalPlayer();
		if      (player !is null && player.getTeamNum() == team)
		{
			Sound::Play("/ResearchComplete.ogg");
			client_AddToChat( name + " tech researched." );
		}
	}
}
