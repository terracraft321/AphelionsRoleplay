/* TentLogic.as
 * author: Aphelion
 */

#include "3kemuc.as";

const int CAPTURE_SECS = 30;
const f32 CAPTURE_RADIUS = 50.0f;

void onInit( CBlob@ this )
{
	this.getSprite().SetZ(-50.0f);
	
    this.CreateRespawnPoint( "tent", Vec2f(0.0f, -4.0f) );
    this.Tag("respawn");
    
    // minimap
    this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8,8));
	this.SetMinimapRenderAlways(true);
    
    // defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	
	this.set_string("required class", "builder");

	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
	if(getNet().isServer())
	{
		const u32 gametime = getGameTime();

		//get relevant blobs
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius( this.getPosition(), CAPTURE_RADIUS, @blobsInRadius ))
		{
			Vec2f pos = this.getPosition();

			// first check if enemies nearby
			int attackersCount = 0;
			int friendlyCount = 0;
			int friendlyInProximity = 0;
			
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
			    if    (b !is this && b.hasTag("player") && !b.hasTag("dead") && b.getName() != "builder")
				{
					bool attacker = isTeamEnemy(this.getTeamNum(), b.getTeamNum());
					if  (attacker)
					{
						this.Tag("capturing");
					}

					Vec2f bpos = b.getPosition();
					if   (bpos.x > pos.x - this.getWidth() / 2.0f && bpos.x < pos.x + this.getWidth() / 2.0f &&
						  bpos.y < pos.y + this.getHeight() / 2.0f && bpos.y > pos.y - this.getHeight() / 2.0f)
					{
						if (attacker)
							attackersCount++;
						else
							friendlyCount++;
					}

					if (!attacker)
					{
						friendlyInProximity++;
					}
				}
			}

			if (attackersCount > 0 && friendlyCount == 0)
			{
				const int tickFreq = this.getCurrentScript().tickFrequency;

				s32 captureTime = this.get_s32("capture time" );
				f32 imbalanceFactor = 1.0f;

				// faster capture if no friendly around
				if (imbalanceFactor < 20.0f && friendlyInProximity == 0)
					imbalanceFactor = 2.0f;
	
				captureTime += tickFreq * Maths::Max( 1, Maths::Min( Maths::Round(Maths::Sqrt(attackersCount)), 8)) * imbalanceFactor; // the more attackers the faster
				this.set_s32("capture time", captureTime );
				
				s32 captureLimit = getCaptureLimit(this);
				if (captureTime >= captureLimit)
				{
	    	        this.set_s32("capture time", 0);
	    	        this.Untag("capturing");

					// send the "lose war" command
					CBitStream params;
					params.write_u8(this.getTeamNum());

					getRules().SendCommand(getRules().getCommandID("lose war"), params);
				}

				this.Sync("capture time", true );
				this.Sync("capturing", true );
				return;
			}
			else
			{
				if (attackersCount > 0)
				{
					return;
				}

				Reset( this );
			}
		}
		else
		{
			Reset( this );
		}

		// reduce capture if nothing going on
		s32 captureTime = this.get_s32("capture time" );
		if (captureTime > 0)
			captureTime -= this.getCurrentScript().tickFrequency;
		else
			captureTime = 0;
		
	    this.set_s32("capture time", captureTime );
	    this.Sync("capture time", true );
	    this.Sync("capturing", true );
	}
}

void Reset( CBlob@ this )
{
	this.Untag("capturing");
}

int getCaptureLimit( CBlob@ this )
{
	return CAPTURE_SECS * (float(getTicksASecond()) / float(this.getCurrentScript().tickFrequency)) * getTicksASecond();
}

bool isBeingCaptured( CBlob@ this )
{
	return this.hasTag("capturing");
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	if (isBeingCaptured(blob))
	{
		Vec2f pos2d = getDriver().getScreenPosFromWorldPos( blob.getPosition() + Vec2f(0.0f, -blob.getHeight()) );
		s32 captureLimit = getCaptureLimit(blob);
		if (getGameTime() % 20 > 4 && captureLimit > 0)
		{
			const s32 captureTime = blob.get_s32("capture time" );			
			GUI::DrawProgressBar( Vec2f(pos2d.x - 80.0f, pos2d.y + 45.0f), Vec2f(pos2d.x + 80.0f, pos2d.y + 60.0f), float(captureTime) / float(captureLimit) );
		}
	}
}
