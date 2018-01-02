// Draw an emoticon

enum PlantBubbles {
	off,
	bubble_1,
	bubble_2,
	need_water,
	bubble_3,
	total
}

void onInit( CBlob@ blob )
{
	CSprite@ sprite = blob.getSprite();
    blob.set_u8("bubble", PlantBubbles::off);

    //init bubble layer
    CSpriteLayer@ bubble = sprite.addSpriteLayer( "bubble", "Entities/Natural/Farming/Seed/SeedBubble.png", 32, 32, 0, 0 );

    if (bubble !is null)
    {
        bubble.SetOffset(Vec2f(0, -sprite.getBlob().getRadius() * 1.5f - 16));
        bubble.SetRelativeZ(100.0f);
        {
            Animation@ anim = bubble.addAnimation( "default", 0, true );

            for (int i = 0; i < PlantBubbles::total; i++)
                anim.AddFrame(i);
        }
        bubble.SetVisible( false );
        bubble.SetHUD( true );
    }
}

void onTick( CBlob@ blob )
{
	CSprite@ sprite = blob.getSprite();

	CSpriteLayer@ bubble = sprite.getSpriteLayer( "bubble");
	if(           bubble !is null)
	{
		const u8 index = blob.get_u8("bubble");
		if      (index != PlantBubbles::off && !blob.hasTag("dead"))
			bubble.SetVisible( true );
		else
			bubble.SetVisible( false );
	}
}
