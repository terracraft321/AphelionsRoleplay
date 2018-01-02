/* f1i372.as
 * author: Aphelion
 *
 * Keeps the total number of blobs below a certain amount, which is just about the amount that causes the infinite loading bug.
 */
 
#define SERVER_ONLY;
 
const u32 TICK_INTERVAL = 60 * getTicksASecond();
const u16 MAX_BLOBS = 1750;
const u16 MIN_TO_DELETE = 100;

const string[] NAMES_TO_DELETE = {
"flowers",
"leaf",
"chicken",
"egg",
"fishy",
"cactus",
"firefly",
"seed",
"heart",
"bush",
};

void onTick( CRules@ this )
{
    const u32 gametime = getGameTime();
	if      ((gametime % TICK_INTERVAL) == 0)
	{
        CBlob@[]  blobs;
        getBlobs(@blobs);
	    
	    if (blobs.length >= MAX_BLOBS)
	    {
		    int    cleared = 0;
		    for(uint i = 0; i < blobs.length; i++)
		    {
		        if(cleared >= MIN_TO_DELETE)
			        break;
			
		        CBlob@ blob = blobs[i];
			    if    (blob !is null && NAMES_TO_DELETE.find(blob.getName()) != -1)
			    {
				    blob.server_Die();
					
				    cleared++;
			    }
		    }
	    }
	}
}
