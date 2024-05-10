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

#########################
### Inventory Menu UI ###
#########################
    var InventoryMenuOrder<private>:int=0
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
