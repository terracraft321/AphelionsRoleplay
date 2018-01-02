/* 34lnvk0.as
 * author: Aphelion
 */

enum Seasons
{
	SPRING = 0,
	SUMMER,
	AUTUMN,
	WINTER,
	TOTAL,
	
	CHRISTMAS
}

const string season_property = "season";
const string season_fade_property = "season fade";
const string season_change_property = "season change time";

const u16 SEASON_CHANGE_THRESHOLD = 180 * 30;

u8 getSeason( CRules@ this )
{
	return this.get_u8(season_property);
}

bool wasSeasonChanged( CRules@ this )
{
	if(this.get_u32(season_change_property) == 0)
	    return false;
	else
	    return this.get_u32(season_change_property) + SEASON_CHANGE_THRESHOLD > getGameTime();
}

s32 ticksSinceSeasonChange( CRules@ this )
{
	if(this.get_u32(season_change_property) == 0)
	    return 0;
	else
	    return this.get_u32(season_change_property) - getGameTime();
}
