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

Game_Manager := class(creative_device):
    GameTotalTime:float=240.0
    var CustomUI:custom_ui_creator=custom_ui_creator{PlayerToCustomPlayerMap:=map{}}
    var CustomPlayers:[player]custom_player=map{}
    var SavedPlayerData:weak_map(player, custom_player) = map{}
    var RoundEnded:logic=false
    PickUpRange:float=120.0
    # Difficulty
    Easy:difficulty=difficulty{DifficultyName:="Easy",ExpireOrder:=120.0,DeliverOrderPoints:=150}
    Medium:difficulty=difficulty{DifficultyName:="Medium",ExpireOrder:=90.0,DeliverOrderPoints:=120}
    Hard:difficulty=difficulty{DifficultyName:="Hard",ExpireOrder:=60.0,DeliverOrderPoints:=100}
    @editable VerySmallXP:accolades_device=accolades_device{}
    @editable SmallXP:accolades_device=accolades_device{}
    @editable MediumXP:accolades_device=accolades_device{}
    @editable LargeXP:accolades_device=accolades_device{}
    @editable VeryLargeXP:accolades_device=accolades_device{}
    var DifficultyArray:[]difficulty=array{}
    var FinalTimeToExpireOrder:float=0.0
    
    MaxPoints:int=750
    MidPoints:int=600
    MinPoints:int=450

    var AwardMaxXP:accolades_device=accolades_device{}
    var AwardMidXP:accolades_device=accolades_device{}
    var AwardMinXP:accolades_device=accolades_device{}

    # Items with meshes
    Nothing:item=item{ItemName:="Null"}
    Carrot:ingredient=ingredient{ItemName:= "Carrot",ItemIcon:=Icons.IC_Carrot,MeshChopped:=DefaultCreativePropAsset,VFXChopped:=visual_effect_powerup_device{}}
    Chicken:ingredient=ingredient{ItemName:= "Chicken",ItemIcon:=Icons.IC_Chicken,MeshChopped:=DefaultCreativePropAsset,VFXChopped:=visual_effect_powerup_device{}}
    Potato:ingredient=ingredient{ItemName:= "Potato",ItemIcon:=Icons.IC_Potato,MeshChopped:=DefaultCreativePropAsset,VFXChopped:=visual_effect_powerup_device{}}
    Plate:container=container{ItemName:="Plate",Deliverable:=true}
    CookingPot1:pot=pot{ItemName:="Cooking Pot",Deliverable:=false,Position:=vector3{X:=76.0,Y:=126.0,Z:=95.0},SoupMesh:=false}
    CookingPot2:pot=pot{ItemName:="Cooking Pot",Deliverable:=false,Position:=vector3{X:=374.0,Y:=78.0,Z:=95.0},SoupMesh:=false}
    @editable CarrotMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable CarrotMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable CarrotVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CarrotVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable ChickenMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable ChickenMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable ChickenVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable ChickenVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PotatoMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable PotatoMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable PotatoVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PotatoVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PlateMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable PlateMeshFull:creative_prop_asset = DefaultCreativePropAsset
    @editable PlateMeshDirty:creative_prop_asset = DefaultCreativePropAsset
    @editable PlateVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PlateVFXFull:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PlateVFXDirty:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable Soup:creative_prop_asset = DefaultCreativePropAsset
    @editable BubblesVFX:vfx_spawner_device=vfx_spawner_device{}
    @editable ClearVFXTrigger:trigger_device=trigger_device{}
    var DroppedItemsArray:[]dropped_item=array{}
    var PlatesTaken:int=0
    var DirtyPlatesArray:[]container=array{}
    # Devices to interact with
    @editable DropInputTrigger:input_trigger_device = input_trigger_device{}
    @editable PickUpInputTrigger:input_trigger_device = input_trigger_device{}
    @editable CarrotButton : button_device = button_device{}
    @editable ChickenButton : button_device = button_device{}
    @editable PotatoButton : button_device = button_device{}
    @editable CuttingBoard1Button : button_device = button_device{}
    @editable CuttingBoard2Button : button_device = button_device{}
    @editable StoveButton1Button : button_device = button_device{}
    @editable StoveButton2Button : button_device = button_device{}
    @editable PlateButton : button_device = button_device{}
    @editable WaiterDevice : character_device = character_device{}
    @editable DirtyPlateButton : button_device = button_device{}
    @editable SinkButton : button_device = button_device{}
    @editable TrashcanButton : button_device = button_device{}
    # Extras
    @editable IntroCinematic:cinematic_sequence_device=cinematic_sequence_device{}
    @editable GameTimer:timer_device=timer_device{}
    @editable ChefsHatVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable GoldChefsHatVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable MusicSlow:audio_player_device=audio_player_device{}
    @editable AmbientCrowd:audio_player_device=audio_player_device{}
    @editable BellRing:audio_player_device=audio_player_device{}
    @editable BellFinal:audio_player_device=audio_player_device{}
    @editable EndGameDevice:end_game_device=end_game_device{}
    #Point System
    var PointsGathered:int=0
    var DeliverOrderPointsGranting:int=0
    
    OnBegin<override>()<suspends>:void=
        Print("Game Started")
        SFX()
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        InitSpawners()
        PlayIntro()
        SetUpDifficulties()
        Sleep(2.0)
        set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
        CustomUI.Assign()
        Sleep(2.0)
        CustomUI.ShowDifficultyVoteUI(true,1,false,array{Easy,Medium,Hard})
        CustomUI.CountdownEndedEvent.Await()
        CustomUI.RemoveSomeHUDS(array{1,2})
        CountVotes(CustomUI.PlayerVotes)
        Sleep(2.0)
        CustomUI.ShowInventoryTextUI(false,3,false)
        CustomUI.ShowPointSystemUI(false,4,false,450)
        spawn{CustomUI.OrderFood(false,5,false,array{Carrot,Chicken,Potato},20.0,FinalTimeToExpireOrder)}
        GameTimer.SetActiveDuration(GameTotalTime)
        GameTimer.Start()
        SetUpItemMeshVFX()
        EnableButtons()
        spawn{ButtonEnabler()}
        DropInputTrigger.PressedEvent.Subscribe(DropItem)
        PickUpInputTrigger.PressedEvent.Subscribe(PickUpItem)
        CarrotButton.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Carrot}.HandlerFunction)
        ChickenButton.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Chicken}.HandlerFunction)
        PotatoButton.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Potato}.HandlerFunction)
        CuttingBoard1Button.InteractedWithEvent.Subscribe(ChoppingItemInteraction)
        CuttingBoard2Button.InteractedWithEvent.Subscribe(ChoppingItemInteraction)
        StoveButton1Button.InteractedWithEvent.Subscribe(CookingPotInteraction_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,CookingPot:=CookingPot1}.HandlerFunction)
        StoveButton2Button.InteractedWithEvent.Subscribe(CookingPotInteraction_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,CookingPot:=CookingPot2}.HandlerFunction)
        PlateButton.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Plate}.HandlerFunction)
        WaiterDevice.InteractedWithEvent.Subscribe(WaiterInteraction)
        DirtyPlateButton.InteractedWithEvent.Subscribe(DirtyPlate)
        SinkButton.InteractedWithEvent.Subscribe(WashDish)
        TrashcanButton.InteractedWithEvent.Subscribe(TrashcanInteraction)
        GameTimer.SuccessEvent.Subscribe(CompleteRound)
    
    InitSpawners():void=
        Spawners:=GetCreativeObjectsWithTag(spawner{})
        for(Obj:Spawners):
            if(Spawner:=player_spawner_device[Obj]):
                Print("Spawner found!")
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        if(Player:=player[Agent]):
            Print("Initializing player...")
            InitPlayer(Player)

    InitPlayer(Player:player):void=
        if:
            Agent:=agent[Player]
            FortChar:=Agent.GetFortCharacter[]
        then:
            if(Existing:=CustomPlayers[Player]){}
            else:
                Print("Adding player to map...")
                CustomPlayer:=custom_player{Player:=Player,ClearVFXTrigger:=ClearVFXTrigger,ChefsHat:=ChefsHatVFX,GoldChefsHat:=GoldChefsHatVFX}
                CustomPlayer.Init()
                if(set CustomPlayers[Player]=CustomPlayer){}
            
    OnPlayerLeftServer(PlayerLeaving:player):void=
        if(CustomPlayer:=CustomPlayers[PlayerLeaving]):
            CustomPlayer.Dispose()
            var NewCustomPlayerMap:[player]custom_player=map{}
            for(Key->Value:CustomPlayers,Key<>PlayerLeaving):
                set NewCustomPlayerMap=ConcatenateMaps(NewCustomPlayerMap,map{Key=>Value})
            set CustomPlayers=NewCustomPlayerMap

    CompleteRound(Agent:?agent):void=
        Print("Round completed, counting game.")
        set RoundEnded=true
        BellFinal.Play()
        DisableButtons()
        CookingPot1.Empty()
        CookingPot2.Empty()
        CustomUI.AnounceScore(PointsGathered)
        for(AwardCustomPlayer:CustomPlayers,AwardPlayer:=AwardCustomPlayer.Player,AwardAgent:=agent[AwardPlayer]):
            if(PointsGathered>MaxPoints):
                AwardMaxXP.Award(AwardAgent)
            else if(PointsGathered>MidPoints):
                AwardMidXP.Award(AwardAgent)
            else if(PointsGathered>MinPoints):
                AwardMinXP.Award(AwardAgent)
        for(Player:CustomPlayers):
            set Player.GamesPlayed+=1
        if(IsAgent:=Agent?):
            spawn{End(IsAgent)}
        
    End(Agent:agent)<suspends>:void=
        Sleep(10.0)
        EndGameDevice.Activate(Agent)

    # Difficulty voting
    CountVotes(WhatEachPlayerVotedMap:[player]difficulty):void=
        var VoteCountMap:[string]int=map{}
        var m:int=0
        var n :int=0
        var WinningDifficulty:string=""
        for(Player->DifficultySelected:WhatEachPlayerVotedMap):
            if(M:=VoteCountMap[DifficultySelected.DifficultyName],set m=M):
                set m+=1
                if(set VoteCountMap[DifficultySelected.DifficultyName]=m):
            else:
                if(set VoteCountMap[DifficultySelected.DifficultyName]=1):
        for(DifficultyName->Count:VoteCountMap):
            if(Count>=n):
                Print("Keeping {DifficultyName} with count: {Count}. n is {n}.")
                set n = Count
                set WinningDifficulty=DifficultyName
            else if(Count = 0):
                Print("{DifficultyName} got {Count} votes.")   
        SelectWinner(WinningDifficulty)

    SelectWinner(WinningDifficulty:string):void=
        var WinnerFound:logic=false
        for(DifficultyOption:DifficultyArray,not WinnerFound?):
            if(WinnerDifficulty:=WinningDifficulty,WinnerDifficulty=DifficultyOption.DifficultyName):
                Print("{DifficultyOption.DifficultyName} won!!!")
                set WinnerFound = true
                SetDifficulty(DifficultyOption)
                return
        if(WinnerDifficulty:=DifficultyArray[1]):
            Print("{WinnerDifficulty.DifficultyName} chosen.")
            SetDifficulty(WinnerDifficulty)

    SetDifficulty(SelectedDifficulty:difficulty):void=
        set FinalTimeToExpireOrder = SelectedDifficulty.ExpireOrder
        set DeliverOrderPointsGranting=SelectedDifficulty.DeliverOrderPoints

    SFX():void=
        MusicSlow.Enable()
        AmbientCrowd.Enable()
        BellRing.Enable()
        BellFinal.Enable()
        MusicSlow.Play()
        AmbientCrowd.Play()

    PlayIntro():void=
        IntroCinematic.SetPlaybackFrame(0)
        IntroCinematic.Play()

    SetUpDifficulties():void=
        set Easy.MinAwardingXP=VerySmallXP
        set Easy.MidAwardingXP=SmallXP
        set Easy.MaxAwardingXP=MediumXP
        set Medium.MinAwardingXP=SmallXP
        set Medium.MidAwardingXP=MediumXP
        set Medium.MaxAwardingXP=LargeXP
        set Hard.MinAwardingXP=MediumXP
        set Hard.MidAwardingXP=LargeXP
        set Hard.MaxAwardingXP=VeryLargeXP
        set DifficultyArray=array{Easy,Medium,Hard}
        set CustomUI.MaxPoints=MinPoints

    SetUpItemMeshVFX():void=
        set Plate.Mesh=PlateMesh
        set Plate.MeshFull=PlateMeshFull
        set Plate.MeshDirty=PlateMeshDirty
        set Plate.VFX=PlateVFX
        set Plate.VFXFull=PlateVFXFull
        set Plate.VFXDirty=PlateVFXDirty
        set CookingPot1.SoupMesh=option{Soup}
        set CookingPot1.BellRing=BellRing
        set CookingPot2.BellRing=BellRing
        set CookingPot2.SoupMesh=option{Soup}
        set Carrot.Mesh=CarrotMesh
        set Carrot.MeshChopped=CarrotMeshChopped
        set Carrot.VFX=CarrotVFX
        set Carrot.VFXChopped=CarrotVFXChopped
        set Carrot.IconVFX=option{Niagara.NS_IconCarrot}
        set Chicken.Mesh=ChickenMesh
        set Chicken.MeshChopped=ChickenMeshChopped
        set Chicken.VFX=ChickenVFX
        set Chicken.VFXChopped=ChickenVFXChopped
        set Chicken.IconVFX=option{Niagara.NS_IconChicken}
        set Potato.Mesh=PotatoMesh
        set Potato.MeshChopped=PotatoMeshChopped
        set Potato.VFX=PotatoVFX
        set Potato.VFXChopped=PotatoVFXChopped
        set Potato.IconVFX=option{Niagara.NS_IconPotato}

    EnableButtons():void=
        DropInputTrigger.Enable()
        PickUpInputTrigger.Enable()
        CarrotButton.Enable()
        ChickenButton.Enable()
        PotatoButton.Enable()
        CuttingBoard1Button.Enable()
        CuttingBoard2Button.Enable()
        StoveButton1Button.Enable()
        StoveButton2Button.Enable()
        PlateButton.Enable()
        WaiterDevice.Enable()
        SinkButton.Enable()
        TrashcanButton.Enable()

    ButtonEnabler()<suspends>:void=
        loop:
            if(RoundEnded?):
                break
            if(PlatesTaken<4):
                PlateButton.Enable()
            else if(PlatesTaken>=4):
                PlateButton.Disable()
            if(DirtyPlatesArray.Length>0):
                DirtyPlateButton.Enable()
            else if(DirtyPlatesArray.Length<=0):
                DirtyPlateButton.Disable()
            Sleep(0.5)

    PickUpItem(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player],FortChar:=Agent.GetFortCharacter[],PlayerPosition:=FortChar.GetTransform().Translation):
            var ClosestItemDistance:float=10000.0
            var M:int=-1
            for(N:=0..DroppedItemsArray.Length-1,DroppedItem:=DroppedItemsArray[N],ItemPosition:=DroppedItem.Position,not CustomPlayer.InventoryFull?):
                if(ItemDistance:=Pow((ItemPosition.X - PlayerPosition.X),2.0) + Pow((ItemPosition.Y - PlayerPosition.Y),2.0),ItemDistance<=Pow(PickUpRange,2.0),ItemDistance<ClosestItemDistance):
                    set ClosestItemDistance=ItemDistance
                    set M=N
            if(ClosestItem:=DroppedItemsArray[M].Item,NewDroppedItemsArray:=DroppedItemsArray.RemoveElement[M],set DroppedItemsArray=NewDroppedItemsArray):
                ClosestItem.Dispose()
                CustomPlayer.PickingUpItem(ClosestItem)

    DropItem(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player],Item:=CustomPlayer.ItemCarrying[0]):
            CustomPlayer.DiscardingItem()
            if(FortChar:=Agent.GetFortCharacter[]):
                PlayerPosition := FortChar.GetTransform().Translation
                PlayerForward := FortChar.GetTransform().Rotation.GetLocalForward() * 100.0
                FinalPosition := PlayerPosition + PlayerForward
                PlayerRotation := FortChar.GetTransform().Rotation
                Item.Dropped(FinalPosition,PlayerRotation)
                DroppedItem:dropped_item=dropped_item{Item:=Item,Position:=FinalPosition}
                set DroppedItemsArray+=array{DroppedItem}

    # here we should have a first click to leave the inventory on top of the chopping board and then a second one of a larger duration to chop the item
    ChoppingItemInteraction(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player],Item:=CustomPlayer.ItemCarrying[0]):
            if(Item.Type="Ingredient",IngredientItem:=ingredient[Item]):
                IngredientItem.Chopping()

    CookingPotInteraction(Agent:agent,CookingPot:pot):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player],Item:=CustomPlayer.ItemCarrying[0]):
            if(Item.Type="Ingredient",IngredientItem:=ingredient[Item]):
                IngredientItem.PuttingInPot(CookingPot,CustomPlayer)
            if(Item.Type="Container",PlateItem:=container[Item]):
                for(Ingredient:CookingPot.Contains):
                    Ingredient.PuttingInPlate(CookingPot,PlateItem,CustomPlayer)
                CookingPot.Empty()
                if(Tick:=CookingPot.SpawnedTickVFX?):
                    Tick.Cancel()

    WaiterInteraction(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            if(ItemCarrying:=CustomPlayer.ItemCarrying[0],ItemCarrying.Type="Container",PlateItem:=container[ItemCarrying],PlateItem.Contains.Length=3):
                DeliverOrder(CustomPlayer,PlateItem)

    DeliverOrder(CustomPlayer:custom_player,PlateItem:container):void=
        for(Ingredient:PlateItem.Contains):
            Print(Ingredient.ItemName)
        var FoundOrder:logic=false
        for(M:=0..CustomUI.ArrayOfRecipes.Length-1,ExistingRecipe:=CustomUI.ArrayOfRecipes[M],not FoundOrder?):
            Print("Checkin recipe {M+1}")
            for(Ingredient:ExistingRecipe.Ingredients):
                Print(Ingredient.ItemName)
            var TempPlate:[]ingredient=PlateItem.Contains              
            for(N:=0..ExistingRecipe.Ingredients.Length,Ingredient:=ExistingRecipe.Ingredients[N]):
                Print("On recipe {M+1}, checking recipe ingredient {N+1}: {Ingredient.ItemName}")                    
                for(L:=0..TempPlate.Length-1,TempIngredient:=TempPlate[L]):
                    Print("Comparing recipe ingredient {N+1}, with plate ingredient {L+1}: {TempIngredient.ItemName}")
                    if(Ingredient.ItemName=TempIngredient.ItemName,TempIngredient.Boiled?,not TempIngredient.Burnt?):
                        Print("Ingredient match")
                        if(NewPlate:=TempPlate.RemoveElement[L]):
                            set TempPlate = NewPlate
                if(TempPlate.Length=0):
                    Print("Order delivered!")
                    set FoundOrder = true
                    CustomUI.DisposeRecipe(ExistingRecipe)
                    for(AwardCustomPlayer:CustomUI.PlayerToCustomPlayerMap,AwardPlayer:=AwardCustomPlayer.Player,AwardAgent:=agent[AwardPlayer]):
                        SmallXP.Award(AwardAgent)
                        WaiterDevice.PlayEmote()
                    ScorePoints()
        CustomPlayer.DiscardingItem()
        spawn{DirtingPlate(PlateItem)}
    
    DirtingPlate(PlateItem:container)<suspends>:void=
        Sleep(10.0)
        Height:=(DirtyPlatesArray.Length*10.0)+90.0
        set PlateItem.Dirty=true
        set PlateItem.Contains=array{}
        set DirtyPlatesArray+=array{PlateItem}
        SpawnProp(PlateItem.ItemMesh(),vector3{X:=-250.0,Y:=412.0,Z:=Height},rotation{})  

    DirtyPlate(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player],not CustomPlayer.InventoryFull?):
            if(N:=DirtyPlatesArray.Length-1,TempDirtyPlate:=DirtyPlatesArray[N]):
                CustomPlayer.PickingUpItem(TempDirtyPlate)
                if(NewDirtyPlatesArray:=DirtyPlatesArray.RemoveElement[N],set DirtyPlatesArray=NewDirtyPlatesArray){}

    WashDish(Agent:agent):void=
        Print("Washing dishes...")
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            if(ItemCarrying:=CustomPlayer.ItemCarrying[0],ItemCarrying.Type="Container",PlateItem:=container[ItemCarrying],PlateItem.Dirty?):
                PlateItem.WashDish(CustomPlayer)
                spawn{Bubbles()}
                set PlatesTaken-=1

    Bubbles()<suspends>:void=
        BubblesVFX.Enable()
        Sleep(5.0)
        BubblesVFX.Disable()

    TrashcanInteraction(Agent:agent):void= #if item is plate empty plate
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            if(ItemCarrying:=CustomPlayer.ItemCarrying[0],ItemCarrying.Type="Container",PlateItem:=container[ItemCarrying]):
                PlateItem.Empty()
                return
            CustomPlayer.DiscardingItem()

    ScorePoints():void=
        set PointsGathered+=DeliverOrderPointsGranting
        set CustomUI.Points=PointsGathered
        if(PointsGathered>=MidPoints):
            set CustomUI.MaxPoints=MaxPoints
        else if(PointsGathered>=MinPoints):
            set CustomUI.MaxPoints=MidPoints

    DisableButtons():void=
        DropInputTrigger.Disable()
        PickUpInputTrigger.Disable()
        CarrotButton.Disable()
        ChickenButton.Disable()
        PotatoButton.Disable()
        CuttingBoard1Button.Disable()
        CuttingBoard2Button.Disable()
        StoveButton1Button.Disable()
        StoveButton2Button.Disable()
        PlateButton.Disable()
        WaiterDevice.Disable()
        SinkButton.Disable()
        TrashcanButton.Disable()