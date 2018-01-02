/* 312pign.as
 * author: Aphelion
 */

#define CLIENT_ONLY

#include "34lnvk0.as";
#include "2efidcr.as";
#include "3kemuc.as";

const int AMBIENCE_INTERVAL = 2 * getTicksASecond(); // Ambience update interval
const int MUSIC_INTERVAL = 15 * getTicksASecond(); // Music update interval

bool ambience_enabled = true;
bool music_enabled = true;

enum SoundTags
{
                       // ambience
    ambience_start = 0,
	ambience_birds,
	ambience_cicadas,
	ambience_owls,
	ambience_mountain,
	ambience_underground,
	ambience_end,
	
	                   // ambient soundtracks
	soundtrack_start,
	soundtrack_spring_theme, 
	soundtrack_spring,  
	soundtrack_summer_theme,
	soundtrack_summer,
	soundtrack_autumn_theme,
	soundtrack_autumn,
	soundtrack_winter_theme,
	soundtrack_winter,
	soundtrack_christmas_theme,
	soundtrack_christmas,
	soundtrack_portal,  // underground portal
	soundtrack_dungeon, // underground dungeon
	soundtrack_end
};

void onInit(CBlob@ this)
{
    CMixer@ mixer = getMixer();		
    if     (mixer is null) { return; }

    mixer.ResetMixer();
    this.set_bool("initialized sounds", false);
}

void onTick(CBlob@ this)
{
    CMixer@ mixer = getMixer();		  
    if     (mixer is null) { return; }
	
    if (s_soundon != 0 && s_musicvolume > 0.0f)
    {
	    //if (s_volume < 0.25f && s_volume > 0.0f)
		//    s_volume = 0.25f;
	    if (s_musicvolume < 0.50f)
		    s_musicvolume = 0.50f;
	    
        if (!this.get_bool("initialized sounds"))
		{
            AddSounds(this, mixer);
        }
        SoundLogic(this, mixer);
    }
    else
    {
        mixer.FadeOutAll(0.0f, 3.0f);
    }
}

void AddSounds(CBlob@ this, CMixer@ mixer)
{
    this.set_bool("initialized sounds", true);
	
	// -- AMBIENCE
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Ambience/Birds.ogg", ambience_birds);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Ambience/Cicadas.ogg", ambience_cicadas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Ambience/Owls.ogg", ambience_owls);
	mixer.AddTrack("Sounds/Music/ambient_mountain.ogg", ambience_mountain);
	mixer.AddTrack("Sounds/Music/ambient_cavern.ogg", ambience_underground);
	mixer.AddTrack("Sounds/Music/ambient_cavern.ogg", ambience_underground);
	mixer.AddTrack("Sounds/Music/ambient_cavern.ogg", ambience_underground);
	mixer.AddTrack("Sounds/Music/ambient_cavern_creatures1.ogg", ambience_underground);
	mixer.AddTrack("Sounds/Music/ambient_cavern_creatures2.ogg", ambience_underground);
	mixer.AddTrack("Sounds/Music/ambient_cavern_creatures3.ogg", ambience_underground);
	mixer.AddTrack("Sounds/Music/ambient_cavern_creatures4.ogg", ambience_underground);
	// --
	
	// -- MUSIC (by Adrian von Ziegler)
	
	// Spring
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Kingdom_of_Bards.ogg", soundtrack_spring_theme);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Kingdom_of_Bards.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Kingdom_of_Bards.ogg", soundtrack_spring);
	
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Spring_Charm.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/For_the_King.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/A_Celtic_Lore.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Where_I_Belong.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Land_of_the_Free.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Evocation.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Breath_of_the_Forest.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Home_of_Heroes.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Hymn_to_Annumara.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Morrigan.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Queen_of_the_Gaels.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Prophecy.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Cliffs_of_Moher.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Welcome_Home.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Woodland_Tales.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alpha.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Moonsong.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Daydream_Melody.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Eventide.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Origins.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Part_of_the_Pack.ogg", soundtrack_spring);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Wolf_Blood.ogg", soundtrack_spring);
	//
	
	// Summer
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alvae.ogg", soundtrack_summer_theme);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alvae.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alvae.ogg", soundtrack_summer);
	
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/For_the_King.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/A_Celtic_Lore.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Where_I_Belong.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Land_of_the_Free.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Evocation.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Breath_of_the_Forest.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Home_of_Heroes.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Hymn_to_Annumara.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Morrigan.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Queen_of_the_Gaels.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Prophecy.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Cliffs_of_Moher.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Welcome_Home.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Woodland_Tales.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alpha.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Moonsong.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Daydream_Melody.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Eventide.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Origins.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Part_of_the_Pack.ogg", soundtrack_summer);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Wolf_Blood.ogg", soundtrack_summer);
	//
	
	// Autumn
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Druidic_Dreams.ogg", soundtrack_autumn_theme);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Druidic_Dreams.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Druidic_Dreams.ogg", soundtrack_autumn);
	
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Autumn_Forest_Pt1.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Autumn_Forest_Pt2.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/For_the_King.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/A_Celtic_Lore.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Where_I_Belong.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Land_of_the_Free.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Evocation.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Breath_of_the_Forest.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Home_of_Heroes.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Hymn_to_Annumara.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Morrigan.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Queen_of_the_Gaels.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Prophecy.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Cliffs_of_Moher.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Welcome_Home.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Woodland_Tales.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alpha.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Moonsong.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Daydream_Melody.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Eventide.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Origins.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Part_of_the_Pack.ogg", soundtrack_autumn);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Wolf_Blood.ogg", soundtrack_autumn);
	//
	
	// Winter
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Bound.ogg", soundtrack_winter_theme);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Bound.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Bound.ogg", soundtrack_winter);
	
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/For_the_King.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/A_Celtic_Lore.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Where_I_Belong.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Land_of_the_Free.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Evocation.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Breath_of_the_Forest.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Home_of_Heroes.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Hymn_to_Annumara.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Morrigan.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Queen_of_the_Gaels.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Prophecy.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Cliffs_of_Moher.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Welcome_Home.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Woodland_Tales.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alpha.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Moonsong.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Daydream_Melody.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Eventide.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Origins.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Part_of_the_Pack.ogg", soundtrack_winter);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Wolf_Blood.ogg", soundtrack_winter);
	//

	// Christmas
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Bound.ogg", soundtrack_christmas_theme);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Bound.ogg", soundtrack_christmas);

	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Kingdom_of_Bards.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alvae.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Druidic_Dreams.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Spring_Charm.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Autumn_Forest_Pt1.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Autumn_Forest_Pt2.ogg", soundtrack_christmas);

	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/For_the_King.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/A_Celtic_Lore.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Where_I_Belong.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Land_of_the_Free.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Evocation.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Breath_of_the_Forest.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Home_of_Heroes.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Hymn_to_Annumara.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Morrigan.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Queen_of_the_Gaels.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Prophecy.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Cliffs_of_Moher.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Welcome_Home.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Woodland_Tales.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Alpha.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Moonsong.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Daydream_Melody.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Eventide.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Origins.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Part_of_the_Pack.ogg", soundtrack_christmas);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Wolf_Blood.ogg", soundtrack_christmas);
	//
	
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Reign_of_the_Dark.ogg", soundtrack_portal);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Invictus.ogg", soundtrack_dungeon);
	mixer.AddTrack("../Mods/Roleplay_Music/Sounds/Music/Dark_Ritual.ogg", soundtrack_dungeon);
	
	// --
}

// LOGIC

void SoundLogic(CBlob@ this, CMixer@ mixer)
{
    const u32 time = getGameTime();
	
	CRules@ rules = getRules();
	
	CBlob@ blob = getLocalPlayerBlob();
	if    (blob is null)
	    return;
	
	CMap@ map = blob.getMap();
	if   (map is null)
	    return;
	
	Vec2f pos = blob.getPosition();
	
	// AMBIENCE
	if(ambience_enabled && (time % AMBIENCE_INTERVAL == 0))
	{
	    // dungeon ambience
	    if (blob.hasTag("dungeon"))
		{
		    changeAmbience(mixer, ambience_underground, 3.0f, 3.0f);
			
			toggleMusic(mixer, true);
		}
		
	    // windy ambience
	    else if (pos.y < map.tilemapheight * map.tilesize * 0.6f &&
		         pos.y > map.tilemapheight * map.tilesize * 0.5f) // not in the Citadel
		{
		    changeAmbience(mixer, ambience_mountain, 3.0f, 3.0f);
			
			toggleMusic(mixer, true);
		}
		
		// underground ambience
		else if (pos.y > map.tilemapheight * map.tilesize * 0.80f &&
		         map.rayCastSolid(pos, Vec2f(pos.x, pos.y - 100.0f))) // to be sure
		{
		    changeAmbience(mixer, ambience_underground, 3.0f, 3.0f);
			
			toggleMusic(mixer, false);
		}
		
		else
		{
			f32 dayTime = map.getDayTime();
			if (dayTime <= 0.85 && dayTime >= 0.15)
				changeAmbience(mixer, ambience_birds, 3.0f, 3.0f);
			else if(dayTime > 0.77 && dayTime < 0.85)
				changeAmbience(mixer, ambience_cicadas, 3.0f, 3.0f);
			else
				changeAmbience(mixer, ambience_owls, 3.0f, 3.0f);
			
			toggleMusic(mixer, true);
		}
	}
	
	// MUSIC
	if(music_enabled && (time % MUSIC_INTERVAL == 0 || (mixer.isPlaying(soundtrack_portal) ||
	                                                    mixer.isPlaying(soundtrack_dungeon) && time % (30 * 3) == 0)))
	{
		// Dungeon music
	    if (blob.hasTag("dungeon"))
		{
		    changeMusic(mixer, soundtrack_dungeon, 3.0f, 3.0f);
			return;
		}
		
		// Zombie portal music
		CBlob@[] nearBlobs;
        map.getBlobsInRadius(pos, 128.0f, @nearBlobs);
		
		for (uint i = 0; i < nearBlobs.length; i++)
        {
			CBlob@ nearBlob = nearBlobs[i];
			if    (nearBlob !is null)
			{
			    if(nearBlob.getName() == "zombie_portal")
				{
				    changeMusic(mixer, soundtrack_portal, 3.0f, 3.0f);
					return;
				}
			}
		}
		
		// current season
	    u8 season = getSeason(rules);
		
		// Season Theme - Played as the sun rises on a new day
		f32 dayTime = map.getDayTime();
		if (dayTime > 0.15f && dayTime < 0.20f)
		{
			changeMusic(mixer, season == SPRING    ? soundtrack_spring_theme :
		                   	   season == AUTUMN    ? soundtrack_autumn_theme :
						   	   season == WINTER    ? soundtrack_winter_theme :
						   	   season == CHRISTMAS ? soundtrack_christmas_theme :
						                             soundtrack_summer_theme, 3.0f, 3.0f);
		}
		
		// Default
		if(!mixer.isPlaying(soundtrack_spring_theme) &&
	       !mixer.isPlaying(soundtrack_summer_theme) &&
		   !mixer.isPlaying(soundtrack_autumn_theme) &&
		   !mixer.isPlaying(soundtrack_winter_theme) &&
		   !mixer.isPlaying(soundtrack_christmas_theme))
		{
			changeMusic(mixer, season == SPRING    ? soundtrack_spring :
		                   	   season == AUTUMN    ? soundtrack_autumn :
						   	   season == WINTER    ? soundtrack_winter :
						   	   season == CHRISTMAS ? soundtrack_christmas :
						                             soundtrack_summer, 3.0f, 3.0f);
		}
	}
}

void changeAmbience(CMixer@ mixer, int nextTrack, f32 fadeoutTime, f32 fadeinTime)
{
    if (!mixer.isPlaying(nextTrack))
	{
        fadeoutAmbience(mixer, fadeoutTime);
		
		mixer.FadeInRandom(nextTrack, fadeinTime);
	}
}

void changeMusic(CMixer@ mixer, int nextTrack, f32 fadeoutTime, f32 fadeinTime)
{
    if (!mixer.isPlaying(nextTrack))
	{
        fadeoutMusic(mixer, fadeoutTime);
		
		mixer.FadeInRandom(nextTrack, fadeinTime);
	}
}

void fadeoutAmbience(CMixer@ mixer, f32 fadeoutTime)
{
    for(u32 i = ambience_start + 1; i < ambience_end; i++)
        mixer.FadeOut(i, fadeoutTime);
}

void fadeoutMusic(CMixer@ mixer, f32 fadeoutTime)
{
    for(u32 i = soundtrack_start + 1; i < soundtrack_end; i++)
        mixer.FadeOut(i, fadeoutTime);
}

void toggleAmbience(CMixer@ mixer, bool enable, f32 fadeoutTime = 3.0f)
{
    ambience_enabled = enable;
	
	if(!enable)
	{
	    fadeoutAmbience(mixer, fadeoutTime);
	}
}

void toggleMusic(CMixer@ mixer, bool enable, f32 fadeoutTime = 3.0f)
{
    music_enabled = enable;
	
	if(!enable)
	{
	    fadeoutMusic(mixer, fadeoutTime);
	}
}
