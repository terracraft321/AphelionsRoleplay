// loads a classic KAG .PNG map
// fileName is "" on client!

#include "BasePNGLoader.as";

bool LoadMap( CMap@ map, const string& in fileName )
{
    print("LOADING PNG MAP " + fileName );
    
    PNGLoader loader();
    
    bool success = loader.loadMap(map, fileName);
	
	/*CBlob@[] coal_deposits;
	getBlobsByName("coal_deposit_s", @coal_deposits);
	getBlobsByName("coal_deposit_m", @coal_deposits);
	getBlobsByName("coal_deposit_l", @coal_deposits);
	
	printf("Placed " + coal_deposits.length + " coal deposit(s)");
	
	CBlob@[] iron_deposits;
	getBlobsByName("iron_deposit_s", @iron_deposits);
	getBlobsByName("iron_deposit_m", @iron_deposits);
	getBlobsByName("iron_deposit_l", @iron_deposits);
	
	printf("Placed " + iron_deposits.length + " iron deposit(s)");
	
	CBlob@[] mythril_deposits;
	getBlobsByName("mythril_deposit_s", @mythril_deposits);
	getBlobsByName("mythril_deposit_m", @mythril_deposits);
	getBlobsByName("mythril_deposit_l", @mythril_deposits);
	
	printf("Placed " + mythril_deposits.length + " mythril deposit(s)");
	
	CBlob@[] adamantite_deposits;
	getBlobsByName("adamantite_deposit_s", @adamantite_deposits);
	getBlobsByName("adamantite_deposit_m", @adamantite_deposits);
	getBlobsByName("adamantite_deposit_l", @adamantite_deposits);
	
	printf("Placed " + adamantite_deposits.length + " adamantite deposit(s)");*/
	
	return success;
}
