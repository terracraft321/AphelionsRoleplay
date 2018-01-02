/* 7ne41h.as
 * author: Aphelion
 */

#include "3kemuc.as";

const string cmd_lose_war = "lose war";

const u32 REBUILD_PERIOD = 10 * 60 * 30; // the period in which wars cannot be started with teams that were involved in wars with one another

void onInit( CRules@ this )
{
	this.addCommandID(cmd_lose_war);
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
    if (cmd == this.getCommandID(cmd_lose_war))
    {
    	u8 team;
		
		if(!params.saferead_u8(team))
		    return;

		CPlayer@ player = getLocalPlayer();
		if(player !is null)
		{
			if(isTeamEnemy(player.getTeamNum(), team))
				Sound::Play("/FanfareWin.ogg");
			else
				Sound::Play("/FanfareLose.ogg");
		}
		
    	CTeam@ losingTeam = this.getTeam(team);
		for(int i = 0; i < this.getTeamsCount(); i++)
		{
			if(isTeamEnemy(team, i))
			{
				if(i != team)
				{
					CTeam@ enemyTeam = this.getTeam(i);
					
					client_AddToChat("The " + losingTeam.getName() + " have been defeated by the " + enemyTeam.getName() + "!", SColor(255, 255, 0, 0));

					// set to neutral
					this.set_u8("disposition_" + team + "_" + i, DISPOSITION_NEUTRAL);
					this.set_u8("disposition_" + i + "_" + team, DISPOSITION_NEUTRAL);

				    this.set_u32("lost_war_" + team + "_" + i, getGameTime() + REBUILD_PERIOD / 2); // team that lost, to team
				    this.Sync("lost_war_" + team + "_" + i, true);
				}
				
				// initiate the rebuild period
				this.set_u32("rebuild_period_" + team + "_" + i, getGameTime() + REBUILD_PERIOD);
				this.set_u32("rebuild_period_" + i + "_" + team, getGameTime() + REBUILD_PERIOD);
		    }
	    }
		
	}
}
