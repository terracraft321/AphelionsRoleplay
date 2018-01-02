
#define SERVER_ONLY

void onInit( CBlob@ this )
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
    if (blob is null || blob.getShape().vellen > 1.0f)
        return;

    string name = blob.getName();
    if    (name == "mat_energyrunes" || name == "mat_miasmarunes" || name == "mat_lightningrunes" || name == "mat_bombrunes")
    {
		this.server_PutInInventory( blob );
    }
}
