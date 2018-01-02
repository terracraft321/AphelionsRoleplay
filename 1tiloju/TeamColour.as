SColor getTeamColor(int team)
{
	SColor teamCol;
	
	switch(team)
	{
		case 0: teamCol.set(0xff2cafde); break; // HUMAN

		case 1: teamCol.set(0xffd5543f); break; // DWARF

		case 2: teamCol.set(0xff9dca22); break; // ELF
	
		case 3: teamCol.set(0xffd379e0); break; // ORC
	
		case 4: teamCol.set(255, 255, 150, 0); break; // ANGEL

		default: teamCol.set(0xff888888); break;
	}
	
	return teamCol;
}
