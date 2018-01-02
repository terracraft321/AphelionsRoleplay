#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "FireCommon.as"
#include "Help.as"

void onInit( CBlob@ this )
{
	this.getCurrentScript().removeIfTag = "dead";
	this.Tag("medium weight");
	
	//default player minimap dot - not for migrants
	if(this.getName() != "migrant")
	{
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8,8));
	}
	
	this.set_s16( burn_duration , 130 );

	setKnockable( this );
	
	if (this.getTeamNum() == 5)
	{
	    this.AddScript("/gsa4na.as");
	}
}

void onTick( CBlob@ this )
{
    DoKnockedUpdate(this);
}

// pick up efffects
// something was picked up

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
    this.getSprite().PlaySound( "/PutInInventory.ogg" );
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    this.getSprite().PlaySound( "/Pickup.ogg" );

	if (getNet().isClient())
	{
		RemoveHelps( this, "help throw" );

		if (!attached.hasTag("activated"))
			SetHelp( this, "help throw", "", "$"+attached.getName()+"$"+"Throw    $KEY_C$", "", 2 );
	}

    // check if we picked a player - don't just take him out of the box
    /*if (attached.hasTag("player"))
    this.server_DetachFrom( attached ); CRASHES*/
}

// set the Z back
void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.getSprite().SetZ(0.0f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    CPlayer@ player = byBlob.getPlayer();
	if      (player !is null)
	{
	    string name = player.getUsername();
		if    (name == "Aphelion" || name == "pmattep99" || name == "kaggit" || name == "yamin" || name == "stabborazz" || name == "MadRaccoon" || name == "Sohkyo" || name == "Duke_Jordan" || name == "zhuum")
		    return true;
	}
	return this.hasTag("migrant") || this.hasTag("dead");
}
