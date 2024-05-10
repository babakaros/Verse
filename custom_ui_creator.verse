using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

## Player's UI ##
custom_ui_creator:=class():
    StringToMessage<localizes>(S:string):message="{S}"
    PlayerNameToMessage<localizes>(Agent:agent):message="{Agent}"
    ### Map pairing player with canvas ###
    var PlayerToCustomPlayerMap:[player]custom_player 
    var PlayerToCanvasMap:[player][int]?canvas=map{}
    var DefaultCanvas:canvas=canvas{}
    var MyCanvasSlot:canvas_slot=canvas_slot{Widget:=canvas{}}
    
    Assign():void=
        Print("Starting UI assignment.")
        var n : int = 1
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
            Print("Player {n} found")
            set n+=1
            Base(Player)

    AppearUI<private>(Interactable:logic,Order:int,Player:player,CanvasSlot:canvas_slot):void=
        if(CustomPlayer:=PlayerToCustomPlayerMap[Player]):
            set MyCanvasSlot=CanvasSlot
            case(Interactable):
                true=>
                    if(PlayerUI:=GetPlayerUI[Player]):
                        MyCanvas:=canvas{}
                        PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder:=0,InputMode:=ui_input_mode.All})
                        MyCanvas.AddWidget(MyCanvasSlot)
                        if(set PlayerToCanvasMap[Player][Order]=option{MyCanvas}):
                            Print("Done")
                _=>
                    if(PlayerUI:=GetPlayerUI[Player]):
                        MyCanvas:=canvas{}
                        PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder:=0,InputMode:=ui_input_mode.None})
                        MyCanvas.AddWidget(MyCanvasSlot)
                        if(set PlayerToCanvasMap[Player][Order]=option{MyCanvas}):
                            Print("Done")

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
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.99},Maximum:=vector2{X:=0.5,Y:=0.99}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=1.0}
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

    RemoveSomeHUDS(OrderArray:[]int):void=
        for(Player->CustomPlayer:PlayerToCanvasMap):
            if(PlayerUI:=GetPlayerUI[Player]):
                for(N:OrderArray,PlayerWidget:=PlayerToCanvasMap[Player][N]?):
                    PlayerUI.RemoveWidget(PlayerWidget)
                if(NewPTCM:=map{},set PlayerToCanvasMap[Player]=NewPTCM){}

    RemoveAllHUDS():void=
        for(Player->CustomPlayer:PlayerToCanvasMap):
            if(PlayerUI:=GetPlayerUI[Player]):
                for(N:=0..PlayerToCanvasMap[Player].Length-1,PlayerWidget:=PlayerToCanvasMap[Player][N]?):
                    PlayerUI.RemoveWidget(PlayerWidget)
                if(NewPTCM:=map{},set PlayerToCanvasMap[Player]=NewPTCM){}

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
    var TotalTimer:float=30.0
    var PreviewText:string=""
    CountdownEndedEvent<public> : event(float) = event(float){}
    var Time:float=10000.0

    ShowCustomTimerUI(Interactable:logic,Order:int,Agent:?agent):void=
        set CountdownTimerOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent]):
                AppearUI(Interactable,Order,Player,CTCanvasSlot())
        else:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,CTCanvasSlot())

    CTCanvasSlot<private>():canvas_slot=
        RemainingTimeTextBlock:text_block=text_block:
            DefaultText:=StringToMessage(PreviewText+"30")
            DefaultTextColor:=Chocolate
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
                Minimum := vector2{X := 0.5, Y := 0.8}
                Maximum := vector2{X := 0.5, Y := 0.8}
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
            if (TimeLeft <= 0.0):
                Print("Time ended!")
                CountdownEndedEvent.Signal(TotalTime)
                break

    UpdateUI<private>(TextBlock:text_block,TimeLeft:float) : void =
        if(IntTime := Int[TimeLeft]):
            TextBlock.SetText(StringToMessage(PreviewText+"{IntTime}"))
##############################
### Countdown Timer UI End ###
##############################