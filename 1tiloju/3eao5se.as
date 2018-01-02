/* 3eao5se.as
 * author: Aphelion
 */

const int RACE_HUMANS = 0;
const int RACE_DWARVES = 1;
const int RACE_ELVES = 2;
const int RACE_ORCS = 3;
const int RACE_ANGELS = 4;
const int RACE_UNDEAD = 5;

bool raceIs(CBlob@ blob, int race)
{
    return blob !is null && blob.getTeamNum() == race;
}
