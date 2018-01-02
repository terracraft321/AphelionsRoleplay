/* tj58vs.as
 * author: Aphelion3371
 */

#define CLIENT_ONLY

const u16 JOIN_MESSAGE_DELAY = 5 * 30;
const u16 MESSAGE_INTERVAL = 90 * 30;

const string[] messages = {
	
	// -- GAME INFO
	"Did you know?: You can access the Diplomacy system via; Esc -> Vote -> Diplomacy",
	"Did you know?: You can open the equipment menu by pressing the F key",
	"Did you know?: You can purchase food and potions from a market or make them yourself at a kitchen",
	"Did you know?: Humans specialize in magic, Dwarves in construction, Elves in archery, and Orcs in melee",
	"Did you know?: Zombies sometimes drop very rare scrolls and potions",
	"Did you know?: It is rumoured that an evil Necromancer named Noom lives deep underground in a dangerous dungeon",
	"Did you know?: Plants will grow faster when exposed to light and plants of the same type, though they don't like overcrowded areas",
	
	// -- MISC INFO
	"Did you know?: You can donate to keep the server online and support further development.\n" +
	               "Donate $5 USD: Receive Donator status and access to the Angel race (they can fly!)\n" +
				   "Donate $25 USD: Receive Sponsor status, a custom builder skin, and access to the Undead race (take over the world!)\n" +
				   "Sponsor status comes with all Donator perks",
	"Did you know?: Donations are sent to aphelionkag@live.com via PayPal, just leave your KAG user as a note!\n" +
	               "For more information on how to donate and the perks of donating, visit the social forum at http://tinyurl.com/aphelionsroleplay\n" +
				   "Instructions on how to join are at the top of the page",
	"Did you know?: If you're wondering how to donate, go to http://tinyurl.com/aphelionsroleplay and click on the red Join Social Forum button",
	"Did you know?: If you have a custom head, you can toggle it by typing /togglehead",
	"Did you know?: If you have a custom skin, type /toggleskin to toggle it\n" +
	               "Custom builder skins are exclusive to sponsors and veteran admins\n",
	"Did you know?: Aphelion is the creator and hoster of Aphelion's Roleplay",
	
	// -- RULES
	"Rule 1) You must Roleplay\n" +
    "Rule 2) Respect the rules\n" +
    "Rule 3) Show respect towards other players (they are human too!) and treat people how you wish to be treated\n" +
    "Rule 4) All diplomacy actions must involve Roleplay (that includes Undead!)\n" +
    "Rule 5) You must accept one term of any race that you lost a war against\n" +
    "Rule 6) Do not grief or take from teams that you are not at war with, unless it's a term of a war being won\n" +
    "Rule 7) Do not perform hacking, spamming or impersonation of other players\n" +
    "Rule 8) Do not build swastikas\n" +
    "Rule 9) Do not exploit bugs\n" +
    "Rule 10) Do not be a jackass/idiot/retard/dick/asshole (as determined by an admin)",
	"Join the social forum at http://tinyurl.com/aphelionsroleplay\n" +
	"Where you can report rule breakers, apply for administrator status, share your ideas, and learn how to donate.\n" +
	"Instructions on how to join are at the top of the page",
	
};

bool just_joined = true;
int counter = 0;

void onTick( CRules@ this )
{
	const u32 time = getGameTime();
	
	if (just_joined && (time % JOIN_MESSAGE_DELAY) == 0)
	{
		client_AddToChat("Welcome to Aphelion's Roleplay Server!", SColor(255, 127, 0, 127));
	    just_joined = false;
	}
	else if(time % MESSAGE_INTERVAL == 0)
	{
	    client_AddToChat(messages[counter++ % messages.length], SColor(255, 127, 0, 127));
	}
}
