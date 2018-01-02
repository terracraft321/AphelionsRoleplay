/* Editor.as
 * author: Aphelion
 */
 
#include "1q3fbmh.as";
#include "i3dan2.as";

#include "BuildBlock.as";
#include "Hitters.as";

const string cmd_place = "editor place";
const string cmd_remove = "editor remove";
const string cmd_copy = "editor copy";
 
void onInit( CRules@ this )
{
    this.addCommandID(cmd_place);
    this.addCommandID(cmd_remove);
    this.addCommandID(cmd_copy);
}

void onTick( CRules@ this )
{
    if(getNet().isClient())
	{
		CPlayer@ p = getLocalPlayer();
		if      (p !is null && p.getBlob() !is null && p.getBlob().hasTag("editor"))
		{
        	if (getControls().isKeyPressed(KEY_KEY_Z))
        	{
			    CBitStream params;
	            params.write_u16(p.getNetworkID());
				
	            this.SendCommand(this.getCommandID(cmd_place), params);
        	}
			else if (getControls().isKeyPressed(KEY_KEY_X))
        	{
			    CBitStream params;
	            params.write_u16(p.getNetworkID());
				
	            this.SendCommand(this.getCommandID(cmd_remove), params);
			}
			else if (getControls().isKeyPressed(KEY_KEY_V))
			{
			    CBitStream params;
	            params.write_u16(p.getNetworkID());
				
	            this.SendCommand(this.getCommandID(cmd_copy), params);
			}
		}
    }
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
    if(!getNet().isServer()) return;

    if (cmd == this.getCommandID(cmd_place))
	{
	    CPlayer@ player = ResolvePlayer(params);
		
		if (MayUseEditor(player))
		{
		    CBlob@ blob = player.getBlob();
			if    (blob !is null)
			{
			    Vec2f cursorPos = blob.getAimPos();
				
				bool buildMenu = blob.getName() == "builder" && !blob.hasTag("editor_menu_off");
				
				u16 tile = blob.get_TileType( buildMenu ? "buildtile" : "editor_tile" );
			    if (tile != 0)
				{
		            getMap().server_SetTile( cursorPos, tile );
					return;
				}
				
				if (buildMenu)
				{
				    u8 buildBlob = blob.get_u8( "buildblob" );
					
					BuildBlock[]@ blocks;
					if (blob.get( "blocks", @blocks ) && buildBlob < blocks.length)
					{
						BuildBlock block = blocks[buildBlob];
							
						if (canPlaceBlobAtPos(cursorPos))
						{
			               	CBlob@ blockBlob = server_CreateBlob(block.name, blob.getTeamNum(), cursorPos);
							if    (blockBlob !is null)
							{
								SnapToGrid(blockBlob, cursorPos);
								if (blockBlob.isSnapToGrid())
								{
							    	CShape@ shape = blockBlob.getShape();
									shape.SetStatic(true);
								}
							}
						}
						return;
					}
				}
				else
				{
				    string editorBlob = blob.get_string( "editor_blob" );
					
					if (canPlaceBlobAtPos(cursorPos))
					{
						CBlob@ blockBlob = server_CreateBlob(editorBlob, blob.getTeamNum(), cursorPos);
						if    (blockBlob !is null)
						{
							SnapToGrid(blockBlob, cursorPos);
							if (blockBlob.isSnapToGrid())
							{
								CShape@ shape = blockBlob.getShape();
								shape.SetStatic(true);
							}
						}
					}
					return;
				}
				
				// default
				getMap().server_SetTile( cursorPos, CMap::tile_castle );
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_remove))
	{
	    CPlayer@ player = ResolvePlayer(params);
		
		if (MayUseEditor(player))
		{
		    CBlob@ blob = player.getBlob();
			if    (blob !is null)
			{
			    Vec2f cursorPos = blob.getAimPos();
				
            	// destroy tile
            	getMap().server_DestroyTile( cursorPos, 10.0f );
				
            	// destroy blob
				CBlob@ behindBlob = getMap().getBlobAtPosition( cursorPos );
				if    (behindBlob !is null && behindBlob !is blob)
				{
				    string name = behindBlob.getName();
					if   ((name != "tent" && name != "base" && name != "dungeon_entrance" && name != "dungeon_exit" && name != "chest_dungeon" &&
					       name != "chest_noom" && name != "noom" && !behindBlob.hasTag("player")) || player.getUsername() == "Aphelion")
					{
				        blob.server_Hit(behindBlob, behindBlob.getPosition(), Vec2f(0, -700), 30.0f, Hitters::cata_boulder, true);
						
						behindBlob.server_Die();
					}
			    }
			}
		}
	}
	else if (cmd == this.getCommandID(cmd_copy))
	{
	    CPlayer@ player = ResolvePlayer(params);
		
		if (MayUseEditor(player))
		{
		    CBlob@ blob = player.getBlob();
			if    (blob !is null)
			{
			    ResetEditorData(blob);
				
				blob.set_TileType( "editor_tile", getMap().getTile( blob.getAimPos() ).type );
				blob.Tag("editor_menu_off");
		    }
		}
	}
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	string[]@ args = text_in.split(" ");
	if       (args[0] == "/editor" && MayUseEditor(player))
	{
	    CBlob@ blob = player.getBlob();
		if    (blob !is null)
		{
		    if(args[1] == "on")
			{
			    ResetEditorData(blob);
				
				blob.Tag("editor");
				blob.Sync("editor", true);
			}
			else if(args[1] == "off")
			{
			    ResetEditorData(blob);
				
				blob.Untag("editor");
				blob.Sync("editor", true);
			}
			
			if(blob.hasTag("editor"))
			{
				if(args[1] == "setblob" && player.getUsername() == "Aphelion")
				{
			        ResetEditorData(blob);
				    
			    	blob.set_string("editor_blob", args[2]);
					blob.Tag("editor_menu_off");
				}
				else if(args[1] == "settile")
				{
			        ResetEditorData(blob);
					
				    if (args[2] == "ground")
						blob.set_TileType("editor_tile", CMap::tile_ground);
			    	else if (args[2] == "ground_back")
						blob.set_TileType("editor_tile", CMap::tile_ground_back);
			    	else if (args[2] == "grass")
						blob.set_TileType("editor_tile", CMap::tile_grass);
			    	else if (args[2] == "castle")
						blob.set_TileType("editor_tile", CMap::tile_castle);
			    	else if (args[2] == "castle_moss")
						blob.set_TileType("editor_tile", CMap::tile_castle_moss);
			    	else if (args[2] == "castle_back")
						blob.set_TileType("editor_tile", CMap::tile_castle_back);
			    	else if (args[2] == "castle_back_moss")
						blob.set_TileType("editor_tile", CMap::tile_castle_back_moss);
			    	else if (args[2] == "gold")
						blob.set_TileType("editor_tile", CMap::tile_gold);
			    	else if (args[2] == "stone")
						blob.set_TileType("editor_tile", CMap::tile_stone);
			    	else if (args[2] == "thickstone")
						blob.set_TileType("editor_tile", CMap::tile_thickstone);
			    	else if (args[2] == "bedrock")
						blob.set_TileType("editor_tile", CMap::tile_bedrock);
			    	else if (args[2] == "wood")
						blob.set_TileType("editor_tile", CMap::tile_wood);
			    	else if (args[2] == "wood_back")
						blob.set_TileType("editor_tile", CMap::tile_wood_back);
					
					blob.Tag("editor_menu_off");
				}
			}
		}
	}
    return true;
}

// -- OPTIONAL DEBUG MESSAGES
bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	string[]@ args = text_in.split(" ");
	if       (args[0] == "/editor" && MayUseEditor(player) && player is getLocalPlayer())
	{
	    CBlob@ blob = player.getBlob();
		if    (blob !is null)
		{
		    if(args[1] == "on")
			    client_AddToChat("EDITOR: Enabled", SColor(255, 255, 0, 0));
			else if(args[1] == "off")
			    client_AddToChat("EDITOR: Disabled", SColor(255, 255, 0, 0));
			
			if(blob.hasTag("editor"))
			{
				if(args[1] == "setblob" && player.getUsername() == "Aphelion")
				{
			        client_AddToChat("EDITOR: Blob set to " + args[2], SColor(255, 255, 0, 0));
				}
				else if(args[1] == "settile")
				{
			    	if (args[2] == "ground" ||
			    		args[2] == "ground_back" ||
			    		args[2] == "grass" ||
			    		args[2] == "castle" ||
			    		args[2] == "castle_moss" ||
			    		args[2] == "castle_back" ||
			    		args[2] == "castle_back_moss" ||
			    		args[2] == "gold" ||
			    		args[2] == "stone" ||
			    		args[2] == "thickstone" ||
			    		args[2] == "bedrock" ||
			    		args[2] == "wood" ||
			    		args[2] == "wood_back")
			            client_AddToChat("EDITOR: Tile set to " + args[2], SColor(255, 255, 0, 0));
				    else
			            client_AddToChat("EDITOR: Specified tile does not exist", SColor(255, 255, 0, 0));
				}
			}
		}
	}
    return true;
}
