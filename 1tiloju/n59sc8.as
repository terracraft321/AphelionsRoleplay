/* n59sc8.as
 * author: Aphelion
 */

void onInit( CBlob@ this )
{
	this.Tag("portal");
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.getSprite().getConsts().accurateLighting = true;
	
	this.set_Vec2f("teleport button pos", Vec2f(-4, 0));
	
	// LIGHT
	this.SetLight(true);
	this.SetLightRadius(64.0f);
    this.SetLightColor(SColor(255, 255, 0, 0));
}

