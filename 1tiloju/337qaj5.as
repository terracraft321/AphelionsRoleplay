/* 337qaj5.as
 * author: Aphelion
 *
 * Script for ambient Bird sounds emitted by Trees.
 */

#define CLIENT_ONLY;

#include "TreeCommon.as";

const string[] sounds = {
	"Wind",
	"Wind",
	"Birds/Chickadee1",
	"Birds/Chickadee2",
	"Birds/Hawk",
	"Birds/Meadowlark",
	"Birds/Mockingbird1",
	"Birds/Mockingbird2",
	"Birds/Sparrow1",
	"Birds/Sparrow2",
	"Birds/Warbler1",
	"Birds/Warbler2",
	"Birds/Woodpecker",
	"Birds/Wren1",
	"Birds/Wren2",
	"Birds/Yellowthroat1"
};

void onInit( CBlob@ this )
{
	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
	const u32 gametime = getGameTime();
	const bool day = getMap().getDayTime() >= 0.15f && getMap().getDayTime() <= 0.85f;

	if(XORRandom(2048) < (day ? 10 : 3))
	{
        TreeVars@ vars;
        this.get("TreeVars", @vars);

        if (vars.height == vars.max_height)
        {
			this.getSprite().PlaySound("../Mods/Roleplay_Music/Sounds/Ambience/" + sounds[XORRandom(sounds.length)] + ".ogg", 0.5f);
        }
	}
}
