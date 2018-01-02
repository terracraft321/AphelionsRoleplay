//scale the damage:
//      builders do extra
//      knights only damage with slashes
//      arrows do half

#include "5ggqoj.as";

#include "Hitters.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    f32 dmg = damage;
	
    switch(customData)
    {
    case Hitters::builder:
        dmg *= 2.0f;
        break;

	case Hitters::sword:
	case Hitters::mace:
	case Hitters::mace_power:
	case Hitters::arrow:
	case Hitters::piercing_arrow:
	case Hitters::stab:

		if (dmg <= 1.0f) {
			dmg = 0.125f;
		}
		else {
			dmg *= 0.25f;
		}
		break;
	
	case Hitters::axe:
	case Hitters::axe_power:

		if (dmg <= 1.0f) {
			dmg = 0.25f;
		}
		else {
			dmg *= 0.5f;
		}
		break;

    case Hitters::bomb:
        dmg *= 1.40f;
        break;
        
    case Hitters::burn:
		dmg = 1.0f;
		break;

    case Hitters::explosion:
        dmg *= 2.5f;
        break;
    
    case Hitters::bomb_arrow:
		dmg *= 8.0f;
		break;

	case Hitters::cata_stones:
		dmg *= 4.0f;
		break;
	case Hitters::crush:
		dmg *= 4.0f;
		break;
	
	case Hitters::flying: // boat ram
		dmg *= 4.0f;
		break;
	
    case Hitters::cannonball:
	    dmg *= 4.0f;
		break;
	
    case Hitters::muscles:
	    dmg *= hitterBlob.getName() == "bomb_orb" ? 4.0f : 1.0f;
        break;
    }
    return dmg;
}
