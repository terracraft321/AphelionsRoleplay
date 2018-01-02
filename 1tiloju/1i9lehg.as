/* 1i9lehg.as
 * author: Aphelion
 */

#include "38el49l.as";
#include "30j68o4.as";

void onInit( CBlob@ this )
{
    if (this.getTeamNum() == 5)
	{
		this.addCommandID("teleport");
		this.addCommandID("teleport none");
		this.addCommandID("teleport to");
		this.addCommandID("server teleport to");
		this.Tag("portal");
		
		AddIconToken("$TRAVEL_NOOM$", "GUI/ClassIcons.png", Vec2f(32, 32), 4);
		AddIconToken("$TRAVEL_BASE$", "GUI/MenuItems.png", Vec2f(32, 32), 31);
		AddIconToken("$TRAVEL_LEFT$", "GUI/MenuItems.png", Vec2f(32, 32), 23 );
		AddIconToken("$TRAVEL_RIGHT$", "GUI/MenuItems.png", Vec2f(32, 32), 22);
		
		if (!this.exists("teleport button pos" ))
			 this.set_Vec2f("teleport button pos", Vec2f_zero );
	}
	else
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (this.getTeamNum() == caller.getTeamNum())
	{
		MakeTravelButton(this, caller, this.get_Vec2f("teleport button pos"), "Teleport", "Teleport");
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	onTunnelCommand( this, cmd, params );
}

// get all team tunnels sorted by team distance 
bool getTunnelsForButtons( CBlob@ this, CBlob@[]@ tunnels )
{
	CBlob@[] list;
	getBlobsByTag("portal", @list);
	
	Vec2f thisPos = this.getPosition();
	
	// add left tunnels
	for (uint i=0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x < thisPos.x)
		{
			bool added = false;	   		
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = 0; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];	   
				if ( (tunnel.getPosition() - thisPos).getLength() < distToBlob )
				{
					tunnels.insert( tunnelInd, blob );
					added = true;
					break;
				}
			}		
				
			if (!added)
				tunnels.push_back( blob );
		}
	}

	tunnels.push_back( null );	// add you are here

	// add right tunnels
	const uint tunnelIndStart = tunnels.length;

	for (uint i = 0; i < list.length; i++)
	{
		CBlob@ blob = list[i];
		if (blob !is this && blob.getTeamNum() == this.getTeamNum() && blob.getPosition().x >= thisPos.x)
		{
			bool added = false;	  			
			const f32 distToBlob = (blob.getPosition() - thisPos).getLength();
			for (uint tunnelInd = tunnelIndStart; tunnelInd < tunnels.length; tunnelInd++)
			{
				CBlob@ tunnel = tunnels[tunnelInd];	   
				if ( (tunnel.getPosition() - thisPos).getLength() > distToBlob )
				{
					tunnels.insert( tunnelInd, blob );
					added = true;
					break;
				}	 
			}
			if (!added)
				tunnels.push_back( blob );
		}
	}	
	
	return tunnels.length > 0;
}

bool isInRadius( CBlob@ this, CBlob @caller )
{
	return ((this.getPosition() - caller.getPosition()).Length() < this.getRadius() * 2.00f + caller.getRadius());
}

CButton@ MakeTravelButton( CBlob@ this, CBlob@ caller, Vec2f buttonPos, const string &in label, const string &in cantTravelLabel )
{
	CBlob@[] tunnels;
	const bool gotTunnels = getTunnels( this, @tunnels);
	const bool teleportAvailable = gotTunnels && isInRadius( this, caller );
	if (!teleportAvailable)
		return null;
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	CButton@ button = caller.CreateGenericButton( 8, buttonPos, this, this.getCommandID("teleport"), gotTunnels ? label : cantTravelLabel, params );
	if (button !is null) {
		button.SetEnabled( teleportAvailable );
	}
	return button;
}

bool doesFitAtTunnel( CBlob@ this, CBlob@ caller, CBlob@ tunnel )
{
	return true;
}

void Travel( CBlob@ this, CBlob@ caller, CBlob@ tunnel )
{
	if (caller !is null && tunnel !is null)
	{
	    if (caller.getName() == "builder" && tunnel.getName() == "mini_portal")
		{
		    sendMessage(caller.getPlayer(), "Noom does not permit builders to enter his dungeon.");
			return;
		}
	    
		if (caller.isAttached())   // attached - like sitting in cata? move whole cata
		{
			const int count = caller.getAttachmentPointCount();	  
			for (int i = 0; i < count; i++)
			{
				AttachmentPoint@ ap = caller.getAttachmentPoint(i);	   
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob !is null)
				{
					occBlob.setPosition( tunnel.getPosition() );
					occBlob.setVelocity( Vec2f_zero );					
					occBlob.getShape().PutOnGround();
				}
			}
		}
		
		// move caller
		caller.setPosition( tunnel.getPosition() );
		caller.setVelocity( Vec2f_zero );
		caller.getShape().PutOnGround();
		
		// tag/untag dungeon thingy
		if (tunnel.getName() == "mini_portal")
		    caller.Tag("dungeon");
		else
		    caller.Untag("dungeon");
		
		caller.Sync("dungeon", true);

		ParticleZombieLightning(this.getPosition());
		ParticleZombieLightning(caller.getPosition());
		
		//if (caller.isMyPlayer())
		//{
		//	Sound::Play( "Travel.ogg" );
		//}
		//else
		//{
		//	Sound::Play( "Travel.ogg", this.getPosition() );
		//	Sound::Play( "Travel.ogg", caller.getPosition() );
		//}
	}
}

void onTunnelCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("teleport"))
	{
		const u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID( callerID );

		CBlob@[] tunnels;
		if (caller !is null && getTunnels( this, @tunnels))
		{
			// instant teleport cause there is just one place to go
			if (tunnels.length == 1)
			{
				Travel( this, caller, tunnels[0] );
			}
			else
			{
				if (caller.isMyPlayer())
					BuildTunnelsMenu( this, callerID );
			}
		}		
	}
	else if (cmd == this.getCommandID("teleport to"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ tunnel = getBlobByNetworkID(params.read_u16());
		
		if (caller !is null && tunnel !is null && 
		   (this.getPosition() - caller.getPosition()).getLength() < (this.getRadius() + caller.getRadius()) * 3.0f && 
		    doesFitAtTunnel(this, caller, tunnel))
		{
			if (getNet().isServer())
			{
				CBitStream params;			
				params.write_u16( caller.getNetworkID() );
				params.write_u16( tunnel.getNetworkID() );	
				this.SendCommand( this.getCommandID("server teleport to"), params );
			}
		}
	}
	else if (cmd == this.getCommandID("server teleport to"))
	{
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		CBlob@ tunnel = getBlobByNetworkID( params.read_u16() );
		Travel( this, caller, tunnel );
	}
	else if (cmd == this.getCommandID("teleport none"))
	{
		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if (caller !is null && caller.isMyPlayer())
			getHUD().ClearMenus();
	}
}

const int BUTTON_SIZE = 2;

void BuildTunnelsMenu( CBlob@ this, const u16 callerID )
{
	CBlob@[] tunnels;
	getTunnelsForButtons( this, @tunnels );

	CGridMenu@ menu = CreateGridMenu( getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f( (tunnels.length)*BUTTON_SIZE, BUTTON_SIZE), "Pick portal to teleport to" );
	if (menu !is null)
	{
		CBitStream exitParams;
		exitParams.write_netid( callerID );
		menu.AddKeyCommand( KEY_ESCAPE, this.getCommandID("teleport none"), exitParams );
		menu.SetDefaultCommand( this.getCommandID("teleport none"), exitParams );
		
		for (uint i = 0; i < tunnels.length; i++)
		{
			CBlob@ tunnel = tunnels[i];
			if    (tunnel is null)
			{
				menu.AddButton( "$CANCEL$", "You are here", Vec2f(BUTTON_SIZE, BUTTON_SIZE) );
			}
			else
			{
				CBitStream params;			
				params.write_u16( callerID );
				params.write_u16( tunnel.getNetworkID() );	
				menu.AddButton( getTravelIcon( this, tunnel ), getTravelDescription( this, tunnel ), this.getCommandID("teleport to"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params );
			}
		}
	}
}

string getTravelIcon( CBlob@ this, CBlob@ tunnel )
{
	if (tunnel.getName() == "base")
		return "$TRAVEL_BASE$";
	else if(tunnel.getName() == "mini_portal")
	    return "$TRAVEL_NOOM$";
	else if (tunnel.getPosition().x > this.getPosition().x)
		return "$TRAVEL_RIGHT$";
	else
	    return "$TRAVEL_LEFT$";
}

string getTravelDescription( CBlob@ this, CBlob@ tunnel )
{
	if (tunnel.getName() == "base")
		return "Return to base";
	else if(tunnel.getName() == "mini_portal")
	    return "Travel to Noom";
	else if (tunnel.getPosition().x > this.getPosition().x)
		return "Travel right";
	else
	    return "Travel left";
}
