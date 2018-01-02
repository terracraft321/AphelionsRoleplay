/* 1dmbkti.as
 * author: Aphelion
 */

#include "3kemuc.as";

void onBlobDie( CRules@ this, CBlob@ victimBlob )
{
	if (victimBlob !is null )
	{
		CPlayer@ victimPlayer = victimBlob.getPlayer();
		if      (victimPlayer !is null)
		{
			victimPlayer.setDeaths(victimPlayer.getDeaths() + 1);
			
			UpdateScore(victimPlayer);
		}
		
		CPlayer@ killer = victimBlob.getPlayerOfRecentDamage();
		if      (killer !is null && !isTeamFriendly(killer.getTeamNum(), victimBlob.getTeamNum()))
		{
			string victimName = victimBlob.getName();
			
			if (victimPlayer !is null || (victimName == "skeleton" ||
				                          victimName == "zombie"   ||
										  victimName == "zombie_knight"))
			{
				killer.setKills(killer.getKills() + 1);
			    
				UpdateScore(killer);
			}
		}
	}
}

void UpdateScore( CPlayer@ player )
{
	player.setScore( 100 * (f32(player.getKills()) / f32(player.getDeaths() + 1)) );
}
