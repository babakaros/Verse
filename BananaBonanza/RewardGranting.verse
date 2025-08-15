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

Reward_Granting := class(creative_device):
    @editable CurrencyManager : Currency_Manager = Currency_Manager{}

    @editable{Categories := array{ParkourCoin}} ParkourFirstCoin : collectible_object_device = collectible_object_device{} 
    @editable{Categories := array{ParkourCoin}} ParkourSecondCoin : collectible_object_device = collectible_object_device{}

    @editable{Categories := array{StatCreator}} LevelsCompleted : stat_creator_device = stat_creator_device{}
    @editable{Categories := array{StatCreator}} OpponentsEliminated : stat_creator_device = stat_creator_device{}
    @editable{Categories := array{StatCreator}} MinutesPlayed : stat_creator_device = stat_creator_device{}
    @editable{Categories := array{StatCreator}} RelicsCollected : stat_creator_device = stat_creator_device{}
    @editable{Categories := array{StatCreator}} BossesEliminated : stat_creator_device = stat_creator_device{}
    
    OnBegin<override>()<suspends>:void=
        GuardSpawners:=FindCreativeObjectsWithTag(guardspawner{})
        for(Obj:GuardSpawners, GuardSpawnerDevice:=guard_spawner_device[Obj]):
            GuardSpawnerDevice.EliminatedEvent.Subscribe(RewardPlayerKill)

        ParkourFirstCoin.CollectedEvent.Subscribe(CurrencyAwardOnAgent_Handler{CurrencyManager := CurrencyManager, CurrencyType := currency_grant_type.ParkourFirst}.HandlerFunctionAgent)
        ParkourSecondCoin.CollectedEvent.Subscribe(CurrencyAwardOnAgent_Handler{CurrencyManager := CurrencyManager, CurrencyType := currency_grant_type.ParkourSecond}.HandlerFunctionAgent)

        LevelsCompleted.MaximumReachedEvent.Subscribe(CurrencyAwardOnAgent_Handler{CurrencyManager := CurrencyManager, CurrencyType := currency_grant_type.ChallengeCompletedSmall}.HandlerFunctionMaybeAgent)
        OpponentsEliminated.MaximumReachedEvent.Subscribe(CurrencyAwardOnAgent_Handler{CurrencyManager := CurrencyManager, CurrencyType := currency_grant_type.ChallengeCompletedSmall}.HandlerFunctionMaybeAgent)
        MinutesPlayed.MaximumReachedEvent.Subscribe(CurrencyAwardOnAgent_Handler{CurrencyManager := CurrencyManager, CurrencyType := currency_grant_type.ChallengeCompletedLarge}.HandlerFunctionMaybeAgent)
        RelicsCollected.MaximumReachedEvent.Subscribe(CurrencyAwardOnAgent_Handler{CurrencyManager := CurrencyManager, CurrencyType := currency_grant_type.ChallengeCompletedLarge}.HandlerFunctionMaybeAgent)
        BossesEliminated.MaximumReachedEvent.Subscribe(CurrencyAwardOnAgent_Handler{CurrencyManager := CurrencyManager, CurrencyType := currency_grant_type.ChallengeCompletedLarge}.HandlerFunctionMaybeAgent)
        
    ## Private ##
    RewardPlayerKill<private>(EliminationResult : device_ai_interaction_result) : void = 
        if(EliminatingAgent := EliminationResult.Source?) then CurrencyManager.CurrencyGrant(EliminatingAgent, currency_grant_type.GuardEliminated)

    ## Here is a great place to grant xp too and maybe use it to track analytics
