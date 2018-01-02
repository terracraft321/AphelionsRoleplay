/* 9h37mv.as
 */

#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 24;
	this.getCurrentScript().removeIfTag = "dead";
}

bool shouldPickup(CBlob@ blob)
{
    const string name = blob.getName();
	
    return name == "mat_gold" || name == "mat_stone" || name == "mat_wood" || name == "mat_flour" ||
	       name == "mat_coal" || name == "mat_iron" || name == "mat_mythril" || name == "mat_adamantite"  ||
		   name == "mat_ironbars" || name == "mat_steelbars" || name == "mat_goldbars" || name == "mat_mythrilbars" || name == "mat_adamantbars" ||
		   name == "grain";
}

void Take(CBlob@ this, CBlob@ blob)
{
	if (blob !is null && blob.getShape().vellen < 1.0f && shouldPickup(blob))
	{
        this.server_PutInInventory(blob);
    }
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			{
				Take(this, blob);
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
    Take(this, blob);
}
