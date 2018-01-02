/* 3b12g16.as
 * author: Aphelion
 */

#include "Help.as";

void onInit(CBlob@ this)
{
	SetHelp(this, "help use carried", "", "$scroll$Use magic scroll    $KEY_E$");
	
	this.SetLight(true);
	this.SetLightRadius(24.0f);
    this.SetLightColor(SColor(255, 0, 255, 0));
}
