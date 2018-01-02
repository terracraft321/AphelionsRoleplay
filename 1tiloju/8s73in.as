/* Sponsor.as
 * author: Aphelion
 */

shared bool isSponsor(CPlayer@ player)
{
    if (getSecurity().checkAccess_Feature(player, "sponsor"))
	    return true;
	
	/*
	// TEMPORARY 
    else if (getSecurity().checkAccess_Feature(player, "admin")) // admin
	{
		u32 month = Time_Month();
		u32 day = Time_MonthDate();
		
		if (month == 5 && day >= 9 && day <= 11)
		    return true;
	}
	// --
	*/
	
	string[] sponsors = {

		// -- SUPER ADMINS
		"Aphelion",
		"Perihelion371",
		"Sohkyo",
		"Duke_Jordan",
		"MadRaccoon",
		"zhuum",
		
		// -- ADMIN VETERANS
		"kaggit",
		"stabborazz",
		"Rspwn",
		"toffie0",
		"yamin",
		
		// -- ADMIN SPONSORS
		"pmattep99",
		"bbpolkagal",
		"Alpha-Penguin",
		"troller111",
		"PalladiumGirl",
		"carlospaul",
		"DeathSmurfxD",
		"WuppieF",
                "de_licious",
		
	};
	
	for(int i = 0; i < sponsors.length; i++)
	{
		string sponsor = sponsors[i];
		if    (sponsor == player.getUsername())
			return true;
	}
	return false;
}
