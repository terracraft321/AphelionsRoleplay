/* 222fdt8.as
 * author: Aphelion
 */

namespace MageParams
{
enum Aim {
    not_aiming = 0,
    readying,
    charging,
    firing,
    no_runes,
}

const ::s32 ready_time = 11;

const ::s32 shoot_period = 30;
const ::s32 shoot_interval = 45;
}

namespace RuneType
{
    enum type
    {
        energy = 0,
	    water,
		lightning,
	    bomb,
		count
    };
}

shared class MageInfo
{
	s8 charge_time;
	u8 charge_state;
	
	bool has_rune;
	u8  rune_type;
	
	bool power_active;
	string power_type;
	u32 power_expire;
	u32[] powers_end = {
		0.0f, 
		0.0f, 
		0.0f, 
		0.0f
	};

	MageInfo()
	{
		charge_time = 0;
		charge_state = 0;
		
		has_rune = false;
		rune_type = RuneType::energy;

		power_active = false;
		power_type = "";
		power_expire = 0;
	}
};

const string[] runeTypeNames = {
    "mat_energyrunes",
	"mat_miasmarunes",
	"mat_lightningrunes",
	"mat_bombrunes"
};

const string[] runeNames = { 
    "Energy rune",
    "Miasma rune",
	"Lightning rune",
	"Bomb rune"
};

const string[] runeIcons = {
    "$mat_energyrunes$",
	"$mat_miasmarunes$",
	"$mat_lightningrunes$",
	"$mat_bombrunes$"
};

bool hasRunes( CBlob@ this )
{
	MageInfo@ mage;
	if (!this.get("mageInfo", @mage))
		return false;
	
	if (mage.rune_type >= 0 && mage.rune_type < runeTypeNames.length)
	{
		return this.getBlobCount(runeTypeNames[mage.rune_type]) > 0;
	}
	return false;
}

bool hasRunes( CBlob@ this, u8 runeType )
{
	return this.getBlobCount(runeTypeNames[runeType]) > 0;
}

u8 getRuneType( CBlob@ this )
{
	MageInfo@ mage;
	if (!this.get("mageInfo", @mage))
		return 0;
	
	return mage.rune_type;
}
