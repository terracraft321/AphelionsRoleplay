// LogsOnDeath.as
//
// Modified for the King Arthur's Gold Mod, ADVENTURE by Aphelion
// -------------------------------------------------

#include "TreeCommon.as";

void onDie(CBlob@ this)
{
    Vec2f pos = this.getPosition();
    f32 fall_angle = 0.0f;

    if (this.exists("tree_fall_angle"))
	{
        fall_angle = this.get_f32("tree_fall_angle");
    }
	
    TreeSegment[]@ segments;
    this.get("TreeSegments", @segments);
	
	if (segments is null)
		return;
	
    for (float i = 0; i < segments.length; i++)
    {
        TreeSegment@ segment = segments[i];
		
        if (getNet().isServer())
        {
            pos = this.getPosition() + (segment.start_pos + segment.end_pos) / 2.0f;
            pos.y -= 4.0f;
			
            CBlob@ log = server_CreateBlob("log", this.getTeamNum(), pos);
			if (log !is null)
			{
				log.setAngleDegrees(fall_angle);
			}
        }
    }
    Sound::Play("Sounds/branches"+ (XORRandom(2) + 1) + ".ogg", this.getPosition());
}
