/* 3jt3pus.as
 * author: Aphelion
 */

#include "upmpi5.as";

#include "Requirements.as";
#include "5ggqoj.as";

const string equipment_property = "equipment";
const string default_equip = "default";

const u8 SLOT_ARMOUR = 0;
const u8 SLOT_WEAPON = 1;

const f32 drop_weapon_probability = 0.75f; //between 0 and 1
const f32 drop_armour_probability = 0.75f; //between 0 and 1

shared class Equipment
{
    string name;
    string icon;
	string swapToBlob;
	u8 slot;
    string description;
	bool defaultEquip;
	bool swapBlob;
    CBitStream reqs;

    Equipment() {} // required for handles to work

    Equipment( bool _defaultEquip, string _name, string _icon, string _swapToBlob, u8 _slot, string _desc, bool _swapBlob = false)
    {
        name = _name;
        icon = _icon;
		swapToBlob = _swapToBlob;
        slot = _slot;
        description = _desc;
		defaultEquip = _defaultEquip;
		swapBlob = _swapBlob;
    }
};

string getDefaultEquipment( CBlob@ this, u8 slot )
{
    Equipment[]@ equipment;

    if (this.get(equipment_property, @equipment))
    {
        for (uint i = 0; i < equipment.length; i++)
        {
            if (equipment[i].slot == slot && equipment[i].defaultEquip)
                return equipment[i].name;
        }
    }
    return default_equip;
}

Equipment@ getEquipmentByBlobName( CBlob@ this, string blobName )
{
    Equipment[]@ equipment;

    if (this.get(equipment_property, @equipment))
    {
        for (uint i = 0; i < equipment.length; i++)
        {
            if (equipment[i].name == blobName)
                return equipment[i];
        }
    }

    warn("getEquipmentByBlobName() equipment not found");
    return null;
}

void addCommonEquipment( CBlob@ this, Equipment[]@ equipment )
{
    {
    	if(isClassTypeKnight(this))
		{
			{   // Copper chestplate
				Equipment e( true, "default_chestplate", "$copper_chestplate$", "", SLOT_ARMOUR, "Copper chestplate\nThe default armour of the Knight\nNo bonus", false );
				equipment.push_back( e );
			}
			{   // Iron chestplate
				Equipment e( false, "iron_chestplate", "$iron_chestplate$", "", SLOT_ARMOUR, "Iron chestplate\nDefence rating of 30", false );
		        AddRequirement( e.reqs, "blob", "iron_chestplate", "Iron chestplate", 1 );
				equipment.push_back( e );
			}
			{   // Steel chestplate
				Equipment e( false, "steel_chestplate", "$steel_chestplate$", "", SLOT_ARMOUR, "Steel chestplate\nDefence rating of 40", false );
		        AddRequirement( e.reqs, "blob", "steel_chestplate", "Steel chestplate", 1 );
				equipment.push_back( e );
			}
			{   // Mythril chestplate
				Equipment e( false, "mythril_chestplate", "$mythril_chestplate$", "", SLOT_ARMOUR, "Mythril chestplate\nDefence rating of 50", false );
		        AddRequirement( e.reqs, "blob", "mythril_chestplate", "Mythril chestplate", 1 );
				equipment.push_back( e );
			}
			{   // Adamant chestplate
				Equipment e( false, "adamant_chestplate", "$adamant_chestplate$", "", SLOT_ARMOUR, "Adamant chestplate\nDefence rating of 60", false );
		        AddRequirement( e.reqs, "blob", "adamant_chestplate", "Adamant chestplate", 1 );
				equipment.push_back( e );
			}
			{   // Golden chestplate
				Equipment e( false, "gold_chestplate", "$gold_chestplate$", "", SLOT_ARMOUR, "Golden chestplate\nDefence rating of 65", false );
		        AddRequirement( e.reqs, "blob", "gold_chestplate", "Golden chestplate", 1 );
				equipment.push_back( e );
			}
			{   // Dragon chestplate
				Equipment e( false, "dragon_chestplate", "$dragon_chestplate$", "", SLOT_ARMOUR, "Dragon chestplate\nDefence rating of 70\nGrants you Dragon wings", false );
		        AddRequirement( e.reqs, "blob", "dragon_chestplate", "Dragon chestplate", 1 );
				equipment.push_back( e );
			}
			
			{   // Copper sword
				Equipment e( true, "default_sword", "$copper_sword$", "knight", SLOT_WEAPON, "Copper sword\nThe default weapon of the Knight\nStab: 1 Slash: 2 Power: 4 Speed: Fastest", true );
				equipment.push_back( e );
			}
			{   // Iron sword
				Equipment e( false, "iron_sword", "$iron_sword$", "knight", SLOT_WEAPON, "Iron sword\nStab: 1.25 Slash: 2.5 Power: 5 Speed: Fastest", true );
		        AddRequirement( e.reqs, "blob", "iron_sword", "Iron sword", 1 );
				equipment.push_back( e );
			}
			{   // Steel sword
				Equipment e( false, "steel_sword", "$steel_sword$", "knight", SLOT_WEAPON, "Steel sword\nStab: 1.5 Slash: 3 Power: 6 Speed: Fastest", true );
		        AddRequirement( e.reqs, "blob", "steel_sword", "Steel sword", 1 );
				equipment.push_back( e );
			}
			{   // Mace
				Equipment e( false, "mace", "$mace$", "maceman", SLOT_WEAPON, "Mace\nStab: 1.125 Slash: 3.75 Power: 8.1 Speed: Slow\nOne in four chance to ignore 15 Defence rating", true );
		        AddRequirement( e.reqs, "blob", "mace", "Mace", 1 );
				equipment.push_back( e );
			}
			{   // War Axe
				Equipment e( false, "war_axe", "$war_axe$", "axeman", SLOT_WEAPON, "War Axe\nStab: 0.75 Slash: 3.375 Power: 7.0 Speed: Fast\nOne in four chance to hit through shield", true );
		        AddRequirement( e.reqs, "blob", "war_axe", "War axe", 1 );
				equipment.push_back( e );
			}
			{   // Golden sword
				Equipment e( false, "gold_sword", "$gold_sword$", "knight", SLOT_WEAPON, "Golden sword\nStab: 1.75 Slash: 3.5 Power: 7 Speed: Fastest", true );
		        AddRequirement( e.reqs, "blob", "gold_sword", "Golden sword", 1 );
				equipment.push_back( e );
			}
			{   // Dragon spear
				//Equipment e( false, "dragon_sword", "$dragon_sword$", "knight", SLOT_WEAPON, "Dragon spear\nStab: 2.5 Slash: 2.5 Power: ?\nSaps the life of your opponent", true );
				Equipment e( false, "dragon_sword", "$dragon_sword$", "knight", SLOT_WEAPON, "Dragon sword\nStab: 2 Slash: 4 Power: 8", true );
		        AddRequirement( e.reqs, "blob", "dragon_sword", "Dragon sword", 1 );
				equipment.push_back( e );
			}
		}
	}
	
	{
		if(isClassTypeMarksman(this))
		{
			{   // Copper chainmail
				Equipment e( true, "default_chainmail", "$no_chainmail$", "", SLOT_ARMOUR, "Copper chainmail\nNo bonus", false );
				equipment.push_back( e );
			}
			{   // Iron chainmail
				Equipment e( false, "iron_chainmail", "$iron_chainmail$", "", SLOT_ARMOUR, "Iron chainmail\nDefence rating of 30", false );
		        AddRequirement( e.reqs, "blob", "iron_chainmail", "Iron chainmail", 1 );
				equipment.push_back( e );
			}
			{   // Steel chainmail
				Equipment e( false, "steel_chainmail", "$steel_chainmail$", "", SLOT_ARMOUR, "Steel chainmail\nDefence rating of 40", false );
		        AddRequirement( e.reqs, "blob", "steel_chainmail", "Steel chainmail", 1 );
				equipment.push_back( e );
			}
			{   // Mythril chainmail
				Equipment e( false, "mythril_chainmail", "$mythril_chainmail$", "", SLOT_ARMOUR, "Mythril chainmail\nDefence rating of 50", false );
		        AddRequirement( e.reqs, "blob", "mythril_chainmail", "Mythril chainmail", 1 );
				equipment.push_back( e );
			}
			{   // Adamant chainmail
				Equipment e( false, "adamant_chainmail", "$adamant_chainmail$", "", SLOT_ARMOUR, "Adamant chainmail\nDefence rating of 60", false );
		        AddRequirement( e.reqs, "blob", "adamant_chainmail", "Adamant chainmail", 1 );
				equipment.push_back( e );
			}
			{   // Armadyl chainmail
				Equipment e( false, "armadyl_chainmail", "$armadyl_chainmail$", "", SLOT_ARMOUR, "Armadyl chainmail\nDefence rating of 70\nGrants you Angelic wings", false );
		        AddRequirement( e.reqs, "blob", "armadyl_chainmail", "Armadyl chainmail", 1 );
				equipment.push_back( e );
			}
			
			{   // Composite bow
				Equipment e( true, "default_bow", "$composite_bow$", "archer", SLOT_WEAPON, "Composite bow\nThe default weapon of the Marksman", true );
				equipment.push_back( e );
			}
			{   // Crossbow
				Equipment e( false, "default_crossbow", "$crossbow$", "crossbowman", SLOT_WEAPON, "Crossbow\nA slower firing, yet more accurate bow", true );
				equipment.push_back( e );
			}
			{   // Musket
				Equipment e( false, "musket", "$musket$", "musketman", SLOT_WEAPON, "Musket\nA powerful sniping weapon\nInflicts 4 damage", true );
				AddRequirement( e.reqs, "blob", "musket", "Musket", 1 );
				equipment.push_back( e );
			}
			{   // Hand cannon
				Equipment e( false, "hand_cannon", "$hand_cannon$", "handcannoneer", SLOT_WEAPON, "Hand cannon\nA powerful siege weapon\nInflicts heavy damage against structures", true );
				AddRequirement( e.reqs, "blob", "hand_cannon", "Hand cannon", 1 );
				equipment.push_back( e );
			}
			{   // Shotgun
				Equipment e( false, "shotgun", "$shotgun$", "shotgunner", SLOT_WEAPON, "Shotgun", true );
				AddRequirement( e.reqs, "blob", "shotgun", "Shotgun", 1 );
				equipment.push_back( e );
			}
			{   // Armadyl crossbow
				Equipment e( true, "armadyl_crossbow", "$armadyl_crossbow$", "archer_armadyl", SLOT_WEAPON, "Armadyl crossbow", true );
				equipment.push_back( e );
			}
		}
	}
	
	{
		if(isClassTypeMage(this))
		{
			//{   // Aura of Healing
			//	Equipment e( true, "aura_default", "$aura_default$", "mage", SLOT_ARMOUR, "Aura of Healing\nNo bonus\nHeal yourself and allies\nCooldown of 15 seconds", true );
			//	equipment.push_back( e );
			//}
			{   // Aura of Shadow
				Equipment e( true, "aura_default", "$aura_default$", "mage", SLOT_ARMOUR, "Aura of Shadow\nDefence rating of 10\nBecome invisible for up to 20 seconds\nCooldown of 10 seconds", true );
				equipment.push_back( e );
			}
			{   // Aura of Teleportation
				Equipment e( true, "aura_teleportation", "$aura_teleportation$", "mage", SLOT_ARMOUR, "Aura of Teleportation\nDefence rating of 30\nTeleport to somewhere nearby\nCooldown of 30 seconds", true );
				AddRequirement( e.reqs, "blob", "aura_teleportation", "Aura of Teleportation", 1 );
				equipment.push_back( e );
			}
			{   // Aura of Flight
				Equipment e( true, "aura_flight", "$aura_flight$", "mage", SLOT_ARMOUR, "Aura of Flight\nDefence rating of 50\nGrants you Angelic wings", true );
				AddRequirement( e.reqs, "blob", "aura_flight", "Aura of Flight", 1 );
				equipment.push_back( e );
			}
			
			{   // Wizard's staff
				Equipment e( true, "default_staff", "$staff$", "mage", SLOT_WEAPON, "Wizard's staff", true );
				equipment.push_back( e );
			}
			/*{  // Druid's staff
				Equipment e( true, "druid_staff", "$staff$", "mage", SLOT_WEAPON, "Druid's staff", true );
				equipment.push_back( e );
			}
			{   // Nus's staff
				Equipment e( true, "nus_staff", "$staff$", "mage", SLOT_WEAPON, "Nus's staff", true );
				equipment.push_back( e );
			}
			{   // Noom's staff
				Equipment e( true, "noom_staff", "$staff$", "mage", SLOT_WEAPON, "Noom's staff", true );
				equipment.push_back( e );
			}*/
		}
	}
}

bool isSpecialItem( string name )
{
    return name.findFirst("dragon") != -1 ||
	       name.findFirst("armadyl") != -1 ||
		   name.findFirst("gold") != -1 ||
		   name == "aura_flight";
}

bool isDefaultItem( string name )
{
    return name.findFirst("default") != -1;
}

string getEquipmentSlotItem( CBlob@ this, u8 slot )
{
    return this.get_string("equip_slot_" + slot);
}

void setEquipmentSlotItem( CBlob@ this, string item, u8 slot )
{
    this.set_string("equip_slot_" + slot, item);
	this.Sync("equip_slot_" + slot, true);
}

/* Extremely important. When you equip armour or swap to another type of weapon you get a new blob.
 * Therefore equipment data must be transferred to the new blob.
 */
void transferEquipmentData( CBlob@ fromBlob, CBlob@ toBlob )
{
    toBlob.set_string("equip_slot_" + 0, getEquipmentSlotItem(fromBlob, 0));
	toBlob.set_string("equip_slot_" + 1, getEquipmentSlotItem(fromBlob, 1));
	toBlob.Sync("equip_slot_" + 0, true);
	toBlob.Sync("equip_slot_" + 1, true);
}

float getDamageModifier( CBlob@ this, u8 hitter )
{
    float modifier = 1.0f;
	
    string armour = getEquipmentSlotItem(this, SLOT_ARMOUR);
	if    (armour == "aura_default")
	    modifier = 0.9f;
	if    (armour == "iron_chestplate" || armour == "iron_chainmail" || armour == "aura_teleportation")
	    modifier = 0.7f;
	else if (armour == "steel_chestplate" || armour == "steel_chainmail")
	    modifier = 0.6f;
	else if (armour == "mythril_chestplate" || armour == "mythril_chainmail" || armour == "aura_flight")
	    modifier = 0.5f;
	else if (armour == "adamant_chestplate" || armour == "adamant_chainmail")
	    modifier = 0.4f;
	else if (armour == "gold_chestplate")
	    modifier = 0.35f;
	else if (armour == "dragon_chestplate" || armour == "armadyl_chainmail")
	    modifier = 0.3f;
	
	if (modifier < 1.0f)
    {
	    if (hitter == Hitters::mace_power)
		    modifier = Maths::Min(modifier + 0.15f, 1.0f);
		else if (hitter == Hitters::piercing_arrow)
		    modifier = Maths::Min(modifier + 0.10f, 1.0f);
	}
	return modifier;
}
