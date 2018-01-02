/* TechsCommon.as
 * author: Aphelion
 */

#include "3t0evcr.as";

f32 getChainsawMaximumHeatModifier(u8 team)
{
	if(isTechResearched("Machinery III", team))
		return 3.00f;
	else if(isTechResearched("Machinery II", team))
		return 2.25f;
	else if(isTechResearched("Machinery I", team))
		return 1.50f;
	
	return 1.00f;
}

f32 getDrillMaximumHeatModifier(u8 team)
{
	if(isTechResearched("Machinery III", team))
		return 3.00f;
	else if(isTechResearched("Machinery II", team))
		return 2.25f;
	else if(isTechResearched("Machinery I", team))
		return 1.50f;
	
	return 1.00f;
}

f32 getSawWoodModifier(u8 team)
{
	if(isTechResearched("Machinery III", team))
		return 1.50f;
	else if(isTechResearched("Machinery II", team))
		return 1.30f;
	else if(isTechResearched("Machinery I", team))
		return 1.15f;
	
	return 1.00f;
}

f32 getMillGrindTimeModifier(u8 team)
{
	if(isTechResearched("Machinery III", team))
		return 0.50f;
	else if(isTechResearched("Machinery II", team))
		return 0.70f;
	else if(isTechResearched("Machinery I", team))
		return 0.85f;
	
	return 1.00f;
}

f32 getBuilderIncomingDamageModifier(u8 team)
{
	if(isTechResearched("Dwarven Sappers", team))
		return 0.5f;

	return 1.0f;
}

f32 getKnightSpeedModifier(u8 team)
{
	if(isTechResearched("Orc Elite Knights", team))
		return 1.1f;
	else if(isTechResearched("Endurance III", team))
		return 1.0f;
	else if(isTechResearched("Endurance II", team))
		return 0.9f;
	else if(isTechResearched("Endurance I", team))
		return 0.8f;

	return 0.7f;
}

f32 getKnightJumpModifier(u8 team)
{
	if(isTechResearched("Orc Elite Knights", team))
		return 1.1f;

	return 1.0f;
}

f32 getKnightGlideTimeModifier(u8 team)
{
	if(isTechResearched("Orc Elite Knights", team))
		return 2.50f;
	else if(isTechResearched("Shield Gliding III", team))
		return 1.75f;
	else if(isTechResearched("Shield Gliding II", team))
		return 1.50f;
	else if(isTechResearched("Shield Gliding I", team))
		return 1.25f;

	return 1.0f;
}

f32 getMarksmanFireTimeModifier(u8 team)
{
	if(isTechResearched("Elven Master Marksmen", team))
		return 0.70f;
	else if(isTechResearched("Marksmanship III", team))
		return 0.82f;
	else if(isTechResearched("Marksmanship II", team))
		return 0.88f;
	else if(isTechResearched("Marksmanship I", team))
		return 0.94f;
    
	return 1.0f;
}

f32 getMarksmanGrappleLengthModifier(u8 team)
{
	if(isTechResearched("Elven Master Marksmen", team))
		return 2.0f;
	else if(isTechResearched("Grappling III", team))
		return 1.6f;
	else if(isTechResearched("Grappling II", team))
		return 1.4f;
	else if(isTechResearched("Grappling I", team))
		return 1.2f;
    
	return 1.0f;
}

f32 getMageSpellRadiusModifier(u8 team)
{
	if(isTechResearched("Human Archmages", team))
		return 1.5f;
	else if(isTechResearched("Wizardry III", team))
		return 1.3f;
	else if(isTechResearched("Wizardry II", team))
		return 1.2f;
	else if(isTechResearched("Wizardry I", team))
		return 1.1f;

	return 1.0f;
}

f32 getMageAbilityCooldownModifier(u8 team)
{
	if(isTechResearched("Human Archmages", team))
		return 0.20f;
	else if(isTechResearched("Willpower III", team))
		return 0.40f;
	else if(isTechResearched("Willpower II", team))
		return 0.60f;
	else if(isTechResearched("Willpower I", team))
		return 0.80f;

	return 1.00f;
}
