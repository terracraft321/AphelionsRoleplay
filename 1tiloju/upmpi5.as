/* upmpi5.as
 * author: Aphelion
 *
 * Utility script for categorizing classes.
 */

bool isClassTypeBuilder( CBlob@ this )
{
    if(this !is null)
	{
	    string name = this.getName();
		
		return name == "builder";
	}
    return false;
}

bool isClassTypeKnight( CBlob@ this )
{
    if(this !is null)
	{
	    string name = this.getName();
		
		return name == "knight" || name == "maceman" || name == "axeman";
	}
    return false;
}

bool isClassTypeMarksman( CBlob@ this )
{
    if(this !is null)
	{
	    string name = this.getName();
		
		return name == "archer" || name == "crossbowman" || name == "handcannoneer" || name == "musketman";
	}
    return false;
}

bool isClassTypeMage( CBlob@ this )
{
    if(this !is null)
	{
	    string name = this.getName();
		
		return name == "mage";
	}
    return false;
}

bool isClassTypeBuilder( string name )
{
    return name == "builder";
}

bool isClassTypeKnight( string name )
{
   	return name == "knight" || name == "maceman" || name == "axeman";
}
	
bool isClassTypeMarksman( string name )
{
    return name == "archer" || name == "crossbowman" || name == "handcannoneer" || name == "musketman";
}
	
bool isClassTypeMage( string name )
{
    return name == "mage";
}
