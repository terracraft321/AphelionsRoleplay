/* 3kkim59.as
 * author: Aphelion
 */

#include "2efidcr.as";
#include "3kemuc.as";
#include "37vdq0n.as"; 

#include "5ggqoj.as";
#include "Knocked.as";

namespace EnergySpell
{
    
    const f32 DAMAGE = 1.0f;
    const f32 RADIUS = 24.0f;
	const f32 DEVIATION = 1.25f;
    const u8 STUN_TIME = 0;
    const u8 MAX_TARGETS = 5;
    
    const string particles_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/EnergySpell.png";
    const string soundeffect_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/MagickaPulse.ogg";
	
}

void EnergySpell(CBlob@ caster, Vec2f pos)
{
    f32 distance = (caster.getPosition() - pos).getLength();
	f32 deviation = int(distance / 8) * EnergySpell::DEVIATION;
	
	pos = Vec2f(pos.x + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)), 
	            pos.y + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)));
	
	CBlob@[] nearBlobs;
    getMap().getBlobsInRadius(pos, EnergySpell::RADIUS * getMageSpellRadiusModifier(caster.getTeamNum()), @nearBlobs);
	
	u8  targets = 0;
	for (uint i = 0; i < nearBlobs.length; i++)
	{
	    if (targets >= EnergySpell::MAX_TARGETS)
		    break;
		
	    CBlob@ target = nearBlobs[i];
		if    (target !is null && target !is caster && target.hasTag("flesh") && !isTeamFriendly(caster.getTeamNum(), target.getTeamNum()))
		{
    		if (getNet().isClient())
			{
			    EnergyEffect(target.getPosition());
			}
			
			if (EnergySpell::STUN_TIME > 0 && target.hasTag("player"))
			{
				SetKnocked(target, EnergySpell::STUN_TIME);
				Sound::Play("/Stun", target.getPosition(), 1.0f, target.getSexNum() == 0 ? 1.0f : 2.0f);
			}
	
    		caster.server_Hit(target, target.getPosition(), Vec2f(0, -1), EnergySpell::DAMAGE, Hitters::magic, true);
			targets++;
		}
	}
	
	if (targets == 0 && getNet().isClient())
	{
	    EnergyEffect(pos);
	}
}

void EnergyEffect(Vec2f pos)
{
	CParticle@ p = ParticleAnimated(EnergySpell::particles_path,
									pos,
									Vec2f(0, 0), //vel
									0.0f, //angle
									1.0f, //scale
									1, //animtime
									0.0f, //gravity
									true); //selflit
	if (p !is null)
	{
		p.Z = 110.0f;
		
		p.width = 32;
		p.height = 32;
	}
	
	Sound::Play(EnergySpell::soundeffect_path, pos, 1.0f);
}
