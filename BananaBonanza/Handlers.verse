using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Devices }

# A handler function to use on interactedwithevent
MutatorEvent_Handler := class():
    Device:Game_Manager
    Enters:logic
    MutatorTags:tag_view
    HandlerFunction(Agent:agent) : void=
        if:
            Player:=player[Agent]
            CustomPlayer:=Device.CustomPlayers[Player]
        then:
            #When player enters level
            if(Enters?):
                # Enters specific Level 1
                if(MutatorTags.Has[level1{}]):
                    spawn{Device.SelectItemUI(Agent,1)}
                    Device.BasementPulse.DeactivateObjectivePulse(Agent)
                    Device.ShopPulse.DeactivateObjectivePulse(Agent)
                    Device.HealShopPulse.DeactivateObjectivePulse(Agent)
                # Enters all levels
                for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap,MutatorTags.Has[Level.Tag]):
                    if(set Device.LevelsToArrayCustomPlayersMap[Level] += array{CustomPlayer}):
                        if(Level.Cleared?):
                            Device.IsInClearedLevel(CustomPlayer,Level)
                            LevelsCleared := CustomPlayer.PlayerStats.CurrentLevelsCleared
                            # Enters final level
                            if(Level.Index=Device.LevelsToArrayCustomPlayersMap.Length):
                                Device.EndGameHUD(CustomPlayer)
                            #Enter other Cleared level except 1
                            else if(Level.Index<>1,LevelsCleared<Level.Index):
                                spawn{Device.SelectItemUI(Agent,Level.Index)}
                return
            #When player exits level
            for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap,MutatorTags.Has[Level.Tag]):
                Device.ExitedClearedLevel(CustomPlayer,Level)
                if: 
                    PlayerIndex:=Device.LevelsToArrayCustomPlayersMap[Level].Find[CustomPlayer]
                    TempArray:=Device.LevelsToArrayCustomPlayersMap[Level].RemoveElement[PlayerIndex]
                    set Device.LevelsToArrayCustomPlayersMap[Level] = TempArray
                if:
                    Level.Index = 1
                then:
                    for(TempLevel->NewCustomPlayersArray:Device.LevelsToArrayCustomPlayersMap,TempLevel.Index=2):
                        if(not Device.LevelsToArrayCustomPlayersMap[TempLevel].Find[CustomPlayer]):
                            CustomPlayer.SetCurrentLevelsClearedValue(0)
                    if(Device.LevelsToArrayCustomPlayersMap[Level].Length = 0) then spawn{Device.ResetLevel(Level,Agent)}
                    
#Handler for level completion
TriggerEvent_Handler := class(): 
    Device:Game_Manager
    ChallengeManager:Challenge_Manager
    TriggerTags:tag_view
    HandlerFunction(Agent:?agent) : void=
        var CurrentLevelIndex:int=-1
        for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap, TriggerTags.Has[Level.Tag]):      
            set CurrentLevelIndex = Level.Index
            Device.LevelCleared(Level)
            for(CustomPlayer:CustomPlayersArray, TrueAgent:=agent[CustomPlayer.Player]):
                ChallengeManager.LevelStatIncrease(CustomPlayer)
                CustomPlayer.SetCurrentLevelsClearedValue(CustomPlayer.PlayerStats.CurrentLevelsCleared)
                Device.IsInClearedLevel(CustomPlayer,Level) #Here we run everything related to player entering/ being in a Cleared level
                # Spawns UI and Grants Gold upon Level Completion
                if(Level.Index <> Device.LevelsToArrayCustomPlayersMap.Length):
                    Device.CurrencyManager.CurrencyGrant(TrueAgent, currency_grant_type.LevelCleared)
                    spawn{Device.SelectItemUI(TrueAgent,Level.Index)}
                else:
                    Device.EndGameHUD(CustomPlayer)
                # Grants more gold on boss elim, higher amount on higher boss
                if:
                    Mod[Level.Index,5] = 0
                    N:=Ceil(Level.Index/5)
                then:
                    #ChallengeManager.ElimStatIncrease(CustomPlayer, stat_type.BossElim)
                    for(ImportanceIndex:=0..N-1):
                        Device.CurrencyManager.CurrencyGrant(TrueAgent, currency_grant_type.BossLevelCleared)
        for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap,Level.Index = CurrentLevelIndex+1):
            if(TrueAgent:=Agent?, Device.LevelsToArrayCustomPlayersMap[Level].Length=0) then spawn{Device.ResetLevel(Level,TrueAgent)}

ItemSelectButton_Handler := class():
    Item:item
    Event:event(widget_message)
    PlayerToCustomPlayerMap:[player]custom_player

    HandlerFunction(Wdata:widget_message):void=
        if:
            Player := Wdata.Player
            CustomPlayer := PlayerToCustomPlayerMap[Player]
            Agent := agent[Player]
        then:
            Item.GrantItem(CustomPlayer)
            Event.Signal(Wdata)

TabSelectButton_Handler := class():
    CurrentTab : int
    PlayerToCustomPlayerMap:[player]custom_player

    HandlerFunction(Wdata:widget_message):void=
        return

CurrencyAwardOnAgent_Handler := class():
    CurrencyManager : Currency_Manager
    CurrencyType : currency_grant_type

    HandlerFunctionAgent(Agent : agent):void=
        CurrencyManager.CurrencyGrant(Agent, CurrencyType)

    HandlerFunctionMaybeAgent(MaybeAgent : ?agent, NewLevel : int):void=
        if(Agent := MaybeAgent?):
            CurrencyManager.CurrencyGrant(Agent, CurrencyType)


#OG code found here https://dev.epicgames.com/community/snippets/d8k/fortnite-wrapping-subscribe-to-pass-additional-data-to-listeners
(Listenable : listenable(widget_message)).SubscribeUIButton(OutputFunc : widget_message -> void) : cancelable =
    Wrapper := wrapper_agent_UIbutton(){OutputFunc := OutputFunc}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_agent_UIbutton() := class():
    OutputFunc : widget_message -> void
    InputFunc(Wdata : widget_message):void = 
        OutputFunc(Wdata)


(Listenable : listenable(widget_message)).SubscribePurchaseButton(OutputFunc:tuple(widget_message, item, logic)->void, ExtraData1:item, ExtraData2:logic) : cancelable =
    Wrapper := wrapper_agent_purchasebutton(){ExtraData1 := ExtraData1, ExtraData2 := ExtraData2, OutputFunc := OutputFunc}
    Listenable.Subscribe(Wrapper.InputFunc)
 
wrapper_agent_purchasebutton() := class():
    ExtraData1 : item
    ExtraData2 : logic
    OutputFunc : tuple(widget_message, item, logic) -> void
    InputFunc(Wdata : widget_message):void = OutputFunc(Wdata, ExtraData1, ExtraData2)


(Listenable : listenable(widget_message)).SubscribeChangeShopLayoutButton(OutputFunc : type{_(:widget_message,:item_type,:int)<suspends>:void},ExtraData1:item_type,ExtraData2:int) : cancelable =
    Wrapper := wrapper_agent_ChangeShopLayoutButton(){OutputFunc := OutputFunc, ExtraData1 := ExtraData1, ExtraData2 := ExtraData2}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_agent_ChangeShopLayoutButton() := class():
    ExtraData1 : item_type
    ExtraData2 : int
    OutputFunc : type{_(:widget_message,:item_type,:int)<suspends>:void}
    InputFunc(Wdata : widget_message):void = 
        spawn{OutputFunc(Wdata, ExtraData1, ExtraData2)}

(Listenable : listenable(device_ai_interaction_result)).SubscribeStatIncrease(OutputFunc : tuple(device_ai_interaction_result, stat_type) -> void,ExtraData1:stat_type) : cancelable =
    Wrapper := wrapper_agent_StatIncrease(){OutputFunc := OutputFunc, ExtraData1:=ExtraData1}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_agent_StatIncrease() := class():
    ExtraData1 : stat_type
    OutputFunc : tuple(device_ai_interaction_result, stat_type) -> void
    InputFunc(AIResult : device_ai_interaction_result):void = 
        OutputFunc(AIResult, ExtraData1)

(Listenable : listenable(agent)).SubscribeLevelCompletion(OutputFunction : tuple(custom_level, agent) -> void,ExtraData1:custom_level) : cancelable =
    Wrapper := wrapper_agent_LevelCompletion(){OutputFunction := OutputFunction, ExtraData1:=ExtraData1}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_agent_LevelCompletion() := class():
    ExtraData1 : custom_level
    OutputFunction : tuple(custom_level, agent) -> void
    InputFunc(Agent : agent):void = 
        OutputFunction(ExtraData1, Agent)
