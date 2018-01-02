/* 1lahplr.as
 * author: Aphelion
 */

#include "GameplayEvents.as";
 
const string cmd_portal_activate = "portal activate";
const string cmd_portal_deactivate = "portal deactivate";
const string cmd_spawn_undead = "spawn undead";

const int MAX_UNDEAD_POWER = 15;

const u32 ACTIVE_INTERVAL = 120 * 30; // Active for 2 minutes every 2 minutes
const u32 TELEPORT_INTERVAL = 30 * 30; // Every thirty seconds

const int COINS_ON_DESTRUCTION = 80;

void onInit( CBlob@ this )
{
    this.addCommandID(cmd_portal_activate);
	this.addCommandID(cmd_portal_deactivate);
	this.addCommandID(cmd_spawn_undead);
	
	this.set_TileType("background tile", CMap::tile_castle_back_moss);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.getSprite().getConsts().accurateLighting = true;
	
	this.set_u32("next_breach", getGameTime() + (ACTIVE_INTERVAL / 2));
	this.set_u32("end_breach", 0);
	this.set_u32("next_teleport", 0);
	this.set_bool("breached", false);
	this.Tag("portal");
	
	// LIGHT
	this.SetLight(false);
	this.SetLightRadius(128.0f);
    this.SetLightColor(SColor(255, 255, 0, 0));
	
	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
    if(getNet().isServer())
	{
		const u32 time = getGameTime();
		const bool breached = this.get_bool("breached");
		
		// TELEPORT IF ACTIVE
		if(breached && time >= this.get_u32("next_teleport"))
		{
	        if(getUndeadPower(this) < MAX_UNDEAD_POWER)
		    {
		        this.SendCommand(this.getCommandID(cmd_spawn_undead));
		    }
		    this.set_u32("next_teleport", getGameTime() + TELEPORT_INTERVAL);
		}
		
		// WAIT TO ACTIVATE
		else if(!breached && time >= this.get_u32("next_breach"))
		{
		    this.SendCommand(this.getCommandID(cmd_portal_activate));
		
			this.set_u32("end_breach", time + ACTIVE_INTERVAL);
			this.set_u32("next_teleport", time + TELEPORT_INTERVAL);
			this.set_bool("breached", true);
		}
	
		// WAIT TO DE-ACTIVATE
		else if(breached && time >= this.get_u32("end_breach"))
		{
		    this.SendCommand(this.getCommandID(cmd_portal_deactivate));
			
			this.set_u32("next_breach", time + ACTIVE_INTERVAL);
			this.set_bool("breached", false);
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream@ params )
{
    if (cmd == this.getCommandID(cmd_portal_activate))
    {
        PortalActivate(this);
    }
	else if(cmd == this.getCommandID(cmd_portal_deactivate))
	{
	    PortalDeactivate(this);
	}
	else if(cmd == this.getCommandID(cmd_spawn_undead))
	{
		SpawnUndead(this);
	}
}

void onDie( CBlob@ this )
{
	server_DropCoins(this.getPosition(), COINS_ON_DESTRUCTION);
}

void PortalActivate( CBlob@ this )
{
	this.SetLight(true);
	this.getSprite().PlaySound("/PortalBreach");
}

void PortalDeactivate( CBlob@ this )
{
	this.SetLight(false);
	this.getSprite().PlaySound("/BreachEnd");
}

void SpawnUndead( CBlob@ this )
{
    if(getNet().isServer())
	{
		if(XORRandom(5) == 0)
		{	
			server_CreateBlob("zombie_knight", 5, this.getPosition());
		}
		else if(XORRandom(4) == 0)
		{
			int target_amount = 2 + XORRandom(4);
			
			for (uint i = 0; i < target_amount; i++)
				server_CreateBlob("ankou", 5, this.getPosition());
		}
		else if(XORRandom(3) == 0)
		{
			int target_amount = 2 + XORRandom(3);
			
			for (uint i = 0; i < target_amount; i++)
				server_CreateBlob("zombie", 5, this.getPosition());
		}
		else
		{
	    	int target_amount = 2 + XORRandom(4);
			
	    	for (uint i = 0; i < target_amount; i++)
				server_CreateBlob("skeleton", 5, this.getPosition());
		}
	}
    ParticleZombieLightning(this.getPosition());
	
	this.getSprite().PlaySound("/Teleport");
}

u8 getUndeadPower( CBlob@ this )
{
    u8 undead_power = 0;
    
	CBlob@[] nearBlobs;
    getMap().getBlobsInRadius(this.getPosition(), 512.0f, @nearBlobs);
	
	for (uint i = 0; i < nearBlobs.length; i++)
    {
		CBlob@ nearBlob = nearBlobs[i];
		if(nearBlob !is null)
		{
			string name = nearBlob.getName();
			if(name == "zombie_knight")
				undead_power += 4;
			else if(name == "ankou")
			    undead_power += 3;
			else if(name == "zombie")
				undead_power += 2;
			else if(name == "skeleton")
			    undead_power++;
	    }
	}
	return undead_power;
}
