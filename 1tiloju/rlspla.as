/* rlspla.as
 * author: Aphelion
 */

#include "2efidcr.as";
#include "37vdq0n.as"; 

#include "5ggqoj.as";
#include "Knocked.as";

namespace MiasmaSpell
{
    
    const f32 DAMAGE = 0.5f;
    const f32 RADIUS = 40.0f;
	const f32 DEVIATION = 0.3f;
    const u8 STUN_TIME = 45;
    const u8 MAX_TARGETS = 7;
    
    const string particles_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/MiasmaSpell.png";
    const string soundeffect_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/MagickaMiasma.ogg";
	
}

void MiasmaSpell(CBlob@ caster, Vec2f pos)
{
	f32 distance = (caster.getPosition() - pos).getLength();
	f32 deviation = int(distance / 8) * MiasmaSpell::DEVIATION;
	
	pos = Vec2f(pos.x + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)), 
	            pos.y + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)));
	
	CBlob@[] nearBlobs;
    getMap().getBlobsInRadius(pos, MiasmaSpell::RADIUS * getMageSpellRadiusModifier(caster.getTeamNum()), @nearBlobs);
	
	u8  targets = 0;
	for (uint i = 0; i < nearBlobs.length; i++)
	{
	    if (targets >= MiasmaSpell::MAX_TARGETS)
		    break;
		
	    CBlob@ target = nearBlobs[i];
		if    (target !is null && target.hasTag("flesh") && !target.hasTag("dead"))
		{
    		if (getNet().isClient())
			{
			    MiasmaEffect(target.getPosition());
			}
			
			if (MiasmaSpell::STUN_TIME > 0 && target.hasTag("player"))
			{
				target.Tag("dazzled"); // dazzle
				
				SetKnocked(target, MiasmaSpell::STUN_TIME);
				Sound::Play("/Stun", target.getPosition(), 1.0f, target.getSexNum() == 0 ? 2.0f : 3.0f);
			}
			
    		caster.server_Hit(target, target.getPosition(), Vec2f(0, -1), MiasmaSpell::DAMAGE, Hitters::magic, true);
			targets++;
		}
	}
	
	if (targets == 0 && getNet().isClient())
	{
	    MiasmaEffect(pos);
	}
}

void MiasmaEffect(Vec2f pos)
{
	CParticle@ p = ParticleAnimated(MiasmaSpell::particles_path,
									pos,
									Vec2f(0, 0), //vel
									0.0f, //angle
									1.0f, //scale
									3, //animtime
									0.0f, //gravity
									true); //selflit
	if (p !is null)
	{
		p.Z = 110.0f;
		
		p.width = 48;
		p.height = 48;
	}
	
	Sound::Play(MiasmaSpell::soundeffect_path, pos, 1.0f);
}
