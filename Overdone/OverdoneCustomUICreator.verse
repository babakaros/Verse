using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Concurrency }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

#########################################################################
########################### Player's UI Class ###########################
#########################################################################
custom_ui_creator:=class():
    StringToMessage<localizes>(S:string):message="{S}"
    PlayerNameToMessage<localizes>(Agent:agent):message="{Agent}"
    var PlayerToCustomPlayerMap:[player]custom_player 
    var PlayerToCanvasMap:[player][int]?canvas=map{}
    var DefaultCanvas:canvas=canvas{}
    
    Assign():void=
        var n : int = 1
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
            Print("Player {n} found")
            set n+=1
            Base(Player)

    AppearUI<private>(Interactable:logic,Order:int,Player:player,CanvasSlot:canvas_slot):void=
        var ZOrder:type {_X:int where 0 <= _X, _X <= 2147483647}=0
        if(TempOrder:=type {_X:int where 0 <= _X, _X <= 2147483647}[Order],set ZOrder=TempOrder){}
        if(CustomPlayer:=PlayerToCustomPlayerMap[Player]):
            if(PlayerUI:=GetPlayerUI[Player]):
                MyCanvas:=canvas{}
                case(Interactable):
                    true=>
                            PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder:=ZOrder,InputMode:=ui_input_mode.All}) 
                    _=>
                            PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder:=ZOrder,InputMode:=ui_input_mode.None})
                MyCanvas.AddWidget(CanvasSlot)
                if(set PlayerToCanvasMap[Player][Order]=option{MyCanvas}):
                    Print("Canvas num {Order} added to map.")

    Base<private>(Player:player):void=
        if(PlayerUI:=GetPlayerUI[Player]):
            MyCanvas:=MakeDefaultCanvas()
            if(set PlayerToCanvasMap[Player]=map{0=>option{MyCanvas}}):
                PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder:=0,InputMode:=ui_input_mode.None})

    MakeDefaultCanvas<private>():canvas=
        set DefaultCanvas=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=texture_block:
                        DefaultImage:=Icons.IC_MapCode
                        DefaultDesiredSize := vector2{X := 440.0, Y := 100.0}
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.03},Maximum:=vector2{X:=0.5,Y:=0.03}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=0  
        return DefaultCanvas

    MakeCustomCanvasSlot(CustomPlayer:custom_player):canvas_slot=
        EmptyCanvasSlot:=canvas_slot{Widget:=canvas{}}
        return EmptyCanvasSlot

    CurrentWidget():canvas_slot=
        EmptyCanvasSlot:=canvas_slot{Widget:=canvas{}}
        return EmptyCanvasSlot

    RemovePlayerHUD(Agent:agent,Order:int):void=
        if(Player:=player[Agent],PlayerUI:=GetPlayerUI[Player],PlayerWidget:=PlayerToCanvasMap[Player][Order]?):
            PlayerUI.RemoveWidget(PlayerWidget)

    RemoveSomeHUDS(UIOrderArray:[]int):void=
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
            if(PlayerUI:=GetPlayerUI[Player]):
                for(N:UIOrderArray,PlayerWidget:=PlayerToCanvasMap[Player][N]?):
                    Print("Removing widget {N}")
                    PlayerUI.RemoveWidget(PlayerWidget)
                    var NewMap:[int]?canvas=map{}
                    for(M->L:PlayerToCanvasMap[Player],M<>N):
                        set NewMap = ConcatenateMaps(NewMap,map{M=>L})
                    if(set PlayerToCanvasMap[Player]=NewMap){}

    RemoveAllHUDS():void=
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
            if(PlayerUI:=GetPlayerUI[Player]):
                for(N:=0..PlayerToCanvasMap[Player].Length-1,PlayerWidget:=PlayerToCanvasMap[Player][N]?):
                    PlayerUI.RemoveWidget(PlayerWidget)
                if(NewPTCM:=map{},set PlayerToCanvasMap[Player]=NewPTCM){}
###################################################################################################################################################################################################


##########################
### Countdown Timer UI ###
##########################
    var CountdownTimerOrder<private>:int=0
    var TotalTimer<private>:float=0.0
    var CountdownText<private>:string=""
    CountdownHalfTimeEvent<public> : event(float) = event(float){}
    CountdownEndedEvent<public> : event(float) = event(float){}
    var Time<private>:float=10000.0

    ShowCustomTimerUI(Interactable:logic,Order:int,Agent:?agent,CountdownTime:float,PreviewText:string):void=
        set CountdownTimerOrder=Order
        set TotalTimer=CountdownTime
        set CountdownText=PreviewText
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent]):
                AppearUI(Interactable,Order,Player,CTCanvasSlot())
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,CTCanvasSlot())

    CTCanvasSlot<private>():canvas_slot=
        var IntTime:int=0
        if(TempInt:=Round[TotalTimer],set IntTime=TempInt){}
        RemainingTimeTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("{CountdownText}{IntTime}")
            DefaultTextColor:=CadetBlue
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=3.0,Y:=3.0}}
        RemainingTimeTextBlock.SetShadowOpacity(1.0)
        TimerCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget := RemainingTimeTextBlock
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5 }
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true     
                    ZOrder:=2
                canvas_slot:
                    Widget:=texture_block:
                        DefaultImage:=Icons.IC_Circle
                        DefaultDesiredSize := vector2{X := 70.0, Y := 70.0}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5 }
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true     
                    ZOrder:=1
        CountdownTimerSlot:=canvas_slot:
            Widget:=TimerCanvas
            Anchors := anchors:
                Minimum := vector2{X := 0.5, Y := 0.11}
                Maximum := vector2{X := 0.5, Y := 0.11}
            Alignment := vector2{X := 0.5, Y := 0.5 }
            Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
            SizeToContent := true     
            ZOrder:=2
        spawn{RunCountdown(RemainingTimeTextBlock)}
        return CountdownTimerSlot
        
    RunCountdown<private>(TextBlock:text_block)<suspends> : void =
        var TotalTime:float = 0.0
        TimerTickPeriod:float = 1.0
        var TimeLeft:float=TotalTimer
        loop:
            Sleep(TimerTickPeriod)
            set TotalTime += TimerTickPeriod
            set TimeLeft -= TimerTickPeriod
            set Time=TimeLeft
            UpdateUI(TextBlock,TimeLeft)
            if(TimeLeft<=(TotalTimer/2.0)):
                CountdownHalfTimeEvent.Signal(TotalTime)
            if(TimeLeft <= 0.0):
                CountdownEndedEvent.Signal(TotalTime)
                break

    UpdateUI<private>(TextBlock:text_block,TimeLeft:float) : void =
        if(IntTime := Int[TimeLeft]):
            TextBlock.SetText(StringToMessage(CountdownText+"{IntTime}"))
##############################
### Countdown Timer UI End ###
##############################


#########################
### Difficulty Vote UI###
#########################
    var DifficultyVoteOrder<private>:int=0
    var PlayerDifficultyVotes:[player]difficulty=map{}
    var DifficultyArray:[]difficulty=array{}

    ShowDifficultyVoteUI(Interactable:logic,Order:int,Agent:?agent):void=
        set DifficultyVoteOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,DVCanvasSlot(CustomPlayer))
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,DVCanvasSlot(CustomPlayer))
    
    DVCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot=
        EasyButton:button_regular=button_regular{}
        EasyButton.SetText(StringToMessage("Easy"))
        EasyButton.OnClick().Subscribe(DifficultyButton_Handler{CustomUI:=Self,Difficulty:="Easy"}.HandlerFunction)
        MediumButton:button_regular=button_regular{}
        MediumButton.SetText(StringToMessage("Medium"))
        MediumButton.OnClick().Subscribe(DifficultyButton_Handler{CustomUI:=Self,Difficulty:="Medium"}.HandlerFunction)
        HardButton:button_regular=button_regular{}
        HardButton.SetText(StringToMessage("Hard"))
        HardButton.OnClick().Subscribe(DifficultyButton_Handler{CustomUI:=Self,Difficulty:="Hard"}.HandlerFunction)
        SubmitButton := button_loud:
            DefaultText:=StringToMessage("Submit")
        SubmitButton.OnClick().Subscribe(ExitDVote)

        DifficultyUIOptionsStack := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Widget:=texture_block:
                        DefaultImage:=Icons.IC_SelectDifficulty
                        DefaultDesiredSize:=vector2{X:=361.9,Y:=220.0}
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=7.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                stack_box_slot:
                    Widget:=EasyButton
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=30.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                stack_box_slot:
                    Widget:=MediumButton
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=25.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                stack_box_slot:
                    Widget:=HardButton
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=25.0,Left:=0.0,Bottom:=20.0,Right:=0.0}
                stack_box_slot:
                    Widget:=SubmitButton    
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=65.0,Left:=0.0,Bottom:=80.0,Right:=0.0}
        DifficultyUICanvas:canvas = canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=DifficultyUIOptionsStack
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=1
                canvas_slot:
                    Widget:=texture_block:
                        DefaultImage:=Icons.IC_DifficultyBG
                        DefaultDesiredSize := vector2{X := 400.0, Y := 700.0}
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.475}
                    ZOrder:=0
        VotingUICanvasSlot:=canvas_slot:
            Widget:=DifficultyUICanvas
            Anchors := anchors:
                Minimum := vector2{X := 0.5, Y := 0.5}
                Maximum := vector2{X := 0.5, Y := 0.5}
            Alignment := vector2{X := 0.5, Y := 0.5 }
            Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
            SizeToContent := true
            ZOrder:=1
        return VotingUICanvasSlot

    DifficultyVote(Difficulty:string,Wdata:widget_message):void=
        if(Difficulty="Easy"):
            if(Easy:=DifficultyArray[0], set PlayerDifficultyVotes[Wdata.Player]=Easy){}
        if(Difficulty="Medium"):
            if(Medium:=DifficultyArray[1], set PlayerDifficultyVotes[Wdata.Player]=Medium){}
        if(Difficulty="Hard"):
            if(Hard:=DifficultyArray[2], set PlayerDifficultyVotes[Wdata.Player]=Hard){}
        Print("{Difficulty}")

    ExitDVote<private>(Wdata:widget_message):void=
        if(Player:=Wdata.Player,Agent:=agent[Player]):
            RemovePlayerHUD(Agent,DifficultyVoteOrder)
            RemovePlayerHUD(Agent,CountdownTimerOrder)
##############################
### Difficulty Vote UI End ###
##############################


####################
### End Score UI ###
####################
    var EndScoreOrder<private>:int=0
    var FinalPoints<private>:int=0

    ShowEndScoreUI(Interactable:logic,Order:int,Agent:?agent):void=
        set EndScoreOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent]):
                AppearUI(Interactable,Order,Player,ESCanvasSlot())
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,ESCanvasSlot())

    ESCanvasSlot<private>():canvas_slot=
        PointsTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("Final Score: {FinalPoints}")
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=3.0,Y:=3.0}}
        PointsTextBlock.SetShadowOpacity(1.0)
        PointsCanvas:canvas = canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=PointsTextBlock
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=1
                canvas_slot:
                    Widget:=texture_block:
                        DefaultImage:=Icons.IC_OrderSoupBG
                        DefaultDesiredSize := vector2{X := 300.0, Y := 75.0}
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=0    
        PointsCanvasSlot:=canvas_slot:
            Widget:=PointsCanvas
            Anchors:=anchors:
                Minimum := vector2{X := 0.5, Y := 0.5}
                Maximum := vector2{X := 0.5, Y := 0.5}
            Alignment := vector2{X := 0.5, Y := 0.5 }
            SizeToContent := true     
            ZOrder:=10
        return PointsCanvasSlot   

    AnounceScore(PointsGotten:int):void=
        set FinalPoints=PointsGotten
        ShowEndScoreUI(false,5,false)
########################
### End Score UI End ###
########################


#########################
### Inventory Text UI ###
#########################
    var InventoryTextOrder<private>:int=0
    var InventoryText<private>:string="Empty" 

    ShowInventoryTextUI(Interactable:logic,Order:int,Agent:?agent):void=
        set InventoryTextOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,ITCanvasSlot(CustomPlayer))
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,ITCanvasSlot(CustomPlayer))

    ITCanvasSlot<private>(Player:custom_player):canvas_slot=
        InventoryTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("{InventoryText}")
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=3.0,Y:=3.0}}
        InventoryTextBlock.SetShadowOpacity(1.0)
        InventoryCanvas:=canvas_slot:
            Widget := InventoryTextBlock
            Anchors := anchors:
                Minimum := vector2{X := 0.02, Y := 0.9}
                Maximum := vector2{X := 0.02, Y := 0.9}
            Alignment := vector2{X := 0.0, Y := 0.0 }
            Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
            SizeToContent := true     
            ZOrder:=10
        spawn{RefreshInventory(InventoryTextBlock,Player)}
        return InventoryCanvas      
        
    RefreshInventory<private>(TextBlock:text_block,Player:custom_player)<suspends> : void =
        TotalTime:float = 1.0
        TimerTickPeriod:float = 0.25
        loop:
            Sleep(TimerTickPeriod)
            if(CurrentInventory:=Player.ItemCarrying[0],CurrentInventoryItem:=CurrentInventory):
                UpdateUI(TextBlock,CurrentInventory)
            else:
                UpdateUI(TextBlock,Nothing:item=item{ItemName:="Null"})
            if (TotalTime <= 0.0):
                break
    
    UpdateUI<private>(TextBlock:text_block,CurrentInventory:item) : void =
        if(CurrentInventory.Type="Container",Container:=container[CurrentInventory]):
            var IngredientArray:[]ingredient=array{}
            var Ing1:string=""
            var Ing2:string=""
            var Ing3:string=""
            for(Ingredient:Container.Contains):
                set IngredientArray+=array{Ingredient}
            if(Ingredient1:=IngredientArray[0],set Ing1=Ingredient1.ItemName){}
            if(Ingredient2:=IngredientArray[1],set Ing2=Ingredient2.ItemName){}
            if(Ingredient3:=IngredientArray[2],set Ing3=Ingredient3.ItemName){}
            TextBlock.SetText(StringToMessage("{CurrentInventory.ItemName} with {Ing1},{Ing2},{Ing3}"))
        else:
            TextBlock.SetText(StringToMessage("{CurrentInventory.ItemName}"))
##############################
### Inventory Text UI End ###
##############################


##########################
### Level Selection UI ###
##########################
    var LevelVoteOrder<private>:int=0
    var Levels:[]custom_level=array{}
    var SelectedLevels:[]custom_level=array{}
    var PlayerLevelVotes:[player]widget=map{}
    var WidgetToLevelMap:[widget]custom_level=map{}
    var ChooseLevelsEndedEvent<public>:event()=event(){}
    var LevelsSelected:logic=false

    ShowLevelVoteUI(Interactable:logic,Order:int,Agent:?agent):void=
        set LevelVoteOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,LSCanvasSlot(CustomPlayer))
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,LSCanvasSlot(CustomPlayer))

    LSCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot=
        ChooseLevels()
        loop:
            if(LevelsSelected?):
                break
        if(Player:=CustomPlayer.Player,Agent:=agent[Player]):
                ShowCustomTimerUI(false,3,option{Agent},20.0,"")

        SubmitButton := button_loud:
            DefaultText:=StringToMessage("Submit")
        SubmitButton.OnClick().Subscribe(ExitLVote)

        for(Level:SelectedLevels):
            spawn:
                LevelButtonsAwait(Level)
        
        if(Level1:custom_level=SelectedLevels[0],Level2:custom_level=SelectedLevels[1]):
            VotingOptionsStack := stack_box:
                Orientation := orientation.Horizontal
                Slots := array:
                    stack_box_slot:
                        Widget := Level1.StackBoxCreator()
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Padding:=margin{Top:=0.0,Left:=25.0,Bottom:=0.0,Right:=25.0}
                    stack_box_slot:
                        Widget := Level2.StackBoxCreator()
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Padding:=margin{Top:=0.0,Left:=25.0,Bottom:=0.0,Right:=25.0}
            VotingUICanvas:canvas = canvas:
                Slots:=array:
                    canvas_slot:
                        Widget:=texture_block:
                            DefaultImage:=Icons.IC_SelectLevel
                            DefaultDesiredSize:=vector2{X:=369.0,Y:=230.0}
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 0.055}
                            Maximum := vector2{X := 0.5, Y := 0.055}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                        SizeToContent := true
                        ZOrder:=3
                    canvas_slot:
                        Widget:=SubmitButton    
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 0.9}
                            Maximum := vector2{X := 0.5, Y := 0.9}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                        SizeToContent := true
                        ZOrder:=2
                    canvas_slot:
                        Widget:=VotingOptionsStack
                        Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                        Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                        SizeToContent:=true
                        Alignment:=vector2{X:=0.5,Y:=0.5}
                        ZOrder:=1
                    canvas_slot:
                        Widget:=texture_block:
                            DefaultImage:=Icons.IC_DifficultyBG
                            DefaultDesiredSize:=vector2{X:=800.0,Y:=700.0}
                        Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.52},Maximum:=vector2{X:=0.5,Y:=0.52}}
                        Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                        SizeToContent:=true
                        Alignment:=vector2{X:=0.5,Y:=0.5}
                        ZOrder:=0
            VotingUICanvasSlot:=canvas_slot:
                Widget:=VotingUICanvas
                Anchors := anchors:
                    Minimum := vector2{X := 0.5, Y := 0.5}
                    Maximum := vector2{X := 0.5, Y := 0.5}
                Alignment := vector2{X := 0.5, Y := 0.5 }
                Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                SizeToContent := true
                ZOrder:=1
            return VotingUICanvasSlot
        EmptyCanvasSlot:=canvas_slot{Widget:=canvas{}}
        return EmptyCanvasSlot

    ChooseLevels():void=
        var SelectedNumbers:[]int=array{}
        var LevelIndex:int=0
        var InIndex:logic=false
        var Iteration:int=1

        loop:
            if(SelectedNumbers.Length=2):           
                break
            set Iteration=Iteration+1
            set LevelIndex=GetRandomInt(0,Levels.Length-1)
            if(SelectedNumbers.Length=0):
                set SelectedNumbers=SelectedNumbers+array{LevelIndex}
            else:
                for (Num := 0..SelectedNumbers.Length - 1,not InIndex?):
                    if(LevelIndex=SelectedNumbers[Num]):
                        set InIndex = true
                    if(LevelIndex<>SelectedNumbers[Num],Num=SelectedNumbers.Length-1):
                        set SelectedNumbers=SelectedNumbers+array{LevelIndex}
                set InIndex = false
        if:
            TempLevel1:custom_level=Levels[SelectedNumbers[0]]
            TempLevel2:custom_level=Levels[SelectedNumbers[1]]
        then:           
            set SelectedLevels += array{TempLevel1,TempLevel2}
        set LevelsSelected=true

    LevelButtonsAwait<private>(Level:custom_level)<suspends>:void=
        Level.ButtonClickedEvent.Await()
        if(Widget:widget_message=Level.WdataArray[0],set WidgetToLevelMap[Widget.Source]=Level):
            SubmitVote(Widget)
        spawn{LevelButtonsAwait(Level)} # because it's retriggable

    SubmitVote<private>(Wdata:widget_message):void=
        if(set PlayerLevelVotes[Wdata.Player]=Wdata.Source):
            Print("Player vote added to map.")

    ExitLVote<private>(Wdata:widget_message):void=
        if(Player:=Wdata.Player,Agent:=agent[Player]):
            RemovePlayerHUD(Agent,LevelVoteOrder)
##############################
### Level Selection UI End ###
##############################


################
### Order UI ###
################
    var OrderOrder<private>:int=0
    var RecipeIcon:texture=Icons.IC_MapCode
    var TimeBetweenOrders<private>:float=0.0
    var TimeToExpireOrder<private>:float=0.0
    var ArrayOfRecipes:[]recipe=array{}
    var PlayerToOrderStackMap<private>:[player]stack_box=map{}
    var RecipeCanvasToUniqueIDMap<private>:[canvas]int=map{}
    var RecipeUniqueID:int=0
    var StandardIngredientOrder<private>:?[]ingredient=false
    var MaximumIngredients<private>:int=3

    ShowOrderUI(Interactable:logic,Order:int,Agent:?agent,SelectedTimeBetweenOrders:float,SelectedTimeToExpreOrder:float):void=
        set OrderOrder=Order
        set TimeBetweenOrders=SelectedTimeBetweenOrders
        set TimeToExpireOrder=SelectedTimeToExpreOrder
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,OCanvasSlot(CustomPlayer))
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,OCanvasSlot(CustomPlayer))

    OrderFood(Interactable:logic,Order:int,Agent:?agent,PossibleItems:[]ingredient,StandardSlots:?[]ingredient,MaxIngredients:int,IconRecipe:texture,SelectedTimeBetweenOrders:float,SelectedTimeToExpreOrder:float)<suspends>:void=
        ShowOrderUI(Interactable,Order,false,SelectedTimeBetweenOrders,SelectedTimeToExpreOrder)
        set StandardIngredientOrder=StandardSlots
        set MaximumIngredients=MaxIngredients
        set RecipeIcon=IconRecipe
        loop:
            if(ArrayOfRecipes.Length<5):
                set ArrayOfRecipes+=array{AssignRecipe(PossibleItems)}
            Print("Current Running Orders: {ArrayOfRecipes.Length}")
            Sleep(TimeBetweenOrders)

    OCanvasSlot(CustomPlayer:custom_player):canvas_slot=
        AnchorX:=0.98
        AnchorY:=0.05
        TotalOrdersStack:stack_box=stack_box{Orientation:=orientation.Vertical}
        OrderCanvasSlot:=canvas_slot:
            Widget:=TotalOrdersStack
            Anchors := anchors:
                Minimum := vector2{X:=AnchorX,Y:=AnchorY}
                Maximum := vector2{X:=AnchorX,Y:=AnchorY}
            Alignment := vector2{X := 1.0, Y := 0.0 }
            Offsets := margin{}
            SizeToContent := true     
            ZOrder:=9
        if(set PlayerToOrderStackMap[CustomPlayer.Player]=TotalOrdersStack){}
        return OrderCanvasSlot
    
    AssignRecipe<private>(PossibleItems:[]ingredient):recipe=
        Recipe:=recipe{MaxTime:=TimeToExpireOrder,RecipeUniqueID:=RecipeUniqueID,RecipeIcon:=RecipeIcon}
        if(not StandardIngredientOrder?):
            for(M:=0..MaximumIngredients-1):
                if(set Recipe.Ingredients+=array{PossibleItems[GetRandomInt(0,PossibleItems.Length-1)]}){}   
        else:
            if(IngredientOrder:=StandardIngredientOrder?):
                for(Ingredient:IngredientOrder):
                    set Recipe.Ingredients+=array{Ingredient}
                for(Remaining:=0..(MaximumIngredients-Recipe.Ingredients.Length-1)):
                    if(set Recipe.Ingredients+=array{PossibleItems[GetRandomInt(0,PossibleItems.Length-1)]}){}
        for(Player->OrderStack:PlayerToOrderStackMap):
            IngredientStack:stack_box=stack_box:
                Orientation := orientation.Vertical
            for(N:=0..Recipe.Ingredients.Length-1):
                if(CurrentIngredient:=Recipe.Ingredients[N]):
                    IngredientBGTextureBlock := texture_block:
                        DefaultImage:= Icons.IC_OrderIngredientBG  
                        DefaultDesiredSize := vector2{X := 50.0, Y := 50.0}  
                    IngredientTextureBlock := texture_block:
                        DefaultImage:= CurrentIngredient.ItemIcon  
                        DefaultDesiredSize := vector2{X := 100.0, Y := 90.0}
                    IngredientCanvas:canvas=canvas:
                        Slots:=array:
                            canvas_slot:
                                Widget:=IngredientTextureBlock
                                Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                                Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                                SizeToContent:=true
                                Alignment:=vector2{X:=0.5,Y:=0.5}
                                ZOrder:=1
                            canvas_slot:
                                Widget:=IngredientBGTextureBlock
                                Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                                Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                                SizeToContent:=true
                                Alignment:=vector2{X:=0.5,Y:=0.5}
                                ZOrder:=0
                    IngredientSlot:=stack_box_slot:
                        Widget:=IngredientCanvas
                        HorizontalAlignment:=horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                    IngredientStack.AddWidget(IngredientSlot)
            RecipeCanvas:=Recipe.MakeRecipeCanvas(IngredientStack)
            if(set RecipeCanvasToUniqueIDMap[RecipeCanvas]=RecipeUniqueID):
            OrderStackSlot:=stack_box_slot:
                Widget:=RecipeCanvas
                HorizontalAlignment:=horizontal_alignment.Left
                VerticalAlignment:=vertical_alignment.Bottom
            OrderStack.AddWidget(OrderStackSlot)
        spawn{RecipeTimedOut(Recipe)}
        spawn{Recipe.KillRecipe()}
        set RecipeUniqueID+=1
        return Recipe

    RecipeTimedOut<private>(Recipe:recipe)<suspends>:void=
        Recipe.TimeOutEvent.Await()
        DisposeRecipe(Recipe)
        spawn{RecipeTimedOut(Recipe)}

    DisposeRecipe(ExpiredRecipe:recipe):void=
        UniqueID:=ExpiredRecipe.RecipeUniqueID
        for(Recipe->ID:RecipeCanvasToUniqueIDMap,ID=ExpiredRecipe.RecipeUniqueID):
            for(Player->OrderStack:PlayerToOrderStackMap):
                OrderStack.RemoveWidget(Recipe)
        for(M:=0..ArrayOfRecipes.Length-1,ExistingRecipe:=ArrayOfRecipes[M]):
            if(ExpiredRecipe=ExistingRecipe):
                if(NewArrayOfRecipes:=ArrayOfRecipes.RemoveElement[M],set ArrayOfRecipes=NewArrayOfRecipes){}
####################
### Order UI End ###
####################


#######################
### Point System UI ###
#######################
    var PointSystemOrder<private>:int=0
    var Points:int=0 
    var MaxPoints:int=0

    ShowPointSystemUI(Interactable:logic,Order:int,Agent:?agent,SelectedMaxPoints:int):void=
        set PointSystemOrder=Order
        set MaxPoints=SelectedMaxPoints
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent]):
                AppearUI(Interactable,Order,Player,PSCanvasSlot())
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,PSCanvasSlot())

    PSCanvasSlot():canvas_slot=
        PointsTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("{Points}")
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=3.0,Y:=3.0}}
        PointsTextBlock.SetShadowOpacity(1.0)
        PointsCanvas:=canvas_slot:
            Widget := PointsTextBlock
            Anchors := anchors:
                Minimum := vector2{X := 0.02, Y := 0.1}
                Maximum := vector2{X := 0.02, Y := 0.1}
            Alignment := vector2{X := 0.0, Y := 0.0 }
            SizeToContent := true     
            ZOrder:=10
        spawn{UpdateUI(PointsTextBlock)}
        return PointsCanvas   
    
    UpdateUI<private>(TextBlock:text_block)<suspends>:void=
        loop:
            TextBlock.SetText(StringToMessage("Points to next reward: {Points}/{MaxPoints}"))
            if(Points<0):
                break
            Sleep(1.0)
###########################
### Point System UI End ###
###########################
