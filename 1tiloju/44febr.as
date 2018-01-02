
//Roleplay gamemode logic script

#define SERVER_ONLY

#include "2efidcr.as";
#include "3kemuc.as";
#include "3mdq1g2.as";
#include "36hb1cn.as";

#include "RulesCore.as";
#include "RespawnSystem.as";

//simple config function - edit the variables below to change the basics

void Config(RPCore@ this)
{
    string configstr = "../Mods/" + RP_NAME + "/Rules/" + RP_NAME + "/roleplay_vars.cfg";
	if (getRules().exists("rpconfig"))
	{
	   configstr = getRules().get_string("rpconfig");
	}
	ConfigFile cfg = ConfigFile( configstr );
	
	//how long to wait for everyone to spawn in?
    s32 warmUpTimeSeconds = cfg.read_s32("warmup_time", 300);
    this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);
    
    //how long for the game to play out?
    s32 gameDurationMinutes = cfg.read_s32("game_time", -1);
    if (gameDurationMinutes <= 0)
    {
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
    else
    {
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	
    //how many players have to be in for the game to start
    this.minimum_players_in_team = cfg.read_s32("minimum_players_in_team", 1);
	
    //whether to scramble each game or not
    this.scramble_teams = cfg.read_bool("scramble_teams", false);

    //spawn after death time 
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 10));

}

shared string base_name() { return "base"; }

//CTF spawn system

const s32 spawnspam_limit_time = 10;

shared class RPSpawns : RespawnSystem
{
    RPCore@ CTF_core;

    bool force;
    s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@CTF_core = cast<RPCore@>(core);
		
		limit = spawnspam_limit_time;
	}

    void Update()
    {
        for (uint team_num = 0; team_num < CTF_core.teams.length; ++team_num )
        {
            CTFTeamInfo@ team = cast<CTFTeamInfo@>( CTF_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
                
                DoSpawnPlayer( info );
            }
        }
    }
    
    void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
    {
		if ( info !is null)
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "ctf spawn time "+info.username;
			
			CTF_core.rules.set_u8( propname, spawn_property );
			CTF_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}

	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {
			//limit how many spawn per second
			if(limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}

			// tutorials hack
			if (getRules().exists("singleplayer")){
				p_info.team = 0;
			}
			
            CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

            if (player is null)
            {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (player.getTeamNum() != int(p_info.team))
            {
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob	  			
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer( null );
				blob.server_Die();					
			}
			
			p_info.blob_name = getMasterClassForBlobName(p_info.blob_name);
            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);

            if (playerBlob !is null)
            {
                // spawn resources
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);
            }
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);

        if (info is null) { warn("CTF LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

        if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ c_info = cast<CTFPlayerInfo@>(p_info);
		if(c_info !is null)
        {
			CBlob@ pickSpawn = getBlobByNetworkID( c_info.spawn_point );
			if (pickSpawn !is null && pickSpawn.hasTag("respawn") && pickSpawn.getTeamNum() == p_info.team)
			{
				return pickSpawn.getPosition();
			}
			else
			{
				CBlob@[] spawns;
				PopulateSpawnList(spawns, p_info.team);
				
				for (uint step = 0; step < spawns.length; ++step)
				{
					if (spawns[step].getTeamNum() == s32(p_info.team) ) {
						return spawns[step].getPosition();
					}
				}
			}
        }

        return Vec2f(0,0);
    }

    void RemovePlayerFromSpawn(CPlayer@ player)
    {
        RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
    }
    
    void RemovePlayerFromSpawn(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);
        
        if (info is null) { warn("CTF LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "ctf spawn time "+info.username;
        
        for (uint i = 0; i < CTF_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(CTF_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		CTF_core.rules.set_u8( propname, 255 ); //not respawning
		CTF_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {
		s32 tickspawndelay = s32(CTF_core.spawnTime);
        
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("CTF LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
		if (info.team < CTF_core.teams.length)
		{
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(CTF_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			
			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }

	bool isSpawning( CPlayer@ player )
	{
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < CTF_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(CTF_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}
	
    string getMasterClassForBlobName( string name )
    {
        if(isClassTypeKnight(name))
	        return "knight";
	    else if(isClassTypeMarksman(name))
	        return "archer";
	    else if(isClassTypeMage(name))
	        return "mage";
	    else
	        return "builder";
    }
	
	bool isClassTypeBuilder( string name )
	{
    	return name == "builder";
	}
	
	bool isClassTypeKnight( string name )
	{
   		 return name == "knight";
	}
	
	bool isClassTypeMarksman( string name )
	{
    	return name == "archer" || name == "crossbowman" || name == "handcannoneer" || name == "musketman";
	}
	
	bool isClassTypeMage( string name )
	{
    	return name == "mage";
	}
};

shared class RPCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

	s32 minimum_players_in_team;

    s32 players_in_small_team;
    bool scramble_teams;

    RPSpawns@ ctf_spawns;

    RPCore() {}

    RPCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }

	
    int gamestart;
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        gamestart = getGameTime();
        @ctf_spawns = cast<RPSpawns@>(_respawns);
        server_CreateBlob( "sound_controller" );
        players_in_small_team = -1;
    }
	
    void Update()
    {
        if (rules.isGameOver()) { return; }

        s32 ticksToStart = gamestart + warmUpTime - getGameTime();
        ctf_spawns.force = false;
		
		if (ticksToStart <= 0 && (rules.isWarmup()))
        {
            rules.SetCurrentState(GAME);
        }
		else if (ticksToStart > 0 && rules.isWarmup())
        {
            rules.SetGlobalMessage("Peacetime ends in " + ((ticksToStart / 30) + 1));
        }
        else if (rules.isMatchRunning())
        {
            rules.SetGlobalMessage("");
        }
		
        RulesCore::Update(); //update respawns
    }

    //HELPERS
    bool allTeamsHavePlayers()
    {
        for (uint i = 0; i < teams.length; i++)
        {
            if (teams[i].players_count < minimum_players_in_team)
            {
                return false;
            }
        }

        return true;
    }

    //team stuff

    void AddTeam(CTeam@ team)
    {
        CTFTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
        CTFPlayerInfo p(player.getUsername(), player.getTeamNum(), player.isBot() ? "knight" : "builder");
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
    }

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null )
		{
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
		}
	}
	
	void onSetPlayer( CBlob@ blob, CPlayer@ player )
	{
		if (blob !is null && player !is null) {
			//GiveSpawnResources( blob, player );
		}
	}

    //setup the CTF bases

    void SetupBase( CBlob@ base )
    {
        if (base is null) {
            return;
        }

        //nothing to do
    }

    void SetupBases()
    {
        // destroy all previous spawns if present
        CBlob@[] oldBases;
        getBlobsByName( base_name(), @oldBases );

        for (uint i=0; i < oldBases.length; i++) {
            oldBases[i].server_Die();
        }
        
        CMap@ map = getMap();

        if (map !is null)
        {
			//spawn the spawns :D
            Vec2f respawnPos;

            if (!getMap().getMarker("blue main spawn", respawnPos ))
            {
				warn("Roleplay: Human spawn added to default position");
                respawnPos = Vec2f(100.0f, map.getLandYAtX(100.0f/map.tilesize)*map.tilesize - 16.0f);
            }
			else
			{
			    print("Roleplay: Human spawn added to map position");
			}

			respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 0, respawnPos ) );

            if (!getMap().getMarker("red main spawn", respawnPos ))
            {
				warn("Roleplay: Dwarf spawn added to default position");
                respawnPos = Vec2f(100.0f, map.getLandYAtX(100.0f/map.tilesize)*map.tilesize - 16.0f);
            }
			else
			{
			    print("Roleplay: Dwarf spawn added to map position");
			}

            respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 1, respawnPos ) );
			
			if (!getMap().getMarker("green main spawn", respawnPos ))
            {
				warn("Roleplay: Elf spawn added to default position");
                respawnPos = Vec2f(map.tilemapwidth*map.tilesize - 100.0f, map.getLandYAtX(map.tilemapwidth - (100.0f/map.tilesize))*map.tilesize- 16.0f);
            }
			else
			{
			    print("Roleplay: Elf spawn added to map position");
			}

            respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 2, respawnPos ) );
			
			if (!getMap().getMarker("purple main spawn", respawnPos ))
            {
				warn("Roleplay: Orc spawn added to default position");
                respawnPos = Vec2f(map.tilemapwidth*map.tilesize - 100.0f, map.getLandYAtX(map.tilemapwidth - (100.0f/map.tilesize))*map.tilesize- 16.0f);
            }
			else
			{
			    print("Roleplay: Orc spawn added to map position");
			}

            respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 3, respawnPos ) );
			
			if (!getMap().getMarker("orange main spawn", respawnPos ))
            {
				warn("Roleplay: Angel spawn added to default position");
                respawnPos = Vec2f(map.tilemapwidth * map.tilesize / 2, map.getLandYAtX(map.tilemapwidth - (100.0f/map.tilesize)) * map.tilesize - 16.0f);
            }
			else
			{
			    print("Roleplay: Angel spawn added to map position");
			}

            respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 4, respawnPos ) );
			
			if (!getMap().getMarker("undead main spawn", respawnPos ))
            {
				warn("Roleplay: Undead spawn added to default position");
                respawnPos = Vec2f(map.tilemapwidth * map.tilesize / 2, map.getLandYAtX(map.tilemapwidth - (100.0f/map.tilesize)) * map.tilesize - 16.0f);
            }
			else
			{
			    print("Roleplay: Undead spawn added to map position");
			}

            respawnPos.y -= 8.0f;
            SetupBase( server_CreateBlob( base_name(), 5, respawnPos ) );
        }

        rules.SetCurrentState(WARMUP);
    }

    void addKill(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            CTFTeamInfo@ team_info = cast<CTFTeamInfo@>( teams[team] );
        }
    }

};

void Reset( CRules@ this )
{
    printf("Restarting rules script: " + getCurrentScriptName() );
	
    RPSpawns spawns();
    RPCore core(this, spawns);
    Config(core);
    core.SetupBases();
	
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
	
	ResetDiplomacy(this);
}

void onRestart( CRules@ this )
{
	Reset( this );
}

void onInit( CRules@ this )
{
	Reset( this );
}
