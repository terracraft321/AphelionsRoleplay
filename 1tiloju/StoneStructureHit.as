//scale the damage:
//      knights cant damage
//      arrows cant damage

#include "5ggqoj.as";

#include "Hitters.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    f32 dmg = damage;
	
    switch(customData)
    {
    case Hitters::builder:
        dmg *= 2.0f; //builder is great at smashing stuff
        break;

	case Hitters::sword:
	case Hitters::axe:
	case Hitters::axe_power:
	case Hitters::arrow:
	case Hitters::stab:
		dmg = 0.0f;
		break;
	
	case Hitters::mace:
	case Hitters::mace_power:
	case Hitters::piercing_arrow:
		if (dmg <= 1.0f)
			dmg = 0.125f;
		else
			dmg *= 0.25f;
		break;

    case Hitters::bomb:
        dmg *= 0.5f;
        break;

	case Hitters::keg:
	case Hitters::explosion:
        dmg *= 2.5f;
        break;
        
    case Hitters::bomb_arrow:
		dmg *= 8.0f;
		break;

	case Hitters::cata_stones:
		dmg *= 5.0f;
		break;
	case Hitters::crush:
		dmg *= 4.0f;
		break;		

	case Hitters::flying: // boat ram
		dmg *= 3.5f;
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
