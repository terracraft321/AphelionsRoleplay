/* 3kemuc.as
 * author: Aphelion
 */

const u8 DISPOSITION_NEUTRAL = 0;
const u8 DISPOSITION_ALLIED = 1;
const u8 DISPOSITION_ENEMY = 2;

const string neutral_string = "Neutral";
const string allied_string = "Allied";
const string enemy_string = "War";

void ResetDiplomacy( CRules@ this )
{
	for(int team = 0; team < this.getTeamsCount(); team++)
	{
	    for(uint i = 0; i < this.getTeamsCount(); i++)
		{
		    if (team != i)
			{
	    		string str = "disposition_" + team + "_" + i;
	    		string rebuild_str = "rebuild_period_" + team + "_" + i;
				
				this.set_u8(str, (team == 5 || i == 5) ? DISPOSITION_ENEMY : (team == 4 || i == 4) ? DISPOSITION_ALLIED : DISPOSITION_NEUTRAL);
				this.set_u32(rebuild_str, 0);
				
				if (getNet().isServer())
				{
			    	this.Sync(str, true);
			    	this.Sync(rebuild_str, true);
				}
			}
		}
	}
}

void setDisposition( CRules@ rules, int team, int team_to, int disposition )
{
    if (rules !is null)
	{
	    // SET
	    rules.set_u8("disposition_" + team + "_" + team_to, disposition);
	    rules.set_u8("disposition_" + team_to + "_" + team, disposition);
		
		// SYNC
		if (getNet().isServer())
		{
			rules.Sync("disposition_" + team + "_" + team_to, true);
			rules.Sync("disposition_" + team_to + "_" + team, true);
		}
		
		CTeam@ team1 = rules.getTeam(team);
		CTeam@ team2 = rules.getTeam(team_to);
		
		/*
	    bool angels = team_to == 5;
		bool undead = team_to == 4;
		
		if (disposition == DISPOSITION_ALLIED && (angels || undead))
		{
			client_AddToChat("The " + team1.getName() + " have sided with the " + (angels ? "Angels" : "Undead") + ".", SColor(255, 255, 0, 0));
			
			int other_team = angels ? 5 : 4;
			
			// SET
			rules.set_u8("disposition_" + team + "_" + other_team, DISPOSITION_ENEMY);
			rules.set_u8("disposition_" + other_team + "_" + team, DISPOSITION_ENEMY);
			
			// SYNC
			if (getNet().isServer())
			{
				rules.Sync("disposition_" + team + "_" + other_team, true);
				rules.Sync("disposition_" + other_team + "_" + team, true);
			}
		}
		else */
		
		if(disposition == DISPOSITION_ALLIED)
			client_AddToChat("The " + team1.getName() + " and " + team2.getName() + " have become allies!", SColor(255, 255, 0, 0));
		else if(disposition == DISPOSITION_ENEMY)
			client_AddToChat("The " + team1.getName() + " have declared war against the " + team2.getName() + "!", SColor(255, 255, 0, 0));
		else
			client_AddToChat("The " + team1.getName() + " have revoked their relations with the " + team2.getName() + "!", SColor(255, 255, 0, 0));
	}
}

int getDisposition( CRules@ rules, int team, int team_compare )
{
    if(team == team_compare)
	    return DISPOSITION_ALLIED;
	
    u8 disposition = rules.get_u8("disposition_" + team + "_" + team_compare);
	//printf("Dispo: " + team + "-" + team_compare + "=" + textForDisposition(disposition));
	
	return disposition;
}

string textForDisposition( int disposition )
{
    switch (disposition)
	{
		case 0:
		    return neutral_string;
	    case 1:
		    return allied_string;
		case 2:
		    return enemy_string;
	}
	return "Unknown";
}

bool isAlliedWithAll( CRules@ rules, int team )
{
    for(uint team_other = 0; team_other < 4; team_other++)
	{
	    if(team_other != team && getDisposition(rules, team, team_other) != DISPOSITION_ALLIED)
            return false;
	}
	return true;
}

bool isTeamFriendly( u8 team, u8 team_other )
{
    return team == team_other || getDisposition(getRules(), team, team_other) == DISPOSITION_ALLIED;
}

bool isTeamEnemy( u8 team, u8 team_other )
{
    return team_other == -1 || (team != team_other && getDisposition(getRules(), team, team_other) == DISPOSITION_ENEMY);
}

f32 onPlayerTakeDamage( CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale )
{
	if(victim !is null && attacker !is null && victim.getTeamNum() != attacker.getTeamNum())
	{
	    int disposition = getDisposition(this, victim.getTeamNum(), attacker.getTeamNum());
		switch(disposition)
		{
		    case DISPOSITION_NEUTRAL:
		    case DISPOSITION_ALLIED:
			    return 0.0f;
		}
	}
	return DamageScale;
}

bool canDeclareWar( u8 team, u8 team_other )
{
	CRules@ rules = getRules();
	if(rules is null)
		return false;
	else if(!rules.isMatchRunning())
	    return false;
	else if(getDisposition(rules, team, team_other) != DISPOSITION_NEUTRAL)
		return false;
	else
		return getGameTime() >= rules.get_u32("rebuild_period_" + team + "_" + team_other);
}
