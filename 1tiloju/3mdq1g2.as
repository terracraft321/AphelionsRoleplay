// management structs

#include "Rules/CommonScripts/BaseTeamInfo.as";
#include "Rules/CommonScripts/PlayerInfo.as";

namespace ItemFlag {

const u32 Builder = 0x01;
const u32 Archer = 0x02;
const u32 Knight = 0x04;

}

shared class CTFPlayerInfo : PlayerInfo
{
    u32 can_spawn_time;

	u32 flag_captures;
	
	u32 spawn_point;
	
	u32 items_collected;
	
    CTFPlayerInfo() { Setup( "", 0, "" ); }
    CTFPlayerInfo(string _name, u8 _team, string _default_config ) { Setup( _name, _team, _default_config ); }

    void Setup( string _name, u8 _team, string _default_config )
    {
        PlayerInfo::Setup(_name,_team,_default_config);
        can_spawn_time = 0;
        flag_captures = 0;
        spawn_point = 0;
        
        items_collected = 0;
    }
};

//teams

shared class CTFTeamInfo : BaseTeamInfo
{
    PlayerInfo@[] spawns;

    CTFTeamInfo() { super(); }

    CTFTeamInfo(u8 _index, string _name)
    {
        super(_index, _name);
    }

    void Reset()
    {
        BaseTeamInfo::Reset();
        //spawns.clear();
    }
};

//how each team is serialised

shared class CTF_HUD
{
    //is this our team?
    u8 team_num;
    //easy serial
    string flag_pattern;
    
    CTF_HUD() { }
    CTF_HUD(CBitStream@ bt) { Unserialise(bt); }

    void Serialise(CBitStream@ bt)
    {
        bt.write_u8(team_num);
        bt.write_string(flag_pattern);
    }

    void Unserialise(CBitStream@ bt)
    {
        team_num = bt.read_u8();
        flag_pattern = bt.read_string();
    }

};
