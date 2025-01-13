using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation/Tags }

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
                if(MutatorTags.Has[level1{}]):
                    Print("Entered level 1")
                    spawn{Device.SelectItemUI(Agent)}
                    Device.BasementPulse.DeactivateObjectivePulse(Agent)
                    Device.ShopPulse.DeactivateObjectivePulse(Agent)
                for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap):
                    if:
                        MutatorTags.Has[Level.Tag]
                        set Device.LevelsToArrayCustomPlayersMap[Level] += array{CustomPlayer}
                    then:
                        if(Level.Index<>1,Level.Completed?,CustomPlayer.LevelReached<Level.Index):
                            Print("Entered completed level")
                            spawn{Device.SelectItemUI(Agent)}
                return
            #When player exits level
            for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap):
                if:
                    MutatorTags.Has[Level.Tag]
                    PlayerIndex:=Device.LevelsToArrayCustomPlayersMap[Level].Find[CustomPlayer]
                    TempArray:=Device.LevelsToArrayCustomPlayersMap[Level].RemoveElement[PlayerIndex]
                    set Device.LevelsToArrayCustomPlayersMap[Level] = TempArray
                if:
                    Level.Index = 1
                then:
                    set CustomPlayer.LevelReached = -1 
                    if:
                        Device.LevelsToArrayCustomPlayersMap[Level].Length = 0
                    then:
                        spawn{Device.ResetLevel(Level,Agent)}
                    
#Handler for level completion                    
TriggerEvent_Handler := class(): 
    Device:Game_Manager
    TriggerTags:tag_view
    HandlerFunction(Agent:?agent) : void=
        Print("Level completed")
        var CurrentLevelIndex:int=-1
        for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap, TriggerTags.Has[Level.Tag]):      
            set Level.Completed = true
            set CurrentLevelIndex = Level.Index
            for(CustomPlayer:CustomPlayersArray, CustomAgent:=agent[CustomPlayer.Player]):
                if( Level.Index <> Device.LevelsToArrayCustomPlayersMap.Length):
                    Device.CurrencyGranter.GrantItemIndex(CustomAgent,1)
                    spawn{Device.SelectItemUI(CustomAgent)}
                if:
                    Mod[Level.Index,5] = 0
                    N:=Ceil(Level.Index/5)
                then:
                    for(ImportanceIndex:=0..N-1):
                        Device.CurrencyGranter.GrantItemIndex(CustomAgent,2)
                if(Level.Index = Device.LevelsToArrayCustomPlayersMap.Length):
                    Device.EndGameMessage.Show(CustomAgent)
                    TimesCompleted:=CustomPlayer.TimesCompleted
                    Device.UpdatePlayerData(CustomPlayer.Player, "TimesCompleted", TimesCompleted)
                set CustomPlayer.LevelReached = CurrentLevelIndex

        for(Level->CustomPlayersArray:Device.LevelsToArrayCustomPlayersMap,Level.Index = CurrentLevelIndex+1):
            if(TrueAgent:=Agent?, Device.LevelsToArrayCustomPlayersMap[Level].Length=0):
                spawn{Device.ResetLevel(Level,TrueAgent)}

ItemSelectButton_Handler := class():
    Item:item
    Event:event(widget_message)

    HandlerFunction(Wdata:widget_message):void=
        if:
            Player:=Wdata.Player
            Agent:=agent[Player]
        then:
            Item.Granter.GrantItem(Agent)
            Event.Signal(Wdata)

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
