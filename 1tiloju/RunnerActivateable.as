void onInit( CBlob@ this )
{
    //these don't actually use it, they take the controls away
	this.push("names to activate", "lantern");
	this.push("names to activate", "beer");
	this.push("names to activate", "potion_swiftness");
	this.push("names to activate", "potion_feather");
	this.push("names to activate", "potion_waterbreathing");
	this.push("names to activate", "potion_invisibility");
	this.push("names to activate", "potion_rockskin");
	this.push("names to activate", "potion_regeneration");
	this.push("names to activate", "potion_sapping");
	this.push("names to activate", "potion_mystery");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
