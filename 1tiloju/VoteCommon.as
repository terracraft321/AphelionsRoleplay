/**
 * Vote functor interface
 * override
 */

//shared
class VoteFunctor
{
	VoteFunctor() {}
	void Pass(bool outcome) { /* do your vote action in here - remember to check server/client */ }
	
	// -- hacky solution
	bool two_sided_vote = false;
	int team1 = 0;
	int team1_yes = 0;
	int team1_size = 0;
	int team2 = 0;
	int team2_yes = 0;
	int team2_size = 0;
	
	float team1_percentage()
	{
	    if (team1_size > 0)
		    return Maths::Min(float(team1_yes) / float(team1_size), 1.0f);
	    else
		    return 0.0f;
	}
	
	float team2_percentage()
	{
	    if (team2_size > 0)
		    return Maths::Min(float(team2_yes) / float(team2_size), 1.0f);
	    else
		    return 0.0f;
	}
};

//shared
class VoteCheckFunctor
{
	VoteCheckFunctor() {}
	bool PlayerCanVote(CPlayer@ player) { return true; }
};

//shared
class VotePlayerLeaveFunctor
{
	VotePlayerLeaveFunctor() {}
	void PlayerLeft(VoteObject@ vote, CPlayer@ player) { }
};
	
/**
 * The vote object
 */
//shared
class VoteObject
{

	VoteObject()
	{
		@onvotepassed = null;
		@canvote = null;
		@playerleave = null;
		maximum_votes = getPlayersCount();
		current_yes = current_no = 0;
		timeremaining = 30 * 30; //default 30s
		required_percent = 0.5f; //default 50%
	}

	VoteFunctor@ onvotepassed;
	VoteCheckFunctor@ canvote;
	VotePlayerLeaveFunctor@ playerleave;

	string title;
	string reason;
	string byuser;
	string forcePassFeature;

	u16[] players; //id of players that have voted explicitly

	int current_yes;
	int current_no;

	float required_percent; //required ratio yes/(yes+no)
	int maximum_votes; //number of players who can vote

	int timeremaining;
};

shared SColor vote_message_colour() { return SColor(0xff444444); }

//rules methods

void Rules_SetVote(CRules@ this, VoteObject@ vote)
{
	if (!Rules_AlreadyHasVote(this))
	{
		this.set("g_vote", vote);

		if (CanPlayerVote(vote, getLocalPlayer()))
			client_AddToChat("--- A vote was started by " + vote.byuser + " ---", vote_message_colour());
		else
			client_AddToChat("--- Vote \"" + vote.title + "\" was started by " + vote.byuser
			                 + ". Reason: " + vote.reason + " ---", vote_message_colour()); //more info for server and those who cant see the vote
	}
}

VoteObject@ Rules_getVote(CRules@ this)
{
	VoteObject@ vote = null;
	this.get("g_vote", @vote);
	return vote;
}

bool Rules_AlreadyHasVote(CRules@ this)
{
	VoteObject@ tempvote = Rules_getVote(this);
	if (tempvote is null) return false;

	return tempvote.timeremaining > 0;
}

//vote methods

bool Vote_Conclusive(VoteObject@ vote)
{
	VoteFunctor@ functor = vote.onvotepassed;
	
	if (functor !is null && functor.two_sided_vote)
	{
		return (functor.team1_percentage() >= vote.required_percent &&
			    functor.team2_percentage() >= vote.required_percent);
	}
	else
	{
		bool adminOnline = getRules().get_bool("admin online");
		return !adminOnline && (vote.current_yes > vote.required_percent * vote.maximum_votes
								|| vote.current_no > (1 - vote.required_percent) * vote.maximum_votes
								|| vote.current_yes + vote.current_no >= vote.maximum_votes);
	}
}

void PassVote(VoteObject@ vote)
{
	if (vote is null || vote.timeremaining < 0) return;
	vote.timeremaining = -1; // so the gui hides and another vote can start

	if (vote.onvotepassed is null) return;
	
	VoteFunctor@ functor = vote.onvotepassed;
	bool outcome = false;
	
	if (functor.two_sided_vote)
	{
	    float team1_percentage = functor.team1_percentage();
		float team2_percentage = functor.team2_percentage();
		
	    outcome = team1_percentage >= vote.required_percent && team2_percentage >= vote.required_percent;
		
		//client_AddToChat("T1: " + functor.team1 + " T1 Size: " + functor.team1_size + ", T1 Yes: " + functor.team1_yes);
		//client_AddToChat("T2: " + functor.team2 + " T2 Size: " + functor.team2_size + ", T2 Yes: " + functor.team2_yes);
		client_AddToChat("--- Vote " + (outcome ? "passed: " : "failed: ") +
						 int(team1_percentage * 100) + " percent vs " + int(team2_percentage * 100) +
						 " percent ---", vote_message_colour());
	}
	else
	{
		outcome = vote.current_yes > vote.required_percent * (vote.current_yes + vote.current_no);
		
		client_AddToChat("--- Vote " + (outcome ? "passed: " : "failed: ") +
						 (vote.current_yes) + " vs " + (vote.current_no) +
						 " ---", vote_message_colour());
	}
	
	functor.Pass(outcome);
}

void ForcePassVote(VoteObject@ vote, CPlayer@ player)
{
	if (vote is null || vote.timeremaining < 0) return;
	vote.timeremaining = -1; // so the gui hides and another vote can start
	client_AddToChat("--- Admin " + player.getUsername() + " forced vote to pass ---");
	vote.onvotepassed.Pass(true);
}

void CancelVote(VoteObject@ vote, CPlayer@ player = null)
{
	if (vote is null || vote.timeremaining < 0) return;
	vote.timeremaining = -1; // so the gui hides and another vote can start

	if (player !is null)
	{
		client_AddToChat("--- Vote cancelled by admin " + player.getUsername() + " ---", vote_message_colour());
	}
	else
	{
		client_AddToChat("--- Vote cancelled ---", vote_message_colour());
	}
}

/**
 * Check if a player should be allowed to vote - note that this
 * doesn't check if they already have voted
 */

bool CanPlayerVote(VoteObject@ vote, CPlayer@ player)
{
	if (player is null || vote is null)
		return false;

	if (vote.canvote is null)
		return true;

	return vote.canvote.PlayerCanVote(player);
}

/**
 * Cast a vote from a player, in favour or against
 */
void Vote(VoteObject@ vote, CPlayer@ p, bool favour)
{
	if (vote is null || vote.timeremaining < 0) return;

	bool voted = false;

	u16 p_id = p.getNetworkID();
	for (uint i = 0; i < vote.players.length; ++i)
		if (vote.players[i] == p_id)
		{
			voted = true;
			break;
		}

	if (voted)
		warning("double-vote from " + p.getUsername()); //warning about exploits
	else
	{
		vote.players.push_back(p_id);
		
	    VoteFunctor@ functor = vote.onvotepassed;
		
		if (functor !is null && functor.two_sided_vote)
		{
		    int player_team_num = p.getTeamNum();
			CTeam@ player_team = getRules().getTeam(player_team_num);
			
			if (favour)
			{
				if (player_team_num == functor.team1)
				    functor.team1_yes++;
				else
				    functor.team2_yes++;
			}
			
			if (CanPlayerVote(vote, getLocalPlayer()) || getNet().isServer()) //include all in server logs
				client_AddToChat("--- " + p.getUsername() + " (" + player_team.getName() + ") " + "Voted "
								 + (favour ? "In Favour" : "Against") + " ---", vote_message_colour());
		}
		else
		{
			if (favour)
				vote.current_yes++;
			else
				vote.current_no++;

			if (CanPlayerVote(vote, getLocalPlayer()) || getNet().isServer()) //include all in server logs
				client_AddToChat("--- " + p.getUsername() + " Voted "
								 + (favour ? "In Favour" : "Against") + " ---", vote_message_colour());
		}
	}
}

void CalculateVoteThresholds(VoteObject@ vote)
{
	vote.maximum_votes = 0;
	
	for (int i = 0; i < getPlayersCount(); ++i)
	{
	    CPlayer@ player = getPlayer(i);
		
		if (CanPlayerVote(vote, player))
		{
			vote.maximum_votes++;
			
			VoteFunctor@ functor = vote.onvotepassed;
			
			if (functor !is null && functor.two_sided_vote)
			{
		        int player_team_num = player.getTeamNum();
				
				if (player_team_num == functor.team1)
				    functor.team1_size++;
				else if(player_team_num == functor.team2)
				    functor.team2_size++;
			}
		}
	}
}
