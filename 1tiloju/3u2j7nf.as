const u32 VANISH_BODY_SECS = 20;

void onInit( CBlob@ this )
{
	this.set_f32("hit dmg modifier", 0.0f);
	this.set_f32("hit dmg modifier", 0.0f);
	this.getCurrentScript().tickFrequency = 0; // make it not run ticks until dead
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    // make dead state
    // make sure this script is at the end of onHit scripts for it gets the final health
    if (this.getHealth() <= 0.0f && !this.hasTag("dead"))
    {
        this.Tag("dead");
        this.set_u32( "death time", getGameTime() );
        
        this.set_f32("hit dmg modifier", 0.1f);
		this.set_f32("hit dmg modifier", 0.1f);

        // add pickup attachment so we can pickup body
        CAttachment@ a = this.getAttachments();

        if (a !is null)
        {
            AttachmentPoint@ ap = a.AddAttachmentPoint( "PICKUP", false );
        }
		
		this.getCurrentScript().tickFrequency = 30;

        this.set_f32("hit dmg modifier", 0.5f);

		// new physics vars so bodies don't slide
		this.getShape().setFriction( 0.75f );
		this.getShape().setElasticity( 0.2f );

        // disable tags
        this.getShape().getVars().isladder = false;
		this.getShape().getVars().onladder = false;
		this.getShape().checkCollisionsAgain = true;
        this.getShape().SetGravityScale( 1.0f );
		
        // fall out of attachments/seats // drop all held things
        this.server_DetachAll();
    }
	else
	{
	    this.set_u32( "death time", getGameTime() );
	}
    return damage;
}


// erase all items before vanishing

void onTick( CBlob@ this )
{
	if (this.get_u32( "death time" ) + VANISH_BODY_SECS * getTicksASecond() < getGameTime() )
	{
		// destroy what was in inv

		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob @blob = inv.getItem(i);	
				blob.server_Die();
			}
		}

		// zambie revival
		if(this.getName() == "zombie")
			server_CreateBlob("zombie", -1, this.getPosition());
		else if(this.getName() == "zombie_knight")
			server_CreateBlob("zombie_knight", -1, this.getPosition());
		else if(this.getName() == "hell_knight")
			server_CreateBlob("hell_knight", -1, this.getPosition());

		// vanish ourselves
		this.server_Die();
	}
}
				   
// reset vanish counter on pickup

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{  
	this.set_u32( "death time", getGameTime() );
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return (this.hasTag("dead") && this.getInventory().getItemsCount() > 0 );
}
