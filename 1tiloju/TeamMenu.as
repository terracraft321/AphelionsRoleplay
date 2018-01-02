/* TeamMenu.as
 * modified by: Aphelion
 */

#include "8s73in.as";

const int BUTTON_SIZE = 3;

void onInit( CRules@ this )
{
    this.addCommandID("pick teams");
    this.addCommandID("pick spectator");
	this.addCommandID("pick none");

    AddIconToken("$ANGELS_C$", "GUI/RaceIcons.png", Vec2f(64, 64), 0);
    AddIconToken("$ANGELS_G$", "GUI/RaceIcons.png", Vec2f(64, 64), 6);
    AddIconToken("$UNDEAD_C$", "GUI/RaceIcons.png", Vec2f(64, 64), 1);
    AddIconToken("$UNDEAD_G$", "GUI/RaceIcons.png", Vec2f(64, 64), 7);
    AddIconToken("$HUMANS_C$", "GUI/RaceIcons.png", Vec2f(64, 64), 2);
    AddIconToken("$HUMANS_G$", "GUI/RaceIcons.png", Vec2f(64, 64), 8);
    AddIconToken("$DWARVES_C$", "GUI/RaceIcons.png", Vec2f(64, 64), 3);
    AddIconToken("$DWARVES_G$", "GUI/RaceIcons.png", Vec2f(64, 64), 9);
    AddIconToken("$ELVES_C$", "GUI/RaceIcons.png", Vec2f(64, 64), 4);
    AddIconToken("$ELVES_G$", "GUI/RaceIcons.png", Vec2f(64, 64), 10);
    AddIconToken("$ORCS_C$", "GUI/RaceIcons.png", Vec2f(64, 64), 5);
    AddIconToken("$ORCS_G$", "GUI/RaceIcons.png", Vec2f(64, 64), 11);
}

void ShowTeamMenu(CRules@ this)
{
    CPlayer@ player = getLocalPlayer();
    if      (player is null)
        return;
	
	getHUD().ClearMenus(true);
	
	bool donator = getSecurity().checkAccess_Feature(player, "donator");
	
	CGridMenu@ main_menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0, -128), null, Vec2f(((this.getTeamsCount() - 2) + 0.8f) * BUTTON_SIZE, BUTTON_SIZE), "Pick your race");
	if        (main_menu !is null)
	{
		CBitStream exitParams;
		main_menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("pick none"), exitParams);
		main_menu.SetDefaultCommand(this.getCommandID("pick none"), exitParams);
		
		bool enabled;
        string icon, name;
		
        for (int i = 0; i < 4; i++)
        {
			enabled = donator || player.getTeamNum() == 255 || (player.getTeamNum() != 255 && player.getTeamNum() == i);
			
            if (i == 0)
            {
                icon = enabled ? "$HUMANS_C$" : "$HUMANS_G$";
                name = "Human: Capable lumberjacks and miners, the Human Kingdom is home to some of the most elite wizards, known as Archmages";
            }
            else if (i == 1)
            {
                icon = enabled ? "$DWARVES_C$" : "$DWARVES_G$";
                name = "Dwarf: Expert stone miners, Mountain Dwarves have some of the most capable and enduring engineers known as Sappers";
            }
			else if (i == 2)
            {
                icon = enabled ? "$ELVES_C$" : "$ELVES_G$";
                name = "Elf: Skilled woodcutters, Forest Elves are the renowned for their skill in archery, their very finest known as Master Archers";
            }
			else if (i == 3)
            {
                icon = enabled ? "$ORCS_C$" : "$ORCS_G$";
                name = "Orc: Proficient ore miners, the Orcs of the depths are known for their expertly trained and agile warriors known as Elite Knights";
            }
			
            CBitStream params;
            params.write_u16(player.getNetworkID());
            params.write_u8(i);
			params.write_bool(enabled);
			
			CGridButton@ button = main_menu.AddButton(icon, name, this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
        }
		
		// spectator
        CBitStream params;
        params.write_u16(getLocalPlayer().getNetworkID());
        params.write_u8(this.getSpectatorTeamNum());
		params.write_bool(true);
		
        main_menu.AddButton("$SPECTATOR$", "Spectate", this.getCommandID("pick spectator"), Vec2f(2, BUTTON_SIZE), params);
	}
	
	CGridMenu@ second_menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0, 56), null, Vec2f(2 * BUTTON_SIZE, BUTTON_SIZE), "Exclusive races");
	if        (second_menu !is null)
	{
		CBitStream exitParams;
		second_menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("pick none"), exitParams);
		second_menu.SetDefaultCommand(this.getCommandID("pick none"), exitParams);
		
		string icon, name;
		bool enabled;
		
        for (int i = 4; i < this.getTeamsCount(); i++)
        {
			if (i == 4)
            {
                icon = enabled ? "$ANGELS_C$" : "$ANGELS_G$";
                name = "Angel: Guardians of the mortal world, the Angels have the gift of flight and can gather resources at twice the rate";
			    enabled = donator;
            }
			else if (i == 5)
            {
                icon = enabled ? "$UNDEAD_C$" : "$UNDEAD_G$";
                name = "Undead: Scourge of the underworld, the Undead are fiercly at war with all the races of Eve";
			    enabled = isSponsor(player);
            }
			
            CBitStream params;
            params.write_u16(player.getNetworkID());
            params.write_u8(i);
			params.write_bool(enabled);
			
			CGridButton@ button = second_menu.AddButton(icon, name, this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
		}
	}
}

// the actual team changing is done in the player management script -> onPlayerRequestTeamChange()
void ReadChangeTeam( CRules@ this, CBitStream @params )
{
    CPlayer@ player = getPlayerByNetworkId(params.read_u16());
    u8 team = params.read_u8();
	
	bool enabled = params.read_bool();
    if  (enabled && player is getLocalPlayer())
    {
        player.client_ChangeTeam(team);
        getHUD().ClearMenus();
    }
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("pick teams"))
    {
        ReadChangeTeam(this, params);
    }
    else if (cmd == this.getCommandID("pick spectator"))
    {
        ReadChangeTeam(this, params);
	}
	else if (cmd == this.getCommandID("pick none"))
	{
		getHUD().ClearMenus();
	}
}
