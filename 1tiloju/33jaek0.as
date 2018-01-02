/* 33jaek0.as
 * author: Aphelion
 */

#include "2efidcr.as";

#include "34lnvk0.as";

void onInit( CRules@ this )
{
    this.addCommandID("change season");
	
	onRestart(this);
}

void onRestart( CRules@ this )
{
	if (getNet().isServer())
	{
		u8 season = XORRandom(Seasons::TOTAL);

		if (Time_Month() == 12)
		{
			season = Seasons::CHRISTMAS;
		}

		this.set_u8(season_property, season);
		this.set_u32(season_change_property, 0);
		
		this.Sync(season_property, true);
		this.Sync(season_change_property, true);
	}
	
	this.set_u8(season_fade_property, 255);
}

void onTick( CRules@ this )
{
	if (getNet().isClient())
	{
		const u32 gametime = getGameTime();
		if       (gametime < 300)
		{
			LoadSeason(this, getMap(), getSeason(this));
		}
    }

	u8 fade = this.get_u8(season_fade_property);
		
	float dayTime = getMap().getDayTime();
	if   (dayTime <= 0.05f)
	{
		if(!wasSeasonChanged(this))
		{
			if (fade < 250)
				fade++;
			else
			{
			    u8  currentSeason = getSeason(this);

			    if (currentSeason > Seasons::TOTAL) // special theme
			    {
		            this.set_u32(season_change_property, getGameTime());
			    	return;
			    }

				ChangeSeason(this, currentSeason == WINTER ? 0 : currentSeason + 1);
			}
		}
		else
		{
		    if (fade > 0)
			    fade--;
		}
	}
	else
	{
		if (fade > 0)
			fade--;
	}
	
	this.set_u8(season_fade_property, fade);
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("change season"))
	{
    	u8 season;
		
		if(!params.saferead_u8(season))
		    return;
		
	    LoadSeason(this, getMap(), season);

		this.set_u8(season_property, season);
		this.set_u32(season_change_property, getGameTime());
	}
}

void onRender( CRules@ this )
{
    u8  fade = this.get_u8(season_fade_property);	   	
	if (fade > 0)
    {
        SetScreenFlash(fade, 0, 0, 0);
    }
}

void ChangeSeason( CRules@ this, u8 season )
{
	CBitStream params;
	params.write_u8(season);

	this.SendCommand(this.getCommandID("change season"), params);
}

void LoadSeason( CRules@ this, CMap@ map, u8 season )
{
	if (getNet().isClient())
	{
		// world
		string world_sprite = season == Seasons::SPRING    ? "../Mods/" + RP_NAME + "/Sprites/world-spring.png" :
		                      season == Seasons::AUTUMN    ? "../Mods/" + RP_NAME + "/Sprites/world-autumn.png" :
		                      season == Seasons::WINTER    ? "../Mods/" + RP_NAME + "/Sprites/world-winter.png" :
		                      season == Seasons::CHRISTMAS ? "../Mods/" + RP_NAME + "/Sprites/world-christmas.png" :
		                                                     "../Mods/" + RP_NAME + "/Sprites/world.png";

		map.CreateTileMap(0, 0, 8.0f, world_sprite);
		
		// sky
		map.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
		map.CreateSkyGradient("Sprites/skygradient.png"); // override sky color with gradient
		
		// plains
		string background_plains_sprite = season == Seasons::SPRING    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundPlains-summer.png" :
		                                  season == Seasons::AUTUMN    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundPlains-autumn.png" :
		                                  season == Seasons::WINTER    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundPlains-winter.png" :
		                                  season == Seasons::CHRISTMAS ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundPlains-winter.png" :
		                                                                 "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundPlains-summer.png";
		string background_trees_sprite =  season == Seasons::SPRING    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundTrees-summer.png" :
		                                  season == Seasons::AUTUMN    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundTrees-autumn.png" :
		                                  season == Seasons::WINTER    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundTrees-winter.png" :
		                                  season == Seasons::CHRISTMAS ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundTrees-winter.png" :
		                                                                 "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundTrees-summer.png";
		string background_castle_sprite = season == Seasons::SPRING    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundCastle-summer.png" :
		                                  season == Seasons::AUTUMN    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundCastle-autumn.png" :
		                                  season == Seasons::WINTER    ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundCastle-winter.png" :
		                                  season == Seasons::CHRISTMAS ? "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundCastle-winter.png" :
		                                                                 "../Mods/" + RP_NAME + "/Sprites/Back/BackgroundCastle-summer.png";

		map.AddBackground(background_plains_sprite, Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
		map.AddBackground(background_trees_sprite,  Vec2f(0.0f, -5.0f),  Vec2f(0.4f, 0.4f), color_white);
		map.AddBackground(background_castle_sprite, Vec2f(0.0f,  70.0f), Vec2f(0.6f, 0.6f), color_white);
	}
}
