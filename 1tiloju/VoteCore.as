
//voting generic update and render

#include "VoteCommon.as"

//extended vote functionality
const Vec2f dim(300, 100);

Vec2f getTopLeft()
{
	return Vec2f(10, 134 + (Maths::Sin(getGameTime() / 10.0f) + 1.0f) * 3.0f);
}

//hooks

void onRender( CRules@ this )
{
	if(!Rules_AlreadyHasVote(this)) return;

	VoteObject@ vote = Rules_getVote(this);

	if(!CanPlayerVote(vote,getLocalPlayer()) || g_have_voted) return;

	Vec2f tl = getTopLeft();
	Vec2f br = tl + dim;
	Vec2f text_dim;

	GUI::DrawPane(tl, br, SColor(0x80ffffff));

	GUI::GetTextDimensions( vote.title, text_dim );
	GUI::DrawText( vote.title, tl+Vec2f(Maths::Max(dim.x/2 - text_dim.x/2, 3.0), 3), color_white);

	GUI::DrawText( "Reason: "+vote.reason, tl+Vec2f(3, 3+text_dim.y*2), color_white);
	GUI::DrawText( "Cast by: "+vote.byuser, tl+Vec2f(3, 3+text_dim.y*3), color_white);
	GUI::DrawText( "[O] - Yes", tl+Vec2f(20, 3+text_dim.y*4), SColor(0xff30bf30));
	GUI::DrawText( "[P] - No", tl+Vec2f(120, 3+text_dim.y*4), SColor(0xffbf3030));
	GUI::DrawText( "Right click to close ("+Maths::Ceil(vote.timeremaining/30.0f) +"s)", tl+Vec2f(25, 3+text_dim.y*5), color_white);
//const bool can_cancel = getSecurity().checkAccess_Feature(getLocalPlayer(), "vote_cancel");
}

bool g_have_voted = false;

void onTick( CRules@ this )
{
	if(!Rules_AlreadyHasVote(this))
	{
		g_have_voted = false;
		return;
	}

	VoteObject@ vote = Rules_getVote(this);

	vote.timeremaining--;
	
	CRules@ rules = getRules();
	
	if(getNet().isServer() && ((vote.timeremaining == 0) || Vote_Conclusive(vote)))	//time up or decision made
	{
		PassVote(vote); //pass it serverside
		rules.SendCommand(rules.getCommandID(vote_end_id), CBitStream());
	}

	//--------------------------------- CLIENT ---------------------------------
	CPlayer@ me = getLocalPlayer();
	if (!getNet().isClient() || !CanPlayerVote(vote, me) || g_have_voted) return;

	CControls@ controls = getControls();
	if(controls is null) return;
	
	u16 id = me.getNetworkID();
	bool voted = false; //voted yes or no
	bool favour = true;
	
	if( controls.mousePressed2 )
	{
		Vec2f tl = getTopLeft();
		Vec2f br = tl + dim;
		Vec2f mousepos = controls.getMouseScreenPos();

		if(mousepos.x > tl.x && mousepos.y > tl.y - 6 &&
			mousepos.x < br.x && mousepos.y < br.y + 6)
		{
			g_have_voted = true;
		}
	}

	if( controls.isKeyPressed(KEY_KEY_O) )
	{
		voted = true;
	} 
	else if ( controls.isKeyPressed(KEY_KEY_P) )
	{
		if( (controls.isKeyPressed(KEY_LCONTROL) || controls.isKeyPressed(KEY_RCONTROL))
			&& getSecurity().checkAccess_Feature(me, "vote_cancel") )
		{
			CBitStream params;
			params.write_u16(id);
			rules.SendCommand(rules.getCommandID(vote_cancel_id), params);
			g_have_voted = true;
			return;
		}

		voted = true;
		favour = false;
	}
	
	if(voted)
	{
		CBitStream params;
		params.write_u16(id);
		rules.SendCommand(rules.getCommandID(favour ? vote_yes_id : vote_no_id), params);
		
		g_have_voted = true;
	}
}

const string vote_yes_id = "vote: yes";		//client "yes" vote
const string vote_no_id = "vote: no";		//client "no" vote
const string vote_end_id = "vote: ended";	//server "vote over"
const string vote_cancel_id = "vote: cancel";

void onInit(CRules@ this)
{
	this.addCommandID(vote_yes_id);
	this.addCommandID(vote_no_id);
	this.addCommandID(vote_end_id);
	this.addCommandID(vote_cancel_id);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	//always allow passing the vote, even if its expired
	if(cmd == this.getCommandID(vote_end_id))
	{
		PassVote(Rules_getVote(this));
	}
	
	if(!Rules_AlreadyHasVote(this)) return;
	
	VoteObject@ vote = Rules_getVote(this);

	u16 id;
	if(!params.saferead_u16(id)) return;
	
	CPlayer@ player = getPlayerByNetworkId(id);
	
	if(cmd == this.getCommandID(vote_yes_id) || cmd == this.getCommandID(vote_no_id))
	{
		if(CanPlayerVote(vote, player ))
		{
			Vote(vote, player, cmd == this.getCommandID(vote_yes_id));
		}
	}
	else if (cmd == this.getCommandID(vote_cancel_id))
	{
		if(getSecurity().checkAccess_Feature(player, "vote_cancel")) //double-check to avoid hackers
		{
			CancelVote(vote, player);
		}
	}
}
