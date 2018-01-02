/* 1l1stau.as
 * author: Aphelion
 */

#include "2efidcr.as";
#include "3kemuc.as";
#include "37vdq0n.as"; 

#include "5ggqoj.as";
#include "Knocked.as";

namespace LightningSpell
{
    
    const f32 DAMAGE = 3.0f;
    const f32 RADIUS = 8.0f;
	const f32 DEVIATION = 0.5f;
    const u8 STUN_TIME = 30;
    const u8 MAX_TARGETS = 3;
    
    const string particles_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/LightningSpell.png";
    const string soundeffect_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/MagickaOverpulse.ogg";
	
}

void LightningSpell(CBlob@ caster, Vec2f pos)
{
	f32 distance = (caster.getPosition() - pos).getLength();
	f32 deviation = int(distance / 8) * LightningSpell::DEVIATION;
	
	pos = Vec2f(pos.x + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)), 
	            pos.y + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)));
	
	CBlob@[] nearBlobs;
    getMap().getBlobsInRadius(pos, LightningSpell::RADIUS * getMageSpellRadiusModifier(caster.getTeamNum()), @nearBlobs);
	
	u8  targets = 0;
	for (uint i = 0; i < nearBlobs.length; i++)
	{
	    if (targets >= LightningSpell::MAX_TARGETS)
		    break;
		
	    CBlob@ target = nearBlobs[i];
		if    (target !is null && target !is caster && target.hasTag("flesh") && !isTeamFriendly(caster.getTeamNum(), target.getTeamNum()))
		{
    		if (getNet().isClient())
			{
			    LightningEffect(target.getPosition());
			}
			
			if (LightningSpell::STUN_TIME > 0 && target.hasTag("player"))
			{
				target.Tag("dazzled"); // dazzle
				
				SetKnocked(target, LightningSpell::STUN_TIME);
				Sound::Play("/Stun", target.getPosition(), 1.0f, target.getSexNum() == 0 ? 1.0f : 2.0f);
			}
	
    		caster.server_Hit(target, target.getPosition(), Vec2f(0, -1), LightningSpell::DAMAGE, Hitters::magic, true);
			targets++;
		}
	}
	
	if (targets == 0 && getNet().isClient())
	{
	    LightningEffect(pos);
	}
}

void LightningEffect(Vec2f pos)
{
	CParticle@ p = ParticleAnimated(LightningSpell::particles_path,
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
	
	Sound::Play(LightningSpell::soundeffect_path, pos, 1.0f);
}
