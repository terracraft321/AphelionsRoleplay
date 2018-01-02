/* 2ra1bbn.as
 * author: Aphelion
 *
 * Logic script for the Necromancer, Noom.
 */

#include "BrainCommon.as";
#include "EmotesCommon.as";

namespace AttackPhase
{
    enum type
	{
	    phase_one = 0, // > 75% hp: fire orbs slowly, *yawn* and teleport away if needed
		phase_two,     // < 75% hp: fire orbs faster and teleport more often
		phase_three,   // < 50% hp: start summoning minions
		phase_four,    // < 25% hp: spam orbs like crazy
	};
};

namespace AttackType
{
	enum type
	{
		attack_fire = 0,
		attack_manical,
		attack_summon,
		attack_rest
	};
};

const string cmd_teleport = "teleport to safety";
const string cmd_summon_minions = "summon minions";
const string cmd_change_phase = "change phase";

const int MAX_UNDEAD_POWER = 10;

void onInit( CBlob@ this )
{
    this.addCommandID(cmd_teleport);
	this.addCommandID(cmd_summon_minions);
	this.addCommandID(cmd_change_phase);
	
	this.set_f32("gib health", 0.0f);
    this.Tag("flesh");
	
    this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	
	// for RegenHealth.as
	this.set_f32("regen rate", 0.5f);
	
	this.set_u8("attack stage", AttackType::attack_fire);
	this.set_u8("attack phase", AttackPhase::phase_one);
	this.set_Vec2f("last teleport pos", this.getPosition());
}

void onTick( CBlob@ this )
{
    const u32 gametime = getGameTime();
	
	u8 stage = this.get_u8("attack stage");
	if(stage == AttackType::attack_manical && gametime % 300 == 0)
		this.getSprite().PlaySound("/EvilLaughShort2.ogg");
	else if(stage == AttackType::attack_summon && gametime % 150 == 0) 
		this.getSprite().PlaySound("/EvilLaugh.ogg");
	else if(stage == AttackType::attack_rest && gametime % 150 == 0)
		this.getSprite().PlaySound("/EvilLaughShort1.ogg");
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (hitterBlob.getName() == "orb" && hitterBlob.getTeamNum() == this.getTeamNum())
		return 0.0f;
	
	if (getNet().isServer())
	{
	    DoTeleport(this, this.get_u8("attack phase"));
		
		// attack anyone doing damage
        if (hitterBlob.getPlayer() !is null)
	    {
		    this.getBrain().SetTarget(hitterBlob);
	    }
	}
    return damage;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID(cmd_teleport))
    {
        Teleport(this, params.read_Vec2f());
	}
	else if(cmd == this.getCommandID(cmd_summon_minions))
	{
	    SummonMinions(this, params.read_Vec2f());
	}
	else if(cmd == this.getCommandID(cmd_change_phase))
	{
		this.getSprite().PlaySound("/EvilNotice.ogg", 1.5f);
	}
}

void onInit( CBrain@ this )
{
	InitBrain( this );
	this.server_SetActive(true); // always running
	
	this.getCurrentScript().tickFrequency = 31;
	
	this.getCurrentScript().removeIfTag	= "dead";
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 512.0f;
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
}

void onTick( CBrain@ this )
{
	FindTarget(this); // get a target
	
	CBlob@ blob = this.getBlob();
	CBlob@ target = this.getTarget();

	// logic for target
	if (target !is null)
	{	
		this.getCurrentScript().tickFrequency = 1;
		
		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible(blob, target, visibleDistance);
		
		if (distance < 256.0f)
		{
			const u32 gametime = getGameTime();
			
			// determine the attack phase
			u8 phase = blob.get_u8("attack phase");
			f32 hpPercentage = (blob.getHealth() * 100) / blob.getInitialHealth();
			if (hpPercentage < 25)
			{
			    phase = AttackPhase::phase_four;
				
				// set the regeneration rate to 4HP/3s
				blob.set_f32("regen rate", 2.0f);
			}
			else if(hpPercentage < 50)
			{
			    phase = AttackPhase::phase_three;
				
				// set the regeneration rate to 3HP/3s
				blob.set_f32("regen rate", 1.5f);
			}
			else if(hpPercentage < 75)
			{
			    phase = AttackPhase::phase_two;
				
				// set the regeneration rate to 2HP/3s
				blob.set_f32("regen rate", 1.0f);
			}
			else
			{
			    phase = AttackPhase::phase_one;
				
				// set the regeneration rate to 1HP/3s
				blob.set_f32("regen rate", 0.5f);
			}
			
			// was the phase changed?
			if(phase != blob.get_u8("attack phase"))
			{
				blob.SendCommand(blob.getCommandID(cmd_change_phase));
			}
			blob.set_u8("attack phase", phase);
			
			// teleport away from danger
			if((distance < (phase >= AttackPhase::phase_two ? 64.0f : 40.0f) || XORRandom(512) < (phase >= AttackPhase::phase_two ? 80 : 64)) 
			 && gametime % 30 == 0)
			{
			    DoTeleport(blob, phase);
			    return;
			}
			
			u8 stage = blob.get_u8("attack stage");
			if(stage == AttackType::attack_manical || (stage == AttackType::attack_fire && gametime % 50 == 0)) 
			{
				blob.setKeyPressed( key_action1, true );
				f32 vellen = target.getShape().vellen;
				Vec2f randomness = Vec2f( -5 + XORRandom(100) * 0.1f, -5 + XORRandom(100) * 0.1f );
				blob.setAimPos( target.getPosition() + target.getVelocity() * vellen * vellen + randomness );
			}
			else if(stage == AttackType::attack_summon && gametime % 30 == 0)
			{
			    u8 undead_power = 0;
   				
				CBlob@[] nearBlobs;
    			getMap().getBlobsInRadius(blob.getPosition(), 512.0f, @nearBlobs);
				
				for (uint i = 0; i < nearBlobs.length; i++)
    			{
					CBlob@ nearBlob = nearBlobs[i];
					if(nearBlob !is null)
					{
						string name = nearBlob.getName();
						if(name == "zombie_knight")
							undead_power += 3;
		   				else if(name == "zombie" || name == "skeleton")
							undead_power++;
	    			}
				}
				
				if(undead_power < MAX_UNDEAD_POWER)
				{
				    Vec2f[] spawners;
					
					CMap@ map = getMap();
					if   (map.getMarkers("necromancer minion spawner", spawners))
					{
						CBitStream params;
						params.write_Vec2f(spawners[XORRandom(spawners.length)]);
						
						blob.SendCommand(blob.getCommandID(cmd_summon_minions), params);
					}
				}
			}
			
			// determine the attack type
			int x = gametime % 300;
			
			// phase 4: spam orbs most of the time
			if (x < 200 && phase == AttackPhase::phase_four)
			{
				if (x < 40) // 20%
					stage = AttackType::attack_fire;
				else        // 80%
					stage = visibleTarget ? AttackType::attack_manical : AttackType::attack_fire;
			}
			
			// phase 2-3: even chance to spam or fire normally
			else if(x < 200 && phase >= AttackPhase::phase_two)
			{
				if (x < 100) // 50%
					stage = AttackType::attack_fire;
				else         // 50%
					stage = visibleTarget ? AttackType::attack_manical : AttackType::attack_fire;
			}
			
			// phase 1: low chance to spam orbs
			else if(x < 250 && phase == AttackPhase::phase_one)
			{
				if (x < 200) // 80%
					stage = AttackType::attack_fire;
				else         // 20%
					stage = visibleTarget ? AttackType::attack_manical : AttackType::attack_fire;
			}
			
			// phase 3-4: summon minions
			else if (x < 275 && phase >= AttackPhase::phase_three)
			    stage = AttackType::attack_summon;
				
		    // rest
			else 
				stage = AttackType::attack_rest;

			blob.set_u8("attack stage", stage);
			blob.Sync("attack stage", true);
		}
		
		// lose target
		if (XORRandom(5) == 0 && (target.hasTag("dead") || distance > 256.0f))
	    {
			this.SetTarget(null);
		}
	}
	else
	{
	    this.getCurrentScript().tickFrequency = 31;
		
		RandomTurn( blob );
	}
}

void FindTarget( CBrain@ this )
{
	CBlob@ blob = this.getBlob();
	CBlob@ target = this.getTarget();
	if    (target is null)
	{
		@target = getTarget(this, blob, 256.0f);
		
		this.SetTarget( target );
	}
}	   

CBlob@ getTarget( CBrain@ this, CBlob@ blob, f32 radius )
{
	CBlob@[] nearBlobs;
	blob.getMap().getBlobsInRadius( blob.getPosition(), radius, @nearBlobs );

	CBlob@ best_candidate;
	f32 closest_dist = 999999.9f;
	for(int step = 0; step < nearBlobs.length; ++step)
	{
		CBlob@ candidate = nearBlobs[step];
		if    (candidate is null) break;
		
		if (candidate.hasTag("player") && !candidate.hasTag("dead"))
		{
			f32 dist = (candidate.getPosition() - blob.getPosition()).getLength();
			if (dist < closest_dist && isVisible(blob, candidate) && blob.getTeamNum() != candidate.getTeamNum())
			{
				@best_candidate = candidate;
				closest_dist = dist;
				break;
			}
		}
	}
	return best_candidate;
}

void DoTeleport( CBlob@ blob, u8 phase )
{
    Vec2f lastTeleport = blob.get_Vec2f("last teleport pos");
	Vec2f pos = blob.getPosition();
	Vec2f[] teleports;
		
	CMap@ map = getMap();
	if   (map.getMarkers("necromancer teleport", teleports)) 
	{
		Vec2f nextTeleport = lastTeleport;
		
        // sometimes we'll go with a random position
		bool teleportRandomly = XORRandom(512) < (phase > AttackPhase::phase_two ? 64 : 128);
		if  (teleportRandomly)
		{
		    nextTeleport = teleports[XORRandom(teleports.length)];
		}
		else
		{
			// pick the furthest possible location to teleport to
			Vec2f furthestPos = lastTeleport;
			f32 furthestDist = 0.0f;
			for (uint i = 0; i < teleports.length; i++)
			{
			    Vec2f candidatePos = teleports[i];
            	if   (candidatePos == lastTeleport)
            		continue;
				
				f32 dist = (candidatePos - lastTeleport).Length();
				if (dist > furthestDist)
				{
					furthestPos = candidatePos;
					furthestDist = dist;
				}
			}
			nextTeleport = furthestPos;
		}
        
        // send the command
		CBitStream params;
		params.write_Vec2f(nextTeleport);
		
		blob.SendCommand(blob.getCommandID(cmd_teleport), params);
	}
}

void Teleport( CBlob@ blob, Vec2f teleportPos )
{
	ParticleZombieLightning(blob.getPosition());
	Sound::Play("Teleport.ogg", blob.getPosition());
	blob.set_Vec2f("last teleport pos", teleportPos);
	blob.setPosition(teleportPos);
	blob.setVelocity(Vec2f_zero);
	ParticleZombieLightning(teleportPos);
	Sound::Play("Respawn.ogg", teleportPos);
}

void SummonMinions( CBlob@ blob, Vec2f summonPos )
{
	if(getNet().isServer())
	{
    	if(XORRandom(5) == 0)
		{	
			server_CreateBlob("zombie_knight", blob.getTeamNum(), summonPos);
		}
		else if(XORRandom(3) == 0)
		{
	    	int target_amount = 2 + XORRandom(3);
				      		
			for (uint i = 0; i < target_amount; i++)
				server_CreateBlob("zombie", blob.getTeamNum(), summonPos);
		}
		else
		{
	    	int target_amount = 2 + XORRandom(4);
			
			for (uint i = 0; i < target_amount; i++)
				server_CreateBlob("skeleton", blob.getTeamNum(), summonPos);
		}
	}
	ParticleZombieLightning(summonPos);
    	
	Sound::Play("Teleport.ogg", summonPos);
}
