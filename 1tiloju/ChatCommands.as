// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "3kemuc.as";

#include "1028jcn.as";
#include "3js8kmj.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

const string head_tag = "head disabled";
const string skin_tag = "skin disabled";

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;
	
	string name = player.getUsername();
	
	const bool aphelion = name == "Aphelion" || name == "Perihelion371";
	const bool superadmin = getSecurity().getPlayerSeclev(player).getName() == "Super Admin";
	const bool mod = player.isMod();
	const bool canSpawn = aphelion;
	
    CBlob@ blob = player.getBlob();
    if    (blob is null)
        return true;
	
	bool chatVisible = true;
    string[]@ args = text_in.split(" ");
	
	Vec2f pos = blob.getAimPos();
	int team = blob.getTeamNum();
	
	if (aphelion)
	{
	    if (args[0] == "/spoof")
		{
			if (args[1] == "off")
			{
				SetSpoofing(this, player, false);
			}
			else
			{
				SetSpoofing(this, player, true, args[1]);
			}
		}
		else if(args[0] == "/season")
		{
			u8 seasonNum = 0;
			
			string  season = args[1];
			if     (season == "spring")
				seasonNum = 0;
			else if(season == "summer")
				seasonNum = 1;
			else if(season == "autumn")
				seasonNum = 2;
			else if(season == "winter")
				seasonNum = 3;
			else if(season == "christmas")
				seasonNum = 5;
			
			CBitStream params;
			params.write_u8(seasonNum);
			
			getRules().SendCommand(getRules().getCommandID("change season"), params);
			
			chatVisible = false;
		}
	}
	
	if (superadmin)
	{
		if(text_in == "!s" || text_in == "!stone")
		{
			CBlob@ b = server_CreateBlob( "mat_stone", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if(text_in == "!w" || text_in == "!wood")
		{
			CBlob@ b = server_CreateBlob( "mat_wood", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if((text_in == "!g" || text_in == "!gold") && aphelion)
		{
			CBlob@ b = server_CreateBlob( "mat_gold", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
	}
	
	// MODERATOR COMMANDS
	if (mod)
	{
		if (args[0] == "/teleto")
		{
			string playerName = args[1];
			
			for(uint i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ teletoPlayer = getPlayer(i);
				if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
				{
					CBlob@ teletoBlob = teletoPlayer.getBlob();
					if    (teletoBlob !is null)
					{
						blob.setPosition(teletoBlob.getPosition());
						blob.setVelocity( Vec2f_zero );			  
						blob.getShape().PutOnGround();
						
						if (teletoBlob.hasTag("dungeon"))
							blob.Tag("dungeon");
						else
							blob.Untag("dungeon");
					}
				}
			}
		}
	    else if (text_in == "/forcepeace")
		{
		    ResetDiplomacy(this);
		}
		else if(text_in == "/mypos")
		{
		    Vec2f pos = blob.getPosition();
			
	        client_AddToChat("Pos X:" + pos.x + ", Pos Y:" + pos.y);
		}
	}
	
	if (text_in == "/togglehead")
	{
	    bool head = !blob.hasTag(head_tag);
		if  (head)
		{
			blob.Tag(head_tag);
			blob.Sync(head_tag, true);
		}
		else
		{
			blob.Untag(head_tag);
			blob.Sync(head_tag, true);
		}
		chatVisible = false;
	}
	else if(text_in == "/toggleskin")
	{
	    bool skin = !blob.hasTag(skin_tag);
		if  (skin)
		{
			blob.Tag(skin_tag);
			blob.Sync(skin_tag, true);
		}
		else
		{
			blob.Untag(skin_tag);
			blob.Sync(skin_tag, true);
		}
		chatVisible = false;
	}
	
	// TEMP
    if (text_in == "!debug" && aphelion)
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );
		printf("BLOBS TOTAL: " + all.length);
    }
	
	if (!chatVisible && aphelion)
	{
	    return false;
	}
    
	// SPAWNING
	if (canSpawn)
	{
		if (text_in == "!henry" && aphelion)
        {
        	CPlayer@ bot = AddBot( "Henry" );
        }
		else if (text_in == "!spawnwater" && aphelion)
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!pine")
		{
			server_MakeSeed( pos, "tree_pine", 300, 1, 8 );
		}
		else if (text_in == "!oak")
		{
			server_MakeSeed( pos, "tree_bushy", 300, 2, 8 );
		}
		else if (text_in == "!redwood")
		{
			server_MakeSeed( pos, "tree_redwood", 300, 7, 8 );
		}
		else if (text_in == "!flowers")
        {
            server_CreateBlob( "Entities/Natural/Flowers/Flowers.cfg", blob.getTeamNum(), blob.getPosition() );
        }
		else if (text_in == "!s" || text_in == "!stone")
		{
			CBlob@ b = server_CreateBlob( "mat_stone", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if (text_in == "!w" || text_in == "!wood")
		{
			CBlob@ b = server_CreateBlob( "mat_wood", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if (text_in == "!g" || text_in == "!gold")
		{
			CBlob@ b = server_CreateBlob( "mat_gold", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if (text_in == "!c" || text_in == "!coal")
		{
			CBlob@ b = server_CreateBlob( "mat_coal", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
		else if (text_in == "!i" || text_in == "!iron")
		{
			CBlob@ b = server_CreateBlob( "mat_iron", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
		else if (text_in == "!m" || text_in == "!mythril")
		{
			CBlob@ b = server_CreateBlob( "mat_mythril", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_bombs", team, pos );
				
				if (b !is null) 
				{
					b.server_SetQuantity(4);
				}
			}
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_arrows", team, pos );

				if (b !is null) {
					b.server_SetQuantity(30);
				}
			}
		}
		else if (text_in == "!bombarrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_bombarrows", team, pos );

				if (b !is null) {
					b.server_SetQuantity(2);
				}
			}
		}
		else if (text_in == "!crate")
		{
			server_MakeCrate( "", "", 0, team, Vec2f( pos.x, pos.y - 30.0f ) );
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 500);
		}
		else if (text_in.substr(0,1) == "!")
        {
            string[]@ tokens = text_in.split(" ");
            
            if (tokens.length > 1)
            {
				if (tokens[0] == "!settime" && aphelion)
			    {
				    float time = parseFloat(tokens[1]);
					getMap().SetDayTime(time);
				}
				else if (tokens[0] == "!bot" && aphelion)
			    {
        	        CPlayer@ bot = AddBot( tokens[1] );
				}
				else if (tokens[0] == "!team" && aphelion)
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
				}
			}
			
			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());
			
			server_CreateBlob( name, team, pos );
		}
		else 
		{
		    return true;
		}
		return !aphelion;
	}
    return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player.isMod() || player.isAdmin())
	{
		string[]@ args = text_in.split(" ");

		const bool aphelion = player.getUsername() == "Aphelion";
		if        (aphelion)
		{
			if (args[0] == "/spoof")
			{
				if (args[1] == "off")
				{
					SetSpoofing(this, player, false);
				}
				else
				{
					SetSpoofing(this, player, true, args[1]);
				}
			}
		}

		if (args[0] == "/teleto")
		{
			string playerName = args[1];
			
			for(uint i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ teletoPlayer = getPlayer(i);
				if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
				{
					CBlob@ teletoBlob = teletoPlayer.getBlob();
					if    (teletoBlob !is null)
					{
						player.getBlob().setPosition(teletoBlob.getPosition());
						player.getBlob().setVelocity( Vec2f_zero );			  
						player.getBlob().getShape().PutOnGround();
						
						if (teletoBlob.hasTag("dungeon"))
						{
							player.getBlob().Tag("dungeon");
						}
						else
						{
							player.getBlob().Untag("dungeon");
						}
					}
				}
			}
		}
	}
    return true;
}
