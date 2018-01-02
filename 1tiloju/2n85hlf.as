/* GrainTransition.as
 * author: Aphelion
 *
 * Script for handling seasonal transitioning of grain.
 */

#include "2efidcr.as";

#include "34lnvk0.as";

const string sprite_spring = "../Mods/" + RP_NAME + "/Entities/Natural/Farming/Grain/Grain-Spring.png";
const string sprite_summer = "../Mods/" + RP_NAME + "/Entities/Natural/Farming/Grain/Grain-Summer.png";
const string sprite_autumn = "../Mods/" + RP_NAME + "/Entities/Natural/Farming/Grain/Grain-Autumn.png";
const string sprite_winter = "../Mods/" + RP_NAME + "/Entities/Natural/Farming/Grain/Grain-Winter.png";
const string sprite_christmas = "../Mods/" + RP_NAME + "/Entities/Natural/Farming/Grain/Grain-Christmas.png";

void onInit( CSprite@ this )
{
	Reload(this);
}

void onTick( CSprite@ this )
{
	if (ticksSinceSeasonChange(getRules()) < 300)
	{
		Reload(this);
	}
}

void Reload( CSprite@ this )
{
	string sprite_path = getSpritePath();

	if (this.getFilename() != sprite_path)
	{
		this.ReloadSprite(sprite_path);
	}
}

string getSpritePath()
{
	u8 season = getSeason(getRules());

	return season == Seasons::SPRING    ? sprite_spring :
	       season == Seasons::AUTUMN    ? sprite_autumn :
	       season == Seasons::WINTER    ? sprite_winter :
	       season == Seasons::CHRISTMAS ? sprite_christmas :
	                                      sprite_summer;
}
