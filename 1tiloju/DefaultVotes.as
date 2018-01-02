//author of the Diplomacy system: Aphelion
//implements 2 default vote types (kick and next map) and menus for them

#include "3kemuc.as";

#include "VoteCommon.as";

bool g_haveStartedVote = false;
s32 g_lastVoteCounter = 0;
const float required_minutes = 0.5; //time you have to wait after joining w/o skip_votewait. time between votes is half this

s32 g_lastNextmapCounter = 0;
const float required_minutes_nextmap = 1; //global nextmap vote cooldown

const s32 VoteKickTime = 30*60; //seconds (30min default)

//kicking related globals and enums
enum kick_reason {
	kick_reason_griefer = 0,
	kick_reason_hacker,
	kick_reason_teamkiller,
	kick_reason_spammer,
	kick_reason_afk,
	kick_reason_count,
};
string[] kick_reason_string = { "Griefer", "Hacker", "Teamkiller", "Spammer", "AFK" };

string g_kick_reason = kick_reason_string[kick_reason_griefer]; //default

//next map related globals and enums
enum nextmap_reason {
	nextmap_reason_ruined = 0,
	nextmap_reason_stalemate,
	nextmap_reason_bugged,
	nextmap_reason_count,
};

string[] nextmap_reason_string = { "Map Ruined", "Stalemate", "Game Bugged" };

//diplomacy related globals
string[] diplomacy_races_string = { "Humans", "Dwarves", "Elves", "Orcs", "Angels", "Undead" };
string[] diplomacy_options_string = { "Neutral", "Alliance", "War" };

//votekick and vote nextmap

const string votekick_id = "vote: kick";
const string votenextmap_id = "vote: nextmap";
const string votediplomacy_id = "vote: diplomacy";

//set up the ids
void onInit(CRules@ this)
{
	this.addCommandID(votekick_id);
	this.addCommandID(votenextmap_id);
	this.addCommandID(votediplomacy_id);
}

void onTick(CRules@ this)
{
	if(g_lastVoteCounter < 60*getTicksASecond()*required_minutes)
		g_lastVoteCounter++;
	if(g_lastNextmapCounter < 60*getTicksASecond()*required_minutes_nextmap)
		g_lastNextmapCounter++;
}

//VOTE KICK --------------------------------------------------------------------
//votekick functors

class VoteKickFunctor : VoteFunctor {
	VoteKickFunctor() {} //dont use this
	VoteKickFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}
	
	CPlayer@ kickplayer;
	
	void Pass(bool outcome)
	{
		if( kickplayer !is null && outcome )
		{
			client_AddToChat( "Votekick passed! "+kickplayer.getUsername()+" will be kicked out.", vote_message_colour() );
			
			if( getNet().isServer() )
				BanPlayer(kickplayer, VoteKickTime); //30 minutes ban
		}
	}
};

class VoteKickCheckFunctor : VoteCheckFunctor {
	VoteKickCheckFunctor() {}//dont use this
	VoteKickCheckFunctor(CPlayer@ _kickplayer, string _reason)
	{
		@kickplayer = _kickplayer;
		reason = _reason;
	}
	
	CPlayer@ kickplayer;
	string reason;

	bool PlayerCanVote(CPlayer@ player)
	{
		if( !getSecurity().checkAccess_Feature( player, "mark_player" ) ) return false;

		if(reason.find(kick_reason_string[kick_reason_griefer]) != -1 //reason contains "Griefer"
			|| reason.find(kick_reason_string[kick_reason_teamkiller]) != -1 //or TKer
			|| reason.find(kick_reason_string[kick_reason_afk]) != -1) //or AFK
			return (player.getTeamNum() == kickplayer.getTeamNum() //must be same team
				|| getSecurity().checkAccess_Feature( player, "mark_any_team" )); //or has mark_any_team
		
		return true; //spammer, hacker (custom?)
	}
};

//setting up a votekick object
VoteObject@ Create_Votekick(CPlayer@ player, CPlayer@ byplayer, string reason)
{
	VoteObject vote;
	
	@vote.onvotepassed = VoteKickFunctor(player);
	@vote.canvote = VoteKickCheckFunctor(player, reason);
	
	vote.title = "Kick "+ player.getUsername() +"?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	
	CalculateVoteThresholds(vote);
	
	return vote;
}

//VOTE NEXT MAP ----------------------------------------------------------------
//nextmap functors

class VoteNextmapFunctor : VoteFunctor {
	VoteNextmapFunctor() {} //dont use this
	VoteNextmapFunctor(CPlayer@ player)
	{
		playername = player.getUsername();
	}
	
	string playername;
	void Pass(bool outcome)
	{
		if(outcome)
		{
			if(getNet().isServer())
				LoadNextMap();
		}
		else 
			client_AddToChat( playername+" needs to take a spoonful of cement! Play on!", vote_message_colour() );
	}
};

class VoteNextmapCheckFunctor : VoteCheckFunctor {
	VoteNextmapCheckFunctor() {}

	bool PlayerCanVote(CPlayer@ player)
	{
		return getSecurity().checkAccess_Feature( player, "map_vote" );
	}
};

//setting up a vote next map object
VoteObject@ Create_VoteNextmap(CPlayer@ byplayer, string reason)
{
	VoteObject vote;
	
	@vote.onvotepassed = VoteNextmapFunctor(byplayer);
	@vote.canvote = VoteNextmapCheckFunctor();
	
	vote.title = "Skip to next map?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.required_percent = 0.7f;
	
	CalculateVoteThresholds(vote);

	return vote;
}

//VOTE DIPLOMACY ----------------------------------------------------------------
// diplomacy functors

class VoteDiplomacyFunctor : VoteFunctor {
	VoteDiplomacyFunctor() {} //dont use this
	VoteDiplomacyFunctor(int _team_starter, int _team_other, int _disposition)
	{
	    team_starter = _team_starter;
		team_other = _team_other;
		disposition = _disposition;
		
		if ((_disposition == DISPOSITION_NEUTRAL && getDisposition(getRules(), team_starter, team_other) == DISPOSITION_ENEMY) ||
		     _disposition == DISPOSITION_ALLIED)
		{
		    two_sided_vote = true;
		    team1 = team_starter;
		    team2 = team_other;
		}
	}
	
	int team_starter; // The team that is changing the stance towards the other team
	int team_other; // The team that the first team is changing its stance towards
	int disposition;
	
	void Pass(bool outcome)
	{
		if(outcome)
		{
			client_AddToChat( "Diplomacy Vote Successful!", vote_message_colour() );
			
			CRules@ rules = getRules();
		    if(rules !is null)
			{
			    setDisposition(rules, team_starter, team_other, disposition);
			}
		}
		else
		{
			client_AddToChat( "Diplomacy Vote Failed!", vote_message_colour() );
		}
	}
};

class VoteDiplomacyCheckFunctor : VoteCheckFunctor {
	VoteDiplomacyCheckFunctor() {}
	VoteDiplomacyCheckFunctor(int _team_starter, int _team_other, int _disposition)
	{
		team_starter = _team_starter;
		team_other = _team_other;
		disposition = _disposition;
	}
	
	int team_starter, team_other, disposition;
	
	bool PlayerCanVote(CPlayer@ player)
	{
	    int team_num = player.getTeamNum();
		
		if((disposition == DISPOSITION_NEUTRAL && getDisposition(getRules(), team_starter, team_other) == DISPOSITION_ENEMY) || disposition == DISPOSITION_ALLIED)
		{
		    return team_num == team_starter || team_num == team_other;
		}
		return team_num == team_starter;
	}
	
};

//setting up a vote diplomacy object
VoteObject@ Create_VoteDiplomacy(CPlayer@ byplayer, int team_starter, int team_other, int option_idx)
{
	VoteObject vote;
	
	@vote.onvotepassed = VoteDiplomacyFunctor(team_starter, team_other, option_idx);
	@vote.canvote = VoteDiplomacyCheckFunctor(team_starter, team_other, option_idx);
	
	if(option_idx == DISPOSITION_NEUTRAL)
		vote.title = "Revoke relations with the " + getRules().getTeam(team_other).getName();
	else if(option_idx == DISPOSITION_ALLIED)
		vote.title = getRules().getTeam(team_starter).getName() + " want an alliance with the " + getRules().getTeam(team_other).getName();
	else if(option_idx == DISPOSITION_ENEMY)
		vote.title = "Start a war with the " + getRules().getTeam(team_other).getName();
	
	vote.reason = "N/A";
	vote.byuser = byplayer.getUsername();
	vote.timeremaining = 20 * 30;
	
	CalculateVoteThresholds(vote);
	
	return vote;
}

//create menus for kick and nextmap

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	//get our player first - if there isn't one, move on
	CPlayer@ me = getLocalPlayer();
	if(me is null) return;
	
	CRules@ rules = getRules();
	
	if(Rules_AlreadyHasVote(rules))
	{
		Menu::addContextItem(menu, "(Vote already in progress)", "DefaultVotes.as", "void CloseMenu()");
		Menu::addSeparator(menu);
		
		return;
	}
	
	//not in game long enough
	if(g_lastVoteCounter < 60*getTicksASecond()*required_minutes 
		&& (!getSecurity().checkAccess_Feature( me, "skip_votewait") || g_haveStartedVote) )
	{
		if(!g_haveStartedVote)
		{
			Menu::addInfoBox(menu, "Can't Start Vote Yet", "Voting is only available after\n"+
															"at least "+required_minutes+" min of play to\n"+
															"prevent spamming/abuse.\n");
		}
		else
		{
			Menu::addInfoBox(menu, "Can't Start Vote", "Voting requires a "+(required_minutes/2)+" min wait\n"+
														"after each started vote to\n"+
														"prevent spamming/abuse.\n");	
		}
		Menu::addSeparator(menu);
		
		return;
	}
	
	//and advance context menu when clicked
	CContextMenu@ votemenu = Menu::addContextMenu(menu, "Start a Vote");
	Menu::addSeparator(menu);
	
	//vote options menu
	
	CContextMenu@ kickmenu = Menu::addContextMenu(votemenu, "Kick");
	CContextMenu@ mapmenu = Menu::addContextMenu(votemenu, "Next Map");
	CContextMenu@ diplomacymenu = Menu::addContextMenu(votemenu, "Diplomacy");
	Menu::addSeparator(votemenu); //before the back button
	
	//kick menu
	if( getSecurity().checkAccess_Feature( me, "mark_player" ) )
	{
		Menu::addInfoBox(kickmenu, "Vote Kick", "Vote to kick a player on your team\nout of the game.\n\n"+
												"- use responsibly\n"+
												"- report any abuse of this feature.\n"+
												"\nTo Use:\n\n"+
												"- select a reason from the\n     list (default is griefing).\n"+
												"- select a name from the list.\n"+
												"- everyone votes.\n");
		
		Menu::addSeparator(kickmenu);
		
		//reasons
		for(uint i = 0 ; i < kick_reason_count; ++i)
		{
			CBitStream params;
			params.write_u8(i);
			Menu::addContextItemWithParams(kickmenu, kick_reason_string[i], "DefaultVotes.as", "Callback_KickReason", params);
		}
		
		Menu::addSeparator(kickmenu);
		
		//write all players on our team
		bool added = false;
		for(int i = 0; i < getPlayersCount(); ++i)
		{
			CPlayer@ player = getPlayer(i);
			
			//if(player is me) continue; //don't display ourself for kicking
			//commented out for max lols
			
			int player_team = player.getTeamNum();
			if( ( player_team == me.getTeamNum() || player_team == this.getSpectatorTeamNum() 
					|| getSecurity().checkAccess_Feature( me, "mark_any_team" ))
				&& ( !getSecurity().checkAccess_Feature( player, "kick_immunity" ) ) ) //TODO: check seclevs properly (what's improper with this? ~~norill)
			{
				string descriptor = player.getCharacterName();

				if( player.getUsername() != player.getCharacterName() )
					descriptor += " ("+player.getUsername()+")";

				CContextMenu@ usermenu = Menu::addContextMenu(kickmenu, "Kick "+descriptor);
				Menu::addInfoBox(usermenu, "Kicking "+descriptor, "Make sure you're voting to kick\nthe person you meant.\n");
				Menu::addSeparator(usermenu);

				CBitStream params;
				params.write_u16(player.getNetworkID());

				Menu::addContextItemWithParams(usermenu, "Yes, I'm sure", "DefaultVotes.as", "Callback_Kick", params);
				added = true;

				Menu::addSeparator(usermenu);
			}
		}
		
		if(!added)
		{
			Menu::addContextItem(kickmenu, "(No-one available)", "DefaultVotes.as", "void CloseMenu()");
		}
	}
	else
	{
		Menu::addInfoBox(kickmenu, "Can't vote", "You cannot vote to kick\n"+
												"players on this server\n");
	}
	
	Menu::addSeparator(kickmenu);
	
	//nextmap menu
	if( getSecurity().checkAccess_Feature( me, "map_vote" ) )
	{
		if(g_lastNextmapCounter < 60*getTicksASecond()*required_minutes_nextmap 
		&& (!getSecurity().checkAccess_Feature( me, "skip_votewait") || g_haveStartedVote) )
		{
			Menu::addInfoBox(mapmenu, "Can't Start Vote", "Voting for next map\n"+
														"requires a "+required_minutes_nextmap+" min wait\n"+
														"after each started vote\n"+
														"to prevent spamming.\n");
		}
		else
		{
			Menu::addInfoBox(mapmenu, "Vote Next Map", "Vote to change the map\nto the next in cycle.\n\n"+
													"- report any abuse of this feature.\n"+
													"\nTo Use:\n\n"+
													"- select a reason from the list.\n"+
													"- everyone votes.\n");
			
			Menu::addSeparator(mapmenu);
			//reasons
			for(uint i = 0 ; i < nextmap_reason_count; ++i)
			{
				CBitStream params;
				params.write_u8(i);
				Menu::addContextItemWithParams(mapmenu, nextmap_reason_string[i], "DefaultVotes.as", "Callback_NextMap", params);
			}
		}
	}
	else
	{
		Menu::addInfoBox(mapmenu, "Can't vote", "You cannot vote to change\n"+
												"the map on this server\n");
	}
	
	Menu::addSeparator(mapmenu);
	
	// DIPLOMACY
	int team_num = me.getTeamNum();
	
	Menu::addInfoBox(diplomacymenu, "Diplomacy", "Vote for your teams diplomacy status towards another team.\n\n" +
		                                        "Note: after a war is ended by reaching the enemy tent a\n" +
		                                        "ten minute rebuild time is\n" +
		                                        "initiated in this time any teams\n" + 
		                                        "involved in the war will be unable\n" +
												"to declare it again");
	
	Menu::addSeparator(diplomacymenu);

	CTeam@ team = rules.getTeam(team_num);
	if    (team is null) return;

	string team_name = team.getName();
	
	// Create the race menus and log the team numbers
	CContextMenu@[] race_menus;
	u16[] race_numbers;
	
	for(uint i = 0; i < diplomacy_races_string.length; i++)
	{
	    if (team_num != i) //&& (team_num < 4 || team_num == 4 && i == 5 || team_num == 5 && i == 4))
		{
		    race_menus.push_back(Menu::addContextMenu(diplomacymenu, diplomacy_races_string[i]));
			race_numbers.push_back(i);
		}
	}
	
	// Add options to the race menus
	for(uint i = 0 ; i < race_menus.length; i++)
	{
	    CContextMenu@ race_menu = race_menus[i];
		
		for(uint i2 = 0 ; i2 < diplomacy_options_string.length; i2++)
		{
		    int race_num = race_numbers[i];
			int option_idx = i2;
			
			if (team_num == 4 || team_num == 5)
			{
			    if ((i == 4 || i == 5) && option_idx != DISPOSITION_ENEMY)
				    continue; // Angels can only declare war upon the Undead, and vice versa
				else if(team_num == 4 && option_idx == DISPOSITION_ENEMY)
				    continue; // Angels cannot declare war, prevents abuse
			}
		    
		    if((!canDeclareWar(team_num, race_num) && option_idx == DISPOSITION_ENEMY) || getDisposition(rules, team_num, race_num) == option_idx)
                continue;
		
		    string option_string = diplomacy_options_string[i2];
			
		    CBitStream params;
			params.write_u16(race_num); // write other team number
		    params.write_u16(option_idx); // write option idx
		    Menu::addContextItemWithParams(race_menu, option_string, "DefaultVotes.as", "Callback_Diplomacy", params);
		}
	}
	
	Menu::addSeparator(diplomacymenu);
}

void CloseMenu()
{
	Menu::CloseAllMenus();
}

void onPlayerStartedVote()
{
	g_lastVoteCounter /= 2;
	g_haveStartedVote = true;
}

void Callback_KickReason(CBitStream@ params)
{
	u8 id; if(!params.saferead_u8(id)) return;
	
	if(id < kick_reason_count)
	{
		g_kick_reason = kick_reason_string[id];
	}
}

void Callback_Kick(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu
	
	CPlayer@ me = getLocalPlayer();
	if(me is null) return;
	
	u16 id; 
	if(!params.saferead_u16(id)) return;
	
	CPlayer@ other_player = getPlayerByNetworkId(id);
	if(other_player is null) return;
	
	if(getSecurity().checkAccess_Feature( other_player, "kick_immunity" ))
		return;
	
	CBitStream params2;
	
	params2.write_u16(other_player.getNetworkID());
	params2.write_u16(me.getNetworkID());
	params2.write_string(g_kick_reason);
	
	getRules().SendCommand(getRules().getCommandID(votekick_id), params2);
	onPlayerStartedVote();
}

void Callback_NextMap(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu
	
	CPlayer@ me = getLocalPlayer();
	if(me is null) return;
	
	u8 id;
	if(!params.saferead_u8(id)) return;
	
	string reason = "";
	if(id < nextmap_reason_count)
	{
		reason = nextmap_reason_string[id];
	}
	
	CBitStream params2;
	
	params2.write_u16(me.getNetworkID());
	params2.write_string(reason);
	
	getRules().SendCommand(getRules().getCommandID(votenextmap_id), params2);
	onPlayerStartedVote();
}

void Callback_Diplomacy(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu
	
	CPlayer@ me = getLocalPlayer();
	if(me is null) return;
	
	u16 team_other; if(!params.saferead_u16(team_other)) return;
	u16 option; if(!params.saferead_u16(option)) return;
	
	CBitStream params2;
	
	params2.write_u16(me.getNetworkID());
	params2.write_u16(me.getTeamNum());
	params2.write_u16(team_other);
	params2.write_u16(option);
	
	getRules().SendCommand(getRules().getCommandID(votediplomacy_id), params2);
	onPlayerStartedVote();
}

//actually setting up the votes
void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(Rules_AlreadyHasVote(this))
		return;
	
	if (cmd == this.getCommandID(votekick_id))
	{
		u16 playerid, byplayerid;
		string reason;
		
		if(!params.saferead_u16(playerid)) return;
		if(!params.saferead_u16(byplayerid)) return;
		if(!params.saferead_string(reason)) return;
		
		CPlayer@ player = getPlayerByNetworkId(playerid);
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);
		
		if(player !is null && byplayer !is null)
			Rules_SetVote(this, Create_Votekick(player, byplayer, reason));
	}
	else if(cmd == this.getCommandID(votenextmap_id))
	{
		u16 byplayerid;
		string reason;
		
		if(!params.saferead_u16(byplayerid)) return;
		if(!params.saferead_string(reason)) return;
		
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);
		
		if(byplayer !is null)
			Rules_SetVote(this, Create_VoteNextmap(byplayer, reason));

		g_lastNextmapCounter = 0;
	}
	else if(cmd == this.getCommandID(votediplomacy_id))
	{
		u16 byplayerid;
		u16 team_starter;
		u16 team_other;
		u16 option_idx;
		
		if(!params.saferead_u16(byplayerid)) return;
		if(!params.saferead_u16(team_starter)) return;
		if(!params.saferead_u16(team_other)) return;
		if(!params.saferead_u16(option_idx)) return;
		
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);
		
		if(byplayer !is null)
			Rules_SetVote(this, Create_VoteDiplomacy(byplayer, team_starter, team_other, option_idx));
	}
}

//ban a player if they leave
void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	if(Rules_AlreadyHasVote(this)) //vote is still going
	{
		//is it a votekick functor?
		VoteKickFunctor@ f = cast<VoteKickFunctor@>(Rules_getVote(this).onvotepassed);
		if(f !is null && f.kickplayer is player)
		{
			client_AddToChat( f.kickplayer.getUsername()+" left early, acting as if they were kicked.", vote_message_colour() );
			if(getNet().isServer())
				BanPlayer(player, VoteKickTime);
		}
	}
}
