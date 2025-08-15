using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
    
DEBUGMODE : logic = false

CustomUIWidgets := module :
    WidgetMaterials<public> := module: 

var SavedPlayerData:weak_map(player, saved_data) = map{}

Game_Manager := class(creative_device):
    @editable DebugControllerDevice : DebugController = DebugController{}
    @editable ChallengeManagerDevice : Challenge_Manager = Challenge_Manager{}

    ## Variables ## 
    var CustomUI:custom_ui_creator=custom_ui_creator{PlayerToCustomPlayerMap:=map{},RealTimeProp:=false, CurrencyManager := Currency_Manager{}}
    var CustomPlayers:[player]custom_player=map{}
    var LevelsToArrayCustomPlayersMap:[custom_level][]custom_player=map{}
    var GameRunning:logic=false

    var AllWeapons:[]item=array{}
    var AllSpecials:[]item=array{}
    var AllHeals:[]item=array{}
    var AllThrowables:[]item=array{}
    var AllAbilities:[]item=array{}
    var AllItems:[]item=array{}

    ## Editables ## 
    @editable BrainRotSFX : []audio_player_device = array{}
    @editable NoLaPolizia : audio_player_device = audio_player_device{}
    @editable RealTimeProp : creative_prop = creative_prop{}

    @editable ShowCinematicTrigger: trigger_device=trigger_device{}
    @editable IntroCinematic : cinematic_sequence_device=cinematic_sequence_device{}
    @editable IntroCinematicPersonal : cinematic_sequence_device=cinematic_sequence_device{}

    @editable BasementPulse:objective_device=objective_device{}

    @editable ItemShopButton:button_device=button_device{}
    @editable ShopPulse:objective_device=objective_device{}
    @editable HealShopButton:button_device=button_device{}
    @editable HealShopPulse:objective_device=objective_device{}

    @editable DamageMultiplier:damage_amplifier_powerup_device=damage_amplifier_powerup_device{}
    @editable GoldDiggerGranter:item_granter_device=item_granter_device{}

    <# @editable CloseUIInput : input_trigger_device = input_trigger_device{}
    @editable CloseUIHUD : hud_message_device = hud_message_device{} #>

    @editable PlaytimeTimerUI : timer_device = timer_device{}
    @editable HighestLevelClearedUI : stat_creator_device = stat_creator_device{}

    #@editable PlaytimeTrackerChallenge_StatCreator : stat_creator_device = stat_creator_device{}
    @editable PlaytimeTimer : timer_device = timer_device{}
    @editable CurrentLevelsCleared_StatCreator:stat_creator_device=stat_creator_device{}

    @editable EvilLaughSFX : audio_player_device = audio_player_device{}
    @editable EvilGuyWidget : hud_message_device = hud_message_device{}
    @editable EvilGuyDisppearVFX : creative_prop_asset=DefaultCreativePropAsset
    #@editable BossesEliminatedChallenge_StatCreator:stat_creator_device=stat_creator_device{}

    #@editable TotalLevelsCleared_StatCreator:stat_creator_device=stat_creator_device{}

    @editable ClearInventory:item_remover_device=item_remover_device{}
    @editable DBNOInput : input_trigger_device = input_trigger_device{}
    @editable DBNOHUD : hud_message_device = hud_message_device{}

    @editable RoundSettings:round_settings_device=round_settings_device{}

    @editable EndGameMessage:hud_message_device=hud_message_device{}
    @editable EndGameButton:popup_dialog_device=popup_dialog_device{}

    ## Currency functionality ##
    @editable{Categories := array{Currency}} CurrencyManager:Currency_Manager=Currency_Manager{}


    Common:common=common{}
    Uncommon:uncommon=uncommon{}
    Rare:rare=rare{}
    Epic:epic=epic{}
    Legendary:legendary=legendary{}
    Exotic:exotic=exotic{}
    Mythic:mythic=mythic{}


    ### Item Granters ###
    #Pistol
    @editable{Categories := array{Pistol}} Pistol_Tactical_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Pistol}} Pistol_Suppresed_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Pistol}} Pistol_Dual_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Pistol}} Pistol_HandCanon_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Pistol}} Pistol_KillSwitchRevolvers_Granter:item_granter_device=item_granter_device{}
    #SMG
    @editable{Categories := array{SMG}} SMG_Recoil_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{SMG}} SMG_FirePetal_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{SMG}} SMG_Charge_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{SMG}} SMG_DualMicro_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{SMG}} SMG_SurgeFire_Granter:item_granter_device=item_granter_device{}
    #Shotgun
    @editable{Categories := array{Shotgun}} Shotgun_CoreDPS_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Shotgun}} Shotgun_Combat_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Shotgun}} Shotgun_Standard_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Shotgun}} Shotgun_PumpNDump_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Shotgun}} Shotgun_Drum_Granter:item_granter_device=item_granter_device{}
    #Assault
    @editable{Categories := array{Assault}} Assault_Auto_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Assault}} Assault_SemiAuto_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Assault}} Assault_PistolCaliber_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Assault}} Assault_Fury_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Assault}} Assault_MK_Granter:item_granter_device=item_granter_device{}
    #Sniper
    @editable{Categories := array{Sniper}} Hunter_BoltAction_Sniper_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Sniper}} FalconEye_Sniper_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Sniper}} RailGun_Sniper_Granter:item_granter_device=item_granter_device{}
    #Misc
    @editable{Categories := array{Misc}} Rocket_Launcher_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Misc}} Launcher_Grenade_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Misc}} ExCalliber_Rifle_Granter:item_granter_device=item_granter_device{}
    #Special
    @editable{Categories := array{Special}} Heisted_Accelerant_Shotgun:item_granter_device=item_granter_device{}
    @editable{Categories := array{Special}} Shadow_Tracker:item_granter_device=item_granter_device{}
    @editable{Categories := array{Special}} Dragons_Breath_Sniper:item_granter_device=item_granter_device{}
    @editable{Categories := array{Special}} HopRock_Dualies:item_granter_device=item_granter_device{}
    @editable{Categories := array{Special}} Chiller_Launcher:item_granter_device=item_granter_device{}
    @editable{Categories := array{Special}} ThunderBolt_Of_Zeus_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Special}} Typhoon_Blade_Granter:item_granter_device=item_granter_device{}
    #Healing
    @editable{Categories := array{Heals}} Apple_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Heals}} Banana_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Heals}} Bandage_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Heals}} Medkit_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Heals}} Medmist_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Heals}} Flopper_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Heals}} ChugSplash_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Heals}} BananaOfTheGods_Granter:item_granter_device=item_granter_device{}
    #Throwables
    @editable{Categories := array{Throwables}} Grenade_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} PortAShack_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} DanceGrenade_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} FireflyJar_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} ImpulseGrenade_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} ProximityMine_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} ShieldBubble_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} Present_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} BottleRockets_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} BusinessTurret_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} ClusterClinger_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} CowCatcher_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Throwables}} Dynamite_Granter:item_granter_device=item_granter_device{}

    OnBegin<override>()<suspends>:void=
        Print("Game Started")
        PlayIntro()
        DebugControllerDevice.SetDebugMode(DEBUGMODE)
        RoundSettings.DisableMatchmaking()
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        spawn{Initialization()}
        IntroCinematic.StoppedEvent.Subscribe(GameStart)
        EndGameButton.RespondingButtonEvent.Subscribe(EndGameFunctionality)

    OnPlayerLeftServer(PlayerLeaving:player):void=
        if(CustomPlayer:=CustomPlayers[PlayerLeaving]):
            UpdatePlayerUnlockedWeapons(CustomPlayer.Player)
            CustomPlayer.Dispose()
            var NewCustomPlayerMap:[player]custom_player=map{}
            for(Key->Value:CustomPlayers,Key<>PlayerLeaving):
                set NewCustomPlayerMap=ConcatenateMaps(NewCustomPlayerMap,map{Key=>Value})
            set CustomPlayers=NewCustomPlayerMap

    ############################################################################################################
    #Init Items ################################################################################################
    Initialization()<suspends> : void = 
        InitItems()
        InitSpawners()
        Sleep(2.0)
        InitLevels()
        InitCustomUI()
        CurrencyManager.InitCurrencyManager(CustomPlayers)
        ChallengeManagerDevice.InitChallengeManager(CustomPlayers)

    InitItems():void=
        set AllWeapons = array : 
            PistolTactical()
            PistolSuppresed()
            PistolHandCanon()
            PistolDual()
            PistolKillSwitchRevolver()
            SMGRecoil()
            SMGFirePetal()
            SMGCharge()
            SMGDualMicro()
            SMGSurgefire()
            ShotgunCoreDPS()
            ShotgunCombat()
            ShotgunStandard()
            ShotgunDrum()
            ShotgunPumpNDump()
            AssaultAuto()
            AssaultSemiAuto()
            AssaultPistolCaliber()
            AssaultFury()
            AssaultMK()
            HunterBoltAction()
            SniperRailGun()
            SniperFalconEye()
            RocketLauncher()
            LauncherGrenade()
            ExCalliberRifle()
            
        set AllSpecials = array :
            HeistedAccelerantShotgun()
            ShadowTracker()
            DragonsBreathSniper()
            HopRockDualies()
            #ChillerLauncher()
            ZeusThunderbolt()
            TyphoonBlade()

        set AllHeals = array :
            AppleCommon()
            BananaCommon()
            BandageCommon()
            MedkitUncommon()
            MedmistUncommon()
            FlopperUncommon()
            ChugSplashRare()
            BananaOfTheGodsLegendary()

        set AllThrowables = array:
            GrenadeCommon()
            CowCatcherCommon()
            PortAShackUncommon()
            ShieldBubbleUncommon()
            BottleRocketsUncommon()
            DynamiteUncommon()
            ClusterClingerUncommon()
            DanceGrenadeRare()
            FireflyJarRare()
            ImpulseGrenadeRare()
            ProximityMineRare()
            BusinessTurretEpic()
            PresentLegendary()

        set AllAbilities = array:
            GrantGoldUncommon()
            GrantGoldRare()
            GrantHealthUncommon()
            GrantHealthRare()
            IncreaseMaxHealth()
            HealthRegen()
            LifeSteal()
            #GoldDigger()
            #DamageInc()
            #Respawn()

        set AllItems += AllWeapons + AllSpecials + AllHeals + AllThrowables + AllAbilities
        set CustomUI.LTOArray =  AllSpecials <# + array{RocketLauncherEpic(), RocketLauncherLegendary()} #>

    PistolTactical():pistol=pistol{Name<override>:="COMBAT PISTOL",Icon<override>:=Icons.IC_PistolTactical,BasePrice<override>:=50,Granter:=Pistol_Tactical_Granter}
    PistolSuppresed():pistol=pistol{Name<override>:="SUPPRESED PISTOL",Icon<override>:=Icons.IC_Suppresed_Pistol,BasePrice<override>:=75,Granter:=Pistol_Suppresed_Granter}
    PistolHandCanon():pistol=pistol{Name<override>:="HAND CANON",Icon<override>:=Icons.IC_Hand_Canon,BasePrice<override>:=125,Granter:=Pistol_HandCanon_Granter,MinRarity:=Rare}
    PistolKillSwitchRevolver():pistol=pistol{Name<override>:="KILLSWITCH REVOLVERS",Icon<override>:=Icons.IC_Killswitch_Revolvers,BasePrice<override>:=250,Granter:=Pistol_KillSwitchRevolvers_Granter,MinRarity:=Rare}
    PistolDual():pistol=pistol{Name<override>:="DUAL PISTOLS",Icon<override>:=Icons.IC_Dual_Pistol,BasePrice<override>:=100,Granter:=Pistol_Dual_Granter,MinRarity:=Uncommon}
    SMGRecoil():smg=smg{Name<override>:="COMBAT SMG",Icon<override>:=Icons.IC_SMGRecoil,BasePrice<override>:=100,Granter:=SMG_Recoil_Granter}
    SMGFirePetal():smg=smg{Name<override>:="PRECISION SMG",Icon<override>:=Icons.IC_Veiled_Presicion_SMG,BasePrice<override>:=100,Granter:=SMG_FirePetal_Granter}
    SMGCharge():smg=smg{Name<override>:="CHARGE SMG",Icon<override>:=Icons.IC_Charge_SMG,BasePrice<override>:=115,Granter:=SMG_Charge_Granter}
    SMGDualMicro():smg=smg{Name<override>:="DUAL MICRO SMG",Icon<override>:=Icons.IC_Dual_Micro_SMG,BasePrice<override>:=125,Granter:=SMG_DualMicro_Granter}
    SMGSurgefire():smg=smg{Name<override>:="SURGE FIRE SMG",Icon<override>:=Icons.IC_Surgefire_SMG,BasePrice<override>:=125,Granter:=SMG_SurgeFire_Granter}
    ShotgunCoreDPS():shotgun=shotgun{Name<override>:="AUTO SHOTGUN",Icon<override>:=Icons.IC_ShotgunCoreDPS,BasePrice<override>:=80,Granter:=Shotgun_CoreDPS_Granter}
    ShotgunCombat():shotgun=shotgun{Name<override>:="COMBAT SHOTGUN",Icon<override>:=Icons.IC_Combat_Shotgun,BasePrice<override>:=80,Granter:=Shotgun_Combat_Granter}
    ShotgunStandard():shotgun=shotgun{Name<override>:="PUMP SHOTGUN",Icon<override>:=Icons.IC_Pump_Shotgun,BasePrice<override>:=90,Granter:=Shotgun_Standard_Granter}
    ShotgunDrum():shotgun=shotgun{Name<override>:="DRUM SHOTGUN",Icon<override>:=Icons.IC_DrumShotgun,BasePrice<override>:=90,Granter:=Shotgun_Drum_Granter}
    ShotgunPumpNDump():shotgun=shotgun{Name<override>:="PUMP AND DUMP SHOTGUN",Icon<override>:=Icons.IC_Pump_Dump,BasePrice<override>:=140,Granter:=Shotgun_PumpNDump_Granter}
    AssaultAuto():assault=assault{Name<override>:="ASSAULT RIFLE",Icon<override>:=Icons.IC_AssaultAuto,BasePrice<override>:=200,Granter:=Assault_Auto_Granter}
    AssaultSemiAuto():assault=assault{Name<override>:="BURST ASSAULT RIFLE",Icon<override>:=Icons.IC_Burst_Assault_Rifle,BasePrice<override>:=200,Granter:=Assault_SemiAuto_Granter}
    AssaultPistolCaliber():assault=assault{Name<override>:="TACTICAL ASSAULT RIFLE",Icon<override>:=Icons.IC_Tactical_Assault_Rifle,BasePrice<override>:=220,Granter:=Assault_PistolCaliber_Granter}
    AssaultFury():assault=assault{Name<override>:="FURY ASSAULT RIFLE",Icon<override>:=Icons.IC_FuryAssaultRifle,BasePrice<override>:=200,Granter:=Assault_Fury_Granter}
    AssaultMK():assault=assault{Name<override>:="MK ASSAULT RIFLE",Icon<override>:=Icons.IC_MK_Assault_Rifle,BasePrice<override>:=225,Granter:=Assault_MK_Granter}
    HunterBoltAction():sniper=sniper{Name<override>:="HUNTER BOLT ACTION",Icon<override>:=Icons.IC_SniperCoreSniper,BasePrice<override>:=400,Granter:=Hunter_BoltAction_Sniper_Granter}
    SniperRailGun():sniper=sniper{Name<override>:="RAIL GUN",Icon<override>:=Icons.IC_Rail_Gun,BasePrice<override>:=600,Granter:=RailGun_Sniper_Granter,MinRarity:=Rare}
    SniperFalconEye():sniper=sniper{Name<override>:="FALCON EYE SNIPER",Icon<override>:=Icons.IC_Falcon_Eye_Sniper,BasePrice<override>:=450,Granter:=FalconEye_Sniper_Granter}
    RocketLauncher():explosive=explosive{Name<override>:="ROCKET LAUNCHER",Icon<override>:=Icons.IC_LauncherRocket,BasePrice<override>:=1600,Granter:=Rocket_Launcher_Granter}
    LauncherGrenade():explosive=explosive{Name<override>:="GRENADE LAUNCHER",Icon<override>:=Icons.IC_Grenade_Launcher,BasePrice<override>:=1000,Granter:=Launcher_Grenade_Granter,MinRarity:=Rare}
    ExCalliberRifle():explosive=explosive{Name<override>:="EXCALLIBER RIFLE",Icon<override>:=Icons.IC_ExCalliber_Rifle,BasePrice<override>:=750,Granter:=ExCalliber_Rifle_Granter,MinRarity:=Rare}

    #Specials
    HeistedAccelerantShotgun():special=special{Name:="HEISTED ACCELERANT SHOTGUN",Icon:=Icons.IC_HeistedAccelerantShotgun,BasePrice:=5000,Granter:=Heisted_Accelerant_Shotgun, MinRarity:=Exotic, MaxRarity:=Exotic}
    ShadowTracker():special=special{Name:="SHADOW TRACKER",Icon:=Icons.IC_ShadowTracker,BasePrice:=5000,Granter:=Shadow_Tracker, MinRarity:=Exotic, MaxRarity:=Exotic}
    DragonsBreathSniper():special=special{Name:="DRAGONS BREATH SNIPER",Icon:=Icons.IC_DragonsBreathSniper,BasePrice:=5000,Granter:=Dragons_Breath_Sniper, MinRarity:=Exotic, MaxRarity:=Exotic}
    HopRockDualies():special=special{Name:="HOP ROCK DUALIES",Icon:=Icons.IC_HopRockDualies,BasePrice:=5000,Granter:=HopRock_Dualies, MinRarity:=Exotic, MaxRarity:=Exotic}
    ChillerLauncher():special=special{Name:="CHILLER LAUNCHER",Icon:=Icons.IC_ChillerLauncher,BasePrice:=5000,Granter:=Chiller_Launcher, MinRarity:=Exotic, MaxRarity:=Exotic}
    ZeusThunderbolt():special=special{Name:="ZEUS THUNDER",Icon:=Icons.IC_Thunderbold_of_Zeus,BasePrice:=5000,Granter:=ThunderBolt_Of_Zeus_Granter, MinRarity:=Exotic, MaxRarity:=Exotic}
    TyphoonBlade():special=special{Name:="TYPHOON BLADE",Icon:=Icons.IC_Typhoon_Blade,BasePrice:=5000,Granter:=Typhoon_Blade_Granter, MinRarity:=Mythic, MaxRarity:=Mythic}

    #Healings
    AppleCommon():heal=heal{Name:="APPLE",Icon:=Icons.IC_Apple,BasePrice:=100,Granter:=Apple_Granter, MinRarity:=Common, MaxRarity:=Common}
    BananaCommon():heal=heal{Name:="BANANA",Icon:=Icons.IC_BananaOfTheGods,BasePrice:=100,Granter:=Banana_Granter, MinRarity:=Common, MaxRarity:=Common}
    BandageCommon():heal=heal{Name:="BANDAGE",Icon:=Icons.IC_Bandages,BasePrice:=100,Granter:=Bandage_Granter, MinRarity:=Common, MaxRarity:=Common}
    MedkitUncommon():heal=heal{Name:="MEDKIT",Icon:=Icons.IC_Medkit,BasePrice:=1000,Granter:=Medkit_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    MedmistUncommon():heal=heal{Name:="MEDMIST",Icon:=Icons.IC_Medmist,BasePrice:=1000,Granter:=Medmist_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    FlopperUncommon():heal=heal{Name:="FLOPPER",Icon:=Icons.IC_Flopper,BasePrice:=1000,Granter:=Flopper_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    ChugSplashRare():heal=heal{Name:="CHUG SPLASH",Icon:=Icons.IC_ChugSplash,BasePrice:=1250,Granter:=ChugSplash_Granter, MinRarity:=Rare, MaxRarity:=Rare}
    BananaOfTheGodsLegendary():heal=heal{Name:="BANANA OF THE GODS",Icon:=Icons.IC_BananaOfTheGods,BasePrice:=1750,Granter:=BananaOfTheGods_Granter, MinRarity:=Legendary, MaxRarity:=Legendary}

    #Throwables
    GrenadeCommon():throwable=throwable{Name:="GRENADE",Icon:=Icons.IC_Grenade,BasePrice:=100,Granter:=Grenade_Granter, MinRarity:=Common, MaxRarity:=Common}
    PortAShackUncommon():throwable=throwable{Name:="PORT-A-BUNKER",Icon:=Icons.IC_PortAShack,BasePrice:=500,Granter:=PortAShack_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    DanceGrenadeRare():throwable=throwable{Name:="BOOGIE BOMB",Icon:=Icons.IC_DanceGrenade,BasePrice:=750,Granter:=DanceGrenade_Granter, MinRarity:=Rare, MaxRarity:=Rare}
    FireflyJarRare():throwable=throwable{Name:="FIREFLY JAR",Icon:=Icons.IC_FireflyJar,BasePrice:=750,Granter:=FireflyJar_Granter, MinRarity:=Rare, MaxRarity:=Rare}
    ImpulseGrenadeRare():throwable=throwable{Name:="IMPULSE GRENADE",Icon:=Icons.IC_ImpulseGrenade,BasePrice:=750,Granter:=ImpulseGrenade_Granter, MinRarity:=Rare, MaxRarity:=Rare}
    ProximityMineRare():throwable=throwable{Name:="PROXIMITY MINE",Icon:=Icons.IC_ProximityMine,BasePrice:=750,Granter:=ProximityMine_Granter, MinRarity:=Rare, MaxRarity:=Rare}
    ShieldBubbleUncommon():throwable=throwable{Name:="SHIELD BUBBLE",Icon:=Icons.IC_ShieldBubble,BasePrice:=750,Granter:=ShieldBubble_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    PresentLegendary():throwable=throwable{Name:="PRESENT",Icon:=Icons.IC_Present,BasePrice:=1750,Granter:=Present_Granter, MinRarity:=Legendary, MaxRarity:=Legendary}
    CowCatcherCommon():throwable=throwable{Name:="COW CATCHER",Icon:=Icons.IC_CowCatcher,BasePrice:=100,Granter:=CowCatcher_Granter, MinRarity:=Common, MaxRarity:=Common}
    BottleRocketsUncommon():throwable=throwable{Name:="FIREWORKS",Icon:=Icons.IC_BottleRockets,BasePrice:=500,Granter:=BottleRockets_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    DynamiteUncommon():throwable=throwable{Name:="DYNAMITE",Icon:=Icons.IC_Dynamite,BasePrice:=500,Granter:=Dynamite_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    ClusterClingerUncommon():throwable=throwable{Name:="CLUSTER CLINGER",Icon:=Icons.IC_ClusterClinger,BasePrice:=500,Granter:=ClusterClinger_Granter, MinRarity:=Uncommon, MaxRarity:=Uncommon}
    BusinessTurretEpic():throwable=throwable{Name:="BUSINESS TURRET",Icon:=Icons.IC_BusinessTurret,BasePrice:=1250,Granter:=BusinessTurret_Granter, MinRarity:=Epic, MaxRarity:=Epic}

    #Abiltiies
    GrantGoldUncommon():ability=grant_gold {CurrencyManager:= CurrencyManager, CurrencyGrantType:=currency_grant_type.AbilityGoldUncommon, MinRarity:=Common, MaxRarity:=Common}
    GrantGoldRare():ability=grant_gold {Name<override>:="125 GOLD", CurrencyManager:= CurrencyManager, CurrencyGrantType:=currency_grant_type.AbilityGoldRare, MinRarity:=Rare, MaxRarity:=Rare}
    GrantHealthUncommon():ability=grant_health {MinRarity:=Uncommon, MaxRarity:=Uncommon}
    GrantHealthRare():ability=grant_health {MinRarity:=Rare, MaxRarity:=Rare, Name<override>:="100 HP"}
    IncreaseMaxHealth():ability=increase_max_health {MinRarity:=Uncommon, MaxRarity:=Uncommon}
    HealthRegen():ability=health_regen {MinRarity:=Epic, MaxRarity:=Epic}
    DamageInc():ability=damage_inc {MinRarity:=Uncommon, MaxRarity:=Uncommon, DamageMultiplier := DamageMultiplier}
    LifeSteal():ability=life_steal {MinRarity:=Epic, MaxRarity:=Epic}
    GoldDigger():ability=gold_digger {MinRarity:=Legendary, MaxRarity:=Legendary}
    #Respawn():ability=respawn {MinRarity:=Legendary, MaxRarity:=Legendary}

    ######################################################################################################################
    # Init Spawners ######################################################################################################
    InitSpawners():void=
        Spawners:=FindCreativeObjectsWithTag(spawner{})
        for(Obj:Spawners):
            if(Spawner:=player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        if:
            Player:=player[Agent]
            not CustomPlayers[Player]
        then:
            PossibleCustomPlayer := InitPlayer(Player, Agent)
            if(CustomPlayer := PossibleCustomPlayer?) then CheckPreviousPlaysForPulse(CustomPlayer)
            if(GameRunning?):
                set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
                CustomUI.ApplyGlobalExistingUIs(Player)
        else if:
            Player:=player[Agent]
            CustomPlayer := CustomPlayers[Player]
        then:
            UpdateLevelClearedRunTime(CustomPlayer)
            CheckPreviousPlaysForPulse(CustomPlayer)

    CheckPreviousPlaysForPulse(CustomPlayer:custom_player):void=
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
        then:
            if:
                CustomPlayer.NewPlayer?
            then:
                UpdatePlayerData(Player, "NewPlayer", 0.0)
                Print("Player ain't old no more")
                BasementPulse.ActivateObjectivePulse(Agent)
            else:
                Print("Player will stay old for ever")
                #ShowCinematicTrigger.Trigger(Agent)
                ShopPulse.ActivateObjectivePulse(Agent)
        
    InitPlayer(Player:player, Agent : agent) : ?custom_player=
        if:
            FortChar:=Agent.GetFortCharacter[]
            Player.IsActive[]
        then:
            CustomPlayer:=MakeCustomPlayer(Player, InitializePlayerInventory(AllWeapons),InitializePlayerInventory(AllHeals), InitializePlayerInventory(AllThrowables), InitializePlayerInventory(AllAbilities),  InitializePlayerInventory(AllSpecials), CurrentLevelsCleared_StatCreator, PlaytimeTimer, HighestLevelClearedUI, CurrencyManager)
            if:
                not SavedPlayerData[Player]
                set SavedPlayerData[Player] = saved_data{}
            OldSavedPlayerData:=GetPlayerData(Player)
            CustomPlayer.Init(OldSavedPlayerData.NewPlayer, OldSavedPlayerData.TimesCompleted, OldSavedPlayerData.BestRunTime, OldSavedPlayerData.UnlockedItemsV2)
            if(set CustomPlayers[Player]=CustomPlayer){}
            #spawn{PlaytimeTracker(CustomPlayer)}
            FortChar.EliminatedEvent().Subscribe(OnEliminatedEvent)
            <# if(GameRunning?):
                IntroCinematicPersonal.SetPlaybackFrame(0)
                IntroCinematicPersonal.Play(Agent)
                ShowCinematicTrigger.Trigger(Agent) #>
            return option{CustomPlayer}
        return false

    InitializePlayerInventory(Items:[]item): []item = 
        var PlayerItems :[]item= array{}
        for(Item: Items):
            newItem := Item.Clone()
            set PlayerItems += array{newItem}
        return PlayerItems

    GetPlayerData(Player : player) : saved_data=
        if (PlayerTable:=SavedPlayerData[Player]) then return PlayerTable
        return saved_data{}

    UpdatePlayerData(Player : player, DataToUpdate : string, Value : float) : void=
        if:
            Player.IsActive[]
            PlayerTable := SavedPlayerData[Player]
            CustomPlayer:=CustomPlayers[Player]
        then:
            case(DataToUpdate):
                "NewPlayer"=> 
                    if:
                        Value = 0.0
                        set SavedPlayerData[Player] = saved_data:
                            MakeSavedData<constructor>(PlayerTable)
                            NewPlayer := false
                        set CustomPlayer.NewPlayer = false
                    <# else if:
                        set SavedPlayerData[Player] = saved_data:
                            MakeSavedData<constructor>(PlayerTable)
                            NewPlayer := true
                        set CustomPlayer.NewPlayer = true #>
                "TimesCompleted"=>
                    CurrentTimesCompleted := PlayerTable.TimesCompleted  
                    if:
                        set SavedPlayerData[Player] = saved_data:
                            MakeSavedData<constructor>(PlayerTable)
                            TimesCompleted :=  CurrentTimesCompleted + 1
                        set CustomPlayer.PlayerStats.TimesCompleted = CurrentTimesCompleted + 1
                "BestRunTime"=>
                    CustomPlayer.SetBestRunTimeValue(Value)
                    if:
                        set SavedPlayerData[Player] = saved_data:
                            MakeSavedData<constructor>(PlayerTable)
                            BestRunTime :=  CustomPlayer.PlayerStats.BestRunTime
                _=>
        return

    UpdatePlayerUnlockedWeapons(Agent:agent) :void =
        var PlayerUnlockedItems:[string]int=map{}
        if(Player := player[Agent], CustomPlayer:=CustomPlayers[Player]):
            for(Item:CustomPlayer.UnlockedItemArray):
                if(set PlayerUnlockedItems[Item.Name] = Item.Rarity.Order){}
            PersistanceUpdatedMap := StartingItemsPersistenceCheck(CustomPlayer,PlayerUnlockedItems) #set a function that compares players inventory with new default items. 
            if:
                Player.IsActive[]
                PlayerTable := SavedPlayerData[Player]
                set SavedPlayerData[Player] = saved_data:
                    MakeSavedData<constructor>(PlayerTable)
                    UnlockedItemsV2 := PersistanceUpdatedMap

    StartingItemsPersistenceCheck(CustomPlayer:custom_player, PlayerUnlockedItems : [string]int) : [string]int = 
        allRarities :[]rarity= array{locked{}, common{}, uncommon{}, rare{}, epic{}, legendary{}, exotic{}, mythic{}}
        NewSavedData := saved_data{}
        var UpdatedArray : [string]int = PlayerUnlockedItems
        Print("Starting Updated array length is: {UpdatedArray.Length}")
        for(UnlockedItemName->UnlockedItemRarityOrder:PlayerUnlockedItems):
            var Found : logic = false
            for(NewItemName->NewItemRarityOrder:NewSavedData.UnlockedItemsV2,not Found?):
                if:
                    UnlockedItemName = NewItemName
                    set UpdatedArray[UnlockedItemName] = NewItemRarityOrder
                then:
                    set Found = true
            for(UnlockedItem:CustomPlayer.UnlockedItemArray,UnlockedItem.Name = UnlockedItemName):
                if:
                    UnlockedItemRarityOrder > UnlockedItem.Rarity.Order
                    RarityToSet := allRarities[UnlockedItemRarityOrder]
                then:
                    set UnlockedItem.Rarity = RarityToSet
        Print("Final Updated array length is: {UpdatedArray.Length}")
        return UpdatedArray

    PlayIntro():void=
        IntroCinematic.SetPlaybackFrame(0)
        IntroCinematic.Play()

    <# PlaytimeTracker(CustomPlayer : custom_player)<suspends> : void = 
        loop:
            Sleep(60.0)
            if:
                Player:=CustomPlayer.Player
                Agent:=agent[Player]
                CurrentValue := PlaytimeTrackerChallenge_StatCreator.GetValue[Agent]
                PlaytimeTrackerChallenge_StatCreator.SetValue[Agent, CurrentValue + 1]
            if(not CustomPlayer.PlayerAlive?) then break #>

    OnEliminatedEvent(ElimResult:elimination_result):void=
        DeadChar:=ElimResult.EliminatedCharacter
        NoLaPolizia.Play()
        if(Agent:=DeadChar.GetAgent[],Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            ClearInventory.Remove(Agent)
            CustomUI.RemoveSomeHUDS(option{Agent},false)
            CustomPlayer.Reset()
            UpdatePlayerUnlockedWeapons(Player)
            DBNOInput.Unregister(Agent)
            DBNOHUD.Hide(Agent)

    UpdateLevelClearedRunTime(CustomPlayer : custom_player) : void = 
        if:
            Agent := agent[CustomPlayer.Player]
        then:
            UpdatePlayerData(CustomPlayer.Player,"BestRunTime",CustomPlayer.GetRunTimeValue())
            CustomUI.RemoveSomeHUDS(option{Agent},option{array{6}})
            #CustomUI.ShowBestTimeUI(false, 6, option{Agent})
        return

    ############################################################################################################
    #Init Levels################################################################################################
    InitLevels():void=
        Level1:custom_level=MakeLevel(level1{},1)
        Level2:custom_level=MakeLevel(level2{},2)
        Level3:custom_level=MakeLevel(level3{},3)
        Level4:custom_level=MakeLevel(level4{},4)
        Level5:custom_level=MakeLevel(level5{},5)
        Level6:custom_level=MakeLevel(level6{},6)
        Level7:custom_level=MakeLevel(level7{},7)
        Level8:custom_level=MakeLevel(level8{},8)
        Level9:custom_level=MakeLevel(level9{},9)
        Level10:custom_level=MakeLevel(level10{},10)
        Level11:custom_level=MakeLevel(level11{},11)
        Level12:custom_level=MakeLevel(level12{},12)
        Level13:custom_level=MakeLevel(level13{},13)
        Level14:custom_level=MakeLevel(level14{},14)
        Level15:custom_level=MakeLevel(level15{},15)
        Level16:custom_level=MakeLevel(level16{},16)
        Level17:custom_level=MakeLevel(level17{},17)
        Level18:custom_level=MakeLevel(level18{},18)
        Level19:custom_level=MakeLevel(level19{},19)
        Level20:custom_level=MakeLevel(level20{},20)
        set LevelsToArrayCustomPlayersMap = map{
            Level1=>array{}
            Level2=>array{}
            Level3=>array{}
            Level4=>array{}
            Level5=>array{}
            Level6=>array{}
            Level7=>array{}
            Level8=>array{}
            Level9=>array{}
            Level10=>array{}
            Level11=>array{}
            Level12=>array{}
            Level13=>array{}
            Level14=>array{}
            Level15=>array{}
            Level16=>array{}
            Level17=>array{}
            Level18=>array{}
            Level19=>array{}
            Level20=>array{}
            }
        MutatorZones:=FindCreativeObjectsWithTag(mutatorzone{})
        for(Obj:MutatorZones, MutatorZone:=mutator_zone_device[Obj]):
            MutatorTags:=MutatorZone.GetTags()
            MutatorZone.AgentEntersEvent.Subscribe(MutatorEvent_Handler{Device:=Self, Enters:=true, MutatorTags:=MutatorTags}.HandlerFunction)
            MutatorZone.AgentExitsEvent.Subscribe(MutatorEvent_Handler{Device:=Self, Enters:=false, MutatorTags:=MutatorTags}.HandlerFunction)
        ClearedLevelTriggers:=FindCreativeObjectsWithTag(trigger{})
        for(Obj:ClearedLevelTriggers, ClearedLevelTrigger:=trigger_device[Obj]):
            TriggerTags:=ClearedLevelTrigger.GetTags()
            ClearedLevelTrigger.TriggeredEvent.Subscribe(TriggerEvent_Handler{Device:=Self, ChallengeManager:=ChallengeManagerDevice, TriggerTags:=TriggerTags}.HandlerFunction)
        GuardSpawnerDevices:=FindCreativeObjectsWithTag(guardspawner{})
        for(Obj:GuardSpawnerDevices, GuardSpawnerDevice:=guard_spawner_device[Obj]):
            GuardSpawnerDevice.DamagedEvent.Subscribe(ApplyAbilities)
        for(Level->Array:LevelsToArrayCustomPlayersMap):
            PossiblePeely := GetCharacterDevice(Level)
            if(Peely := PossiblePeely?) then Peely.Disable()
        ItemShopButton.InteractedWithEvent.Subscribe(ItemShopUI)
        HealShopButton.InteractedWithEvent.Subscribe(HealShopUI)

    IsInClearedLevel(CustomPlayer:custom_player,Level:custom_level):void=
        LevelsCleared := CustomPlayer.PlayerStats.CurrentLevelsCleared
        if:
            Agent := agent[CustomPlayer.Player]
            LevelsCleared < Level.Index
        then:
            CustomPlayer.SetCurrentLevelsClearedValue(Level.Index)
            UpdateLevelClearedRunTime(CustomPlayer)
            CurrencyManager.CurrencyGrant(Agent, currency_grant_type.LevelCleared)
            PossibleObjective := GetObjectiveDevice(Level)
            if(Objective := PossibleObjective?) then Objective.ActivateObjectivePulse(Agent)

    GetCharacterDevice(Level : custom_level) : ?character_device = 
        var CharactersArray : []character_device = array{}
        CompletedLevelCharacters:=FindCreativeObjectsWithTag(Level.Tag)
        for(CharacterDevice : CompletedLevelCharacters, Character := character_device[CharacterDevice]):
            CurTags := CharacterDevice.GetTags()
            if(not CurTags.Has[secondary{}]):
                set CharactersArray += array{Character}
        if(TrueCharacter := CharactersArray[0]) then return option{TrueCharacter}
        return false

    GetObjectiveDevice(Level : custom_level) : ?objective_device = 
        var ObjectivesArray : []objective_device = array{}
        CompletedLevelObjectives:=FindCreativeObjectsWithTag(Level.Tag)
        for(ObjectiveDevice : CompletedLevelObjectives, Objective := objective_device[ObjectiveDevice]):
            set ObjectivesArray += array{Objective}
        if(TrueObjective := ObjectivesArray[0]) then return option{TrueObjective}
        return false

    GetTeleporterDevice(Level : custom_level) : ?teleporter_device = 
        var TeleportersArray : []teleporter_device = array{}
        CompletedLevelTeleporters:=FindCreativeObjectsWithTag(Level.Tag)
        for(TeleporterDevice : CompletedLevelTeleporters, Teleporter := teleporter_device[TeleporterDevice]):
            set TeleportersArray += array{Teleporter}
            Print("Teleporter found")
        if(TrueTeleporter := TeleportersArray[0]) then return option{TrueTeleporter}
        return false

    GetCinematicDevice(Level : custom_level) : ?cinematic_sequence_device = 
        var CinematicsArray : []cinematic_sequence_device = array{}
        CompletedLevelCinematics:=FindCreativeObjectsWithTag(Level.Tag)
        for(CinematicDevice : CompletedLevelCinematics, Cinematic := cinematic_sequence_device[CinematicDevice]):
            CurTags := CinematicDevice.GetTags()
            if(not CurTags.Has[secondary{}]):
                set CinematicsArray += array{Cinematic}
        if(TrueCinematic := CinematicsArray[0]) then return option{TrueCinematic}
        return false

    GetLockDevice(Level : custom_level) : ?[]lock_device = 
        var LocksArray : []lock_device = array{}
        CompletedLevelLocks:=FindCreativeObjectsWithTag(Level.Tag)
        for(LockDevice : CompletedLevelLocks, Lock := lock_device[LockDevice]):
            set LocksArray += array{Lock}
        return option{LocksArray}

    GetVFXDevice(Level : custom_level) : ?vfx_spawner_device = 
        var VFXsArray : []vfx_spawner_device = array{}
        CompletedLevelVFXs:=FindCreativeObjectsWithTag(Level.Tag)
        for(VFXDevice : CompletedLevelVFXs, VFX := vfx_spawner_device[VFXDevice]):
            set VFXsArray += array{VFX}
        if(TrueVFX := VFXsArray[0]) then return option{TrueVFX}
        return false  

    LevelCleared(Level : custom_level) : void = 
        set Level.Cleared = true
        #PlayRandomSFX()
        PossiblePeely := GetCharacterDevice(Level)
        if(Peely := PossiblePeely?) then {Peely.Enable(),Peely.Show(), Peely.InteractedWithEvent.SubscribeLevelCompletion(TransitionToNextLevel, Level)}

    TransitionToNextLevel(Level : custom_level, Agent:agent) : void = 
        PossibleTeleporter := GetTeleporterDevice(Level)
        if(Teleporter := PossibleTeleporter?) then Teleporter.Enable()
        PossibleCinematic := GetCinematicDevice(Level)
        if(Cinematic := PossibleCinematic?) then {Cinematic.SetPlaybackFrame(0), Cinematic.Play()}
        PossibleLock := GetLockDevice(Level)
        if(Locks := PossibleLock?) then for(Lock:Locks) {Lock.Open(Agent)}
        if(CurrentLevelArray:=LevelsToArrayCustomPlayersMap[Level]):
            for(CustomPlayer:CurrentLevelArray, EachAgent:=agent[CustomPlayer.Player]):
                EvilLaughSFX.Play(EachAgent)
                EvilGuyWidget.Show(EachAgent)
        PossibleVFX := GetVFXDevice(Level)
        if(VFX := PossibleVFX?) then {VFX.Enable(), VFX.Restart()}
        PossiblePeely := GetCharacterDevice(Level)
        if(Peely := PossiblePeely?):
            spawn{PeelyDisappearVFX(Peely.GetTransform())}
            Peely.Hide()
            Peely.Disable()

    PeelyDisappearVFX(CharTransform : transform)<suspends> : void = 
        if:
            Translation := CharTransform.Translation + vector3{X := 0.0, Y:= 0.0, Z := 50.0}
            SpawnedVFX := SpawnProp(EvilGuyDisppearVFX,Translation,rotation{})(0)?
        then:
            Sleep(2.0)
            SpawnedVFX.Dispose()

    ExitedClearedLevel(CustomPlayer:custom_player,Level:custom_level):void=
        ClearedLevelDevices:=FindCreativeObjectsWithTag(Level.Tag)
        for(Obj:ClearedLevelDevices, ClearedLevelObjectiveDevice:=objective_device[Obj]):
            if(Agent:=agent[CustomPlayer.Player]) then ClearedLevelObjectiveDevice.DeactivateObjectivePulse(Agent)

    ResetLevel(Level:custom_level,Agent:agent)<suspends>:void=
        LevelTag:=Level.Tag
        Sleep(1.0)
        Print("Resetting Level")
        LevelDevices:=FindCreativeObjectsWithTag(LevelTag)
        PossiblePeely := GetCharacterDevice(Level)
        if(Peely := PossiblePeely?) then {Peely.Hide(), Peely.Disable()}
        #This resets guard spawner
        for(GuardSpanwer:LevelDevices, Guards:=guard_spawner_device[GuardSpanwer]):
            Print("Resetting guards")
            Guards.Reset()
            Guards.Disable()
            Guards.Enable()
        #This resets all cinematics
        for(Cinematic:LevelDevices, CinematicDevice:=cinematic_sequence_device[Cinematic]):
            Print("Resetting cinematics")
            CinematicDevice.Stop()
            CinematicDevice.SetPlaybackFrame(0)
        #This resets broken props
        for(PropManip:LevelDevices, PropManDev:=prop_manipulator_device[PropManip]):
            Print("Resetting Props")
            PropManDev.ShowProps()
        #This resets trigger for broken props
        for(PropTrigger:LevelDevices):
            PropTriggerTags:=PropTrigger.GetTags()
            if:
                TriggerDevice:=trigger_device[PropTrigger]
            then:
                Print("Resetting trigger count")
                TriggerDevice.Reset()
        #This resets locks
        for(LockTrigger:LevelDevices, LockDevice:=lock_device[LockTrigger]):
            Print("Resetting lock")
            LockDevice.Close(Agent)
            LockDevice.Lock(Agent)
        #This resets switches
        for(SwitchTrigger:LevelDevices, SwitchDevice:=switch_device[SwitchTrigger]):
            SwitchDevice.TurnOff(Agent)
        #This resets VFX
        for(VFXSpawner:LevelDevices, VFXSpawnerDevice:=vfx_spawner_device[VFXSpawner]):
            VFXSpawnerDevice.Disable()
        #This resets Teleporter
        for(Teleporter:LevelDevices, TeleporterDevice:=teleporter_device[Teleporter]):
            TeleporterDevice.Disable()
        #This resets Character Devices
        for(Character:LevelDevices, CharacterDevice:=character_device[Character]):
            CharacterDevice.Show()
        #This resets Collectibles
        for(Collectible:LevelDevices, CollectibleDevice:=collectible_object_device[Collectible]):
            CollectibleDevice.RespawnForAll()
        set Level.Cleared=false

    ItemShopUI(Agent:agent):void=
        CustomUI.ShowWeaponShopUI(true,4,option{Agent})
        ShopPulse.DeactivateObjectivePulse(Agent)
        HealShopPulse.ActivateObjectivePulse(Agent)

    HealShopUI(Agent:agent):void=
        CustomUI.ShowUtilityShopUI(true,4,option{Agent})
        HealShopPulse.DeactivateObjectivePulse(Agent)

    ############################################################################################################
    #Init Custom UI ############################################################################################
    InitCustomUI():void=
        set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
        set CustomUI.RealTimeProp=option{RealTimeProp}
        set CustomUI.CurrencyManager = CurrencyManager
        <# set CustomUI.CloseUIInput = CloseUIInput
        set CustomUI.CloseUIHUD = CloseUIHUD #>
        CustomUI.Assign()
        Print("Showing UIs ...")
        for(CustomPlayer : CustomPlayers) :
            Print("... to player ...")
            if(Agent := agent[CustomPlayer.Player]) :
                if(not CustomPlayer.NewPlayer?):
                    Print("... best time")
                    #CustomUI.ShowBestTimeUI(false, 6, option{Agent}) 
                else:
                    Print("... sike!")
        #CustomUI.ShowCurrencyTextUI(false,20,false)
        #CustomUI.ShowProgressBarUI(false,21,false,LevelsToArrayCustomPlayersMap.Length)
        #CustomUI.ShowStopwatchUI(false,22,false)

    <# GrantItem(Agent:agent):void=
        if:
            Player:=player[Agent]
            CustomPlayer:=CustomPlayers[Player]
            Index:=GetRandomInt(0, CustomPlayer.UnlockedItems.Length)
            SelectedItem:=CustomPlayer.UnlockedItems[Index]
        then:
            SelectedItem.Granter.GrantItem(Agent) #>

    SelectItemUI(Agent:agent,LevelIndex:int)<suspends>:void=
        Sleep(0.5)
        CustomUI.ShowItemSelectionUI(true,2,option{Agent},LevelIndex)
    
    EmptyInventory(Agent:agent):void=
        ClearInventory.Remove(Agent)

    ############################################################################################################
    #Gameplay ##################################################################################################
    GameStart():void=
        set GameRunning = true

    PlayRandomSFX():void=
        Index := GetRandomInt(0,BrainRotSFX.Length-1)
        if (SelectedBrainRotSFX := BrainRotSFX[Index]) then SelectedBrainRotSFX.Play()

    ApplyAbilities(DamageResult : device_ai_interaction_result) : void = 
        if:
            DamagedAgent := DamageResult.Target?
            AIChar := DamagedAgent.GetFortCharacter[]
        then:
            AIChar.DamagedEvent().Subscribe(DamageCalculation)

    DamageCalculation(DamagedResult:damage_result):void=
        if:
            TrueInstigator := DamagedResult.Instigator?
            AttackAgent := TrueInstigator.GetInstigatorAgent[]
            FortChar := AttackAgent.GetFortCharacter[]
            Player := player[AttackAgent]
            CustomPlayer := CustomPlayers[Player]
        then:
            DamageDealt := DamagedResult.Amount 
            CurrentHealth := FortChar.GetHealth()
            var CachedLifeStealRate : float = CustomPlayer.PlayerAbilities.LifeStealRate * 0.005
            FortChar.SetHealth(CurrentHealth + DamageDealt * CachedLifeStealRate)
            Chances := GetRandomInt(0, 100)
            if(Chances < 2*CustomPlayer.PlayerAbilities.GoldDiggerRate):
                GoldDiggerGranter.GrantItem(AttackAgent)

    #############################################################################################################
    #End Game ###################################################################################################
    EndGameHUD(CustomPlayer:custom_player):void=
        if:
            Agent:=agent[CustomPlayer.Player]
        then:
            EndGameMessage.Show(Agent)
            EndGameButton.Show(Agent)
        UpdatePlayerData(CustomPlayer.Player, "TimesCompleted", CustomPlayer.PlayerStats.TimesCompleted * 1.0)

    EndGameFunctionality(Agent:agent,ButtonIndex:int):void=
        if (FortChar := Agent.GetFortCharacter[]):
            FortChar.Damage(1000.0)
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            CustomPlayer.SetCurrentLevelsClearedValue(0)

    #TODO We can also have on the first room 3 guns and after that same number minus one plus one ability or one heal 
    #inspiration by tychoon games on the price tags
