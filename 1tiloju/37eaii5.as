#define CLIENT_ONLY

const string title = "The Rules";
const string rules = "Rule 1) You must Roleplay\n" +
                     "Rule 2) Respect the rules\n" +
                     "Rule 3) Show respect towards other players\n" +
                     "Rule 4) All diplomacy actions must involve Roleplay (including Undead!)\n" +
                     "Rule 5) You must accept one term of any race that you lost a war against\n" +
                     "Rule 6) Do not grief or take from teams that you are not at war with\n" +
					 "(Unless it's a term of a war being won)\n" +
                     "Rule 7) Do not perform hacking, spamming or impersonation\n" +
                     "Rule 8) Do not build swastikas\n" +
                     "Rule 9) Do not exploit bugs\n" +
                     "Rule 10) Do not be a jackass/idiot/retard/dick/asshole";

const Vec2f dimensions(550, 155);

bool show_rules = false;

void onTick(CRules@ this)
{
    CPlayer@ player = getLocalPlayer();
	
	if (player !is null)
        show_rules = player.getBlob() is null;
	else
	    show_rules = false;
}

void onRender(CRules@ this)
{
	if (show_rules)
	{
	    Vec2f tl = Vec2f(getScreenWidth() / 2 - dimensions.x / 2, getScreenHeight() - dimensions.y - 24);
	    Vec2f br = Vec2f(tl.x + dimensions.x, tl.y + dimensions.y);
	    Vec2f text_dim;
		
		GUI::DrawPane(tl, br, SColor(0x80ffffff));
		
	    GUI::GetTextDimensions( title, text_dim );
		GUI::DrawText(title, tl + Vec2f(dimensions.x / 2 - text_dim.x / 2, 5), color_white);
		GUI::DrawText(rules, tl + Vec2f(5, 25), color_white);
	}
}
