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
    IntToMessage<localizes>(I:int):message="{I}"
    AgentToMessage<private><localizes>(A:agent):message="{A}"
    IntToString<private>(I:int):string="{I}"
    var PlayerToCustomPlayerMap:[player]custom_player 
    var PlayerToCanvasMap:[player][int]?canvas=map{}
    var ExistingUIs:[]int=array{}
    var DefaultCanvas:canvas=canvas{}
    var RealTimeProp:?creative_prop

    RealTimeEvent : event(float) = event(float){}
    RefreshUIsEvent : event(float) = event(float){}
    
    Assign():void=
        var n : int = 1
        spawn{RefreshUIs()}
        spawn{CheckTime()}
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
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
                if(set PlayerToCanvasMap[Player][Order]=option{MyCanvas}){}

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
                        DefaultDesiredSize := vector2{X := 660.0, Y := 150.0}
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.03},Maximum:=vector2{X:=0.5,Y:=0.03}}
                    Offsets:=margin{Top:=10.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
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

    CustomButton(ButtonName:string, ButtonPressFunction(Wdata:widget_message):void):button_loud=
        Button:=button_loud{}
        Button.SetText(StringToMessage(ButtonName))
        Button.OnClick().SubscribeUIButton(ButtonPressFunction)
        return Button

    GetTime():string=
        var RTMin:int=0
        var RTSec:int=0
        var Minutes:string=("")
        var Seconds:string=("")
        if(TrueRealTimeProp:=RealTimeProp?):
            RT:=MakeCurrentTime(TrueRealTimeProp)
            set RTMin = RT.Minutes
            set RTSec = RT.Seconds
        if(RTMin>30):
            set RTMin -= 30
        var MinLeft:int=0
        var SecLeft:int=60-RTSec
        if(SecLeft=60):
            set MinLeft = 30 - RTMin
            set SecLeft = 0
        else:
            if(RTMin<>30):
                set MinLeft = 29 - RTMin
            else:
                set MinLeft = 29
        if(MinLeft<10):
            set Minutes = ("0"+"{MinLeft}")
        else:
            set Minutes = ("{MinLeft}")
        if(SecLeft<10):
            set Seconds = ("0"+"{SecLeft}")
        else:
            set Seconds = ("{SecLeft}")
        return "{Minutes}:{Seconds}"

    RefreshUIs<private>()<suspends> : void =
        TotalTime:float = 1.0
        TimerTickPeriod:float = 1.0
        loop:
            Sleep(TimerTickPeriod)
            RefreshUIsEvent.Signal(TotalTime)
            if (TotalTime <= 0.0):
                break

    ApplyGlobalExistingUIs(Player:player):void=
        Base(Player)
        if(Agent:=agent[Player],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
            for(UIOrder:ExistingUIs):
                if(UIOrder=CurrencyTextOrder):
                    ShowCurrencyTextUI(false, UIOrder, option{Agent}) 
                else if(UIOrder=ProgressBarOrder):
                    ShowProgressBarUI(false, UIOrder, option{Agent}, TotalLevelsNumber)

    RemoveSomeHUDS(Agent:?agent, UIOrderArray:?[]int):void=
        if(TrueUIOrderArray:=UIOrderArray?):
            if:
                TrueAgent:=Agent?
                Player:=player[TrueAgent]
                PlayerUI:=GetPlayerUI[Player]
            then:
                for(N:TrueUIOrderArray,PlayerWidget:=PlayerToCanvasMap[Player][N]?):
                    Print("Removing widget {N}")
                    PlayerUI.RemoveWidget(PlayerWidget)
                    var NewMap:[int]?canvas=map{}
                    for(M->L:PlayerToCanvasMap[Player],M<>N):
                        set NewMap = ConcatenateMaps(NewMap,map{M=>L})
                    if(set PlayerToCanvasMap[Player]=NewMap){}
            else:
                for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                    if(PlayerUI:=GetPlayerUI[Player]):
                        for(N:TrueUIOrderArray,PlayerWidget:=PlayerToCanvasMap[Player][N]?):
                            Print("Removing widget {N}")
                            PlayerUI.RemoveWidget(PlayerWidget)
                            var NewMap:[int]?canvas=map{}
                            for(M->L:PlayerToCanvasMap[Player],M<>N):
                                set NewMap = ConcatenateMaps(NewMap,map{M=>L})
                            if(set PlayerToCanvasMap[Player]=NewMap){}
                for(M:TrueUIOrderArray):
                    var NewTempExistingUIs:[]int=array{}
                    for(N:ExistingUIs,N<>M):
                        set NewTempExistingUIs+=array{N}
                    set ExistingUIs=NewTempExistingUIs
        else:
            if:
                TrueAgent:=Agent?
                Player:=player[TrueAgent]
                PlayerUI:=GetPlayerUI[Player]
            then:
                for(Widget:PlayerToCanvasMap[Player],TrueWidget:=Widget?):
                    PlayerUI.RemoveWidget(TrueWidget)
                if(set PlayerToCanvasMap[Player] = map{}){}
                
    RemoveAllHUDS():void=
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
            if(PlayerUI:=GetPlayerUI[Player]):
                for(N:=0..PlayerToCanvasMap[Player].Length-1,PlayerWidget:=PlayerToCanvasMap[Player][N]?):
                    PlayerUI.RemoveWidget(PlayerWidget)
                if(NewPTCM:=map{},set PlayerToCanvasMap[Player]=NewPTCM){}
        set ExistingUIs = array{}
###################################################################################################################################################################################################


##########################
### Class Selection UI ###
##########################
    var ClassSelectionOrder<private>:int=0
    SetPlaybackFrames:[]int=array{90,180,270,360,450,540}
    var VehicleSelectionAudio:audio_player_device=audio_player_device{}
    var VehicleSequence:cinematic_sequence_device=cinematic_sequence_device{}
    var BikeClass:?vehicle_class=false
    var SportBikeClass:?vehicle_class=false
    var ATVClass:?vehicle_class=false
    var RallyCarClass:?vehicle_class=false
    var RacingTruckClass:?vehicle_class=false
    var BigRigClass:?vehicle_class=false

    ShowClassSelectionUI(Interactable:logic,Order:int,Agent:?agent):void=
        set ClassSelectionOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent]):
                AppearUI(Interactable,Order,Player,CSCanvasSlot())
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,CSCanvasSlot())

    CSCanvasSlot<private>():canvas_slot=
        VehicleSequence.Play()
        PickYourRideLogo : texture = UITextures.TPickYourRide
        PickYourRideIcon : texture_block = texture_block{DefaultImage := PickYourRideLogo}
        PickYourRideIcon.SetDesiredSize(vector2{X:=800.0,Y:=210.0})
        
        Button1 : button_quiet = button_quiet{}
        Button1.SetText(StringToMessage("BIKE"))
        Button1.OnClick().Subscribe(ClassSelectionButton_Handler{Frame:=0,CustomUI:=Self}.HandlerFunction)
        
        Button2 : button_quiet = button_quiet{}
        Button2.SetText(StringToMessage("SPORT BIKE"))
        Button2.OnClick().Subscribe(ClassSelectionButton_Handler{Frame:=90,CustomUI:=Self}.HandlerFunction)

        Button3 : button_quiet = button_quiet{}
        Button3.SetText(StringToMessage("ATV"))
        Button3.OnClick().Subscribe(ClassSelectionButton_Handler{Frame:=180,CustomUI:=Self}.HandlerFunction)

        Button4 : button_quiet = button_quiet{}
        Button4.SetText(StringToMessage("RALLY CAR"))
        Button4.OnClick().Subscribe(ClassSelectionButton_Handler{Frame:=270,CustomUI:=Self}.HandlerFunction)
    
        Button5 : button_quiet = button_quiet{}
        Button5.SetText(StringToMessage("RACING TRUCK"))
        Button5.OnClick().Subscribe(ClassSelectionButton_Handler{Frame:=360,CustomUI:=Self}.HandlerFunction)

        Button6 : button_quiet = button_quiet{}
        Button6.SetText(StringToMessage("BIG RIG"))
        Button6.OnClick().Subscribe(ClassSelectionButton_Handler{Frame:=450,CustomUI:=Self}.HandlerFunction)

        ClassStackBox:stack_box=stack_box:
            Orientation := orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=Button1
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=40.0,Left:=0.0,Bottom:=40.0,Right:=0.0}
                stack_box_slot:
                    Widget:=Button2
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=40.0,Left:=0.0,Bottom:=40.0,Right:=0.0}
                stack_box_slot:
                    Widget:=Button3
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=40.0,Left:=0.0,Bottom:=40.0,Right:=0.0}
                stack_box_slot:
                    Widget:=Button4
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=40.0,Left:=0.0,Bottom:=40.0,Right:=0.0}
                stack_box_slot:
                    Widget:=Button5
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=40.0,Left:=0.0,Bottom:=40.0,Right:=0.0}
                stack_box_slot:
                    Widget:=Button6
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=40.0,Left:=0.0,Bottom:=40.0,Right:=0.0}

        ClassSelectionCanvas:canvas=canvas:
            Slots:= array:
                canvas_slot:
                    Widget:=ClassStackBox
                    Anchors:=anchors{Minimum:=vector2{X:=0.0,Y:=0.5},Maximum:=vector2{X:=0.0,Y:=0.5}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=1.7,Y:=0.5}
                    ZOrder:=2
                canvas_slot:
                    Widget:=PickYourRideIcon
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.07},Maximum:=vector2{X:=0.5,Y:=0.07}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=1

        ClassSelectionCanvasSlot:canvas_slot=canvas_slot:
            Widget := ClassSelectionCanvas
            Anchors := anchors:
                Minimum := vector2{X := 0.5, Y := 0.5}
                Maximum := vector2{X := 0.5, Y := 0.5}
            Alignment:=vector2{X:=0.5,Y:=0.5}
            Offsets:=margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
            SizeToContent:=true 
            ZOrder:=10
        ShowCustomTimerUI(false,2,false)
        return ClassSelectionCanvasSlot
    
    CSButtonPressed(Wdata:widget_message,Frame:int):void=
        spawn{CSVehicleSequenceWhole(Frame)}
        if(Agent:=agent[Wdata.Player],Player:=Wdata.Player,CustomPlayer:=PlayerToCustomPlayerMap[Player]):
            if:
                case(Frame):
                    0=> if(TrueBikeClass:=BikeClass?,set CustomPlayer.CurrentClass=TrueBikeClass):
                    90=> if(TrueSportBikeClass:=SportBikeClass?,set CustomPlayer.CurrentClass=TrueSportBikeClass){}
                    180=> if(TrueATVClass:=ATVClass?,set CustomPlayer.CurrentClass=TrueATVClass){}
                    270=> if(TrueRallyCarClass:=RallyCarClass?,set CustomPlayer.CurrentClass=TrueRallyCarClass){}
                    360=> if(TrueRacingTruckClass:=RacingTruckClass?,set CustomPlayer.CurrentClass=TrueRacingTruckClass){}
                    450=> if(TrueBigRigClass:=BigRigClass?,set CustomPlayer.CurrentClass=TrueBigRigClass){}
            CustomPlayer.CurrentClass.ClassSelector.ChangeClass(Agent)

    CSVehicleSequenceWhole<private>(Frame:int)<suspends>:void=
        VehicleSelectionAudio.Play()
        if(Time>5.0):
            CurrentFrame : int = VehicleSequence.GetPlaybackFrame()
            Print("We have a HUD and Current Frame is: {CurrentFrame}")
            for (m:SetPlaybackFrames):
                if(CurrentFrame < m):
                    TimeToSet : float = ((m - CurrentFrame) * 0.04166666666)
                    VehicleSequence.Play()
                    Print("Time to set: {TimeToSet}")
                    Sleep(TimeToSet)
                    VehicleSequence.SetPlaybackFrame(Frame)
                    Print("Setting Playback Frame to: {Frame}")
                    return
                else:
                    Print("Not there yet")
        else:
            Print("Too late")
##############################
### Class Selection UI End ###
##############################


##########################
### Countdown Timer UI ###
##########################
    var CountdownTimerOrder<private>:int=0
    var TotalTimer<private>:float=0.0
    var CountdownText<private>:string=""
    var Time<private>:float=10000.0
    var TimerEnded:logic = false

    ShowCustomTimerUI(Interactable:logic,Order:int,Agent:?agent,CountdownTime:float,PreviewText:string):void=
        set CountdownTimerOrder=Order
        set TotalTimer=CountdownTime
        set CountdownText=PreviewText
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent]):
                AppearUI(Interactable,Order,Player,CTCanvasSlot(Player))
        else:
            set ExistingUIs = ExistingUIs + array{CountdownTimerOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,CTCanvasSlot(Player))

    CTCanvasSlot<private>(Player:player):canvas_slot=
        CountdownEndedEvent : event(float) = event(float){}
        var IntTime:int=0
        if(TempInt:=Round[TotalTimer],set IntTime=TempInt){}
        RemainingTimeTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("{CountdownText}{IntTime}")
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=2.0,Y:=2.0}}
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
                        DefaultImage:=Icons.IC_TimerBG
                        DefaultDesiredSize := vector2{X := 120.0, Y := 120.0}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.65 }
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
        if(Agent:=agent[Player]):
            spawn{RunCountdown(RemainingTimeTextBlock,CountdownEndedEvent,Agent)}
        return CountdownTimerSlot
        
    RunCountdown<private>(TextBlock:text_block,Event:event(float),Agent:agent)<suspends> : void =
        var TotalTime:float = 0.0
        TimerTickPeriod:float = 1.0
        var TimeLeft:float=TotalTimer
        loop:
            if(TimerEnded?):
                break
            Sleep(TimerTickPeriod)
            set TotalTime += TimerTickPeriod
            set TimeLeft -= TimerTickPeriod
            set Time=TimeLeft
            UpdateUI(TextBlock,TimeLeft)
            if(TimeLeft <= 0.0):
                Event.Signal(TotalTime)
                RemoveSomeHUDS(option{Agent},option{array{2,3}})
                break
        set TimerEnded = false

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
    var PlayerVotes:[player]difficulty=map{}
    var DifficultyArray<private>:[]difficulty=array{}
    var PlayerDifficultyVotes:[player]difficulty=map{}
    var DifficultyArray:[]difficulty=array{}

    ShowDifficultyVoteUI(Interactable:logic,Order:int,Agent:?agent,SelectedDifficultyArray:[]difficulty):void=
    ShowDifficultyVoteUI(Interactable:logic,Order:int,Agent:?agent):void=
        set DifficultyVoteOrder=Order
        set DifficultyArray=SelectedDifficultyArray
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,DVCanvasSlot(CustomPlayer))
@@ -210,7 +212,7 @@ custom_ui_creator:=class():
        HardButton.OnClick().Subscribe(DifficultyButton_Handler{CustomUI:=Self,Difficulty:="Hard"}.HandlerFunction)
        SubmitButton := button_loud:
            DefaultText:=StringToMessage("Submit")
        SubmitButton.OnClick().Subscribe(ExitVote)
        SubmitButton.OnClick().Subscribe(ExitDVote)

        DifficultyUIOptionsStack := stack_box:
            Orientation := orientation.Vertical
@@ -269,20 +271,18 @@ custom_ui_creator:=class():
            Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
            SizeToContent := true
            ZOrder:=1
        if(Player:=CustomPlayer.Player,Agent:=agent[Player]):
            ShowCustomTimerUI(false,2,option{Agent},15.0,"")
        return VotingUICanvasSlot

    DifficultyVote(Difficulty:string,Wdata:widget_message):void=
        if(Difficulty="Easy"):
            if(Easy:=DifficultyArray[0], set PlayerVotes[Wdata.Player]=Easy){}
            if(Easy:=DifficultyArray[0], set PlayerDifficultyVotes[Wdata.Player]=Easy){}
        if(Difficulty="Medium"):
            if(Medium:=DifficultyArray[1], set PlayerVotes[Wdata.Player]=Medium){}
            if(Medium:=DifficultyArray[1], set PlayerDifficultyVotes[Wdata.Player]=Medium){}
        if(Difficulty="Hard"):
            if(Hard:=DifficultyArray[2], set PlayerVotes[Wdata.Player]=Hard){}
            if(Hard:=DifficultyArray[2], set PlayerDifficultyVotes[Wdata.Player]=Hard){}
        Print("{Difficulty}")

    ExitVote<private>(Wdata:widget_message):void=
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
    set Points=PointsGotten
    ShowEndScoreUI(false,5,false)
########################
### End Score UI End ###
########################


#########################
### Inventory Menu UI ###
#########################
    var InventoryMenuOrder:int=1
    var Inventory : string = "0/12" 
    var GlassPreviewer:cinematic_sequence_device=cinematic_sequence_device{}
    var GlassesArray:[]glasses=array{}

    ShowInventoryMenuUI(Interactable:logic,Order:int,Agent:?agent):void=
        set InventoryMenuOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,IMCanvasSlot(CustomPlayer))
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,IMCanvasSlot(CustomPlayer))

    IMCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot=
        if(Player:=CustomPlayer.Player,Agent:=agent[Player]):
            GlassPreviewer.SetPlaybackFrame(1)
            GlassPreviewer.Play(Agent)
            GlassPreviewer.SetPlayRate(0.2)
            spawn{Stopper(Agent)}
        BGColorBlock:=color_block:
            DefaultColor:=White
            DefaultOpacity:=0.25
            DefaultDesiredSize:=vector2{X:=1200.0,Y:=1080.0}
        ExitButton:button_regular=button_regular{}
        ExitButton.SetText(StringToMessage("Exit"))
        ExitButton.OnClick().Subscribe(ExitCollection)
        StackBoxRow1:stack_box=stack_box:
            Orientation := orientation.Horizontal
        StackBoxRow2:stack_box=stack_box:
            Orientation := orientation.Horizontal
        StackBoxRow3:stack_box=stack_box:
            Orientation := orientation.Horizontal
        for(N:=0..GlassesArray.Length-1,GlassesObj:=GlassesArray[N]):
            if(N<4):
                StackBoxRow1.AddWidget(GlassesObj.MakeStackBoxSlot())
            else if(N<8):
                StackBoxRow2.AddWidget(GlassesObj.MakeStackBoxSlot())
            else:
                StackBoxRow3.AddWidget(GlassesObj.MakeStackBoxSlot())
        InventoryStackBox:stack_box=stack_box:
            Orientation := orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=StackBoxRow1
                stack_box_slot:
                    Widget:=StackBoxRow2
                stack_box_slot:
                    Widget:=StackBoxRow3
        InventoryCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=BGColorBlock
                canvas_slot:
                    Widget:=CollectionTextBlock:=text_block:
                        DefaultText:=StringToMessage("COLLECTION")
                        DefaultTextColor:=Black
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.07},Maximum:=vector2{X:=0.5,Y:=0.07}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=0  
                canvas_slot:
                    Widget:=InventoryStackBox
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=0
                canvas_slot:
                    Widget:=ExitButton
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.95},Maximum:=vector2{X:=0.5,Y:=0.95}}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
        InventoryCanvasSlot:=canvas_slot:
            Widget := InventoryCanvas
            Anchors := anchors:
                Minimum := vector2{X := 0.28, Y := 0.5}
                Maximum := vector2{X := 0.28, Y := 0.5}
            Alignment := vector2{X := 0.5, Y := 0.5}
            Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
            SizeToContent := true     
            ZOrder:=20
        return InventoryCanvasSlot   

    ExitCollection<private>(Wdata:widget_message):void=
        if(Player:=Wdata.Player,Agent:=agent[Player]):
            RemovePlayerHUD(Agent,InventoryMenuOrder)
            GlassPreviewer.GoToEndAndStop(Agent)

    Stopper<private>(Agent:agent)<suspends>:void=
        Sleep(9.5)
        GlassPreviewer.Pause(Agent)
#############################
### Inventory Menu UI End ###
#############################


#########################
### Inventory Text UI ###
#########################
    var InventoryTextOrder<private>:int=0
    var InventoryText : string = "0/12" 

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
        GlassesTextureBlock := texture_block:
            DefaultImage:= Icons.IC_GlassesClearBG
            DefaultDesiredSize := vector2{X := 50.0, Y := 40.0}  
        InventoryStackBox:stack_box=stack_box:
            Orientation := orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Widget:=InventoryTextBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                stack_box_slot:
                    Widget:=GlassesTextureBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
        InventoryCanvasSlot:=canvas_slot:
            Widget := InventoryStackBox
            Anchors := anchors:
                Minimum := vector2{X := 0.02, Y := 0.5}
                Maximum := vector2{X := 0.02, Y := 0.5}
            Alignment := vector2{X := 0.0, Y := 0.0 }
            Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
            SizeToContent := true     
            ZOrder:=10
        spawn{RefreshInventory(InventoryTextBlock,Player)}
        return InventoryCanvasSlot   
        
    RefreshInventory<private>(TextBlock:text_block,Player:custom_player)<suspends> : void =
        TotalTime:float = 1.0
        TimerTickPeriod:float = 0.25
        loop:
            Sleep(TimerTickPeriod)
            N:=Player.GlassesFound.Length
            UpdateUI(TextBlock,N)
            if (TotalTime <= 0.0):
                break

    UpdateUI<private>(TextBlock:text_block,TotalGlasses:int) : void =
        TextBlock.SetText(StringToMessage("{TotalGlasses}/12"))
##############################
### Inventory Text UI End ###
##############################


#########################
### Item Shop UI ###
#########################
    var ItemShopOrder<private>:int=0
    var ItemsGenreArray:[]item=array{}
    var LTOArray:[]item=array{}
    var AvailableItems:[]item=array{}
        
    ShowItemShopUI(Interactable:logic,Order:int,Agent:?agent,AllItems:[]item):void=
        set ItemShopOrder=Order
        set AvailableItems=AllItems
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,GSCanvasSlot(CustomPlayer))
        else:
            set ExistingUIs = ExistingUIs + array{ItemShopOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,GSCanvasSlot(CustomPlayer))

    GSCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot=
        CountdownClock:=text_block:
            DefaultText:=StringToMessage(GetTime())
            DefaultTextColor:=Red
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=0.8,Y:=0.8}}
            DefaultShadowOpacity:=1.0

        Timer_Canvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=text_block:
                        DefaultText:=StringToMessage("LIMITED TIME OFFER")
                        DefaultTextColor:=White
                        DefaultShadowColor:=Black
                        DefaultShadowOffset:=option{vector2{X := 2.0, Y := 2.0}}
                        DefaultShadowOpacity:=1.0
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.7, Y := 1.0}
                    ZOrder := 10
                canvas_slot:
                    Widget:=CountdownClock
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.7, Y := 0.0}
                    ZOrder := 10
                canvas_slot:
                    Widget:=color_block:
                        DefaultColor:=Yellow 
                        DefaultOpacity:=1.0
                        DefaultDesiredSize:=vector2{X:=500.0, Y:=250.0}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    ZOrder := 9

        LTO_StackBox:=stack_box:
            Orientation:=orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Widget := Timer_Canvas
                    VerticalAlignment:=vertical_alignment.Top
                stack_box_slot:
                    Widget := CurrentLTOStackBox(CustomPlayer)
                    VerticalAlignment:=vertical_alignment.Top

        LTO_Canvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=color_block :
                        DefaultColor:=Yellow 
                        DefaultOpacity:=0.5
                        DefaultDesiredSize:=vector2{X:=1920.0, Y:=250.0}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.0}
                        Maximum := vector2{X := 0.0, Y := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    ZOrder := 10
                canvas_slot:
                    Widget := LTO_StackBox
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.0}
                        Maximum := vector2{X := 0.0, Y := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    ZOrder := 11           

        Shop_StackBox:=stack_box:
            Orientation:=orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=LTO_Canvas
                    Padding:=margin{Bottom:=50.0}
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Top
                stack_box_slot:
                    Widget:=PermanentItemsStackBox(CustomPlayer)
                    HorizontalAlignment:=horizontal_alignment.Center
                stack_box_slot:
                    Widget:=GetCurrencyStackBox(CustomPlayer)
                    Padding:=margin{Top:=150.0,Left:=20.0}

        ItemShop_Canvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget := color_block:
                        DefaultColor:=Black
                        DefaultOpacity:=0.9
                        DefaultDesiredSize:=vector2{X:=3840.0, Y:=2560.0}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.0}
                        Maximum := vector2{X := 0.0, Y := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := true
                    ZOrder:=21
                canvas_slot:
                    Widget := Shop_StackBox
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.0}
                        Maximum := vector2{X := 0.0, Y := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    ZOrder:=22
                canvas_slot:
                    Widget:=CustomButton("Exit",ExitCollection)
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.0}
                        Maximum := vector2{X := 0.0, Y := 0.0}
                    Alignment := vector2{X := -13.0, Y := -1.5}
                    SizeToContent := true
                    ZOrder:=23

        ItemShop_CanvasSlot:=canvas_slot:
            Widget := ItemShop_Canvas
            Anchors := anchors:
                Minimum := vector2{X := 0.0, Y := 0.0}
                Maximum := vector2{X := 0.0, Y := 0.0}
            Alignment := vector2{X := 0.0, Y := 0.0}
            SizeToContent := false
            ZOrder:=20

        spawn{LTOClock(CountdownClock)}
        return ItemShop_CanvasSlot   

    ###    LTO      ##########################################################################################
    LTOClock<private>(TextBlock:text_block)<suspends> : void =
        var LTO:logic=false
        TimerTickPeriod:float = 1.0
        loop:
            if(LTO?):
                break
            Sleep(TimerTickPeriod)
            TextBlock.SetText(StringToMessage("{GetTime()}"))
        set LTO = false

    CheckTime()<suspends>:void=
        var RTMin:int=0
        var RTSec:int=0
        var CheckTimeBool:logic=true
        loop:
            if(not CheckTimeBool?):
                break
            Sleep(1.0)
            if(TrueRealTimeProp:=RealTimeProp?):
                RT:=MakeCurrentTime(TrueRealTimeProp)
                set RTMin = RT.Minutes
                set RTSec = RT.Seconds
            if(( RTMin = 30 or RTMin = 0) and RTSec = 0):
                RealTimeEvent.Signal(0.0)

    #### Update LTO ##########################################################################################
    UpdateLTOValue():int=
        var RTHour:int=0
        var RTMin:int=0
        var N:int=0
        if(TrueRealTimeProp:=RealTimeProp?):
            RT:=MakeCurrentTime(TrueRealTimeProp)
            set RTHour = RT.Hours
            set RTMin = RT.Minutes
        if:
            RTMin>=30
            TempN:int=Mod[RTHour*2+1,LTOArray.Length]
        then:
            set N = TempN
        else if:
            TempN:int=Mod[RTHour*2,LTOArray.Length]
        then:
            set N = TempN
        return N
    #Here we update everything
    RefreshLTO(StackBox:stack_box,CustomPlayer:custom_player,CurrentLTOItemIcon:texture_block,CurrentLTORarityIcon:texture_block,CurrentLTOItemName:text_block,CurrentLTOItemFullPrice:text_block,CurrentLTOItemDiscountPrice:text_block,CurrentButton:button_loud)<suspends>:void=
        RealTimeEvent.Await()
        StackBox.RemoveWidget(CurrentButton)
        CurrentLTOValue:=UpdateLTOValue()
        if(NewLTO:=LTOArray[CurrentLTOValue]):
            CurrentLTOItemIcon.SetImage(NewLTO.Icon)
            CurrentLTORarityIcon.SetImage(NewLTO.Rarity.BGIcon)
            CurrentLTOItemName.SetText(StringToMessage("{NewLTO.Name} V{NewLTO.Rarity.Order}"))
            CurrentLTOItemFullPrice.SetText(StringToMessage("FROM {NewLTO.Price} GOLD"))
            CurrentLTOItemDiscountPrice.SetText(StringToMessage("NOW ONLY {NewLTO.DiscountPrice()} GOLD"))
        StackBox.AddWidget(stack_box_slot{Widget:=GetLTOPurchaseButton(CustomPlayer)})
        spawn{RefreshLTO(StackBox,CustomPlayer,CurrentLTOItemIcon,CurrentLTORarityIcon,CurrentLTOItemName,CurrentLTOItemFullPrice,CurrentLTOItemDiscountPrice,CurrentButton)}

    GetLTOPurchaseButton(CustomPlayer:custom_player):button_loud=
        CurrentLTOValue:=UpdateLTOValue()
        var AlreadyOwned:logic=false
        if(NewLTO:=LTOArray[CurrentLTOValue]):
            for(UnlockedItem:CustomPlayer.UnlockedItems):
                if(UnlockedItem.Name=NewLTO.Name and UnlockedItem.Rarity.Order>=NewLTO.Rarity.Order):
                    set AlreadyOwned = true
        if(not AlreadyOwned?):
            return CustomPurchaseButton("Unlock", ExitCollection, false)
        else:
            return CustomPurchaseButton("Owned", ExitCollection, false)

    #### LTO StackBox ##########################################################################################
    CurrentLTOStackBox(CustomPlayer:custom_player):stack_box=
        CurrentLTOValue:=UpdateLTOValue()
        if(CurrentLTO:=LTOArray[CurrentLTOValue]):
            CurrentLTORarityIcon:=texture_block:
                DefaultImage:=GetIcon(CurrentLTO,"Rarity")
                DefaultDesiredSize := vector2{X := 250.0, Y := 250.0}
            CurrentLTOItemIcon:=texture_block:
                DefaultImage:=GetIcon(CurrentLTO,"ItemIcon")
                DefaultDesiredSize := vector2{X := 250.0, Y := 250.0}

            ItemPic:=canvas:
                Slots:=array:
                    canvas_slot:
                        Widget:=CurrentLTORarityIcon
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 0.5}
                            Maximum := vector2{X := 0.5, Y := 0.5}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := true     
                        ZOrder:=1
                    canvas_slot:
                        Widget:=CurrentLTOItemIcon
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 0.5}
                            Maximum := vector2{X := 0.5, Y := 0.5}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := true     
                        ZOrder:=2

            CurrentLTOItemName:=text_block:
                DefaultText:=StringToMessage("{CurrentLTO.Name} V{CurrentLTO.Rarity.Order}")
                DefaultTextColor:=White
            CurrentLTOItemFullPrice:=text_block:
                DefaultText:=StringToMessage("FROM {CurrentLTO.Price} GOLD")
                DefaultTextColor:=White
            CurrentLTOItemDiscountPrice:=text_block:
                DefaultText:=StringToMessage("NOW ONLY {CurrentLTO.DiscountPrice()} GOLD")
                DefaultTextColor:=Red

            ItemNameButton_StackBox:=stack_box:
                Orientation:=orientation.Vertical
                Slots:=array:
                    stack_box_slot:
                        Widget:=CurrentLTOItemName
                        HorizontalAlignment:=horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
                    stack_box_slot:
                        Widget:=CurrentLTOItemFullPrice
                        HorizontalAlignment:=horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
                    stack_box_slot:
                        Widget:=CurrentLTOItemDiscountPrice
                        HorizontalAlignment:=horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
            
            CurrentLTOPurchaseButton:=GetLTOPurchaseButton(CustomPlayer)
            ItemNameButton_StackBox.AddWidget(stack_box_slot{
                Widget:=CurrentLTOPurchaseButton
                HorizontalAlignment:=horizontal_alignment.Left
                VerticalAlignment:=vertical_alignment.Center})

            CurrentItem_StackBox:=stack_box:
                Orientation:=orientation.Horizontal
                Slots:=array:
                    stack_box_slot:
                        Widget := ItemPic
                        Padding := margin{Left := 50.0, Right := 50.0}
                    stack_box_slot:
                        Widget := ItemNameButton_StackBox 
            spawn{RefreshLTO(ItemNameButton_StackBox,CustomPlayer,CurrentLTOItemIcon,CurrentLTORarityIcon,CurrentLTOItemName,CurrentLTOItemFullPrice,CurrentLTOItemDiscountPrice,CurrentLTOPurchaseButton)}
            return CurrentItem_StackBox
        else: 
            return stack_box{Orientation:=orientation.Vertical}

    ### Permanent StackBox #####################################################################################
    PermanentItemsStackBox(CustomPlayer:custom_player):stack_box=
        PermItemStackBox:=stack_box{Orientation:=orientation.Horizontal}
        for(Item:AvailableItems):
            var CategoryFound:logic=false
            for(UnlockedItem:CustomPlayer.UnlockedItems):
                if(UnlockedItem.Name=Item.Name):
                    set CategoryFound=true
                    if(UnlockedItem.Rarity.Order + 1 = Item.Rarity.Order):
                        PermItemStackBox.AddWidget(ItemStackBoxSlot(option{UnlockedItem.Rarity.Order}, Item))
            if(not CategoryFound?, Item.Rarity.Order = 1): #That wouldn't work with high rarity weapons - we will need to adjust it
                PermItemStackBox.AddWidget(ItemStackBoxSlot(false, Item))
        return PermItemStackBox

    ItemStackBoxSlot(UnlockedItemOrder:?int, Item:item):stack_box_slot=
        var CurrentItemOrder:int=0
        var UpgradePriceString:string="V1: {Item.Price} GOLD"
        if(TrueUnlockedItemOrder:=UnlockedItemOrder?):
            set CurrentItemOrder = TrueUnlockedItemOrder
            set UpgradePriceString = "V{CurrentItemOrder} > V{Item.Rarity.Order}: {Item.Price}"
        ItemStackBox:=stack_box:
            Orientation:=orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=canvas:
                        Slots:=array:
                            canvas_slot:
                                Widget:=texture_block{
                                    DefaultImage:=Item.Rarity.BGIcon
                                    DefaultDesiredSize:=vector2{X := 150.0, Y := 150.0}}
                                Anchors := anchors:
                                    Minimum := vector2{X := 0.5, Y := 0.5}
                                    Maximum := vector2{X := 0.5, Y := 0.5}
                                Alignment := vector2{X := 0.5, Y := 0.5 }
                                SizeToContent := true     
                                ZOrder:=1
                            canvas_slot:
                                Widget:=texture_block{
                                    DefaultImage:=Item.Icon
                                    DefaultDesiredSize:=vector2{X := 150.0, Y := 150.0}}
                                Anchors := anchors:
                                    Minimum := vector2{X := 0.5, Y := 0.5}
                                    Maximum := vector2{X := 0.5, Y := 0.5}
                                Alignment := vector2{X := 0.5, Y := 0.5 }
                                SizeToContent := true     
                                ZOrder:=2
                stack_box_slot:
                    Widget:=text_block{
                        DefaultText:=StringToMessage("{Item.Name}")
                        DefaultTextColor:=White}
                stack_box_slot:
                    Widget:=text_block{
                        DefaultText:=StringToMessage(UpgradePriceString)
                        DefaultTextColor:=White}
                stack_box_slot:
                    Widget:=CustomPurchaseButton("Upgrade", ExitCollection, option{Item})
        return stack_box_slot{Widget:=ItemStackBox,Padding:=margin{Left:=15.0,Right:=15.0}}

    ### Get Currency ###########################################################################################
    GetCurrencyStackBox(CustomPlayer:custom_player):stack_box=
        CurrencyTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("{CurrencyText}{CustomPlayer.GetCurrency()}")
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=3.0,Y:=3.0}}
        CurrencyTextBlock.SetShadowOpacity(1.0)
        CurrencyTextureBlock := texture_block:
            DefaultImage:= Icons.IC_GoldCoin
            DefaultDesiredSize := vector2{X := 40.0, Y := 40.0}  
        CurrencyStackBox:stack_box=stack_box:
            Orientation := orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Widget:=CurrencyTextureBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                stack_box_slot:
                    Widget:=CurrencyTextBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
        return CurrencyStackBox
    
    ### General Functions ######################################################################################
    GetIcon(Item:item,IconType:string):texture=
        case(IconType):
            "Rarity"=>return Item.Rarity.BGIcon
            "ItemIcon"=>return Item.Icon
            _=> Icons.IC_Error
        return Icons.IC_Error

    CustomPurchaseButton(ButtonName:string, ButtonPressFunction(Wdata:widget_message):void, PermanentItem:?item):button_loud=
        CurrentLTOValue:=UpdateLTOValue()
        Button:=button_loud{}
        Button.SetText(StringToMessage(ButtonName))
        if(ButtonName="Owned"):
            return Button
        if(not PermanentItem?, CurrentLTO:=LTOArray[CurrentLTOValue]):
            Button.OnClick().SubscribePurchaseButton(Purchase,CurrentLTO,true)
        else if(TruePermItem:=PermanentItem?):
            Button.OnClick().SubscribePurchaseButton(Purchase,TruePermItem,false)
        return Button

    Purchase(Wdata:widget_message,ItemToPurchase:item,LTO:logic):void=
        var ItemPrice:int=ItemToPurchase.Price
        if(LTO?):
            set ItemPrice = ItemToPurchase.DiscountPrice()
        if(Player:=Wdata.Player,CustomPlayer:=PlayerToCustomPlayerMap[Player],Agent:=agent[Player]):
            PlayerCurrency:=CustomPlayer.GetCurrency()
            if(PlayerCurrency >= ItemPrice):
                for(Index->Item:CustomPlayer.UnlockedItems, Item.Name = ItemToPurchase.Name):
                    if(TempUnlockedItems:=CustomPlayer.UnlockedItems.RemoveElement[Index]):
                        set CustomPlayer.UnlockedItems = TempUnlockedItems
                set CustomPlayer.UnlockedItems += array{ItemToPurchase}
                for(n:=0..ItemPrice-1):
                    CustomPlayer.CurrencyRemover.Remove(Agent)
                ExitCollection(Wdata)
                ShowItemShopUI(true,4,option{Agent},AvailableItems)
            else:
                Print("Not enough funds") #Add that as a UI element later

    ExitCollection<private>(Wdata:widget_message):void=
        if(Player:=Wdata.Player,Agent:=agent[Player]):
            RemoveSomeHUDS(option{Agent},option{array{ItemShopOrder}})
#############################
### Item Shop UI End ###
#############################


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

    OrderFood(Interactable:logic,Order:int,Agent:?agent,PossibleItems:[]ingredient,SelectedTimeBetweenOrders:float,SelectedTimeToExpreOrder:float)<suspends>:void=
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
        Recipe:=recipe{MaxTime:=TimeToExpireOrder,RecipeUniqueID:=RecipeUniqueID}
        for(M:=0..2):
            if(set Recipe.Ingredients+=array{PossibleItems[GetRandomInt(0,2)]}){}    
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
        Print("Time's up")
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
var MaxPoints<private>:int=0

ShowClassSelectionUI(Interactable:logic,Order:int,Agent:?agent,SelectedMaxPoints:int):void=
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


##############################
### Progress Bar UI ##########
##############################
    var ProgressBarOrder<private>:int=0
    var TotalLevelsNumber:int=0
    var MaxPBPercentage:float=100.0
    var PBFrontColorBlock<private>: color_block = color_block{}
    var PBFrontColor<private>: color = Yellow
    var PBBackColorBlock<private>: color_block = color_block{}
    var PBBackColor<private>: color = DarkGray
    var PBSize<private>:vector2=vector2{X:=270.0,Y:=20.0}
    PBOrientation<private>:tuple(horizontal_alignment,vertical_alignment)=(horizontal_alignment.Left,vertical_alignment.Fill)

    ShowProgressBarUI(Interactable:logic,Order:int,Agent:?agent,TotalLevels:int):void=
        set ProgressBarOrder=Order
        set TotalLevelsNumber=TotalLevels 
        if(TrueAgent:=Agent?):
            if:
                Player:=player[TrueAgent]
                CustomPlayer:=PlayerToCustomPlayerMap[Player]
            then:
                AppearUI(Interactable,Order,Player,PBCanvasSlot(CustomPlayer))
        else:
            set ExistingUIs = ExistingUIs + array{ProgressBarOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,PBCanvasSlot(CustomPlayer))

    PBCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot=
        ProgressTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("Current Progress")
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=3.0,Y:=3.0}}
        ProgressTextBlock.SetShadowOpacity(1.0)
        set PBFrontColorBlock = color_block{DefaultColor:=PBFrontColor,DefaultDesiredSize:=vector2{X:=0.0,Y:=0.0}}
        set PBBackColorBlock = color_block{DefaultColor:=PBBackColor,DefaultDesiredSize:=PBSize}
        #PBSlider:slider_regular=slider_regular {DefaultValue:= 0.0, DefaultMinValue:= 0.0, DefaultMaxValue:= MaxPBSlider}
        PBOverlay:overlay:=overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=PBBackColorBlock
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                overlay_slot:
                    Widget:=PBFrontColorBlock
                    HorizontalAlignment:=PBOrientation(0)
                    VerticalAlignment:=PBOrientation(1)
        ProgressStackBox:stack_box=stack_box:
            Orientation := orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=PBOverlay
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                stack_box_slot:
                    Widget:=ProgressTextBlock
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
        PBSliderCanvasSlot:=canvas_slot:
                    Widget:=ProgressStackBox
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.75}
                        Maximum := vector2{X := 0.0, Y := 0.75}
                    Alignment := vector2{X := 0.0, Y := 0.5 }
                    Offsets := margin{Top := 0.0, Left := 20.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true     
                    ZOrder:=10
        spawn{RefreshProgressBar(<# PBSlider, #>CustomPlayer)}
        return PBSliderCanvasSlot
        
    RefreshProgressBar<private>(<# PBSlider:slider_regular, #>CustomPlayer:custom_player)<suspends> : void =
        RefreshUIsEvent.Await()
        LevelReached:=CustomPlayer.LevelReached
        StepSize:=MaxPBPercentage/(TotalLevelsNumber*1.0)
        #PBSlider.SetValue(StepSize*LevelReached)
        PBFrontColorBlock.SetDesiredSize(vector2{X:=PBSize.X*StepSize*LevelReached/100.0})
        spawn{RefreshProgressBar(<# PBSlider, #>CustomPlayer)}

##############################
### Progress Bar UI End ######
##############################
