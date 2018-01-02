/* i3dan2.as
 * author: Aphelion
 */

CPlayer@ ResolvePlayer( CBitStream@ data )
{
    u16 playerNetID;
	if(!data.saferead_u16(playerNetID)) return null;
	
	return getPlayerByNetworkId(playerNetID);
}

void ResetEditorData( CBlob@ blob )
{
	blob.set_string("editor_blob", "");
    blob.set_TileType("editor_tile", 0);
}

/*
void ResetBuildMenu( CBlob@ blob, bool editorOn )
{
	BuildBlock[] blocks;
	{
		addCommonBuilderBlocks( blocks );
		if(editorOn) addEditorBlocks( blob, blocks );
		
		blob.set( blocks_property, blocks );
	}
}*/

bool canPlaceBlobAtPos( Vec2f pos )
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	
	  @_tempBlob = getMap().getBlobAtPosition( pos );
	if(_tempBlob !is null && _tempBlob.isCollidable())
	{
		  @_tempShape = _tempBlob.getShape();
		if(_tempShape.isStatic())
		    return false;
	}
	return true;
}

void SnapToGrid( CBlob@ blob, Vec2f pos )
{
	pos = getMap().getTileWorldPosition(getMap().getTileSpacePosition(pos));
	pos.x += blob.getWidth() / 2;
	pos.y += blob.getHeight() / 2;
	
	blob.setPosition(pos);
}
