using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
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
### Currency Text UI ###
#########################
    var CurrencyTextOrder<private>:int=0
    var CurrencyText : string = "Gold: " 

    ShowCurrencyTextUI(Interactable:logic,Order:int,Agent:?agent):void=
        set CurrencyTextOrder=Order
        if(TrueAgent:=Agent?):
            if(Player:=player[TrueAgent],CustomPlayer:=PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,CuTeCanvasSlot(CustomPlayer))
        else:
            set ExistingUIs = ExistingUIs + array{CurrencyTextOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,CuTeCanvasSlot(CustomPlayer))

    CuTeCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot=
        CurrencyTextBlock:text_block=text_block:
            DefaultText:=StringToMessage("{CurrencyText}{CustomPlayer.Currency}")
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
        CurrencyCanvasSlot:=canvas_slot:
            Widget := CurrencyStackBox
            Anchors := anchors:
                Minimum := vector2{X := 0.0, Y := 0.25}
                Maximum := vector2{X := 0.0, Y := 0.25}
            Alignment := vector2{X := 0.0, Y := 0.5 }
            Offsets := margin{Top := 0.0, Left := 20.0, Bottom := 0.0, Right := 0.0}
            SizeToContent := true     
            ZOrder:=10
        spawn{RefreshCurrency(CurrencyTextBlock,CustomPlayer)}
        return CurrencyCanvasSlot   
        
    RefreshCurrency<private>(CurrencyTextBlock:text_block,CustomPlayer:custom_player)<suspends> : void =
        RefreshUIsEvent.Await()
        CustomPlayer.GetCurrency()
        CurrencyTextBlock.SetText(StringToMessage("{CurrencyText}{CustomPlayer.Currency}"))
        spawn{RefreshCurrency(CurrencyTextBlock,CustomPlayer)}
        
##############################
### Currency Text UI End ###
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
### Item Selection UI ###
##########################
    var ItemSelectionOrder<private>:int=0
    var SelectedItems:[]item=array{}
    var ChooseItemsEndedEvent:event()=event(){}
    var ItemsSelected:logic=false

    ShowItemSelectionUI(Interactable:logic,Order:int,Agent:?agent):void=
        set ItemSelectionOrder=Order
        if(TrueAgent:=Agent?):
            if:
                Player:=player[TrueAgent]
                CustomPlayer:=PlayerToCustomPlayerMap[Player]
            then:
                AppearUI(Interactable,Order,Player,WSCanvasSlot(CustomPlayer))
        else:
            set ExistingUIs = ExistingUIs + array{ItemSelectionOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,WSCanvasSlot(CustomPlayer))

    WSCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot=
        ChooseItems(CustomPlayer)
        loop:
            if(ItemsSelected?):
                break

        if(Player:=CustomPlayer.Player,Agent:=agent[Player]):
            ShowCustomTimerUI(false,3,option{Agent},20.0,"")

        VotingOptionsStack := stack_box{Orientation := orientation.Horizontal}
        for(Item:SelectedItems):
            ButtonClickedEvent: event(widget_message) = event(widget_message){}
            spawn:
                ItemButtonsAwait(Item,ButtonClickedEvent) 
            ItemSlot:=stack_box_slot:
                Widget := StackBoxCreator(Item,ButtonClickedEvent)
                HorizontalAlignment:=horizontal_alignment.Center
                VerticalAlignment:=vertical_alignment.Center
                Padding:=margin{Top:=0.0,Left:=25.0,Bottom:=0.0,Right:=25.0}
            VotingOptionsStack.AddWidget(ItemSlot)
            
        VotingUICanvas:canvas = canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=texture_block:
                        DefaultImage:=Icons.IC_ChooseItem
                        DefaultDesiredSize:=vector2{X:=500.0,Y:=230.0}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.02}
                        Maximum := vector2{X := 0.5, Y := 0.02}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    ZOrder:=3
                canvas_slot:
                    Widget:=VotingOptionsStack
                    Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets:=margin{Top:=0.0,Left:=0.0,Bottom:=0.0,Right:=0.0}
                    SizeToContent:=true
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    ZOrder:=1
                canvas_slot:
                    Widget:=texture_block:
                        DefaultImage:=Icons.IC_Plane
                        DefaultDesiredSize:=vector2{X:=1000.0,Y:=600.0}
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

    StackBoxCreator(Item:item,Event:event(widget_message)):stack_box=
        TrueLevelNameText := text_block:
            DefaultText:=StringToMessage(Item.Name+" V"+IntToString(Item.Rarity.Order)) 
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=2.0,Y:=2.0}}
        TrueLevelNameText.SetShadowOpacity(1.0)
        ItemTextureBlock := texture_block:
            DefaultImage:= Item.Icon
            DefaultDesiredSize := vector2{X := 250.0, Y := 250.0}
        RarityTextureBlock := texture_block:
            DefaultImage:= Item.Rarity.BGIcon
            DefaultDesiredSize := vector2{X := 250.0, Y := 250.0}
        ItemIconCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=RarityTextureBlock
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5 }
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true     
                    ZOrder:=1
                canvas_slot:
                    Widget:=ItemTextureBlock
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5 }
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true     
                    ZOrder:=2
    
        Button := button_loud:
            DefaultText:=StringToMessage("Equip")
        Button.OnClick().Subscribe(ItemSelectButton_Handler{Item:=Item,Event:=Event}.HandlerFunction)
        
        LevelStack := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Widget := ItemIconCanvas
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=0.0,Left:=0.0,Bottom:=5.0,Right:=0.0}
                stack_box_slot:
                    Widget := TrueLevelNameText
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=0.0,Left:=0.0,Bottom:=10.0,Right:=0.0}
                stack_box_slot:
                    Widget := Button
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
        return LevelStack

    ChooseItems(CustomPlayer:custom_player):void=
        var SelectedNumbers:[]int=array{}
        var ItemIndex:int=0
        var InIndex:logic=false
        var Iteration:int=1
        set SelectedItems = array{}
        loop:
            if(Iteration > 20) then break
            if(SelectedNumbers.Length=3):           
                break
            set Iteration=Iteration+1
            set ItemIndex=GetRandomInt(0,CustomPlayer.UnlockedItems.Length-1)
            if(SelectedNumbers.Length=0):
                set SelectedNumbers=SelectedNumbers+array{ItemIndex}
            else:
                for (Num := 0..SelectedNumbers.Length - 1,not InIndex?):
                    if(ItemIndex=SelectedNumbers[Num]):
                        set InIndex = true
                    if(ItemIndex<>SelectedNumbers[Num],Num=SelectedNumbers.Length-1):
                        set SelectedNumbers=SelectedNumbers+array{ItemIndex}
                set InIndex = false
        if:
            TempItem1:item=CustomPlayer.UnlockedItems[SelectedNumbers[0]]
            TempItem2:item=CustomPlayer.UnlockedItems[SelectedNumbers[1]]
            TempItem3:item=CustomPlayer.UnlockedItems[SelectedNumbers[2]]
        then:           
            set SelectedItems = array{TempItem1,TempItem2,TempItem3}
        set ItemsSelected=true

    ItemButtonsAwait<private>(Item:item,Event:event(widget_message))<suspends>:void=
        Wdata:=Event.Await()
        ExitWVote(Wdata)

    ExitWVote<private>(Wdata:widget_message):void=
        if(Player:=Wdata.Player,Agent:=agent[Player]):
            RemoveSomeHUDS(option{Agent},option{array{ItemSelectionOrder,3}})
            set TimerEnded = true
##############################
### Item Selection UI End ###
##############################


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