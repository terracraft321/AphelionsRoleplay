/* 214m9g8.as
 * author: Aphelion
 */

#include "2efidcr.as";
#include "37vdq0n.as"; 

#include "5ggqoj.as";
#include "Knocked.as";

namespace BombSpell
{
    
    const f32 DAMAGE = 2.0f;
	const f32 DEVIATION = 0.25f;
    const f32 EXP_RADIUS = 32.0f;
	const f32 MAP_RADIUS = 16.0f;
	const f32 MAP_RATIO = 0.5f;
    
    const string particles_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/BombSpell.png";
    const string soundeffect_path = "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/Spells/MagickaBomb.ogg";
	
}

void BombSpell(CBlob@ caster, Vec2f pos)
{
	f32 distance = (caster.getPosition() - pos).getLength();
	f32 deviation = int(distance / 8) * BombSpell::DEVIATION;
	
	pos = Vec2f(pos.x + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)), 
	            pos.y + (XORRandom(128) < 64 ? XORRandom(deviation) : -XORRandom(deviation)));
	
    CBlob@ source = server_CreateBlob("spell_source", -1, pos);
	if    (source !is null)
	{
		source.Tag("exploding");
		source.set_f32("explosive_radius", BombSpell::EXP_RADIUS * getMageSpellRadiusModifier(caster.getTeamNum()));
		source.set_f32("explosive_damage", BombSpell::DAMAGE);
		source.set_f32("map_damage_radius", BombSpell::MAP_RADIUS * getMageSpellRadiusModifier(caster.getTeamNum()));
		source.set_f32("map_damage_ratio", BombSpell::MAP_RATIO);
		source.set_u8("custom_hitter", Hitters::magic);
		source.set_string("custom_explosion_sound", BombSpell::soundeffect_path);
		source.SetDamageOwnerPlayer(caster.getPlayer());
		
	    source.AddScript("/ExplodeOnDie.as");
		
		source.server_Die();
	}
}
