// SHOW KILL MESSAGES ON CLIENT

#include "5ggqoj.as";

#include "Hitters.as";
#include "TeamColour.as";
#include "HoverMessage.as";

int fade_time = 300;


class KillMessage
{
    string victim;
    string attacker;
    int attackerteam;
    int victimteam;
    u8 hitter;
    s16 time;

    KillMessage( ) {} //dont use this

    KillMessage( CPlayer@ _victim, CPlayer@ _attacker, u8 _hitter )
    {
        victim = _victim.getCharacterName();
        victimteam = _victim.getTeamNum();

        if (_attacker !is null)
        {
            attacker = _attacker.getCharacterName();
            attackerteam = _attacker.getTeamNum();
			//print("victimteam " + victimteam  + " " + (_victim.getBlob() !is null) + " attackerteam " + attackerteam + " " + (_attacker.getBlob() !is null));
        }
        else
        {
            attacker = "";
            attackerteam = -1;
        }		

        hitter = _hitter;
        time = fade_time;
    }
};

class KillFeed
{
    KillMessage[] killMessages;

    void Update()
    {
        while(killMessages.length > 10)
        {
            killMessages.erase(0);
        }

        for (uint message_step = 0; message_step < killMessages.length; ++message_step)
        {
            KillMessage@ message = killMessages[message_step];
            message.time--;
			
			if(message.time == 0)
				killMessages.erase(message_step--);
        }
    }

    void Render()
    {
		const uint count = Maths::Min( 10, killMessages.length ); 
        for (uint message_step = 0; message_step < count; ++message_step)
        {
            KillMessage@ message = killMessages[message_step];
            Vec2f dim, ul, lr;

            if (message.attackerteam != -1)
            {
                //draw attacker name
				GUI::GetTextDimensions( message.attacker, dim );
                ul.Set( getScreenWidth() - dim.x - 164, (message_step+1) * 16 );
                SColor col = getTeamColor(message.attackerteam);
                GUI::DrawText( message.attacker, ul, col);		  // true, true caches juxta_banner, so we got that bug with wrong team colors
            }

            //draw icon in between based on hitter
            string hitterIcon;

            switch(message.hitter)
            {
            case Hitters::fall:     hitterIcon = "$killfeed_fall$"; break;

            case Hitters::drown:     hitterIcon = "$killfeed_water$"; break;

            case Hitters::fire:
            case Hitters::burn:     hitterIcon = "$killfeed_fire$"; break;

            case Hitters::stomp:    hitterIcon = "$killfeed_stomp$"; break;

            case Hitters::builder:  hitterIcon = "$killfeed_builder$"; break;
            
            case Hitters::spikes:  hitterIcon = "$killfeed_spikes$"; break;

            case Hitters::sword:
            case Hitters::axe:
            case Hitters::axe_power: hitterIcon = "$killfeed_sword$"; break;

            case Hitters::shield:   hitterIcon = "$killfeed_shield$"; break;

            case Hitters::bomb:
            case Hitters::bomb_arrow:
            case Hitters::explosion:     hitterIcon = "$killfeed_bomb$"; break;

            case Hitters::keg:     hitterIcon = "$killfeed_keg$"; break;
			
			case Hitters::arrow:
            case Hitters::piercing_arrow:    hitterIcon = "$killfeed_arrow$"; break;

            case Hitters::ballista: hitterIcon = "$killfeed_ballista$"; break;
			
            case Hitters::boulder:
            case Hitters::cata_boulder:  hitterIcon = "$killfeed_boulder$"; break;
			
            case Hitters::cannonball:
            case Hitters::bullet: hitterIcon = "$killfeed_cannonball$"; break;
			
            case Hitters::magic: hitterIcon = "$killfeed_magic$"; break;

            default: hitterIcon = "$killfeed_fall$";
            }

            if (hitterIcon != "")
            {
			    if(message.hitter == Hitters::cannonball || message.hitter == Hitters::bullet)
					ul.Set( getScreenWidth() - 172 + 16, ((message_step+1) * 16) - 16);
                else
				    ul.Set( getScreenWidth() - 172, ((message_step+1) * 16) - 8 );
				
                GUI::DrawIconByName( hitterIcon, ul);
            }

				//draw victim name
			if (message.victimteam != -1)
			{
				GUI::GetTextDimensions( message.victim, dim );
				ul.Set( getScreenWidth() - 124, (message_step+1) * 16 );
				SColor col = getTeamColor(message.victimteam);
				GUI::DrawText( message.victim, ul, col);
			}
        }
    }

};

void Reset( CRules@ this )
{
    KillFeed feed;
    this.set( "KillFeed", feed );    
}

void onRestart( CRules@ this )
{
    Reset( this );
}

void onInit( CRules@ this )
{
    Reset( this );

    AddIconToken( "$killfeed_fall$", "GUI/KillfeedIcons.png", Vec2f(32,16), 1 );
    AddIconToken( "$killfeed_water$", "GUI/KillfeedIcons.png", Vec2f(32,16), 2 );
    AddIconToken( "$killfeed_fire$", "GUI/KillfeedIcons.png", Vec2f(32,16), 3 );
    AddIconToken( "$killfeed_stomp$", "GUI/KillfeedIcons.png", Vec2f(32,16), 4 );
    
    AddIconToken( "$killfeed_builder$", "GUI/KillfeedIcons.png", Vec2f(32,16), 8 );
    AddIconToken( "$killfeed_axe$", "GUI/KillfeedIcons.png", Vec2f(32,16), 9 );
    AddIconToken( "$killfeed_spikes$", "GUI/KillfeedIcons.png", Vec2f(32,16), 10 );
    AddIconToken( "$killfeed_boulder$", "GUI/KillfeedIcons.png", Vec2f(32,16), 11 );

    AddIconToken( "$killfeed_sword$", "GUI/KillfeedIcons.png", Vec2f(32,16), 12 );
    AddIconToken( "$killfeed_shield$", "GUI/KillfeedIcons.png", Vec2f(32,16), 13 );
    AddIconToken( "$killfeed_bomb$", "GUI/KillfeedIcons.png", Vec2f(32,16), 14 );
    AddIconToken( "$killfeed_keg$", "GUI/KillfeedIcons.png", Vec2f(32,16), 15 );
	
    AddIconToken( "$killfeed_arrow$", "GUI/KillfeedIcons.png", Vec2f(32,16), 16 );
    AddIconToken( "$killfeed_ballista$", "GUI/KillfeedIcons.png", Vec2f(32,16), 17 );
	AddIconToken( "$killfeed_magic$", "GUI/KillfeedIcons.png", Vec2f(32,16), 20 );
	
    AddIconToken( "$killfeed_cannonball$", "Entities/Materials/Materials.png", Vec2f(16,16), 136 );
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customdata )
{
    if (victim !is null)
    {
        KillFeed@ feed;
        if (this.get( "KillFeed", @feed ))
        {
            KillMessage message = KillMessage(victim, killer, customdata);
            feed.killMessages.push_back(message);
        }
						
		// hover message


		if (killer !is null)
		{
			CBlob@ killerblob = killer.getBlob();
			CBlob@ victimblob = victim.getBlob();
			if (killerblob !is null && victimblob !is null && killerblob.isMyPlayer() && killerblob !is victimblob)
			{
				if (!killerblob.exists("messages")) {
					HoverMessage[] messages;
					killerblob.set( "messages", messages);
				}
	
				HoverMessage[]@ messages;		   
				if (killerblob.get("messages",@messages))
				{
						HoverMessage m( victimblob.getInventoryName(), 1, SColor(255, 255, 20,20), 75, 2, false);
						killerblob.push("messages",m);
				}
			}
		}
    }
}

void onTick( CRules@ this )
{
    KillFeed@ feed;

    if (this.get( "KillFeed", @feed ))
    {
        feed.Update();
    }
}

void onRender( CRules@ this )
{
    KillFeed@ feed;

    if (this.get( "KillFeed", @feed ))
    {
        feed.Render();
    }
}
