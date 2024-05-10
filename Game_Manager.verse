using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Teams }
using { /Fortnite.com/UI }
using {/Fortnite.com/Vehicles}
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

Game_Manager := class(creative_device):
    var CustomPlayers:[player]custom_player=map{}
    PlayerTagArray:[]tag=array{Player1{},Player2{},Player3{},Player4{},Player5{},Player6{},Player7{},Player8{},Player9{},Player10{},Player11{},Player12{}}
    var SavedPlayerData:weak_map(player, custom_player) = map{}
    var RoundEnded:logic=false
    var CustomUI:custom_ui_creator=custom_ui_creator{PlayerToCustomPlayerMap:=map{}}

    BikeClass:vehicle_class=vehicle_class{Tag:=tag(Bike{})}
    @editable BikeClassSelector:class_and_team_selector_device=class_and_team_selector_device{}
    SportBikeClass:vehicle_class=vehicle_class{Tag:=tag(SportBike{})}
    @editable SportBikeClassSelector:class_and_team_selector_device=class_and_team_selector_device{}
    ATVClass:vehicle_class=vehicle_class{Tag:=tag(ATV{})}
    @editable ATVClassSelector:class_and_team_selector_device=class_and_team_selector_device{}
    RallyCarClass:vehicle_class=vehicle_class{Tag:=tag(RallyCar{})}
    @editable RallyCarClassSelector:class_and_team_selector_device=class_and_team_selector_device{}
    RacingTruckClass:vehicle_class=vehicle_class{Tag:=tag(RacingTruck{})}
    @editable RacingTruckClassSelector:class_and_team_selector_device=class_and_team_selector_device{}
    BigRigClass:vehicle_class=vehicle_class{Tag:=tag(BigRig{})}
    @editable BigRigClassSelector:class_and_team_selector_device=class_and_team_selector_device{}

    @editable RaceManager:race_manager_device=race_manager_device{}
    @editable TrailerSequence : cinematic_sequence_device = cinematic_sequence_device{}
    @editable VehicleSequence : cinematic_sequence_device = cinematic_sequence_device{}
    @editable VehicleSelectionAudio : audio_player_device = audio_player_device{}
    @editable FlyOverSequence : cinematic_sequence_device = cinematic_sequence_device{}
    @editable RaceStarTimed:timed_objective_device=timed_objective_device{}

    @editable TimeToEndRound:timer_device=timer_device{}
    @editable TotalRoundTime:timer_device=timer_device{}
    @editable EndGameDevice:end_game_device=end_game_device{}

    var PYRDone:logic=false
    @editable MusicIntro:cinematic_sequence_device=cinematic_sequence_device{}
    @editable MusicPickYourRide:cinematic_sequence_device=cinematic_sequence_device{}
    @editable MusicMain:cinematic_sequence_device=cinematic_sequence_device{}
    
    OnBegin<override>()<suspends>:void=
        Print("Round Started")
        #Voting UI to choose map then all these depending the map selected
        #we should have a map class and each map will have its own trailers etc
        #and on game start we will run all these through the class and not here
        TrailerSequence.Play()
        MusicIntro.Play()
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        InitSpawners()
        Sleep(1.0)
        set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
        CustomUI.Assign()
        Sleep(1.0)
        CustomUIFurtherSetUp() 
        VehicleClassInit()
        MusicIntro.StoppedEvent.Subscribe(PlayNextPart)
        MusicPickYourRide.StoppedEvent.Subscribe(PlayNextPart)
        TrailerSequence.StoppedEvent.Subscribe(ShowClassSelectionUI)
        CustomUI.CountdownEndedEvent.Await()
        EndVote()
        RaceManager.LapCompletedEvent.Subscribe(LapUpdate)
        RaceManager.RaceCompletedEvent.Subscribe(CompleteRound)
        TotalRoundTime.SuccessEvent.Subscribe(MaybeCompleteRound)

    InitSpawners():void=
        Spawners:=GetCreativeObjectsWithTag(spawner{})
        for(Obj:Spawners):
            if(Spawner:=player_spawner_device[Obj]):
                Print("Spawner found!")
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        if(Player:=player[Agent]):
            Print("Initializing player...")
            InitPlayer(Player)

    InitPlayer(Player:player):void=
        if:
            Agent:=agent[Player]
            FortChar:=Agent.GetFortCharacter[]
        then:
            if(Existing:=CustomPlayers[Player]){}
            else:
                Print("Adding player to map...")
                TeamCollection:=GetPlayspace().GetTeamCollection()
                TeamArray:=TeamCollection.GetTeams()
                if(AgentsTeam:=TeamCollection.GetTeam[Agent]):
                    for (TeamNumber->Team:TeamArray):
                        if (AgentsTeam=Team,TeamTag:=PlayerTagArray[TeamNumber]):
                            Print("Player on team:{TeamNumber+1}")
                            CustomPlayer:=custom_player{Player:=Player,CurrentClass:=RacingTruckClass,Tag:=option{TeamTag}}
                            CustomPlayer.Init()
                            if(set CustomPlayers[Player]=CustomPlayer){}
            
    OnPlayerLeftServer(PlayerLeaving:player):void=
        if(CustomPlayer:=CustomPlayers[PlayerLeaving]):
            CustomPlayer.Dispose()
            var NewCustomPlayerMap:[player]custom_player=map{}
            for(Key->Value:CustomPlayers,Key<>PlayerLeaving):
                set NewCustomPlayerMap=ConcatenateMaps(NewCustomPlayerMap,map{Key=>Value})
            set CustomPlayers=NewCustomPlayerMap
    
    CompleteRound(Agent:agent):void=
        Print("Race completed")
        TimeToEndRound.Start()
        spawn{End(Agent)}
    MaybeCompleteRound(Agent:?agent):void=
        TimeToEndRound.Start()
        if(TrueAgent:=Agent?):
            spawn{End(TrueAgent)}
        
    End(Agent:agent)<suspends>:void=
        Print("Await")
        TimeToEndRound.SuccessEvent.Await()
        Print("Timer Ended")
        set RoundEnded=true
        for(Player:CustomPlayers):
            set Player.GamesPlayed+=1
            set Player.LapsDone=0
        Sleep(2.0)
        EndGameDevice.Activate(Agent)

    PlayNextPart():void=
        if(not PYRDone?):
            MusicPickYourRide.Play()
            set PYRDone=true
        else:
            MusicMain.Play()

    UISetUp(UI:custom_ui_creator,PlayerToCanvasMap:[player][int]?canvas):void=
        set UI.PlayerToCustomPlayerMap=CustomPlayers
        set UI.PlayerToCanvasMap=PlayerToCanvasMap
    
    CustomUIFurtherSetUp():void=
        set CustomUI.VehicleSelectionAudio=VehicleSelectionAudio
        set CustomUI.VehicleSequence=VehicleSequence
        set CustomUI.BikeClass=option{BikeClass}
        set CustomUI.SportBikeClass=option{SportBikeClass}
        set CustomUI.ATVClass=option{ATVClass}
        set CustomUI.RallyCarClass=option{RallyCarClass}
        set CustomUI.RacingTruckClass=option{RacingTruckClass}
        set CustomUI.BigRigClass=option{BigRigClass}

    ShowClassSelectionUI():void=
        CustomUI.ShowClassSelectionUI(true,1,false)
    
    VehicleClassInit():void=
        set BikeClass.ClassSelector=BikeClassSelector
        BikeClass.Init()
        set SportBikeClass.ClassSelector=SportBikeClassSelector
        SportBikeClass.Init()
        set ATVClass.ClassSelector=ATVClassSelector
        ATVClass.Init()
        set RallyCarClass.ClassSelector=RallyCarClassSelector
        RallyCarClass.Init()
        set RacingTruckClass.ClassSelector=RacingTruckClassSelector
        RacingTruckClass.Init()
        set BigRigClass.ClassSelector=BigRigClassSelector
        BigRigClass.Init()

    EndVote():void=
        CustomUI.RemoveSomeHUDS(array{1,2})
        VehicleSequence.GoToEndAndStop()
        VehicleSequence.StoppedEvent.Subscribe(SpawnVehicles)
        MusicPickYourRide.GoToEndAndStop()
        FlyOverSequence.Play()
        FlyOverSequence.StoppedEvent.Subscribe(StartRace)

    SpawnVehicles():void=
        for(Player->CustomPlayer:CustomPlayers):
            if(Agent:=agent[Player]):
                CustomPlayer.GetPlayerVehicle(Agent)

    StartRace():void=
        TotalRoundTime.Start()
        for(Player->CustomPlayer:CustomPlayers,Agent:=agent[Player]):
            RaceStarTimed.Begin(Agent)

    LapUpdate(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            CustomPlayer.UpdateLaps(Agent)
            set CustomPlayer.TotalLaps+=1