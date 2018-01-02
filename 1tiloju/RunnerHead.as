// RunnerHead.as
// Custom head loading functionality by Skinney

#include "2efidcr.as";
#include "upmpi5.as";
#include "3eao5se.as";

#include "1028jcn.as";
#include "3jt3pus.as";
#include "Requirements.as";

const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;

const string default_path = "Entities/Characters/Sprites/Heads.png";
const string blowjob_path = "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/Heads_013/";
const int blowjob_size = 1024;

int getCustomHeadFrame( CBlob@ blob )
{
    CPlayer@ player = blob.getPlayer();
	if      (player !is null)
	{
	    string username = player.getUsername();
	    
		if(isSpoofing(getRules(), player))
			username = getSpoofedPlayer(getRules(), player);
		
		if (username == "Aphelion")
			return 0;
		else if(username == "Sohkyo")
		    return 4;
		else if(username == "MadRaccoon")
		    return 8;
		else if(username == "troller111")
		    return 12;
		else if(username == "PalladiumGirl")
		    return 16;
		else if(username == "Alpha-Penguin")
		    return 20;
		else if(username == "pmattep99")
		    return 24;
	}
	return -1;
}

int getHeadFrame( CBlob@ blob, int headIndex )
{
	if(headIndex < NUM_UNIQUEHEADS)
		return headIndex * NUM_HEADFRAMES;
	
	if (headIndex == 255 || headIndex == NUM_UNIQUEHEADS)
	{
		bool special = false;

		u32 month = Time_Month();
		u32 day = Time_MonthDate();
		
		int teamNum = blob.getTeamNum();

		if(month == 12) //xmas
		{
			special = true;
			headIndex = NUM_UNIQUEHEADS + 61; //xmas hat
		}
		else if(month == 10 && day >= 30 ||
				month == 11 && day == 1) //halloween
		{
			special = true;
			headIndex = NUM_UNIQUEHEADS + 43; //pumpkin
		}
		
		if(!special) //every other day of the week
		{
			string config = blob.getConfig();
			if    (config == "builder")
			{
				headIndex = NUM_UNIQUEHEADS;
			}
			else if (config == "knight")
			{
				headIndex = NUM_UNIQUEHEADS + 1;
			}
			else if (config == "archer")
			{
			    if (teamNum == 5)
				    headIndex = NUM_UNIQUEHEADS + 44;
				else 
				    headIndex = NUM_UNIQUEHEADS + 2;
			}
			else if (config == "migrant")
			{
				Random _r(blob.getNetworkID());
				headIndex = 69 + _r.NextRanged(2); //head scarf or old
			}
			else //default to pleb head
			{
				headIndex = NUM_UNIQUEHEADS;
			}
		}
	}
	return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) + (blob.getSexNum() == 0 ? 0 : 1)) * NUM_HEADFRAMES;
}

string getSpritePath( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	if    (blob is null) return "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/HumanHeads.png";
	
	if (getEquipmentSlotItem(blob, SLOT_ARMOUR) == "dragon_chestplate")
	{
		return "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/DragonHelmet.png";
	}
	
	CPlayer@ player = blob.getPlayer();
	
	if (!blob.hasTag("head disabled") && player !is null)
	{
		int frame = getCustomHeadFrame(blob);
		if (frame != -1)
		{
			return blob.getTeamNum() == RACE_DWARVES ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomDwarfHeads.png" :
				   blob.getTeamNum() == RACE_ELVES   ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomElfHeads.png" :
				   blob.getTeamNum() == RACE_ORCS    ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomOrcHeads.png" :
				   blob.getTeamNum() == RACE_UNDEAD  ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomUndeadHeads.png" :
														"../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomHumanHeads.png";
		}
		else if (player.getTeamNum() != RACE_UNDEAD) // no blowjob with undead
		{
			string sprite_name = isSpoofing(getRules(), player) ? getSpoofedPlayer(getRules(), player) : player.getUsername();
			
			CFileImage@ image = CFileImage(blowjob_path + sprite_name + ".png");
			if         (image.getSizeInPixels() == blowjob_size)
			{
				return blowjob_path + sprite_name + ".png";
			}
		}
	}
	return blob.getTeamNum() == RACE_DWARVES ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/DwarfHeads.png" :
		   blob.getTeamNum() == RACE_ELVES   ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/ElfHeads.png" :
		   blob.getTeamNum() == RACE_ORCS    ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/OrcHeads.png" :
		   blob.getTeamNum() == RACE_UNDEAD  ?  "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/UndeadHeads.png" :
												"../Mods/" + RP_NAME + "/Entities/Characters/Sprites/HumanHeads.png";
}

CSpriteLayer@ LoadHead( CSprite@ this, u8 headIndex )
{
	this.RemoveSpriteLayer("head");

	CBlob@ blob = this.getBlob();
	if    (blob !is null)
	{
		string path = getSpritePath(this);
		if    (path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomDwarfHeads.png" ||
			   path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomElfHeads.png" ||
			   path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomOrcHeads.png" ||
			   path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomUndeadHeads.png" ||
			   path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/CustomHumanHeads.png")
		{
		    blob.set_s32("head_frame", getCustomHeadFrame(blob));
		}
		else if(path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/HumanHeads.png" || 
				path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/DwarfHeads.png" ||
				path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/ElfHeads.png" || 
				path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/OrcHeads.png" ||
				path == "../Mods/" + RP_NAME + "/Entities/Characters/Sprites/UndeadHeads.png")
		{
			blob.set_s32("head_frame", getHeadFrame(blob, headIndex));
		}
		else
		{
		    blob.set_s32("head_frame", 0);
		}
		blob.set_string("sprite_path", path);
		
		CSpriteLayer@ head = this.addSpriteLayer("head", path, 16, 16, blob.getTeamNum(), blob.getSkinNum());
		if           (head !is null)
		{
			s32 head_frame = blob.get_s32("head_frame");
			Animation@ anim = head.addAnimation("default", 0, false);
			anim.AddFrame(head_frame);
			anim.AddFrame(head_frame + 1);
			anim.AddFrame(head_frame + 2);
			head.SetAnimation(anim);
			head.SetFacingLeft(blob.isFacingLeft());
		}
		return head;
	}
	return null;
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	if    (blob !is null)
	{
		int frame = blob.get_s32("head_frame");
		int frameX = (frame % FRAMES_WIDTH) + 2;
		int frameY = frame / FRAMES_WIDTH;
		Vec2f pos = blob.getPosition();
		Vec2f vel = blob.getVelocity();
		f32 hp = Maths::Min(Maths::Abs(blob.getHealth()),2.0f) + 1.5;
		makeGibParticle(blob.get_string("sprite_path"), pos, vel + getRandomVelocity(90, hp, 30), frameX, frameY, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", blob.getTeamNum());
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if    (blob !is null)
	{
		ScriptData@ script = this.getCurrentScript();
		if (script !is null)
		{
			if (blob.getShape().isStatic())
			{
				script.tickFrequency = 60;
			}
			else
			{
				script.tickFrequency = 1;
			}
		}
	}
	
	CSpriteLayer@ head = this.getSpriteLayer("head");
	if (head is null && (blob.getPlayer() !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3))
	{
		@head = LoadHead(this, blob.getHeadNum());
	}
	
	if (getGameTime() % 45 == 0 && (blob.get_string("sprite_path") != getSpritePath(this)))
	{
		@head = LoadHead(this, blob.getHeadNum());
	}
	
	if (head !is null)
	{
		PixelOffset@ po = getDriver().getPixelOffset(this.getFilename(), this.getFrame());
		if (po !is null)
		{
			if (po.level == 0)
			{
				head.SetVisible(false);
			}
			else
			{
				head.SetVisible(this.isVisible());
				head.SetRelativeZ(po.level * 0.25f);
			}
			
			Vec2f headoffset(this.getFrameWidth()/2, -this.getFrameHeight()/2);
			headoffset += this.getOffset();
			headoffset += Vec2f(-po.x, po.y);
			headoffset += Vec2f(0, -2);
			head.SetOffset(headoffset);
			
			if (blob.hasTag("dead") || blob.hasTag("dead head"))
			{
				head.animation.frame = 2;
			}
			else if (blob.hasTag("attack head"))
			{
				head.animation.frame = 1;
			}
			else
			{
				head.animation.frame = 0;
			}
		}
		else
		{
			head.SetVisible(false);
		}
	}
}
