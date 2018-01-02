#include "Help.as"

#define CLIENT_ONLY

void onInit( CRules@ this )
{
	// knight
	AddIconToken( "$Bomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16,32), 0 );
	AddIconToken( "$WaterBomb$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16,32), 2 );
	AddIconToken( "$Satchel$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16,32), 3 );
	AddIconToken( "$Keg$", "Entities/Characters/Knight/KnightIcons.png", Vec2f(16,32), 4 );
	AddIconToken( "$Help_Bomb1$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8,16), 30 );
	AddIconToken( "$Help_Bomb2$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8,16), 31 );
	AddIconToken( "$Swap$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 7 );
	AddIconToken( "$Jab$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 20 );
	AddIconToken( "$Slash$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 21 );
	AddIconToken( "$Shield$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 22 );
	// archer
	AddIconToken( "$Arrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 0 );
	AddIconToken( "$IronArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 1 );
	AddIconToken( "$SteelArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 2 );
	AddIconToken( "$MythrilArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 3 );
	AddIconToken( "$AdamantArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 4 );
	AddIconToken( "$FireArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 5 );
	AddIconToken( "$BombArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 6 );
	AddIconToken( "$WaterArrow$", "Entities/Characters/Archer/ArcherIcons.png", Vec2f(16,32), 7 );
	AddIconToken( "$Daggar$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 10 );			  
	AddIconToken( "$Help_Arrow1$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8,16), 28 );
	AddIconToken( "$Help_Arrow2$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8,16), 29 );
	AddIconToken( "$Swap$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 7 );
	AddIconToken( "$Grapple$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 16 );
	// builder
	AddIconToken( "$Build$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 11 );
	AddIconToken( "$Pick$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 12 );
	AddIconToken( "$Rotate$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 5 );
	AddIconToken( "$Help_Block1$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8,16), 12 );
	AddIconToken( "$Help_Block2$", "Entities/Common/GUI/HelpIcons.png", Vec2f(8,16), 13 );
	AddIconToken( "$Swap$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 7 );
	AddIconToken( "$BlockStone$", "Sprites/world.png", Vec2f(8,8), 96 );

	AddIconToken( "$workshop$", "Entities/Common/GUI/HelpIcons.png", Vec2f(16,16), 2 );
}			  

void onBlobCreated( CRules@ this, CBlob@ blob )
{
	if (!u_showtutorial)
		return;

	const string name = blob.getName();

	if (blob.hasTag("seats") && !blob.hasTag("animal"))
	{
		SetHelp( blob, "help hop", "", " $down_arrow$ Hop inside  $KEY_S$", "", 5 );
		SetHelp( blob, "help hop out", "", " Get out  $KEY_W$", "", 4 );
	}  
	if (blob.hasTag("trader"))
	{
		SetHelp( blob, "help use", "", "$trader$ Buy    $KEY_E$", "", 3 ); 	
	}	 
	if (blob.hasTag("respawn"))
	{
		SetHelp( blob, "help use", "", "$CLASSCHANGE$ Change class    $KEY_E$", "", 3 );
	}		
	if (blob.hasTag("door"))
	{
		SetHelp( blob, "help rotate", "", "$"+blob.getName()+"$"+" $Rotate$ Rotate    $KEY_SPACE$", "", 3 ); 
	}


		
	if (name == "hall")
	{																					
		SetHelp( blob, "help use", "", "$CLASSCHANGE$ Change class    $KEY_E$", "", 5 );
	}
	else if (name == "trap_block")
	{
		SetHelp( blob, "help show", "builder", "$trap_block$ Opens on enemy", "", 15 ); 
	}
	else if (name == "spikes")
	{
		SetHelp( blob, "help show", "builder", "$spikes$ Retracts on enemy if on stone $STONE$", "", 20 ); 
	}	 
	else if (name == "wooden_platform")
	{
		SetHelp( blob, "help rotate", "", "$wooden_platform$  $Rotate$ Rotate    $KEY_SPACE$", "", 3 );  
	}
	else if (name == "ladder")
	{
		SetHelp( blob, "help rotate", "", "$ladder$  $Rotate$ Rotate    $KEY_SPACE$", "", 3 );  
	}
	else if (name == "tdm_ruins")
	{
		SetHelp( blob, "help use", "", "Change class    $KEY_E$", "", 5 );
	}
	else if (name == "lantern")
	{
		SetHelp( blob, "help activate", "", "$lantern$ On/Off     $KEY_SPACE$", "" ); 
		SetHelp( blob, "help pickup", "", "$lantern$ Pick up    $KEY_C$" ); 
	}
	else if (name == "satchel")
	{
		SetHelp( blob, "help activate", "knight", "$satchel$ Light     $KEY_SPACE$", "$satchel$ Only KNIGHT can light satchel", 3 ); 
		SetHelp( blob, "help throw", "knight", "$satchel$ THROW!    $KEY_SPACE$", "", 3 ); 
	}  
	else if (name == "log")
	{
		SetHelp( blob, "help action2", "builder", "$log$ Chop $mat_wood$   $RMB$", "", 3 ); 
	}  
	else if (name == "keg")
	{
		SetHelp( blob, "help pickup", "", "$keg$Pick up    $KEY_C$", "", 3 ); 
		SetHelp( blob, "help activate", "knight", "$keg$Light    $KEY_SPACE$", "$keg$Only KNIGHT can light keg", 5 ); 
		SetHelp( blob, "help throw", "", "$keg$THROW!    $KEY_SPACE$", "", 3 ); 
	}  
	else if (name == "bomb")
	{
		SetHelp( blob, "help throw", "", "$mat_bombs$THROW!    $KEY_SPACE$", "", 3 ); 
	}  
	else if (name == "crate")
	{
		SetHelp( blob, "help pickup", "", "$crate$Pick up    $KEY_C$", "", 3 ); 		
	}  
	else if (name == "workbench")
	{						   
		SetHelp( blob, "help use", "", "$workbench$    $KEY_TAP$$KEY_E$", "", 4 ); 
	}  
	else if (name == "catapult" || name == "ballista")
	{						   
		SetHelp( blob, "help DRIVER movement", "", "$"+blob.getName()+"$"+"Drive     $KEY_A$ $KEY_S$ $KEY_D$", "", 3 );
		SetHelp( blob, "help GUNNER action", "", "$"+blob.getName()+"$"+"FIRE     $KEY_HOLD$$LMB$", "", 3 ); 
	}  
	else if (name == "mounted_bow")
	{						   
		SetHelp( blob, "help GUNNER action", "", "$"+blob.getName()+"$"+"FIRE     $LMB$", "", 3 ); 
	}  
	else if (name == "food")
	{						   
		SetHelp( blob, "help switch", "", "$food$Take out food  $KEY_HOLD$$KEY_F$", "", 3 );
	} 
	else if (name == "boulder")
	{
		SetHelp( blob, "help pickup", "", "$boulder$ Pick up    $KEY_C$" ); 
	}
	//else if (name == "tent")
	//{
	//	SetHelp( blob, "help use", "", "Change class    $KEY_E$", "", 5 );
	//}
	else if (name == "building")
	{
		SetHelp( blob, "help use", "", "$building$Construct    $KEY_E$", "", 3 );
	}
	else if (name == "archershop" || name == "boatshop" || name == "knightshop" || name == "buildershop" || name == "vehicleshop")
	{
		SetHelp( blob, "help use", "", "$building$Use    $KEY_E$", "", 3 );
	}
	//else if (name == "ctf_flag")
	//{
	//	SetHelp( blob, "help use", "", "$$ctf_flag$ Bring enemy flag to capture", "", 3 );
	//}	 
}
