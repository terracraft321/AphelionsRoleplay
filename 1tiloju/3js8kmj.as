/* 3js8kmj.as
 * modified by: Aphelion
 */

#include "ProductionCommon.as";

CBlob@ server_MakeSeed( Vec2f atpos, string blobname )
{
    if (blobname == "tree_redwood")
        return server_MakeSeed( atpos, blobname, 10 * 30, 3, 8 );  // not actual growth duration, just seed init
    else if (blobname == "tree_pine")
        return server_MakeSeed( atpos, blobname, 10 * 30, 2, 8 );
    else if (blobname == "tree_bushy")
        return server_MakeSeed( atpos, blobname, 10 * 30, 1, 8 );
    else if (blobname == "grain_plant")
        return server_MakeSeed( atpos, blobname, 3 * 30, 4, 4 );
    else if (blobname == "flowers")
        return server_MakeSeed( atpos, blobname, 15 * 30, 5, 4 );
    else if (blobname == "bush")
        return server_MakeSeed( atpos, blobname, 15 * 30, 6, 4 );
    else if (blobname == "cactus")
        return server_MakeSeed( atpos, blobname, 15 * 30, 7, 4 );
    else
        return server_MakeSeed( atpos, blobname, 10 * 30, 0, 8 );
}

CBlob@ server_MakeSeed( Vec2f atpos, string blobname, u16 growtime )
{
    return server_MakeSeed(atpos, blobname, growtime, 0);
}

CBlob@ server_MakeSeed( Vec2f atpos, string blobname, u16 growtime, u8 spriteIndex )
{
    return server_MakeSeed(atpos, blobname, growtime, spriteIndex, 4);
}

CBlob@ server_MakeSeed( Vec2f atpos, string blobname, u16 growtime, u8 spriteIndex, u8 created_blob_radius )
{
    if (!getNet().isServer()) { return null; }

    CBlob@ seed = server_CreateBlobNoInit( "seed" );

    if (seed !is null)
    {
        seed.setPosition( atpos );
        seed.set_string("seed_grow_blobname", blobname);
        seed.set_u16("seed_grow_time", growtime);
        seed.set_u8("sprite index", spriteIndex);
        seed.set_u8("created_blob_radius", created_blob_radius);
		seed.Init();
    }

    return seed;
}

ShopItem@ addSeedItem( CBlob@ this, const string &in seedName,
	const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	const string newIcon = "$" + seedName + "$";
	ShopItem@ item = addProductionItem( this, seedName, newIcon, "seed", description, timeToMakeSecs, false, quantityLimit, requirements );
	return item;
}
