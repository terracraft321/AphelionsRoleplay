/* 1028jcn.as
 * author: Aphelion
 * 
 * Spoof central.
 */

#include "3jt3pus.as";

const string spoofing_prop = " spoofing";
const string spoofed_prop = " spoofed player";

void SetSpoofing( CRules@ this, CPlayer@ player, bool spoofing, string otherPlayerName = "")
{
	if (player is null || player.getBlob() is null) return;

	CBlob@ playerBlob = player.getBlob();

	string username = player.getUsername();

	this.set_bool(username + spoofing_prop, spoofing);
	this.set_string(username + spoofed_prop, otherPlayerName);

	RefreshBlob(playerBlob);
}

void RefreshBlob( CBlob@ blob )
{
    CBlob@ newBlob = server_CreateBlob(blob.getName(), blob.getTeamNum(), blob.getPosition());
    if    (newBlob !is null)
    {
        blob.MoveInventoryTo(newBlob);
        
        // set health to be same ratio
        float healthratio = blob.getHealth() / blob.getInitialHealth();
        newBlob.server_SetHealth( newBlob.getInitialHealth() * healthratio );
		
		// transfer equipment data
		transferEquipmentData(blob, newBlob);
		
        // plug the soul
		newBlob.Tag("equipment swap");
        newBlob.server_SetPlayer(blob.getPlayer());
        newBlob.setPosition(blob.getPosition());
		
        // no extra immunity after class change
        if(blob.exists("spawn immunity time"))
        {
            newBlob.set_u32("spawn immunity time", blob.get_u32("spawn immunity time"));
            newBlob.Sync("spawn immunity time", true);
        }
        
        blob.Tag("switch class");
        blob.server_SetPlayer( null );
        blob.server_Die();
    }
}

bool isSpoofing( CRules@ this, CPlayer@ player )
{
	if(player is null)
	    return false;
	else
	    return this.get_bool(player.getUsername() + spoofing_prop);
}

string getSpoofedPlayer( CRules@ this, CPlayer@ player )
{
	if(player is null)
	    return "";
	else    
	    return this.get_string(player.getUsername() + spoofed_prop);
}
