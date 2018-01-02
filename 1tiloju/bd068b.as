
#include "BuildBlock.as";
#include "Requirements.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b( CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 10 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 2 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "stone_door", "$stone_door$", "Stone Door\nPlace next to walls" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 50 );
		blocks[0].push_back( b );
	} 
	{
		BuildBlock b( CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 2 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 30 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 25 );
		blocks[0].push_back( b );
	}	
	{
		BuildBlock b( 0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 50 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "stone_workshop", "$stone_workshop$", "Stone Workshop\nStand in an open space\nand tap this button." );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 100 );
		b.buildOnGround = true;
		b.size.Set( 40, 24 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 20 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "wooden_spikes", "$wooden_spikes$", "Wooden Spikes\nPlace on Wood Block\nfor Retracting Trap" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 15 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button." );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 150 );
		b.buildOnGround = true;
		b.size.Set( 40,24 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "team_platform", "$team_platform$", "Team Platform" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 30 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "triangle", "$triangle$", "Triangle Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 5 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "wooden_triangle", "$wooden_triangle$", "Wooden Triangle Block" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 5 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "large_building", "$large_building$", "Building\nStand in a wide open space\nand tap this button." );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 300 );
		b.buildOnGround = true;
		b.size.Set( 80, 48 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b( 0, "ladder", "$ladder$", "Ladder\nAnyone can climb it" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 10 );
		blocks[0].push_back( b );
	}
	
	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "sign", "$sign$", "Signpost");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "fireplace", "$fireplace$", "Fireplace");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		AddRequirement(b.reqs, "blob", "lantern", "Lantern", 1);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[1].push_back(b);
	}
}
