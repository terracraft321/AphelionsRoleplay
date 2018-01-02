/* ue3b6s.as
 * author: Aphelion
 */

#include "3kemuc.as";

#include "GameplayEvents.as";

const int coinsOnKillAdd = 4;

const int coinsOnDeathLosePercent = 10;
const int coinsOnDeathByPlayerLosePercent = 20;
const int coinsOnTKLose = 50;

void Reset( CRules@ this )
{
	if(!getNet().isServer())
		return;
    
    uint count = getPlayerCount();
	for(uint p_step = 0; p_step < count; ++p_step)
    {
		CPlayer@ p = getPlayer(p_step);
		p.server_setCoins( 0 );
	}
}

void onRestart( CRules@ this )
{
	Reset( this );
}

void onInit( CRules@ this )
{
	Reset( this );
}

// Coins for: killing enemy units
void onBlobDie( CRules@ this, CBlob@ victim )
{
	if(!getNet().isServer())
		return;
	
	CPlayer@ killer = victim.getPlayerOfRecentDamage();
	
	if(victim !is null && victim.getPlayer() is null && killer !is null)
	{
	    u8 coins = victim.get_u8("coins_on_death");
		if(coins > 0)
		{
			server_DropCoins( victim.getPosition(), XORRandom(coins) );
		}
	}
}

// Coins for: killing enemy players
void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData )
{
	if(!getNet().isServer())
		return;
	
	if (victim !is null )
	{
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins( killer.getCoins() + coinsOnKillAdd );
			}
			else if(killer.getTeamNum() == victim.getTeamNum())
			{
				killer.server_setCoins( killer.getCoins() - coinsOnTKLose );
				return;
			}
		}
		
		//f32 percentLost = XORRandom((killer !is null ? coinsOnDeathByPlayerLosePercent : coinsOnDeathLosePercent) * 0.01f);
		f32 percentLost = (killer !is null ? coinsOnDeathByPlayerLosePercent : coinsOnDeathLosePercent) * 0.01f;
		s32 lost = victim.getCoins() * percentLost;
		
		// Remove coins
		victim.server_setCoins( victim.getCoins() - lost );
		
		// Drop coins
		CBlob@ blob = victim.getBlob();
		if    (blob !is null)
		{
			//server_DropCoins( blob.getPosition(), lost );
			server_DropCoins( blob.getPosition(), XORRandom(lost) );
		}
	}
}
