// Aphelion

#include "3lq7uhv.as";

const u8 ATTACK_FREQUENCY = 30;
const f32 ATTACK_DAMAGE = 1.5f;

const int COINS_ON_DEATH = 30;

void onInit(CBlob@ this)
{
	TargetInfo[] infos;

	{
		TargetInfo i("player", 1.0f, true, true);
		infos.push_back(i);
	}
	{
		TargetInfo i("building", 0.8f, true);
		infos.push_back(i);
	}
	{
		TargetInfo i("bison", 0.7f);
		infos.push_back(i);
	}
	{
		TargetInfo i("stone_door", 0.6f);
		infos.push_back(i);
	}
	{
		TargetInfo i("wooden_door", 0.4f);
		infos.push_back(i);
	}
	{
		TargetInfo i("chicken", 0.2f);
		infos.push_back(i);
	}
	{
		TargetInfo i("lantern", 0.2f);
		infos.push_back(i);
	}
	{
		TargetInfo i("log", 0.1f);
		infos.push_back(i);
	}

	this.set("target infos", infos);
	
	this.set_u8("attack frequency", ATTACK_FREQUENCY);
	this.set_f32("attack damage", ATTACK_DAMAGE);
	this.set_string("attack sound", "ZombieKnightAttack");
	this.set_u8("coins_on_death", COINS_ON_DEATH);
	this.set_f32(target_searchrad_property, 512.0f);

	this.getShape().SetRotationsAllowed(false);

	this.getBrain().server_SetActive(true);

	this.set_f32("gib health", -3.0f);
    this.Tag("flesh");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick( CBlob@ this )
{
	if (getNet().isClient() && XORRandom(1024) == 0)
	{
		this.getSprite().PlaySound("/ZombieKnightGrowl");
	}

	if (getNet().isServer() && getGameTime() % 10 == 0)
	{
		CBlob@ target = this.getBrain().getTarget();

		if (target !is null && this.getDistanceTo(target) < 128.0f)
		{
			this.Tag(chomp_tag);
		}
		else
		{
			this.Untag(chomp_tag);
		}

		this.Sync(chomp_tag, true);
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (damage >= 0.0f)
	{
		this.getSprite().PlaySound("/ZombieHit");
	}

	return damage;
}
