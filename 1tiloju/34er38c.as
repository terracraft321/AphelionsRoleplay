
#include "BuildBlock.as"
#include "bd068b.as"

#include "WARCosts.as"
//should really make ctf costs at some point.. :)

void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
	if (blob !is null && player !is null && blob.getName() == "builder") 
	{
		BuildBlock[] blocks;
		
		addCommonBuilderBlocks( blocks );

		blob.set( blocks_property, blocks );
	}
}
