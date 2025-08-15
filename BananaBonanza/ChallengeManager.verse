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
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

Challenge_Manager := class(creative_device):
    @editable{Categories := array{Currency}} CurrencyManager:Currency_Manager=Currency_Manager{}

    @editable{Categories := array{StatCreator}} EliminateOponentsStatCreator : stat_creator_device = stat_creator_device{}
    MaxOp : int = 10
    @editable{Categories := array{StatCreator}} BossesEliminatedStatCreator : stat_creator_device = stat_creator_device{}
    MaxBoss : int = 4
    @editable{Categories := array{StatCreator}} LevelsClearedStatCreator : stat_creator_device = stat_creator_device{}
    MaxLvls : int = 4
    @editable{Categories := array{StatCreator}} RelicsCollectedStatCreator : stat_creator_device = stat_creator_device{}
    MaxRelics : int = 11
    @editable{Categories := array{StatCreator}} TimePlayedStatCreator : stat_creator_device = stat_creator_device{}
    MaxTime : int = 30

    var CustomPlayers : [player]custom_player = map{}

    OnBegin<override>()<suspends> : void = 
        Print("Challenge Manager Run")

### Initialization ###
    InitChallengeManager(CustomPlayersMap : [player]custom_player) : void = 
        set CustomPlayers = CustomPlayersMap
        InitElimOp()
        InitElimBoss()
        InitRelicsCollected()
        spawn{InitTimePlayed()}

    InitElimOp() : void = 
        GuardSpawners:=FindCreativeObjectsWithTag(guardspawner{})
        for(Obj:GuardSpawners, GuardSpawner:=guard_spawner_device[Obj]):
            GuardSpawner.EliminatedEvent.SubscribeStatIncrease(ElimStatIncrease, stat_type.OpElim)
            #EliminateOponentsStatCreator.MaximumReachedEvent.Subscribe()

    InitElimBoss() : void = 
        BossSpawners:=FindCreativeObjectsWithTag(bossspawner{})
        for(Obj:BossSpawners, BossSpawner:=guard_spawner_device[Obj]):
            BossSpawner.EliminatedEvent.SubscribeStatIncrease(ElimStatIncrease, stat_type.BossElim)

    var RelicsAmount : int = 0 
    InitRelicsCollected() : void = 
        Relics:=FindCreativeObjectsWithTag(relic{})
        for(Obj:Relics, Relic:=collectible_object_device[Obj]):
            set RelicsAmount += 1
            Relic.CollectedEvent.Subscribe(RelicStatIncrease)
        

    InitTimePlayed()<suspends> : void = 
        for(CustomPlayer:CustomPlayers):
            loop:
                Sleep(60.0)
                TimeStatIncrease(CustomPlayer)
                if(not CustomPlayer.PlayerAlive?) then break

### Stat Updating ###
    ElimStatIncrease(AIResult : device_ai_interaction_result, Type : stat_type) : void = 
        if:
            PossibleAgent := AIResult.Source
            Agent := PossibleAgent?
            Player := player[Agent]
            CustomPlayer := CustomPlayers[Player]
        then:
            case(Type):
                stat_type.OpElim => {
                    NewValue := CustomPlayer.PlayerStats.OpEliminated + 1
                    set CustomPlayer.PlayerStats.OpEliminated = NewValue
                    var Units : int = 0
                    if(TempUnits := Mod[NewValue,MaxOp]):
                        if(TempUnits = 0, NewValue > 0) then set Units = MaxOp else set Units = TempUnits
                        Print("Op Elim: {Units}")
                        if:
                            Mod[Units,3] = 0
                            EliminateOponentsStatCreator.SetValue[Agent,Units]
                        if(Units = MaxOp) then CurrencyManager.CurrencyGrant(Agent, currency_grant_type.ChallengeCompletedSmall)
                    }
                stat_type.BossElim => {
                    NewValue := CustomPlayer.PlayerStats.BossEliminated + 1
                    set CustomPlayer.PlayerStats.BossEliminated = NewValue
                    var Units : int = 0
                    if(TempUnits := Mod[NewValue,MaxBoss]):
                        if(TempUnits = 0, NewValue > 0) then set Units = MaxBoss else set Units = TempUnits
                        Print("Boss Elim: {Units}")
                        if(BossesEliminatedStatCreator.SetValue[Agent,Units]){}
                        if(Units = MaxBoss) then CurrencyManager.CurrencyGrant(Agent, currency_grant_type.ChallengeCompletedLarge)
                    }
                _=>

    RelicStatIncrease(Agent : agent) : void = 
        if:
            Player := player[Agent]
            CustomPlayer := CustomPlayers[Player]
        then:
            NewValue := CustomPlayer.PlayerStats.RelicsCollected + 1
            set CustomPlayer.PlayerStats.RelicsCollected = NewValue
            if(RelicsCollectedStatCreator.SetValue[Agent,NewValue]){}
            if(NewValue = MaxRelics) then CurrencyManager.CurrencyGrant(Agent, currency_grant_type.ChallengeCompletedLarge)

    TimeStatIncrease(CustomPlayer:custom_player) : void = 
        if:
            Player:=CustomPlayer.Player
            Agent:=agent[Player]
        then:
            NewValue := CustomPlayer.PlayerStats.TimePlayed + 1
            set CustomPlayer.PlayerStats.TimePlayed = NewValue
            var Units : int =0
            if(TempUnits := Mod[NewValue,MaxTime]):
                if(TempUnits = 0, NewValue > 0) then set Units = MaxTime else set Units = TempUnits
                Print("Min played: {Units}")
                if(TimePlayedStatCreator.SetValue[Agent, Units]){}
                if(Units = MaxTime) then CurrencyManager.CurrencyGrant(Agent, currency_grant_type.ChallengeCompletedLarge)

    LevelStatIncrease(CustomPlayer:custom_player) : void = 
        if:
            Player:=CustomPlayer.Player
            Agent:=agent[Player]
        then:
            NewValue := CustomPlayer.PlayerStats.TotalLevelsCleared + 1
            set CustomPlayer.PlayerStats.TotalLevelsCleared = NewValue
            var Units : int = 0
            if(TempUnits := Mod[NewValue,MaxLvls]):
                if(TempUnits = 0, NewValue > 0) then set Units = MaxLvls else set Units = TempUnits
                Print("Lvls Cleared: {Units}")
                if(LevelsClearedStatCreator.SetValue[Agent, Units]){}
                if(Units = MaxLvls) then CurrencyManager.CurrencyGrant(Agent, currency_grant_type.ChallengeCompletedSmall)
