/* 2oqq4vc.as
 * author: Aphelion
 */

#define CLIENT_ONLY

#include "3kemuc.as";
#include "3mdq1g2.as";

#include "TeamColour.as";

const SColor neutral_color(255, 128, 128, 255);
const SColor allied_color(255, 128, 255, 255);
const SColor war_color(255, 255, 64, 0);

void onRender( CRules@ this )
{
    CPlayer@ p = getLocalPlayer();

    if (p is null || !p.isMyPlayer()) { return; }
	
	CTeam@ team = this.getTeam(p.getTeamNum());
	if    (team !is null)
	{
		// DRAW DIPLOMACY UI
		
		Vec2f upperleft(10, 24); // Box position
		Vec2f size(300, 105); // Box size	
		Vec2f off; // Text offset controller
		GUI::DrawPane(upperleft, upperleft + size, SColor(0x80ffffff));
		
		int teamNum = p.getTeamNum();
		string teamName = team.getName();
		
		Vec2f text_dim;
	    GUI::GetTextDimensions(teamName, text_dim);
		
		off = Vec2f(size.x / 2, 5);
		
	    GUI::DrawText(teamName, Vec2f(upperleft.x + off.x - text_dim.x / 2, upperleft.y + off.y), getTeamColor(teamNum));
		
		int step = 0;
		for(int i = 0; i < this.getTeamsCount(); i++)
		{
			if(teamNum != i)
			{
			    step++;
				
		        off = Vec2f(5, step * 17);
				
	            GUI::DrawText(this.getTeam(i).getName(), upperleft + off, upperleft + off + size, getTeamColor(i), true, true);

				off = Vec2f(size.x - 65, step * 17);
				
				int disposition = getDisposition(this, teamNum, i);
				if (disposition == DISPOSITION_NEUTRAL)
					GUI::DrawText(textForDisposition(disposition), upperleft + off, upperleft + off + size, neutral_color, true, true);
				else if(disposition == DISPOSITION_ALLIED)
					GUI::DrawText(textForDisposition(disposition), upperleft + off, upperleft + off + size, allied_color, true, true);
				else if(disposition == DISPOSITION_ENEMY)
					GUI::DrawText(textForDisposition(disposition), upperleft + off, upperleft + off + size, war_color, true, true);
			}
		}
	}
	
	// DRAW RESPAWN MESSAGE
	
    string propname = "ctf spawn time " + p.getUsername();	
    if (p.getBlob() is null && this.exists(propname) )
    {
        u8 spawn = this.get_u8(propname);
        if(spawn != 255)
        {
            GUI::DrawText("Respawning in: " + spawn, Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
        }
    }
}
