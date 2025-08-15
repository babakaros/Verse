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
using { Icons }

#########################################################################
########################### Player's UI Class ###########################
#########################################################################
custom_ui_creator :=  class():
    var PlayerToCustomPlayerMap:[player]custom_player 
    var PlayerToCanvasMap:[player][int]?canvas = map{}
    var CustomPlayerToUIElements : [custom_player]player_ui_elements = map{}
    var ExistingUIs:[]int = array{}
    var DefaultCanvas:canvas = canvas{}

    var RealTimeProp:?creative_prop
    var CurrencyManager:Currency_Manager

    RealTimeEvent : event(float) = event(float){}
    RefreshUIsEvent : event(float) = event(float){}

    <# var CloseUIInput : input_trigger_device = input_trigger_device{}
    var CloseUIHUD : hud_message_device = hud_message_device{} #>
    
    Assign():void = 
        var n : int = 1
        spawn{RefreshUIs()}
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
            set n += 1
            Base(Player)

    <# AddCloseUI(Agent : agent) : void = 
        CloseUIHUD.Show(Agent)
        CloseUIInput.Register(Agent)
        CloseUIInput.PressedEvent.Subscribe(RemoveAllHUDsAgent) #>

    AppearUI<private>(Interactable:logic,Order:int,Player:player,CanvasSlot:canvas_slot):void =
        var ZOrder:type {_X:int where 0 <= _X, _X <= 2147483647} = 0
        if(TempOrder :=  type {_X:int where 0 <= _X, _X <= 2147483647}[Order],set ZOrder = TempOrder){}
        if(CustomPlayer :=  PlayerToCustomPlayerMap[Player], Agent := agent[CustomPlayer.Player]):
            if(PlayerUI :=  GetPlayerUI[Player]):
                MyCanvas :=  canvas{}
                case(Interactable):
                    true =>
                            PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder :=  ZOrder,InputMode :=  ui_input_mode.All})
                    _ =>
                            PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder :=  ZOrder,InputMode :=  ui_input_mode.None})
                MyCanvas.AddWidget(CanvasSlot)
                if(set PlayerToCanvasMap[Player][Order] = option{MyCanvas}){}
            #AddCloseUI(Agent)

    Base<private>(Player:player):void = 
        if(PlayerUI :=  GetPlayerUI[Player]):
            MyCanvas :=  MakeDefaultCanvas()
            if(set PlayerToCanvasMap[Player] = map{0 =>option{MyCanvas}}):
                PlayerUI.AddWidget(MyCanvas,player_ui_slot{ZOrder :=  0,InputMode :=  ui_input_mode.None})

    MakeDefaultCanvas<private>():canvas = 
        set DefaultCanvas = canvas:
            Slots :=  array:
                <# canvas_slot:
                    Widget :=  texture_block:
                        DefaultImage :=  Icons.IC_MapCode
                        DefaultDesiredSize :=  vector2{X :=  660.0, Y :=  150.0}
                    Anchors :=  anchors{Minimum :=  vector2{X :=  0.5,Y :=  0.0},Maximum :=  vector2{X :=  0.5,Y :=  0.0}}
                    Offsets :=  margin{Top :=  10.0}
                    SizeToContent :=  true
                    Alignment :=  vector2{X :=  0.5,Y :=  0.0}
                    ZOrder :=  0   #>
        return DefaultCanvas

    MakeCustomCanvasSlot(CustomPlayer:custom_player):canvas_slot = 
        EmptyCanvasSlot :=  canvas_slot{Widget :=  canvas{}}
        return EmptyCanvasSlot

    CurrentWidget():canvas_slot = 
        EmptyCanvasSlot :=  canvas_slot{Widget :=  canvas{}}
        return EmptyCanvasSlot

    CustomButton(ButtonName:string, ButtonPressFunction(Wdata:widget_message):void):button_loud = 
        Button :=  button_loud{}
        Button.SetText(StringToMessage(ButtonName))
        Button.OnClick().SubscribeUIButton(ButtonPressFunction)
        return Button

    GetTime():string = 
        var RTMin:int = 0
        var RTSec:int = 0
        var Minutes:string = ("")
        var Seconds:string = ("")
        if(TrueRealTimeProp :=  RealTimeProp?):
            RT :=  MakeCurrentTime(TrueRealTimeProp)
            set RTMin = RT.Minutes
            set RTSec = RT.Seconds
        if(RTMin>30):
            set RTMin -= 30
        var MinLeft:int = 0
        var SecLeft:int = 60-RTSec
        if(SecLeft = 60):
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
        var RTMin:int = 0
        var RTSec:int = 0
        loop:
            Sleep(TimerTickPeriod)

            RefreshUIsEvent.Signal(TotalTime)

            if(TrueRealTimeProp :=  RealTimeProp?):
                RT :=  MakeCurrentTime(TrueRealTimeProp)
                set RTMin = RT.Minutes
                set RTSec = RT.Seconds
            if(( RTMin = 30 or RTMin = 0) and RTSec = 0) then RealTimeEvent.Signal(0.0)

            if (TotalTime <= 0.0) then break
        
    ApplyGlobalExistingUIs(Player:player):void = 
        Base(Player)
        if(Agent :=  agent[Player],CustomPlayer :=  PlayerToCustomPlayerMap[Player]):
            for(UIOrder:ExistingUIs):
                <# if(UIOrder = CurrencyTextOrder):
                    ShowCurrencyTextUI(false, UIOrder, option{Agent}) 
                else if(UIOrder = ProgressBarOrder):
                    ShowProgressBarUI(false, UIOrder, option{Agent}, TotalLevelsNumber) #>
    
    RemoveSomeHUDS(Agent:?agent, UIOrderArray:?[]int):void = 
        if:
            TrueUIOrderArray :=  UIOrderArray?
            TrueAgent :=  Agent?
            Player :=  player[TrueAgent]
            PlayerUI :=  GetPlayerUI[Player]
        then:
            for(N:TrueUIOrderArray,PlayerWidget :=  PlayerToCanvasMap[Player][N]?):
                Print("Removing widget {N}")
                PlayerUI.RemoveWidget(PlayerWidget)
                var NewMap:[int]?canvas = map{}
                for(M->L:PlayerToCanvasMap[Player],M<>N):
                    set NewMap = ConcatenateMaps(NewMap,map{M =>L})
                if(set PlayerToCanvasMap[Player] = NewMap){}
                #RemoveCloseUI(TrueAgent)
        else if:
            TrueUIOrderArray :=  UIOrderArray?
        then:
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                if(PlayerUI :=  GetPlayerUI[Player], TrueAgent := agent[Player]):
                    for(N:TrueUIOrderArray,PlayerWidget :=  PlayerToCanvasMap[Player][N]?):
                        Print("Removing widget {N}")
                        PlayerUI.RemoveWidget(PlayerWidget)
                        var NewMap:[int]?canvas = map{}
                        for(M->L:PlayerToCanvasMap[Player],M<>N):
                            set NewMap = ConcatenateMaps(NewMap,map{M =>L})
                        if(set PlayerToCanvasMap[Player] = NewMap){}
                        #RemoveCloseUI(TrueAgent)
            for(M:TrueUIOrderArray):
                var NewTempExistingUIs:[]int = array{}
                for(N:ExistingUIs,N<>M):
                    set NewTempExistingUIs+= array{N}
                set ExistingUIs = NewTempExistingUIs
        else if:
            TrueAgent :=  Agent?
            Player :=  player[TrueAgent]
            PlayerUI :=  GetPlayerUI[Player]
        then:
            for(Widget:PlayerToCanvasMap[Player],TrueWidget :=  Widget?):
                PlayerUI.RemoveWidget(TrueWidget)
            if(set PlayerToCanvasMap[Player] = map{}){}
            #RemoveCloseUI(TrueAgent)
                
    RemoveAllHUDS():void = 
        for(Player->CustomPlayer:PlayerToCustomPlayerMap):
            if(PlayerUI :=  GetPlayerUI[Player], Agent := agent[Player]):
                for(N :=  0..PlayerToCanvasMap[Player].Length-1,PlayerWidget :=  PlayerToCanvasMap[Player][N]?):
                    PlayerUI.RemoveWidget(PlayerWidget)
                if(NewPTCM :=  map{},set PlayerToCanvasMap[Player] = NewPTCM){}
                #RemoveCloseUI(Agent)
        set ExistingUIs = array{}

    <# RemoveAllHUDsAgent<private>(Agent : agent):void=
        if(Player := player[Agent], PlayerUI :=  GetPlayerUI[Player]):
            for(Widget:PlayerToCanvasMap[Player],TrueWidget :=  Widget?):
                PlayerUI.RemoveWidget(TrueWidget)
            if(set PlayerToCanvasMap[Player] = map{}){}
            RemoveCloseUI(Agent)

    RemoveCloseUI(Agent : agent) : void=
        CloseUIHUD.Hide(Agent)
        CloseUIInput.Unregister(Agent) #>
###################################################################################################################################################################################################


##############################
### Best Time UI #############
##############################
    var BestTimeOrder<private>:int = 0

    ShowBestTimeUI(Interactable:logic,Order:int,Agent:?agent):void = 
        set BestTimeOrder = Order
        if(TrueAgent :=  Agent?):
            if(Player :=  player[TrueAgent],CustomPlayer := PlayerToCustomPlayerMap[Player]):
                TimeText := FloatToTime(3600.00 - CustomPlayer.PlayerStats.BestRunTime)
                AppearUI(Interactable,Order,Player,BTCanvasSlot(Player, TimeText))
        else:
            set ExistingUIs = ExistingUIs + array{BestTimeOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                TimeText := FloatToTime(3600.00 - CustomPlayer.PlayerStats.BestRunTime)
                AppearUI(Interactable,Order,Player,BTCanvasSlot(Player, TimeText))

    BTCanvasSlot<private>(Player:player, TimeText : string):canvas_slot = 
        BestTimeStackBox := stack_box :
            Orientation := orientation.Horizontal
            Slots := array :
                stack_box_slot :
                    Widget := text_block:
                        DefaultText := StringToMessage("Best Run Time: ")
                        DefaultTextColor := White
                        DefaultShadowColor := Black
                        DefaultShadowOpacity := 1.0
                        DefaultShadowOffset := option{vector2{ X := 3.0, Y := 3.0}}
                stack_box_slot :
                    Widget := text_block:
                        DefaultText := StringToMessage(TimeText)
                        DefaultTextColor := White
                        DefaultShadowColor := Black
                        DefaultShadowOpacity := 1.0
                        DefaultShadowOffset := option{vector2{ X := 3.0, Y := 3.0}}

        BestTimeOverlay := overlay :
            Slots := array :
                overlay_slot : 
                    Widget := texture_block{DefaultImage := Icons.IC_BestTime, DefaultDesiredSize := vector2{ X := 380.0, Y := 41.0}}
                overlay_slot : 
                    Widget := BestTimeStackBox

        BestTimeCanvasSlot :=  canvas_slot:
            Widget :=  BestTimeOverlay
            Anchors :=  anchors:
                Minimum :=  vector2{X :=  0.0, Y :=  1.0}
                Maximum :=  vector2{X :=  0.0, Y :=  1.0}
            Alignment :=  vector2{X :=  0.0, Y :=  4.0 }
            Offsets := margin{Left :=  280.0}
            SizeToContent :=  true     
            ZOrder :=  2
        return BestTimeCanvasSlot

##############################
### Best Time UI End #########
##############################


##############################
### Item Selection UI ########
##############################
    var ItemSelectionOrder<private>:int = 0
    var SelectedItems:[]item = array{}
    var ChooseItemsEndedEvent:event() = event(){}
    var ItemsSelected:logic = false
    var NumberOfOptions : int = 3

    ShowItemSelectionUI(Interactable : logic, Order : int, Agent : ?agent, CurrentLevelIndex : int):void = 
        set ItemSelectionOrder = Order
        if(TrueAgent :=  Agent?):
            if:
                Player :=  player[TrueAgent]
                CustomPlayer :=  PlayerToCustomPlayerMap[Player]
            then:
                AppearUI(Interactable,Order,Player,ISCanvasSlot(CustomPlayer,CurrentLevelIndex))
        else:
            set ExistingUIs = ExistingUIs + array{ItemSelectionOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,ISCanvasSlot(CustomPlayer,CurrentLevelIndex))

    ISCanvasSlot<private>(CustomPlayer:custom_player,CurrentLevelIndex:int) : canvas_slot = 
        ChooseItemsForIS(CustomPlayer,CurrentLevelIndex)
        loop:
            if(ItemsSelected?):
                break

        ItemsStackBox : stack_box = stack_box{Orientation :=  orientation.Horizontal}
        
        for(Item:SelectedItems):
            ButtonClickedEvent: event(widget_message) = event(widget_message){}
            spawn:
                ItemButtonsAwait(Item,ButtonClickedEvent) 
            ItemSlot :=  stack_box_slot:
                Widget :=  ItemOverlayCreator(Item, ButtonClickedEvent)
                HorizontalAlignment :=  horizontal_alignment.Center
                VerticalAlignment :=  vertical_alignment.Center
                Padding :=  margin{Left :=  15.0,Right :=  15.0}
           ItemsStackBox.AddWidget(ItemSlot)

        ISStackBox : stack_box = stack_box:
            Orientation :=  orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Widget :=  texture_block:
                        DefaultImage :=  Icons.IC_ChooseItem
                        DefaultDesiredSize :=  vector2{X :=  500.0,Y :=  230.0}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                stack_box_slot:
                    Widget := ItemsStackBox

        ISOverlay : overlay = overlay:
            Slots := array:
                overlay_slot:
                    Widget := color_block{
                        DefaultColor := Black
                        DefaultOpacity := 0.7
                        DefaultDesiredSize := vector2{X :=  1920.0, Y :=  1080.0}}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                overlay_slot:
                    Widget :=  ISStackBox
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center

        VotingUICanvasSlot :=  canvas_slot:
            Widget := ISOverlay
            Anchors :=  anchors:
                Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                Maximum :=  vector2{X :=  0.5, Y :=  0.5}
            Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
            SizeToContent :=  true
            ZOrder :=  1
        return VotingUICanvasSlot

    ItemOverlayCreator(Item : item, Event : event(widget_message)) : overlay = 
        BGSizeX := 350.0
        BGSizeY := 650.0
        ItemBG := overlay :
            Slots := array :
                overlay_slot:
                    Widget := color_block{
                        DefaultColor := White
                        DefaultDesiredSize := vector2{X :=  BGSizeX, Y :=  BGSizeY}}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                overlay_slot:
                    Widget := color_block{
                        DefaultColor := Black
                        DefaultDesiredSize := vector2{X :=  BGSizeX - 10.0, Y :=  BGSizeY - 10.0}}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                overlay_slot:
                    Widget := texture_block{
                        DefaultImage := IC_ItemBG
                        DefaultDesiredSize := vector2{X :=  BGSizeX - 15.0, Y :=  BGSizeY - 15.0}}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center

        RarityTextureBlock :=  texture_block:
            DefaultImage :=  Item.Rarity.BGIcon
            DefaultDesiredSize :=  vector2{X :=  250.0, Y :=  250.0}

        ItemTextureBlock :=  texture_block:
            DefaultImage :=  Item.Icon
            DefaultDesiredSize :=  vector2{X :=  250.0, Y :=  250.0}

        ItemIconCanvas :=  overlay :
            Slots :=  array:
                overlay_slot:
                    Widget :=  RarityTextureBlock
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                overlay_slot:
                    Widget :=  ItemTextureBlock
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center

        TrueNameText :=  text_block:
            DefaultText :=  StringToMessage(ClipString(Item.Name,15)) 
            DefaultTextColor :=  White
            DefaultShadowColor :=  Black
            DefaultShadowOffset :=  option{vector2{X :=  2.0,Y :=  2.0}}
        TrueNameText.SetShadowOpacity(1.0)

        TrueLevelText :=  text_block:
            DefaultText :=  StringToMessage("V"+IntToString(Item.Rarity.Order)) 
            DefaultTextColor :=  White
            DefaultTextOpacity := 0.6
            DefaultShadowColor :=  Black
            DefaultShadowOffset :=  option{vector2{X :=  2.0,Y :=  2.0}}

        Button :=  button_loud:
            DefaultText :=  StringToMessage("Equip")
        Button.OnClick().Subscribe(ItemSelectButton_Handler{Item :=  Item,Event :=  Event, PlayerToCustomPlayerMap := PlayerToCustomPlayerMap}.HandlerFunction)
        
        ItemStack :=  stack_box:
            Orientation :=  orientation.Vertical
            Slots :=  array:
                stack_box_slot:
                    Widget :=  ItemIconCanvas
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                    Padding :=  margin{Bottom :=  30.0}
                stack_box_slot:
                    Widget :=  TrueNameText
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                stack_box_slot:
                    Widget :=  TrueLevelText
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                    Padding :=  margin{Bottom :=  15.0}
                stack_box_slot:
                    Widget :=  Button
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
        return overlay{Slots := array{overlay_slot{Widget := ItemBG}, overlay_slot{Widget := ItemStack}}}

    ChooseItemsForIS(CustomPlayer:custom_player,CurrentLevelIndex:int):void = 
        set SelectedItems = array{}

        WeaponsArray:=GetValidItems(CustomPlayer.UnlockedWeaponArray + CustomPlayer.UnlockedSpecialArray)
        UtilityArray:=GetValidItems(CustomPlayer.UnlockedHealArray + CustomPlayer.UnlockedThrowableArray + CustomPlayer.UnlockedAbilityArray)

        if(CurrentLevelIndex = 1) :
            set SelectedItems = SelectRandomFromArray(WeaponsArray, NumberOfOptions)
        else:
            set SelectedItems = SelectRandomFromArray(WeaponsArray, NumberOfOptions-1)
            set SelectedItems += SelectRandomFromArray(UtilityArray,1)
        set ItemsSelected = true

    GetValidItems(WeaponsArray : []item) :[]item = 
        var ValidItemArray : []item = array{}
        for(Item : WeaponsArray, Item.Rarity.Order > 0):
            set ValidItemArray += array{Item}
        return ValidItemArray

    SelectRandomFromArray(ArrayToChooseFrom : []item, NumberOfElementsToChoose : int) : []item = 
        var Iteration:int = 1
        var SelectedNumbers:[]int = array{}
        var ItemIndex:int = 0
        var InIndex:logic = false
        var SelectedRandomItems : []item = array{}
        loop:
            if(Iteration > 50) then break
            if(SelectedNumbers.Length = NumberOfElementsToChoose):           
                break
            set ItemIndex = GetRandomInt(0,ArrayToChooseFrom.Length-1)
            if(SelectedNumbers.Length = 0):
                set SelectedNumbers = SelectedNumbers+array{ItemIndex}
            else:
                for (Num :=  0..SelectedNumbers.Length - 1,not InIndex?):
                    if(ItemIndex = SelectedNumbers[Num]):
                        set InIndex = true
                    if(ItemIndex<>SelectedNumbers[Num],Num = SelectedNumbers.Length-1):
                        set SelectedNumbers = SelectedNumbers+array{ItemIndex}
                set InIndex = false
            set Iteration = Iteration+1
        for(N:=0..NumberOfOptions-1, TempItem := ArrayToChooseFrom[SelectedNumbers[N]]):
            set SelectedRandomItems += array{TempItem}
        return SelectedRandomItems

    ItemButtonsAwait<private>(Item:item, Event:event(widget_message))<suspends>:void = 
        Wdata :=  Event.Await()
        ExitWVote(Wdata)

    ExitWVote<private>(Wdata:widget_message):void = 
        if(Player :=  Wdata.Player,Agent :=  agent[Player]):
            RemoveSomeHUDS(option{Agent},option{array{ItemSelectionOrder,3}})
            <# set TimerEnded = true #>
##############################
### Item Selection UI End ####
##############################


#######################################################
#######################################################
### Shop Related Modules ##############################
#######################################################
#######################################################


##############################
### Utility Shop UI ##########
##############################
    var UtilityShopOrder<private>:int = 0
    var ArrayOfUtilityArrays : [][]item = array{}
        
    ShowUtilityShopUI(Interactable:logic,Order:int,Agent:?agent):void = 
        set UtilityShopOrder = Order

        if(TrueAgent :=  Agent?):
            if(Player :=  player[TrueAgent],CustomPlayer :=  PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,HSCanvasSlot(CustomPlayer))
        else:
            set ExistingUIs = ExistingUIs + array{UtilityShopOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,HSCanvasSlot(CustomPlayer))

    HSCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot = 
        var CurrentTabArray:[]item = array{}
        if(TrueArray := ArrayOfUtilityArrays[0],set CurrentTabArray = TrueArray){}

        CurTab : item_type = item_type.Heal
        CurPage : int = 0
        CurShopLayoutStackBox : stack_box = ShopLayoutStackBox(CustomPlayer, CurTab,CurPage)

        Shop_StackBox :=  stack_box:
            Orientation :=  orientation.Vertical
            Slots :=  array:
                TabSelection(0)    
                stack_box_slot:
                    Widget :=  CurShopLayoutStackBox
                    HorizontalAlignment :=  horizontal_alignment.Center

        if(ExistingElements := CustomPlayerToUIElements[CustomPlayer]):
            set ExistingElements.ShopLayout = option{NewShopLayout : shop_layout = shop_layout{
                    CurShopLayout := CurShopLayoutStackBox
                    CurTab := CurTab
                    CurPage := CurPage
                    CurParentWidget := Shop_StackBox
                }}
        else:
            if(set CustomPlayerToUIElements[CustomPlayer] = NewUIElements : player_ui_elements = player_ui_elements{ShopLayout := option{NewShopLayout : shop_layout = shop_layout{
                CurShopLayout := CurShopLayoutStackBox
                CurTab := CurTab
                CurPage := CurPage
                CurParentWidget := Shop_StackBox
            }}}){}

        UtilityShop_Canvas :=  canvas:
            Slots :=  array:
                canvas_slot:
                    Widget :=  color_block:
                        DefaultColor :=  Black
                        DefaultOpacity :=  0.9
                        DefaultDesiredSize :=  vector2{X :=  3840.0, Y :=  2560.0}
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  0.0, Y :=  0.0}
                    Alignment :=  vector2{X :=  0.0, Y :=  0.0}
                    SizeToContent :=  true
                    ZOrder :=  21
                canvas_slot:
                    Widget :=  Shop_StackBox
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  1.0, Y :=  1.0}
                    Alignment :=  vector2{X :=  0.5, Y :=  0.5}
                    SizeToContent :=  true
                    ZOrder :=  22
                canvas_slot:
                    Widget :=  GetCurrencyStackBox(CustomPlayer)
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  1.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  1.0, Y :=  0.0}
                    Alignment :=  vector2{X :=  1.5, Y :=  -2.5}
                    SizeToContent :=  true
                    ZOrder :=  23

        UtilityShop_CanvasSlot :=  canvas_slot:
            Widget :=  UtilityShop_Canvas
            Anchors :=  anchors:
                Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                Maximum :=  vector2{X :=  1.0, Y :=  1.0}
            Alignment :=  vector2{X :=  0.5, Y :=  0.5}
            SizeToContent :=  false
            ZOrder :=  20
        return UtilityShop_CanvasSlot
##############################
### Utility Shop UI End ######
##############################


##############################
### Tab Selection UI #########
##############################
    var TabColorBlockArray <private> : []color_block = array{}

    TabSelection(CurrentTab : int) : stack_box_slot = 
        
        FirstTab := color_block:
            DefaultColor :=  Yellow 
            DefaultOpacity :=  1.0
            DefaultDesiredSize :=  vector2{X :=  500.0, Y :=  250.0}
        SecondTab := color_block:
            DefaultColor :=  Yellow 
            DefaultOpacity :=  0.75
            DefaultDesiredSize :=  vector2{X :=  500.0, Y :=  250.0}
        ThirdTab := color_block:
            DefaultColor :=  Yellow 
            DefaultOpacity :=  0.75
            DefaultDesiredSize :=  vector2{X :=  500.0, Y :=  250.0}
        set TabColorBlockArray += array{FirstTab, SecondTab, ThirdTab}

        TabSelection_StackBox :=  stack_box:
            Orientation :=  orientation.Horizontal
            Slots :=  array:
                stack_box_slot :
                    Widget :=  overlay :
                        Slots :=  array :
                            overlay_slot {Widget :=  FirstTab}
                            overlay_slot :
                                Widget :=  ChangeShopLayoutButton("HEALS", item_type.Heal, 0)
                                HorizontalAlignment :=  horizontal_alignment.Center
                                VerticalAlignment :=  vertical_alignment.Center
                stack_box_slot :
                    Widget :=  overlay :
                        Slots :=  array :
                            overlay_slot {Widget := SecondTab}
                            overlay_slot :
                                Widget :=  ChangeShopLayoutButton("THROWABLES", item_type.Throwable, 0)
                                HorizontalAlignment :=  horizontal_alignment.Center
                                VerticalAlignment :=  vertical_alignment.Center
                stack_box_slot :
                    Widget :=  overlay :
                        Slots :=  array :
                            overlay_slot {Widget := ThirdTab}
                            overlay_slot :
                                Widget :=  ChangeShopLayoutButton("ABILITIES", item_type.Ability, 0)
                                HorizontalAlignment :=  horizontal_alignment.Center
                                VerticalAlignment :=  vertical_alignment.Center
                stack_box_slot :
                    Widget :=  color_block:
                        DefaultColor :=  Yellow 
                        DefaultOpacity :=  0.5
                        DefaultDesiredSize :=  vector2{X :=  500.0, Y :=  250.0}
                        
        return stack_box_slot{
            Widget := TabSelection_StackBox
            Padding :=  margin{Bottom :=  15.0}
            HorizontalAlignment :=  horizontal_alignment.Left
            VerticalAlignment :=  vertical_alignment.Top}
##############################
### Tab Selection End ########
##############################


##############################
### Weapon Shop UI ###########
##############################
    var WeaponShopOrder<private>:int = 0
    var LTOArray:[]item = array{}
        
    ShowWeaponShopUI(Interactable:logic,Order:int,Agent:?agent):void = 
        set WeaponShopOrder = Order
        if(TrueAgent :=  Agent?):
            if(Player :=  player[TrueAgent],CustomPlayer :=  PlayerToCustomPlayerMap[Player]):
                AppearUI(Interactable,Order,Player,WSCanvasSlot(CustomPlayer))
        else:
            set ExistingUIs = ExistingUIs + array{WeaponShopOrder}
            for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                AppearUI(Interactable,Order,Player,WSCanvasSlot(CustomPlayer))

    WSCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot = 
        CountdownClock :=  text_block:
            DefaultText :=  StringToMessage(GetTime())
            DefaultTextColor :=  Red
            DefaultShadowColor :=  Black
            DefaultShadowOffset :=  option{vector2{X :=  0.8,Y :=  0.8}}
            DefaultShadowOpacity :=  1.0

        Timer_Canvas :=  canvas:
            Slots :=  array:
                canvas_slot:
                    Widget :=  text_block:
                        DefaultText :=  StringToMessage("LIMITED TIME OFFER")
                        DefaultTextColor :=  White
                        DefaultShadowColor :=  Black
                        DefaultShadowOffset :=  option{vector2{X :=  2.0, Y :=  2.0}}
                        DefaultShadowOpacity :=  1.0
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                        Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                    Alignment :=  vector2{X :=  0.7, Y :=  1.0}
                    ZOrder :=  10
                canvas_slot:
                    Widget :=  CountdownClock
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                        Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                    Alignment :=  vector2{X :=  0.7, Y :=  0.0}
                    ZOrder :=  10
                canvas_slot:
                    Widget :=  color_block:
                        DefaultColor :=  Yellow 
                        DefaultOpacity :=  1.0
                        DefaultDesiredSize :=  vector2{X :=  500.0, Y :=  250.0}
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                        Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                    Alignment :=  vector2{X :=  0.5, Y :=  0.5}
                    ZOrder :=  9

        LTO_StackBox :=  stack_box:
            Orientation :=  orientation.Horizontal
            Slots :=  array:
                stack_box_slot:
                    Widget :=  Timer_Canvas
                    VerticalAlignment :=  vertical_alignment.Top
                stack_box_slot:
                    Widget :=  CurrentLTOStackBox(CustomPlayer)
                    VerticalAlignment :=  vertical_alignment.Top

        LTO_Canvas :=  canvas:
            Slots :=  array:
                canvas_slot:
                    Widget :=  color_block :
                        DefaultColor :=  Yellow 
                        DefaultOpacity :=  0.5
                        DefaultDesiredSize :=  vector2{X :=  1920.0, Y :=  250.0}
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  0.0, Y :=  0.0}
                    Alignment :=  vector2{X :=  0.0, Y :=  0.0}
                    ZOrder :=  10
                canvas_slot:
                    Widget :=  LTO_StackBox
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  0.0, Y :=  0.0}
                    Alignment :=  vector2{X :=  0.0, Y :=  0.0}
                    ZOrder :=  11       

        CurTab : item_type = item_type.Weapon
        CurPage : int = 0
        CurShopLayoutStackBox : stack_box = ShopLayoutStackBox(CustomPlayer, CurTab,CurPage)

        Shop_StackBox :=  stack_box:
            Orientation :=  orientation.Vertical
            Slots :=  array:
                stack_box_slot:
                    Widget :=  LTO_Canvas
                    Padding :=  margin{Bottom :=  15.0}
                    HorizontalAlignment :=  horizontal_alignment.Left
                    VerticalAlignment :=  vertical_alignment.Top
                stack_box_slot:
                    Widget :=  CurShopLayoutStackBox
                    HorizontalAlignment :=  horizontal_alignment.Center  

        if(ExistingElements := CustomPlayerToUIElements[CustomPlayer]):
            set ExistingElements.ShopLayout = option{NewShopLayout : shop_layout = shop_layout{
                    CurShopLayout := CurShopLayoutStackBox
                    CurTab := CurTab
                    CurPage := CurPage
                    CurParentWidget := Shop_StackBox
                }}
        else:
            if(set CustomPlayerToUIElements[CustomPlayer] = NewUIElements : player_ui_elements = player_ui_elements{ShopLayout := option{shop_layout{
                CurShopLayout := CurShopLayoutStackBox
                CurTab := CurTab
                CurPage := CurPage
                CurParentWidget := Shop_StackBox
            }}}){}

        WeaponShop_Canvas :=  canvas:
            Slots :=  array:
                canvas_slot:
                    Widget :=  color_block:
                        DefaultColor :=  Black
                        DefaultOpacity :=  0.9
                        DefaultDesiredSize :=  vector2{X :=  3840.0, Y :=  2560.0}
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  0.0, Y :=  0.0}
                    Alignment :=  vector2{X :=  0.0, Y :=  0.0}
                    SizeToContent :=  true
                    ZOrder :=  21
                canvas_slot:
                    Widget :=  Shop_StackBox
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  1.0, Y :=  1.0}
                    Alignment :=  vector2{X :=  0.5, Y :=  0.5}
                    SizeToContent :=  true
                    ZOrder :=  22
                canvas_slot:
                    Widget :=  GetCurrencyStackBox(CustomPlayer)
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  1.0, Y :=  0.0}
                        Maximum :=  vector2{X :=  1.0, Y :=  0.0}
                    Alignment :=  vector2{X :=  1.5, Y :=  -2.5}
                    SizeToContent :=  true
                    ZOrder :=  23

        WeaponShop_CanvasSlot :=  canvas_slot:
            Widget :=  WeaponShop_Canvas
            Anchors :=  anchors:
                Minimum :=  vector2{X :=  0.0, Y :=  0.0}
                Maximum :=  vector2{X :=  1.0, Y :=  1.0}
            Alignment :=  vector2{X :=  0.5, Y :=  0.5}
            SizeToContent :=  false
            ZOrder :=  20

        spawn{RefreshLTOClock(CountdownClock)}
        return WeaponShop_CanvasSlot   
##############################
### Weapon Shop UI End #######
##############################


##############################
### Limited Time Offer UI ####
##############################
    CurrentLTOStackBox<private>(CustomPlayer:custom_player):stack_box = 
        CurrentLTOIndex :=  GetLTOIndex()
        if(CurrentLTO :=  LTOArray[CurrentLTOIndex]):
            CurrentLTORarityIcon :=  texture_block:
                DefaultImage :=  GetRarityIcon(CurrentLTO.MaxRarity)
                DefaultDesiredSize :=  vector2{X :=  250.0, Y :=  250.0}
            CurrentLTOItemIcon :=  texture_block:
                DefaultImage :=  GetItemIcon(CurrentLTO)
                DefaultDesiredSize :=  vector2{X :=  250.0, Y :=  250.0}

            ItemPic :=  canvas:
                Slots :=  array:
                    canvas_slot:
                        Widget :=  CurrentLTORarityIcon
                        Anchors :=  anchors:
                            Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                            Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                        Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                        SizeToContent :=  true     
                        ZOrder :=  1
                    canvas_slot:
                        Widget :=  CurrentLTOItemIcon
                        Anchors :=  anchors:
                            Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                            Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                        Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                        SizeToContent :=  true     
                        ZOrder :=  2

            CurrentLTOItemName :=  text_block:
                DefaultText :=  StringToMessage("{CurrentLTO.Name} V{CurrentLTO.Rarity.Order}")
                DefaultTextColor :=  White
            CurrentLTOItemFullPrice :=  text_block:
                DefaultText :=  StringToMessage("FROM {CurrentLTO.PriceCalculator(false)} GOLD")
                DefaultTextColor :=  White
            CurrentLTOItemDiscountPrice :=  text_block:
                DefaultText :=  StringToMessage("NOW ONLY {CurrentLTO.PriceCalculator(true)} GOLD")
                DefaultTextColor :=  Red

            ItemNameButton_StackBox :=  stack_box:
                Orientation :=  orientation.Vertical
                Slots :=  array:
                    stack_box_slot:
                        Widget :=  CurrentLTOItemName
                        HorizontalAlignment :=  horizontal_alignment.Left
                        VerticalAlignment :=  vertical_alignment.Center
                    stack_box_slot:
                        Widget :=  CurrentLTOItemFullPrice
                        HorizontalAlignment :=  horizontal_alignment.Left
                        VerticalAlignment :=  vertical_alignment.Center
                    stack_box_slot:
                        Widget :=  CurrentLTOItemDiscountPrice
                        HorizontalAlignment :=  horizontal_alignment.Left
                        VerticalAlignment :=  vertical_alignment.Center
            
            CurrentLTOPurchaseButton :=  GetLTOPurchaseButton(CustomPlayer)
            ItemNameButton_StackBox.AddWidget(stack_box_slot{
                Widget :=  CurrentLTOPurchaseButton
                HorizontalAlignment :=  horizontal_alignment.Left
                VerticalAlignment :=  vertical_alignment.Center})

            CurrentItem_StackBox :=  stack_box:
                Orientation :=  orientation.Horizontal
                Slots :=  array:
                    stack_box_slot:
                        Widget :=  ItemPic
                        Padding :=  margin{Left :=  50.0, Right :=  50.0}
                    stack_box_slot:
                        Widget :=  ItemNameButton_StackBox 
            spawn{RefreshLTO(ItemNameButton_StackBox,CustomPlayer,CurrentLTOItemIcon,CurrentLTORarityIcon,CurrentLTOItemName,CurrentLTOItemFullPrice,CurrentLTOItemDiscountPrice,CurrentLTOPurchaseButton)}
            return CurrentItem_StackBox
        else: 
            return stack_box{Orientation :=  orientation.Vertical}

    RefreshLTOClock<private>(TextBlock:text_block)<suspends> : void = 
        RefreshUIsEvent.Await()
        TextBlock.SetText(StringToMessage(GetTime()))
        spawn{RefreshLTOClock(TextBlock)}

    GetLTOIndex<private>():int = 
        var RTHour:int = 0
        var RTMin:int = 0
        var N:int = 0
        if(TrueRealTimeProp :=  RealTimeProp?):
            RT :=  MakeCurrentTime(TrueRealTimeProp)
            set RTHour = RT.Hours
            set RTMin = RT.Minutes
        if:
            RTMin  >= 30
            TempN:int = Mod[RTHour*2+1,LTOArray.Length]
        then:
            set N = TempN
        else if:
            TempN:int = Mod[RTHour*2,LTOArray.Length]
        then:
            set N = TempN
        return N

    RefreshLTO<private>(StackBox:stack_box,CustomPlayer:custom_player,CurrentLTOItemIcon:texture_block,CurrentLTORarityIcon:texture_block,CurrentLTOItemName:text_block,CurrentLTOItemFullPrice:text_block,CurrentLTOItemDiscountPrice:text_block,CurrentButton:button_loud)<suspends>:void = 
        RealTimeEvent.Await()
        StackBox.RemoveWidget(CurrentButton)
        CurrentLTOIndex :=  GetLTOIndex()
        if:
            NewLTO :=  LTOArray[CurrentLTOIndex]
        then:
            CurrentLTOItemIcon.SetImage(NewLTO.Icon)
            CurrentLTORarityIcon.SetImage(NewLTO.Rarity.BGIcon)
            CurrentLTOItemName.SetText(StringToMessage("{NewLTO.Name} V{NewLTO.Rarity.Order}"))
            CurrentLTOItemFullPrice.SetText(StringToMessage("FROM {NewLTO.PriceCalculator(false)} GOLD"))
            CurrentLTOItemDiscountPrice.SetText(StringToMessage("NOW ONLY {NewLTO.PriceCalculator(true)} GOLD"))
        StackBox.AddWidget(stack_box_slot{Widget :=  GetLTOPurchaseButton(CustomPlayer)})
        if(PlayerWidget :=  PlayerToCanvasMap[CustomPlayer.Player][WeaponShopOrder]?):
            spawn{RefreshLTO(StackBox,CustomPlayer,CurrentLTOItemIcon,CurrentLTORarityIcon,CurrentLTOItemName,CurrentLTOItemFullPrice,CurrentLTOItemDiscountPrice,CurrentButton)}

    GetLTOPurchaseButton<private>(CustomPlayer:custom_player):button_loud = 
        CurrentLTOIndex :=  GetLTOIndex()
        var AlreadyOwned:logic = false
        if(NewLTO :=  LTOArray[CurrentLTOIndex]):
            for(Item: CustomPlayer.UnlockedItemArray, Item.Name=NewLTO.Name):
                if(Item.Rarity.Order > 0) then return CustomPurchaseButton("Owned", false)
        return CustomPurchaseButton("Unlock", false)
##############################
### Limited Time Offer UI End#
##############################


##############################
### Shop Layout Functions ####
##############################
    GetAvailableItems<private>(PlayerPossibleItems: []item): tuple([]item,[]item,[]item) =
        var UpgradableItems : []item = array{}
        var UnlockableItems : []item = array{}
        var MaxedOutItems : []item = array{}
        for (Item: PlayerPossibleItems):
            if(Item.Rarity.Order < Item.MinRarity.Order) then set UnlockableItems += array{Item.NextRarity()}
            else if(Item.Rarity.Order >= Item.MaxRarity.Order) then set MaxedOutItems += array{Item}
            else set UpgradableItems += array{Item.NextRarity()}
        return (UpgradableItems, UnlockableItems, MaxedOutItems)

    ShopLayoutStackBox<private>(CustomPlayer:custom_player, CurrentTab:item_type, CurrentPage:int):stack_box = 
        var ItemsToShow : []item = array{}
        case(CurrentTab):
            item_type.Weapon => set ItemsToShow = CustomPlayer.UnlockedWeaponArray
            item_type.Heal => set ItemsToShow = CustomPlayer.UnlockedHealArray
            item_type.Throwable => set ItemsToShow = CustomPlayer.UnlockedThrowableArray
            item_type.Ability => set ItemsToShow = CustomPlayer.UnlockedAbilityArray
            _=>

        NumberOfItemsInRow:int = 6
        NumberOfRowsInPage:int = 2

        AvailableItems: tuple([]item, []item, []item) = GetAvailableItems(ItemsToShow)
        TotalItems:int = AvailableItems(0).Length + AvailableItems(1).Length + AvailableItems(2).Length

        var TotalRows:int = 0
        if(TempRatRows :=  TotalItems/NumberOfItemsInRow) then set TotalRows = Ceil(TempRatRows)

        var TotalPages:int = 0
        if(TempRatPages :=  TotalRows/NumberOfRowsInPage) then set TotalPages = Ceil(TempRatPages)

        PermItemStackBox :=  stack_box{Orientation :=  orientation.Vertical}
        PermItemStackBox.AddWidget(ShopRowsStackBox(AvailableItems,NumberOfItemsInRow,NumberOfRowsInPage,CurrentPage))

        ChangePageButtonStackBox := stack_box{Orientation :=  orientation.Horizontal}
        if(CurrentPage > 0) then ChangePageButtonStackBox.AddWidget(stack_box_slot{
            Widget := ChangeShopLayoutButton("<",CurrentTab,CurrentPage-1)
            HorizontalAlignment :=  horizontal_alignment.Left
            VerticalAlignment :=  vertical_alignment.Center})
        ChangePageButtonStackBox.AddWidget(stack_box_slot{
            Widget :=  CustomButton("Exit",ExitShop)
            Padding :=  margin{Left :=  5.0, Right := 5.0}})
        if(CurrentPage < TotalPages-1) then ChangePageButtonStackBox.AddWidget(stack_box_slot{
            Widget :=  ChangeShopLayoutButton(">",CurrentTab,CurrentPage+1)
            HorizontalAlignment :=  horizontal_alignment.Right
            VerticalAlignment :=  vertical_alignment.Center})
        PermItemStackBox.AddWidget(stack_box_slot{Widget :=  ChangePageButtonStackBox})
        return PermItemStackBox

    ShopRowsStackBox<private>(AvailableItems:tuple([]item, []item, []item),NumberOfItemsInRow:int,NumberOfRowsInPage:int,CurrentPage:int):stack_box_slot = 
        ShopStackBox :=  stack_box{Orientation :=  orientation.Vertical}
        var UpgradableItems : []item = AvailableItems(0)
        var UnlockableItems : []item = AvailableItems(1)
        var MaxedOutItems : []item = AvailableItems(2)
        for(X:=0..NumberOfRowsInPage-1):
            ItemsInRowStackBox := stack_box{Orientation := orientation.Horizontal}
            RowStackBoxSlot := stack_box_slot:
                Widget := ItemsInRowStackBox
                Padding := margin{Bottom := 10.0}
            for(Y:=0..NumberOfItemsInRow-1):
                CurrentItemIndex : int = CurrentPage*NumberOfRowsInPage*NumberOfItemsInRow + X*NumberOfItemsInRow + Y
                var CurrentArray : int = 0
                if(CurrentItemIndex > UpgradableItems.Length + UnlockableItems.Length-1) :
                    if(Item := AvailableItems(2)[CurrentItemIndex - UpgradableItems.Length - UnlockableItems.Length]):
                        ItemsInRowStackBox.AddWidget(ItemStackBoxSlot(Item,option{"Max"}))
                else if (CurrentItemIndex > UpgradableItems.Length-1) :
                    if(Item := AvailableItems(1)[CurrentItemIndex - UpgradableItems.Length]):
                        ItemsInRowStackBox.AddWidget(ItemStackBoxSlot(Item,false))
                else:
                    if(Item := AvailableItems(0)[CurrentItemIndex]):
                        ItemsInRowStackBox.AddWidget(ItemStackBoxSlot(Item,false))
            ShopStackBox.AddWidget(RowStackBoxSlot)
        return stack_box_slot{Widget :=  ShopStackBox, Padding :=  margin{Left :=  15.0,Right :=  15.0},HorizontalAlignment := horizontal_alignment.Center}

    ItemFinalStackBox<private>(Item:item, Maxed:?string):stack_box =
        var UpgradePriceString:string = ""
        var ButtonText:string = ""
        #Here we check for raritys and adjust accordingly
        if(Maxed?):
            set UpgradePriceString = "Max Lvl Reached"
            set ButtonText = "Owned"
        else if(Item.Rarity.Order > Item.MinRarity.Order):
            set UpgradePriceString = "V{Item.Rarity.Order - 1} > V{Item.Rarity.Order}: {Item.PriceCalculator(false)}"
            set ButtonText = "Upgrade"
        else:
            set UpgradePriceString = "V{Item.Rarity.Order}: {Item.PriceCalculator(false)}"
            set ButtonText = "Unlock"
        var ItemNameClipped : string = ClipString(Item.Name,13)    
        return stack_box:
            Orientation :=  orientation.Vertical
            Slots :=  array:
                stack_box_slot:
                    Widget :=  canvas:
                        Slots :=  array:
                            canvas_slot:
                                Widget :=  texture_block{
                                    DefaultImage :=  Item.Rarity.BGIcon
                                    DefaultDesiredSize :=  vector2{X :=  150.0, Y :=  150.0}}
                                Anchors :=  anchors:
                                    Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                                    Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                                Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                                SizeToContent :=  true     
                                ZOrder :=  1
                            canvas_slot:
                                Widget :=  texture_block{
                                    DefaultImage :=  Item.Icon
                                    DefaultDesiredSize :=  vector2{X :=  150.0, Y :=  150.0}}
                                Anchors :=  anchors:
                                    Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                                    Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                                Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                                SizeToContent :=  true     
                                ZOrder :=  2
                stack_box_slot:
                    Widget :=  canvas:
                        Slots := array:
                            canvas_slot:
                                Widget := text_block{
                                    DefaultText :=  StringToMessage("{ItemNameClipped}")
                                    DefaultTextColor :=  White
                                    DefaultJustification := text_justification.Center
                                    DefaultOverflowPolicy := text_overflow_policy.Clip}
                                Anchors :=  anchors:
                                    Minimum :=  vector2{X :=  0.0, Y :=  0.5}
                                    Maximum :=  vector2{X :=  0.0, Y :=  0.5}
                                Alignment :=  vector2{X :=  0.0, Y :=  0.5 }
                                Offsets := margin{Bottom := 30.0}
                                SizeToContent := false
                    HorizontalAlignment := horizontal_alignment.Center
                stack_box_slot:
                    Widget :=  text_block{
                        DefaultText :=  StringToMessage(UpgradePriceString)
                        DefaultTextColor :=  White
                        DefaultTextOpacity := 0.7}
                stack_box_slot:
                    Widget :=  CustomPurchaseButton(ButtonText, option{Item})

    ItemStackBoxSlot<private>(Item:item, Maxed:?string):stack_box_slot = 
        BackgroundCanvas := canvas:
            Slots :=  array:
                canvas_slot:
                    Widget :=  color_block{
                        DefaultColor := White
                        DefaultOpacity := 0.1
                        DefaultDesiredSize :=  vector2{X :=  275.0, Y :=  350.0}}
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                        Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                    Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                    SizeToContent :=  true     
        ItemBackgroundOverlay := overlay:
            Slots := array:
                overlay_slot:
                    Widget := BackgroundCanvas
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                overlay_slot:
                    Widget := ItemFinalStackBox(Item, Maxed)
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center

        return stack_box_slot{Widget :=  ItemBackgroundOverlay,Padding :=  margin{Left :=  5.0,Right :=  5.0},HorizontalAlignment := horizontal_alignment.Center}

    ChangeShopLayoutButton<private>(ButtonName:string, TabToOpen:item_type ,PageToOpen:int):button_quiet = 
        Button :=  button_quiet{DefaultText:=StringToMessage(ButtonName)}
        Button.OnClick().SubscribeChangeShopLayoutButton(RedrawShopLayout, TabToOpen, PageToOpen)
        return Button

    RedrawShopLayout(Wdata:widget_message, TabToOpen:item_type, PageToOpen:int)<suspends> : void=
        ExitShop(Wdata)
        Sleep(0.005)
        var TabIndex : int = 0 
        if(Player := Wdata.Player, Agent := agent[Player]):
            case(TabToOpen):
                item_type.Heal => {
                    set TabIndex = 0
                    ShowUtilityShopUI(true,4,option{Agent})}
                item_type.Throwable => {
                    set TabIndex = 1
                    ShowUtilityShopUI(true,4,option{Agent})}
                item_type.Ability => {
                    set TabIndex = 2 
                    ShowUtilityShopUI(true,4,option{Agent})}
                _=> {
                    set TabIndex = 0 
                    ShowWeaponShopUI(true,4,option{Agent})}
        Sleep(0.025)
        if:
            Player := Wdata.Player
            Agent := agent[Player]
            CustomPlayer := PlayerToCustomPlayerMap[Player]
            CurrentUIElements := CustomPlayerToUIElements[CustomPlayer]
            CurrentShopLayout := CurrentUIElements.ShopLayout?
        then: 
            NewShopLayout := ShopLayoutStackBox(CustomPlayer, TabToOpen, PageToOpen)
            CurrentShopLayout.CurParentWidget.RemoveWidget(CurrentShopLayout.CurShopLayout)
            CurrentShopLayout.CurParentWidget.AddWidget(stack_box_slot{
                Widget := NewShopLayout
            })
            set CurrentUIElements.ShopLayout = option{shop_layout{
                    CurShopLayout := NewShopLayout
                    CurTab := TabToOpen
                    CurPage := PageToOpen
                    CurParentWidget := CurrentShopLayout.CurParentWidget
                }}
            for(Index -> TabColor : TabColorBlockArray):
                if(TabIndex = Index) then TabColor.SetOpacity(1.0)
                else TabColor.SetOpacity(0.75)

    CustomPurchaseButton<private>(ButtonName:string, PermanentItem:?item):button_loud = 
        CurrentLTOIndex :=  GetLTOIndex()
        Button :=  button_loud{}
        Button.SetText(StringToMessage(ButtonName))
        if(ButtonName = "Owned") then return Button
        if(not PermanentItem?, CurrentLTO :=  LTOArray[CurrentLTOIndex]):
            Button.OnClick().SubscribePurchaseButton(Purchase,CurrentLTO,true)
        else if(TruePermItem :=  PermanentItem?):
            Button.OnClick().SubscribePurchaseButton(Purchase,TruePermItem,false)
        return Button

    GetCurrencyStackBox<private>(CustomPlayer:custom_player):stack_box = 
        CurrencyTextBlock:text_block = text_block:
            DefaultText :=  StringToMessage("{CustomPlayer.GetCurrencyValue()}")
            DefaultTextColor :=  White
            DefaultShadowColor :=  Black
            DefaultShadowOffset :=  option{vector2{X :=  3.0,Y :=  3.0}}
        CurrencyTextBlock.SetShadowOpacity(1.0)
        if(ExistingElements := CustomPlayerToUIElements[CustomPlayer]):
            set ExistingElements.CurrencyTracker = option{currency_tracker{
                CurCurrencyTextBlock := CurrencyTextBlock}}
        else:
            if(set CustomPlayerToUIElements[CustomPlayer] = NewUIElements : player_ui_elements = player_ui_elements{CurrencyTracker := option{currency_tracker{
                CurCurrencyTextBlock := CurrencyTextBlock
            }}}){}
        CurrencyTextureBlock :=  texture_block:
            DefaultImage :=  Icons.IC_Banana_Coin
            DefaultDesiredSize :=  vector2{X :=  40.0, Y :=  40.0}  
        CurrencyStackBox:stack_box = stack_box:
            Orientation :=  orientation.Horizontal
            Slots :=  array:
                stack_box_slot:
                    Widget :=  CurrencyTextureBlock
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                stack_box_slot:
                    Widget :=  CurrencyTextBlock
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
        return CurrencyStackBox

    GetRarityIcon<private>(Rarity:rarity):texture = return Rarity.BGIcon
    GetItemIcon<private>(Item:item):texture = return Item.Icon

    Purchase<private>(Wdata:widget_message,ItemToPurchase:item,Discount:logic):void = 
        if:
            Player :=  Wdata.Player
            CustomPlayer :=  PlayerToCustomPlayerMap[Player]
            Agent :=  agent[Player]
        then:
            var ItemPrice:int = ItemToPurchase.PriceCalculator(Discount)
            PlayerCurrency :=  CustomPlayer.GetCurrencyValue()
            if(PlayerCurrency  >= ItemPrice):
                for(Index->Item:CustomPlayer.UnlockedItemArray):
                    if(Item.Name = ItemToPurchase.Name, Item.MaxRarity.Order >= Item.Rarity.Order):
                        Item.UpgradeRarity()
                        CurrencyManager.CurrencyRemove(Agent, ItemPrice)
                        if(Item.MaxRarity.Order > Item.Rarity.Order):
                            RefreshUIElement(Wdata, ItemToPurchase.NextRarity(), false)
                        else:
                            RefreshUIElement(Wdata, ItemToPurchase, option{"Max"})
            <# else:
                spawn{MissingFunds(Agent)} #>

    MissingFunds(Agent : agent) <suspends> : void = 
        if(Player :=  player[Agent],CustomPlayer :=  PlayerToCustomPlayerMap[Player]):
            AppearUI(true,1000,Player,MFCanvasSlot())
        Sleep(1.0)
        RemoveSomeHUDS(option{Agent} , option{array{1000}})

    MFCanvasSlot() : canvas_slot = 
        MFOverlay : overlay = overlay{
            Slots := array : 
                overlay_slot : 
                    Widget := color_block:
                        DefaultColor :=  Black
                        DefaultOpacity :=  0.9
                        DefaultDesiredSize :=  vector2{X :=  500.0, Y :=  125.0}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                overlay_slot : 
                    Widget := text_block:
                        DefaultText :=  StringToMessage("NOT ENOUGH FUNDS")
                        DefaultTextColor :=  Red
                        DefaultShadowColor :=  White
                        DefaultShadowOffset :=  option{vector2{X :=  3.0,Y :=  3.0}}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
            }
        return canvas_slot{Widget := MFOverlay
                    Anchors :=  anchors:
                        Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                        Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                    Alignment :=  vector2{X :=  0.5, Y :=  0.5}
                    SizeToContent :=  true
                    ZOrder :=  1000}

    RefreshUIElement(Wdata : widget_message, ItemPurchased : item, Maxed:?string):void = 
        SourceWidget := Wdata.Source
        if(LTOItem := special[ItemPurchased]):
            
        if(ParentWidget := SourceWidget.GetParentWidget[], ItemStackBox := stack_box[ParentWidget], CustomPlayer := PlayerToCustomPlayerMap[Wdata.Player]):
            var ItemShopRowStackBoxSlots : []stack_box_slot = array{}
            if:
                ItemSBParent := ItemStackBox.GetParentWidget[]
                ItemSBOverlay := overlay[ItemSBParent]
            then:
                #Print("Second if runs") At a later point, we should feed the elements that need changing here, and set ... only to those
                ItemSBOverlay.RemoveWidget(ItemStackBox)
                ItemSBOverlay.AddWidget(overlay_slot{Widget :=  ItemFinalStackBox(ItemPurchased, Maxed),HorizontalAlignment := horizontal_alignment.Center,VerticalAlignment :=  vertical_alignment.Center})
                
            else:
                ItemStackBox.RemoveWidget(SourceWidget)
                ItemStackBox.AddWidget(stack_box_slot{
                    Widget :=  GetLTOPurchaseButton(CustomPlayer)
                    HorizontalAlignment :=  horizontal_alignment.Left
                    VerticalAlignment :=  vertical_alignment.Center})
            UpdateCurrency(CustomPlayer)

    UpdateCurrency(CustomPlayer : custom_player) : void = 
        if:
            ExistingElements := CustomPlayerToUIElements[CustomPlayer]
            CurrentCurrency := ExistingElements.CurrencyTracker?
        then:
            CurrentCurrency.CurCurrencyTextBlock.SetText(IntToMessage(CustomPlayer.GetCurrencyValue()))

    ExitShop(Wdata:widget_message):void = 
        if(Player :=  Wdata.Player,Agent :=  agent[Player]):
            RemoveSomeHUDS(option{Agent}, option{array{WeaponShopOrder,UtilityShopOrder}})
##############################
### Shop Layout Functions End#
##############################


#######################################################
#######################################################
### End ###############################################
#######################################################
#######################################################



#######################################################
#######################################################
### Disabled Modules ##################################
#######################################################
#######################################################


    <##############################
    ### Countdown Timer UI #######
    ##############################
        var CountdownTimerOrder<private>:int = 0
        var TotalTimer<private>:float = 0.0
        var CountdownText<private>:string = ""
        var Time<private>:float = 10000.0
        var TimerEnded:logic = false

        ShowCustomTimerUI(Interactable:logic,Order:int,Agent:?agent,CountdownTime:float,PreviewText:string):void = 
            set CountdownTimerOrder = Order
            set TotalTimer = CountdownTime
            set CountdownText = PreviewText
            if(TrueAgent :=  Agent?):
                if(Player :=  player[TrueAgent]):
                    AppearUI(Interactable,Order,Player,CTCanvasSlot(Player))
            else:
                set ExistingUIs = ExistingUIs + array{CountdownTimerOrder}
                for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                    AppearUI(Interactable,Order,Player,CTCanvasSlot(Player))

        CTCanvasSlot<private>(Player:player):canvas_slot = 
            CountdownEndedEvent : event(float) = event(float){}
            var IntTime:int = 0
            if(TempInt :=  Round[TotalTimer],set IntTime = TempInt){}
            RemainingTimeTextBlock:text_block = text_block:
                DefaultText :=  StringToMessage("{CountdownText}{IntTime}")
                DefaultTextColor :=  White
                DefaultShadowColor :=  Black
                DefaultShadowOffset :=  option{vector2{X :=  2.0,Y :=  2.0}}
            RemainingTimeTextBlock.SetShadowOpacity(1.0)
            TimerCanvas :=  canvas:
                Slots :=  array:
                    canvas_slot:
                        Widget :=  RemainingTimeTextBlock
                        Anchors :=  anchors:
                            Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                            Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                        Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                        SizeToContent :=  true     
                        ZOrder :=  2
                    canvas_slot:
                        Widget :=  texture_block:
                            DefaultImage :=  Icons.IC_TimerBG
                            DefaultDesiredSize :=  vector2{X :=  120.0, Y :=  120.0}
                        Anchors :=  anchors:
                            Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                            Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                        Alignment :=  vector2{X :=  0.5, Y :=  0.65 }
                        SizeToContent :=  true     
                        ZOrder :=  1
            CountdownTimerSlot :=  canvas_slot:
                Widget :=  TimerCanvas
                Anchors :=  anchors:
                    Minimum :=  vector2{X :=  0.5, Y :=  0.17}
                    Maximum :=  vector2{X :=  0.5, Y :=  0.17}
                Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                SizeToContent :=  true     
                ZOrder :=  2
            if(Agent :=  agent[Player]):
                spawn{RunCountdown(RemainingTimeTextBlock,CountdownEndedEvent,Agent)}
            return CountdownTimerSlot
            
        RunCountdown<private>(TextBlock:text_block,Event:event(float),Agent:agent)<suspends> : void = 
            TimerTickPeriod:float = 1.0
            var TimeLeft:float = TotalTimer

            RefreshUIsEvent.Await()
            if(TimeLeft <= 0.0):
                Event.Signal(TimeLeft)
                RemoveSomeHUDS(option{Agent},option{array{2,3}})
            set TimeLeft -= TimerTickPeriod
            set Time = TimeLeft
            if(IntTime :=  Int[TimeLeft]):
                TextBlock.SetText(StringToMessage(CountdownText+"{IntTime}"))
            spawn{RunCountdown(TextBlock,Event,Agent)}
            
    ##############################
    ### Countdown Timer UI End ###
    ##############################>


    <##############################
    ### Currency Text UI #########
    ##############################
        var CurrencyTextOrder<private>:int = 0
        var CurrencyText : string = "Gold: " 

        ShowCurrencyTextUI(Interactable:logic,Order:int,Agent:?agent):void = 
            set CurrencyTextOrder = Order
            if(TrueAgent :=  Agent?):
                if(Player :=  player[TrueAgent],CustomPlayer :=  PlayerToCustomPlayerMap[Player]):
                    AppearUI(Interactable,Order,Player,CuTeCanvasSlot(CustomPlayer))
            else:
                set ExistingUIs = ExistingUIs + array{CurrencyTextOrder}
                for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                    AppearUI(Interactable,Order,Player,CuTeCanvasSlot(CustomPlayer))

        CuTeCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot = 
            CurrencyTextBlock:text_block = text_block:
                DefaultText :=  StringToMessage("{CurrencyText}{CustomPlayer.CurrencyAmount}")
                DefaultTextColor :=  White
                DefaultShadowColor :=  Black
                DefaultShadowOffset :=  option{vector2{X :=  3.0,Y :=  3.0}}
            CurrencyTextBlock.SetShadowOpacity(1.0)
            CurrencyTextureBlock :=  texture_block:
                DefaultImage :=  Icons.IC_Banana_Coin
                DefaultDesiredSize :=  vector2{X :=  40.0, Y :=  40.0}  
            CurrencyStackBox:stack_box = stack_box:
                Orientation :=  orientation.Horizontal
                Slots :=  array:
                    stack_box_slot:
                        Widget :=  CurrencyTextureBlock
                        HorizontalAlignment :=  horizontal_alignment.Center
                        VerticalAlignment :=  vertical_alignment.Center
                    stack_box_slot:
                        Widget :=  CurrencyTextBlock
                        HorizontalAlignment :=  horizontal_alignment.Center
                        VerticalAlignment :=  vertical_alignment.Center
            CurrencyCanvasSlot :=  canvas_slot:
                Widget :=  CurrencyStackBox
                Anchors :=  anchors:
                    Minimum :=  vector2{X :=  0.0, Y :=  0.5}
                    Maximum :=  vector2{X :=  0.0, Y :=  0.5}
                Alignment :=  vector2{X :=  0.0, Y :=  0.5 }
                Offsets :=  margin{Left :=  20.0}
                SizeToContent :=  true     
                ZOrder :=  10
            spawn{RefreshCurrency(CurrencyTextBlock,CustomPlayer)}
            return CurrencyCanvasSlot   
            
        RefreshCurrency<private>(CurrencyTextBlock:text_block,CustomPlayer:custom_player)<suspends> : void = 
            RefreshUIsEvent.Await()
            CustomPlayer.GetCurrencyAmount()
            CurrencyTextBlock.SetText(StringToMessage("{CurrencyText}{CustomPlayer.CurrencyAmount}"))
            if(PlayerWidget :=  PlayerToCanvasMap[CustomPlayer.Player][CurrencyTextOrder]?):
                spawn{RefreshCurrency(CurrencyTextBlock,CustomPlayer)}
            
    ##############################
    ### Currency Text UI End #####
    ##############################>


    <##############################
    ### Progress Bar UI ##########
    ##############################
        var ProgressBarOrder<private>:int = 0
        var TotalLevelsNumber:int = 0
        var PBFrontColorBlock<private>: color_block = color_block{}
        var PBFrontColor<private>: color = Yellow
        var PBBackColorBlock<private>: color_block = color_block{}
        var PBBackColor<private>: color = DarkGray
        PBSize<private>:vector2 = vector2{X :=  600.0,Y :=  50.0}
        PBOrientation<private>:tuple(horizontal_alignment,vertical_alignment) = (horizontal_alignment.Left,vertical_alignment.Fill)

        ShowProgressBarUI(Interactable:logic,Order:int,Agent:?agent,TotalLevels:int):void = 
            set ProgressBarOrder = Order
            set TotalLevelsNumber = TotalLevels 
            if(TrueAgent :=  Agent?):
                if(Player :=  player[TrueAgent],CustomPlayer :=  PlayerToCustomPlayerMap[Player]):
                    AppearUI(Interactable,Order,Player,PBCanvasSlot(CustomPlayer))
            else:
                set ExistingUIs = ExistingUIs + array{ProgressBarOrder}
                for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                    AppearUI(Interactable,Order,Player,PBCanvasSlot(CustomPlayer))

        PBCanvasSlot<private>(CustomPlayer:custom_player):canvas_slot = 
            ProgressTextBlock:text_block = text_block:
                DefaultText :=  StringToMessage("Current Progress")
                DefaultTextColor :=  White
                DefaultShadowColor :=  Black
                DefaultShadowOffset :=  option{vector2{X :=  3.0,Y :=  3.0}}
            ProgressTextBlock.SetShadowOpacity(1.0)
            set PBFrontColorBlock = color_block{DefaultColor :=  PBFrontColor,DefaultDesiredSize :=  vector2{X :=  0.0,Y :=  0.0}}
            set PBBackColorBlock = color_block{DefaultColor :=  PBBackColor,DefaultDesiredSize :=  PBSize}
            PBOverlay:overlay :=  overlay:
                Slots :=  array:
                    overlay_slot:
                        Widget :=  PBBackColorBlock
                        HorizontalAlignment :=  horizontal_alignment.Fill
                        VerticalAlignment :=  vertical_alignment.Fill
                    overlay_slot:
                        Widget :=  PBFrontColorBlock
                        HorizontalAlignment :=  PBOrientation(0)
                        VerticalAlignment :=  PBOrientation(1)
            ProgressStackBox:stack_box = stack_box:
                Orientation :=  orientation.Vertical
                Slots :=  array:
                    stack_box_slot:
                        Widget :=  ProgressTextBlock
                        HorizontalAlignment :=  horizontal_alignment.Center
                        VerticalAlignment :=  vertical_alignment.Center
                    stack_box_slot:
                        Widget :=  PBOverlay
                        HorizontalAlignment :=  horizontal_alignment.Center
                        VerticalAlignment :=  vertical_alignment.Bottom
            PBSliderCanvasSlot :=  canvas_slot:
                        Widget :=  ProgressStackBox
                        Anchors :=  anchors:
                            Minimum :=  vector2{X :=  0.5, Y :=  0.98}
                            Maximum :=  vector2{X :=  0.5, Y :=  0.98}
                        Alignment :=  vector2{X :=  0.5, Y :=  1.0 }
                        SizeToContent :=  true     
                        ZOrder :=  10
            spawn{RefreshProgressBar(CustomPlayer)}
            return PBSliderCanvasSlot
            
        RefreshProgressBar<private>(CustomPlayer:custom_player)<suspends> : void = 
            RefreshUIsEvent.Await()
            StepSize :=  100.0/(TotalLevelsNumber*1.0)
            PBFrontColorBlock.SetDesiredSize(vector2{X :=  PBSize.X*StepSize*CustomPlayer.LevelCompleted/100.0})
            if(PlayerWidget :=  PlayerToCanvasMap[CustomPlayer.Player][ProgressBarOrder]?):
                spawn{RefreshProgressBar(CustomPlayer)}

    ##############################
    ### Progress Bar UI End ######
    ##############################>


    <##############################
    ### Stopwatch UI #############
    ##############################
        var StopwatchOrder<private>:int = 0
        var StopwatchText<private>:string = "Time taken: "

        ShowStopwatchUI(Interactable:logic,Order:int,Agent:?agent):void = 
            set StopwatchOrder = Order
            if(TrueAgent :=  Agent?):
                if(Player :=  player[TrueAgent]):
                    AppearUI(Interactable,Order,Player,SWCanvasSlot(Player))
            else:
                set ExistingUIs = ExistingUIs + array{CountdownTimerOrder}
                for(Player->CustomPlayer:PlayerToCustomPlayerMap):
                    AppearUI(Interactable,Order,Player,SWCanvasSlot(Player))

        SWCanvasSlot<private>(Player:player):canvas_slot = 
            var IntTime:int = 0
            if(TempInt :=  Round[TotalTimer],set IntTime = TempInt){}
            TimePassedTextBlock:text_block = text_block:
                DefaultText :=  StringToMessage("{CountdownText}{IntTime}")
                DefaultTextColor :=  White
                DefaultShadowColor :=  Black
                DefaultShadowOffset :=  option{vector2{X :=  3.0,Y :=  3.0}}
            TimePassedTextBlock.SetShadowOpacity(1.0)
            TimerCanvas :=  canvas:
                Slots :=  array:
                    canvas_slot:
                        Widget :=  TimePassedTextBlock
                        Anchors :=  anchors:
                            Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                            Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                        Alignment :=  vector2{X :=  0.5, Y :=  0.5 }
                        Offsets :=  margin{Top :=  0.0, Left :=  0.0, Bottom :=  0.0, Right :=  0.0}
                        SizeToContent :=  true     
                        ZOrder :=  2
                    canvas_slot:
                        Widget :=  texture_block:
                            DefaultImage :=  Icons.IC_TimerBG
                            DefaultDesiredSize :=  vector2{X :=  120.0, Y :=  120.0}
                        Anchors :=  anchors:
                            Minimum :=  vector2{X :=  0.5, Y :=  0.5}
                            Maximum :=  vector2{X :=  0.5, Y :=  0.5}
                        Alignment :=  vector2{X :=  0.5, Y :=  0.65 }
                        Offsets :=  margin{Top :=  0.0, Left :=  0.0, Bottom :=  0.0, Right :=  0.0}
                        SizeToContent :=  true     
                        ZOrder :=  1
            CountdownTimerSlot :=  canvas_slot:
                Widget :=  TimerCanvas
                Anchors :=  anchors:
                    Minimum :=  vector2{X :=  0.0, Y :=  0.6}
                    Maximum :=  vector2{X :=  0.0, Y :=  0.6}
                Alignment :=  vector2{X :=  0.0, Y :=  0.5 }
                Offsets :=  margin{Top :=  0.0, Left :=  20.0, Bottom :=  0.0, Right :=  0.0}
                SizeToContent :=  true     
                ZOrder :=  2
            if(Agent :=  agent[Player]):
                spawn{RunStopwatch(TimePassedTextBlock,Agent)}
            return CountdownTimerSlot
            
        RunStopwatch<private>(TextBlock:text_block,Agent:agent)<suspends> : void = 
            var TotalTime:float = 0.0
            TimerTickPeriod:float = 1.0
            var TimeLeft:float = TotalTimer

            RefreshUIsEvent.Await()
            set TotalTime += TimerTickPeriod
            if(IntTime :=  Int[TotalTime]):
                TextBlock.SetText(StringToMessage(StopwatchText+"{IntTime}"))
            spawn{RunStopwatch(TextBlock,Agent)}

    ##############################
    ### Stopwatch UI End #########
    ##############################>


#######################################################
#######################################################
### End ###############################################
#######################################################
#######################################################




#######################################################
#######################################################
### Helper Classes ####################################
#######################################################
#######################################################

player_ui_elements := class <unique> () :
    var ShopLayout : ?shop_layout = false
    var CurrencyTracker : ?currency_tracker = false

shop_layout := class <unique> () :
    CurShopLayout : stack_box
    CurTab : item_type
    CurPage : int
    CurParentWidget : stack_box

currency_tracker := class <unique> () :
    CurCurrencyTextBlock : text_block

#######################################################
#######################################################
### End ###############################################
#######################################################
#######################################################
