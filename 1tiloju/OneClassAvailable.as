// OneClassAvailable.as

#include "StandardRespawnCommand.as";

const string req_class = "required class";

void onInit(CBlob@ this)
{
	this.Tag("change class drop inventory");
	if (!this.exists("class offset")) {
		this.set_Vec2f("class offset", Vec2f(0, -16));
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.exists(req_class)) {
		return;
	}

	string cfg = this.get_string(req_class);
	if (canChangeClass(this,caller) && caller.getName() != cfg) {
		CBitStream params;
		write_classchange(params, caller.getNetworkID(), cfg);
		caller.CreateGenericButton("$change_class$", this.get_Vec2f("class offset"), this, SpawnCmd::changeClass, "Swap Class", params );
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	AddIconToken( "$change_class$", "GUI/InteractionIcons.png", Vec2f(32,32), 12, 2 );
	
	onRespawnCommand( this, cmd, params );
}
