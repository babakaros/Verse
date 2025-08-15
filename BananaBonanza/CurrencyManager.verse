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

Currency_Manager := class(creative_device):
    #Here we should also add xp granting
    # Editables
    ## Currency functionality ##
    @editable{Categories := array{Currency}} Currency_Conditional:conditional_button_device=conditional_button_device{}
    @editable{Categories := array{Currency}} Currency_Granter:item_granter_device=item_granter_device{}
    @editable{Categories := array{Currency}} Currency_VFX:creative_prop_asset=DefaultCreativePropAsset
    @editable{Categories := array{Currency}} Currency_SFX:audio_player_device=audio_player_device{}
    @editable{Categories := array{Currency}} Currency_StatCreator:stat_creator_device=stat_creator_device{}

    ## Pop Up UI ##
    @editable{Categories := array{UI}} TextColor : color = NamedColors.White
    @editable{Categories := array{UI}} EffectTime : float = 2.0

    ## Other ##
    @editable{Categories := array{Currency}} VendingMacines : []vending_machine_device = array{}

    var AgentToOverlayMap : [agent]overlay = map{}
    var CustomPlayers : [player]custom_player = map{}

    # Methods
    InitCurrencyManager(CustomPlayersMap:[player]custom_player)  : void = 
        set CustomPlayers = CustomPlayersMap
        for(VendingMachine : VendingMacines) :
            VendingMachine.ItemSpawnedEvent.Subscribe(UpdateUI)

    UpdateUI(Agent : agent) : void = 
        if(CustomPlayer := CustomPlayers[player[Agent]]):
            spawn{RefreshCurrencyDelay(CustomPlayer)}

    RefreshCurrencyDelay(CustomPlayer : custom_player)<suspends> : void = 
        Sleep(0.5)
        CustomPlayer.GetCurrencyValue() #This doesn't even work properly. We def need to find some other way

    CurrencyGrant(Agent : agent, Value : currency_grant_type) : void = 
        var CurrencyGrantedAmount : int = 5
        #Grant Gold
        case (Value) :
            currency_grant_type.AFKZone =>
                Currency_Granter.GrantItemIndex(Agent, 0) #5
                set CurrencyGrantedAmount = 5
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.GuardEliminated =>
                Currency_Granter.GrantItemIndex(Agent, 1) #10
                set CurrencyGrantedAmount = 10
            currency_grant_type.LevelCleared =>
                Currency_Granter.GrantItemIndex(Agent, 2) #50
                set CurrencyGrantedAmount = 50
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.BossLevelCleared =>
                Currency_Granter.GrantItemIndex(Agent, 3) #125
                set CurrencyGrantedAmount = 125
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.ChallengeCompletedSmall =>
                Currency_Granter.GrantItemIndex(Agent, 3) #125
                set CurrencyGrantedAmount = 125
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.ChallengeCompletedLarge =>
                Currency_Granter.GrantItemIndex(Agent, 4) #1000
                set CurrencyGrantedAmount = 1000
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.AbilityGoldUncommon =>
                Currency_Granter.GrantItemIndex(Agent, 2) #50
                set CurrencyGrantedAmount = 50
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.AbilityGoldRare =>
                Currency_Granter.GrantItemIndex(Agent, 3) #125
                set CurrencyGrantedAmount = 125
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.ParkourFirst =>
                Currency_Granter.GrantItemIndex(Agent, 5) #500
                set CurrencyGrantedAmount = 500
                spawn{SpawnCurrencyVFX(Agent)}
            currency_grant_type.ParkourSecond =>
                Currency_Granter.GrantItemIndex(Agent, 6) #1500
                set CurrencyGrantedAmount = 1500
                spawn{SpawnCurrencyVFX(Agent)}
        Currency_SFX.Play(Agent)
        if:
            CurrentCurrencyValue := Currency_StatCreator.GetValue[Agent]
            Currency_StatCreator.SetValue[Agent, CurrentCurrencyValue + CurrencyGrantedAmount]
        ShowPopUpUI(Agent, CurrencyGrantedAmount)
        return

    CurrencyRemove(Agent : agent, Amount : int) : void = 
        Currency_Conditional.SetItemCountRequired(0, Amount)
        if(Currency_Conditional.HasAllItems[Agent]) then Currency_Conditional.Activate(Agent)
        return

    SpawnCurrencyVFX<private>(Agent : agent)<suspends> : void =
        if:
            FortChar := Agent.GetFortCharacter[]
            Translation := FortChar.GetTransform().Translation + vector3{X := 0.0, Y:= 0.0, Z := 50.0}
            SpawnedVFX := SpawnProp(Currency_VFX,Translation,rotation{})(0)?
        then:
            Sleep(EffectTime)
            SpawnedVFX.Dispose()

    ShowPopUpUI<private>(Agent : agent, Amount : int) : void = 
        #Maybe this can be moved inside UI device that I will create next. 
        var PopUpUIBaseOverlay : overlay = overlay{}
        if: 
            ExistingOverlay := AgentToOverlayMap[Agent]
            set PopUpUIBaseOverlay = ExistingOverlay
        else:
            if(set AgentToOverlayMap[Agent] = PopUpUIBaseOverlay){}
            if(PlayerUI :=  GetPlayerUI[player[Agent]]):
                PlayerUI.AddWidget(PopUpUIBaseOverlay,player_ui_slot{ZOrder :=  100,InputMode :=  ui_input_mode.None})
        spawn{PopUpUIStackBoxCreator(Amount, PopUpUIBaseOverlay)}

    PopUpUIStackBoxCreator<private>(Amount : int, BaseOverlay : overlay)<suspends> : void = 
        TotalText : string = "+ {Amount}"
        TextLengthNormalized := TotalText.Length - 3
        AmountTextStackBox: stack_box = stack_box :
            Orientation := orientation.Horizontal
            Slots := array : 
                stack_box_slot : 
                    Widget := text_block :
                        DefaultText := StringToMessage(TotalText)
                        DefaultTextColor := TextColor
                        DefaultShadowColor := Black
                        DefaultShadowOpacity := 1.0
                        DefaultShadowOffset := option{vector2{ X := 3.0, Y := 3.0}}
                stack_box_slot :
                    Widget := texture_block :
                        DefaultImage :=  Icons.IC_Banana_Coin
                        DefaultDesiredSize :=  vector2{X :=  40.0, Y :=  40.0}  
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center

        TestMaterialBlockOverlay : overlay = overlay:
            Slots := array:
                overlay_slot:
                    Widget := material_block:
                        DefaultImage := CustomUIWidgets.WidgetMaterials.MI_ComicFrame
                        DefaultDesiredSize := vector2{X :=  110.0 + TextLengthNormalized * 20.0, Y :=  65.0}
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                overlay_slot:
                    Widget := AmountTextStackBox
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center

        TransparentColorBlock : color_block = color_block:
            DefaultColor := White
            DefaultOpacity := 0.0
            DefaultDesiredSize :=  vector2{X :=  275.0, Y :=  0.0}

        PopUpUIStackBox : stack_box = stack_box:
            Orientation := orientation.Vertical
            Slots := array :
                stack_box_slot :
                    Widget:= TestMaterialBlockOverlay
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center
                stack_box_slot :
                    Widget := TransparentColorBlock
                    HorizontalAlignment :=  horizontal_alignment.Center
                    VerticalAlignment :=  vertical_alignment.Center

        PopUpOverlaySlot : overlay_slot = overlay_slot:
            Widget := PopUpUIStackBox
            Padding := margin{Left := GetRandomFloat(0.0, 80.0) + 150.0, Bottom := GetRandomFloat(0.0, 40.0)}

        BaseOverlay.AddWidget(PopUpOverlaySlot)

        var N : float = 0.0
        Tick : float = 0.041

        loop:
            CurrentSize := TransparentColorBlock.GetDesiredSize()
            TransparentColorBlock.SetDesiredSize(CurrentSize + vector2{X :=  0.0, Y :=  2.0})
            Sleep(Tick)
            set N += Tick
            if(N >= EffectTime):
                BaseOverlay.RemoveWidget(PopUpUIStackBox)
                break
