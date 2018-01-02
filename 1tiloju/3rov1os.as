// Aphelion

#include "3lq7uhv.as";
#include "Hitters.as";

const u8 ATTACK_FREQUENCY = 30;
const f32 ATTACK_DAMAGE = 0.5f;

const int COINS_ON_DEATH = 10;

void onInit(CBlob@ this)
{
	TargetInfo[] infos;

	{
		TargetInfo i("player", 1.0f, true, true);
		infos.push_back(i);
	}
	{
		TargetInfo i("wooden_door", 0.8f);
		infos.push_back(i);
	}
	{
		TargetInfo i("chicken", 0.6f);
		infos.push_back(i);
	}
	{
		TargetInfo i("log", 0.4f);
		infos.push_back(i);
	}
	{
		TargetInfo i("stone_door", 0.3f);
		infos.push_back(i);
	}

	this.set("target infos", infos);
	
	this.set_u8("attack frequency", ATTACK_FREQUENCY);
	this.set_f32("attack damage", ATTACK_DAMAGE);
	this.set_u8("attack hitter", Hitters::fire);
	this.set_string("attack sound", "AnkouAttack");
	this.set_u16("coins on death", COINS_ON_DEATH);
	this.set_f32(target_searchrad_property, 512.0f);

    this.getSprite().PlayRandomSound("/AnkouSpawn");
	this.getShape().SetRotationsAllowed(false);

	this.getBrain().server_SetActive(true);

	this.set_f32("gib health", 0.0f);
    this.Tag("flesh");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if (getNet().isClient() && XORRandom(768) == 0)
	{
		this.getSprite().PlaySound("/AnkouSayDuh");
	}

	if (getNet().isServer() && getGameTime() % 10 == 0)
	{
		CBlob@ target = this.getBrain().getTarget();

		if (target !is null && this.getDistanceTo(target) < 72.0f)
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
	    this.getSprite().PlaySound("/AnkouHit");
    }

	return damage;
}

void onDie( CBlob@ this )
{
	server_DropCoins(this.getPosition() + Vec2f(0, -3.0f), COINS_ON_DEATH);

    this.getSprite().PlaySound("/AnkouBreak1");	
}
