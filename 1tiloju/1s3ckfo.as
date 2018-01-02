/* 222fdt8.as
 * author: Aphelion
 *
 * Logic script for the Mage class by Aphelion
 */

#include "2efidcr.as";

#include "3kkim59.as";
#include "rlspla.as";
#include "1l1stau.as";
#include "214m9g8.as";

#include "37vdq0n.as";
#include "3jt3pus.as";

#include "222fdt8.as";
#include "RunnerCommon.as";	
#include "ThrowCommon.as";
#include "Hitters.as";
#include "Knocked.as";
#include "Help.as";

void onInit( CBlob@ this )
{
	MageInfo mage;
	this.set("mageInfo", @mage);
	
	this.set_f32("gib health", -3.0f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on runes
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
    this.getSprite().SetEmitSound( "../Mods/" + RP_NAME + "/Entities/Characters/Classes/Mage/StaffCharge.ogg" );
	this.addCommandID("cast spell");
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	AddIconToken( "$Orb$", "MagicOrb.png", Vec2f(8, 8), 0);
	SetHelp( this, "help self action", "mage", "$Orb$Shoot rune    $LMB$", "", 1 ); 

	//add a command ID for each arrow type
	for (uint i = 0; i < runeTypeNames.length; i++)
	{
        this.addCommandID( "pick " + runeTypeNames[i]);
    }

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer( CBlob@ this, CPlayer@ player )
{
	if (player !is null){
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16,16));
	}
}

void onTick( CBlob@ this )
{
    MageInfo@ mage;
	if (!this.get( "mageInfo", @mage ))
		return;

	if(getKnocked(this) > 0)
	{
		mage.charge_time = 0;
		mage.charge_state = 0;
		return;
	}
	
	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;
	
	if (this.isInInventory()) return;
	
	RunnerMoveVars@ moveVars;
	if (!this.get( "moveVars", @moveVars ))
		return;
	
	CSprite@ sprite = this.getSprite();
	
	bool ismyplayer = this.isMyPlayer();
	bool hasrune = mage.has_rune;
	s8 charge_time = mage.charge_time;
    u8 charge_state = mage.charge_state;
	
	if (this.isKeyPressed(key_action1) && !mage.power_active)
	{
		moveVars.walkFactor *= 0.70f;
		moveVars.canVault = false;
		
		if ((getGameTime() + this.getNetworkID()) % 10 == 0)
		{
			hasrune = hasRunes( this );
			
			if (!hasrune)
			{
				for (uint i = RuneType::count - 1; i > 0; i--)
				{
					hasrune = hasRunes(this, i);
					
					if (hasrune)
					{
						mage.rune_type = i;
						break;
					}
				}
			}
		}
		
		const bool just_action1 = this.isKeyJustPressed(key_action1);
		
		if (charge_state == MageParams::not_aiming)
		{
			charge_time = 0;
			charge_state = MageParams::readying;
			
			hasrune = hasRunes(this, getRuneType(this));
			
			if (!hasrune)
			{
				charge_state = MageParams::not_aiming;

				if (ismyplayer && !this.wasKeyPressed(key_action1)) { // playing annoying no ammo sound
					Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
				}

				// set back to default
				mage.rune_type = RuneType::energy;
			}
			else
			{
				sprite.RewindEmitSound();
				sprite.SetEmitSoundPaused( false );
				
				if (!ismyplayer) { // lower the volume of other players charging  - ooo good idea
					sprite.SetEmitSoundVolume( 0.5f );
				}
			}
		}
		else if (charge_state == MageParams::readying)
		{
			charge_time++;

			if(charge_time > MageParams::ready_time)
			{
				charge_time = 1;
				charge_state = MageParams::charging;
			}
		}
		else if (charge_state == MageParams::charging)
		{
			charge_time++;
			
			if(charge_time >= MageParams::shoot_period)
			{
				charge_state = MageParams::firing;
			}
		}
		else if(charge_state == MageParams::firing)
		{
		    if(!hasrune)
			{
			    charge_state = MageParams::not_aiming;
				charge_time = 0;
			}
			else
			{
				const u32 gametime = getGameTime();
		        
		        u32 lastFireTime = this.get_u32("last magic fire");
		        int diff = gametime - (lastFireTime + MageParams::shoot_interval);
		        if (diff > 0)
		        {
			        this.set_u32("last magic fire", gametime);
					
					Vec2f aimPos = this.getAimPos();
					
					Vec2f col;
					if(getMap().rayCastSolid(this.getPosition(), aimPos, col))
					    aimPos = col;
					
					CastSpell(this, aimPos, mage.rune_type);
				}
			}
			
			sprite.SetEmitSoundPaused( true );
		}
	}
	else
	{
		charge_state = MageParams::not_aiming;    //set to not aiming either way
		charge_time = 0;
		
		sprite.SetEmitSoundPaused( true );
	}
	
	mage.charge_time = charge_time;
	mage.charge_state = charge_state;
	mage.has_rune = hasrune;
	
	// my player!
    if ( ismyplayer )
    {
		// set cursor
		if (!getHUD().hasButtons()) 
		{
			int frame = 0;
			if (mage.charge_state == MageParams::readying)
			{
				frame = 1 + float(mage.charge_time) / float(MageParams::shoot_period + MageParams::ready_time) * 7;
			}
			else if (mage.charge_state == MageParams::charging) 
			{
				if (mage.charge_time <= MageParams::shoot_period)
					frame = Maths::Min(int(float(MageParams::ready_time + mage.charge_time) / float(MageParams::shoot_period) * 7), 9);
				else
					frame = 9;
			}
			else if(mage.charge_state == MageParams::firing)
			{
			    frame = 10;
			}
			getHUD().SetCursorFrame( frame );
		}
		
		// activate/throw
        if (this.isKeyJustPressed(key_action3))
        {
			client_SendThrowOrActivateCommand( this );
        }
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("cast spell"))
	{
		Vec2f aimPos = params.read_Vec2f();
		u8 runeType = params.read_u8();

		MageInfo@ mage;
		if (!this.get( "mageInfo", @mage ))
			return;

		mage.rune_type = runeType;
		
		if (!hasRunes( this, runeType ))
			return;
		
		this.TakeBlob(runeTypeNames[runeType], 1);
		
		if(runeType == RuneType::energy)
		    EnergySpell(this, aimPos);
		else if(runeType == RuneType::water)
		    MiasmaSpell(this, aimPos);
	    else if(runeType == RuneType::lightning)
		    LightningSpell(this, aimPos);
		else if(runeType == RuneType::bomb)
		    BombSpell(this, aimPos);
	}
    else if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		// cycle runes
		MageInfo@ mage;
		if (!this.get( "mageInfo", @mage ))
			return;
		
		u8 type = mage.rune_type;

		int count = 0;
		while(count < runeTypeNames.length)
		{
			type++;
			count++;
			if (type >= runeTypeNames.length)
				type = 0;
			if (this.getBlobCount( runeTypeNames[type] ) > 0)
			{
				mage.rune_type = type;
				if (this.isMyPlayer())
				{
					Sound::Play("/CycleInventory.ogg");
				}
				break;
			}
		}
	}
	else
    {
		MageInfo@ mage;
		if (!this.get( "mageInfo", @mage ))
			return;
		
        for (uint i = 0; i < runeTypeNames.length; i++)
        {
            if (cmd == this.getCommandID( "pick " + runeTypeNames[i]))
            {
                mage.rune_type = i;
                break;
            }
        }
    }
}

void CastSpell( CBlob@ this, Vec2f aimPos, const u8 runeType )
{
    if (canSend(this)) // player or bot
	{
		CBitStream params;
		params.write_Vec2f( aimPos );
		params.write_u8( runeType );
		
		this.SendCommand( this.getCommandID("cast spell"), params );
	}
}

bool canSend( CBlob@ this )
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

void onCreateInventoryMenu( CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu )
{
    if (runeTypeNames.length == 0)
        return;
	
    this.ClearGridMenusExceptInventory();
    Vec2f pos( gridmenu.getUpperLeftPosition().x + 0.5f*(gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
               gridmenu.getUpperLeftPosition().y - 32 * 1 - 2*24 );
    CGridMenu@ menu = CreateGridMenu( pos, this, Vec2f( runeTypeNames.length, 1 ), "Current rune" );

	MageInfo@ mage;
	if (!this.get( "mageInfo", @mage )) {
		return;
	}
	const u8 runeSel = mage.rune_type;

    if (menu !is null)
    {
		menu.deleteAfterClick = false;

        for (uint i = 0; i < runeTypeNames.length; i++)
        {
            string matname = runeTypeNames[i];
            CGridButton @button = menu.AddButton( runeIcons[i], runeNames[i], this.getCommandID( "pick " + matname) );

            if (button !is null)
            {
				bool enabled = this.getBlobCount( runeTypeNames[i] ) > 0;
                button.SetEnabled( enabled );
				button.selectOneOnClick = true;
                if (runeSel == i) {
                    button.SetSelected(1);
                }
			}
        }
    }
}

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	string itemname = blob.getName();
	
	CInventory@ inv = this.getInventory();
	if         (inv.getItemsCount() == 0)
	{
		MageInfo@ mage;
		if (!this.get( "mageInfo", @mage ))
			return;
		
		for (uint i = 0; i < runeTypeNames.length; i++)
			if (itemname == runeTypeNames[i])
				mage.rune_type = i;
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if (hitBlob.getName() == "magic_rune" && hitBlob.getTeamNum() == this.getTeamNum())
		return 0.0f;
	
	// the damage modifier
	f32 modifier = getDamageModifier(this, customData);
	
	CPlayer@ player = this.getPlayer();
	if      (player !is null && player.getUsername() == "Aphelion")
	    return (damage * modifier) * 0.75;
	
	CPlayer@ hitterPlayer = hitBlob.getPlayer();
	if      (hitterPlayer !is null && hitterPlayer.getUsername() == "Aphelion")
	    return (damage * modifier) * 1.25;
	
	return damage * modifier;
}
