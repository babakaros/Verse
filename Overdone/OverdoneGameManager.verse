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
    var CurrentLevel:custom_level=custom_level{
        LevelName:=false
        LevelIcon:=false
        RecipeIcon:=false
        LevelTag:=false
        LevelRandomIngredients:=false
        StandardSlots:=false
        MaxIngredients:=0
        }
    # Difficulty
    Easy:difficulty=difficulty{DifficultyName:="Easy",ExpireOrder:=120.0,DeliverOrderPoints:=150}
    Medium:difficulty=difficulty{DifficultyName:="Medium",ExpireOrder:=90.0,DeliverOrderPoints:=120}
    Hard:difficulty=difficulty{DifficultyName:="Hard",ExpireOrder:=60.0,DeliverOrderPoints:=100}
    @editable VerySmallXP:accolades_device=accolades_device{}
    @editable SmallXP:accolades_device=accolades_device{}
    @editable MediumXP:accolades_device=accolades_device{}
    @editable LargeXP:accolades_device=accolades_device{}
    @editable VeryLargeXP:accolades_device=accolades_device{}
    var FinalTimeToExpireOrder:float=0.0
    
    MaxPoints:int=750
    MidPoints:int=600
    MinPoints:int=450

    var AwardMaxXP:accolades_device=accolades_device{}
    var AwardMidXP:accolades_device=accolades_device{}
    var AwardMinXP:accolades_device=accolades_device{}

    Nothing:item=item{ItemName:="Null"}
    # Ingredients
    Carrot:ingredient=ingredient{
        ItemName:= "Carrot"
        ItemIcon:=Icons.IC_Carrot
        ItemChoppable:=true
        ItemBoilable:=true
        MeshChopped:=DefaultCreativePropAsset
        VFXChopped:=visual_effect_powerup_device{}}
    Chicken:ingredient=ingredient{
        ItemName:= "Chicken"
        ItemIcon:=Icons.IC_Chicken
        ItemChoppable:=true
        ItemBoilable:=true
        MeshChopped:=DefaultCreativePropAsset
        VFXChopped:=visual_effect_powerup_device{}}
    Cucumber:ingredient=ingredient{
        ItemName:= "Cucumber"
        ItemIcon:=Icons.IC_Cucumber
        ItemChoppable:=true
        ItemBoilable:=false
        MeshChopped:=DefaultCreativePropAsset
        VFXChopped:=visual_effect_powerup_device{}}
    Potato:ingredient=ingredient{
        ItemName:= "Potato"
        ItemIcon:=Icons.IC_Potato
        ItemChoppable:=true
        ItemBoilable:=true
        MeshChopped:=DefaultCreativePropAsset
        VFXChopped:=visual_effect_powerup_device{}}
    Seaweed:ingredient=ingredient{
        ItemName:= "Seaweed"
        ItemIcon:=Icons.IC_Seaweed
        ItemChoppable:=false
        ItemBoilable:=false
        Prepared:=true
        MeshChopped:=DefaultCreativePropAsset
        VFXChopped:=visual_effect_powerup_device{}}
    Rice:ingredient=ingredient{
        ItemName:= "Rice"
        ItemIcon:=Icons.IC_Rice
        ItemChoppable:=false
        ItemBoilable:=true
        MeshChopped:=DefaultCreativePropAsset
        VFXChopped:=visual_effect_powerup_device{}}
    Fish:ingredient=ingredient{
        ItemName:= "Fish"
        ItemIcon:=Icons.IC_Fish
        ItemChoppable:=true
        ItemBoilable:=false
        MeshChopped:=DefaultCreativePropAsset
        VFXChopped:=visual_effect_powerup_device{}}
    
    # Containers
    Plate:container=container{ItemName:="Plate",Deliverable:=true}
    CookingPot1:pot=pot{ItemName:="Cooking Pot",Deliverable:=false,Position:=vector3{X:=76.0,Y:=126.0,Z:=95.0},SoupMesh:=false}
    CookingPot2:pot=pot{ItemName:="Cooking Pot",Deliverable:=false,Position:=vector3{X:=374.0,Y:=78.0,Z:=95.0},SoupMesh:=false}
    CookingPot3:pot=pot{ItemName:="Camping Stove",Deliverable:=false,Position:=vector3{X:=19756.27,Y:=54.9,Z:=274.0},SoupMesh:=false,Size:=1,BoilTime:=4.0}
    CookingPot4:pot=pot{ItemName:="Camping Stove",Deliverable:=false,Position:=vector3{X:=19869.73,Y:=57.8,Z:=274.0},SoupMesh:=false,Size:=1,BoilTime:=4.0}
    # Props / VFX
    @editable CarrotMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable CarrotMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable CarrotVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CarrotVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable ChickenMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable ChickenMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable ChickenVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable ChickenVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CucumberMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable CucumberMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable CucumberVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CucumberVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable FishMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable FishMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable FishVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable FishVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PotatoMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable PotatoMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable PotatoVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PotatoVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable RiceMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable RiceMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable RiceVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable RiceVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable SeaweedMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable SeaweedMeshChopped:creative_prop_asset = DefaultCreativePropAsset
    @editable SeaweedVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable SeaweedVFXChopped:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PlateMesh:creative_prop_asset = DefaultCreativePropAsset
    @editable PlateMeshFull:creative_prop_asset = DefaultCreativePropAsset
    @editable PlateMeshFullSushi:creative_prop_asset = DefaultCreativePropAsset
    @editable PlateMeshDirty:creative_prop_asset = DefaultCreativePropAsset
    @editable PlateVFX:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PlateVFXFullSoup:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PlateVFXFullSushi:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable PlateVFXDirty:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable Soup:creative_prop_asset = DefaultCreativePropAsset
    @editable RiceBoiling:creative_prop_asset = DefaultCreativePropAsset
    @editable BubblesVFX:vfx_spawner_device=vfx_spawner_device{}
    @editable ClearVFXTrigger:trigger_device=trigger_device{}
    # Extra Functionality
    var DroppedItemsArray:[]dropped_item=array{}
    var PlatesTaken:int=0
    var DirtyPlatesArray:[]container=array{}
    # Devices to interact with
    @editable DropInputTrigger:input_trigger_device = input_trigger_device{}
    @editable PickUpInputTrigger:input_trigger_device = input_trigger_device{}
    var PlateButton : button_device = button_device{}
    var DirtyPlateButton : button_device = button_device{}
    var WaiterDevice : character_device = character_device{}
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
    # Point System
    var PointsGathered:int=0
    var DeliverOrderPointsGranting:int=0
    
    OnBegin<override>()<suspends>:void=
        Print("Game Started")
        SFX()
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        InitSpawners()
        PlayIntro()
        InitLevels()
        InitDifficulties()
        Sleep(1.0)
        set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
        CustomUI.Assign()
        Sleep(3.0)
        VotingUIs()
        CustomUI.CountdownEndedEvent.Await()
        CustomUI.RemoveSomeHUDS(array{2,3})
        CountLevelVotes(CustomUI.PlayerLevelVotes,CustomUI.WidgetToLevelMap,CustomUI.SelectedLevels)
        CountDifficultyVotes(CustomUI.PlayerDifficultyVotes)
        Sleep(1.0)
        CustomUI.ShowInventoryTextUI(false,4,false)
        CustomUI.ShowPointSystemUI(false,5,false,450)
        spawn{CustomUI.OrderFood(false,6,false,CurrentLevel.TrueLevelRandomIngredients,CurrentLevel.StandardSlots,CurrentLevel.MaxIngredients,CurrentLevel.TrueRecipeIcon,20.0,FinalTimeToExpireOrder)}
        GameTimer.SetActiveDuration(GameTotalTime)
        GameTimer.Start()
        SetUpItemMeshVFX()
        spawn{ButtonEnabler()}
        ButtonFunctionality()
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

    VotingUIs()<suspends>:void=
        CustomUI.ShowLevelVoteUI(true,1,false) 
        CustomUI.CountdownHalfTimeEvent.Await()
        CustomUI.RemoveSomeHUDS(array{1})
        CustomUI.ShowDifficultyVoteUI(true,2,false)

    CountLevelVotes(WhatEachPlayerVotedMap:[player]widget,WidgetToLevelMap:[widget]custom_level,SelectedLevelModes:[]custom_level):void=
        var VoteCountMap:[string]int=map{}
        var VoteCountArray:[]int=array{}
        var WinningLevel:string=""
        var n :int=0
        var m:int=0
        Print("Starting counting votes...")
        for(Player->Widget:WhatEachPlayerVotedMap,LevelMode:=WidgetToLevelMap[Widget]):
            Print("Checking player votes...")
            if(M:=VoteCountMap[LevelMode.LevelName],set m=M):
                set m+=1
                if(Name:=LevelMode.LevelName?,set VoteCountMap[Name]=m):
                    Print("Vote towards {Name} counted.")
            else:
                if(Name:=LevelMode.LevelName?,set VoteCountMap[Name]=1):
                    Print("No vote towards {Name} before, counting first vote.")
        for(LevelName->Count:VoteCountMap):
            if(Count>=n):
                Print("Keeping {LevelName} with count: {Count}. n is {n}.")
                set n = Count
                set WinningLevel=LevelName
            else if(Count = 0):
                Print("{LevelName} got 0 votes.")
            else:
                Print("{LevelName} got less votes than another one.")    
        SelectLevelWinner(WinningLevel,SelectedLevelModes)

    SelectLevelWinner(WinningLevelName:string,SelectedLevels:[]custom_level):void=
        var WinnerFound:logic=false
        for(SelectedLevel:SelectedLevels,not WinnerFound?):
            if(Name:=SelectedLevel.LevelName?,WinningLevelName=Name):
                Print("{Name} won!!!")
                set WinnerFound = true
                SetLevel(SelectedLevel)
                return
        n:=GetRandomInt(0,1)
        Print("{n} selected.")
        if(WinnerLevel:=SelectedLevels[n],Name:=WinnerLevel.LevelName?):
            Print("{Name} chosen.")
            SetLevel(WinnerLevel)

    SetLevel(SelectedLevel:custom_level):void=
        set CurrentLevel=SelectedLevel
        SelectedLevel.Start()
        for(CustomPlayer:CustomPlayers,Player:=CustomPlayer.Player,Agent:=agent[Player]):
            SelectedLevel.Teleporter.Teleport(Agent)

    CountDifficultyVotes(WhatEachPlayerVotedMap:[player]difficulty):void=
        var VoteCountMap:[string]int=map{}
        var m:int=0
        var n :int=0
        var WinningDifficulty:string=""
        Print("Counting difficulty votes")
        for(Player->DifficultySelected:WhatEachPlayerVotedMap):
            Print("First ok")
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
        Print("Difficulty votes counted") 
        SelectDifficultyWinner(WinningDifficulty)

    SelectDifficultyWinner(WinningDifficulty:string):void=
        var WinnerFound:logic=false
        Print("Selecting Difficulty Winner")
        for(DifficultyOption:CustomUI.DifficultyArray,not WinnerFound?):
            if(WinnerDifficulty:=WinningDifficulty,WinnerDifficulty=DifficultyOption.DifficultyName):
                Print("{DifficultyOption.DifficultyName} won!!!")
                set WinnerFound = true
                SetDifficulty(DifficultyOption)
                return
        if(WinnerDifficulty:=CustomUI.DifficultyArray[1]):
            Print("{WinnerDifficulty.DifficultyName} chosen.")
            SetDifficulty(WinnerDifficulty)

    SetDifficulty(SelectedDifficulty:difficulty):void=
        Print("Adjusting difficulties")
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

    InitLevels():void=
        Print("")
        Level1:custom_level=custom_level{
            LevelName:=option{"Level 1: The Basics"}
            LevelIcon:=option{Icons.IC_Level1}
            RecipeIcon:=option{Icons.IC_Pot}
            LevelTag:=option{level1{}}
            LevelRandomIngredients:=option{array{Carrot,Chicken,Potato}}
            StandardSlots:=false
            MaxIngredients:=3
            }
        Level2:custom_level=custom_level{
            LevelName:=option{"Level 2: Deep Dive"}
            LevelIcon:=option{Icons.IC_Level2}
            RecipeIcon:=option{Icons.IC_Sushi}
            LevelTag:=option{level2{}}
            LevelRandomIngredients:=option{array{Fish,Cucumber}}
            StandardSlots:=option{array{Seaweed,Rice}}
            MaxIngredients:=3
            }
        set CustomUI.Levels=array{Level1,Level2}

    InitDifficulties():void=
        set Easy.MinAwardingXP=VerySmallXP
        set Easy.MidAwardingXP=SmallXP
        set Easy.MaxAwardingXP=MediumXP
        set Medium.MinAwardingXP=SmallXP
        set Medium.MidAwardingXP=MediumXP
        set Medium.MaxAwardingXP=LargeXP
        set Hard.MinAwardingXP=MediumXP
        set Hard.MidAwardingXP=LargeXP
        set Hard.MaxAwardingXP=VeryLargeXP
        set CustomUI.DifficultyArray=array{Easy,Medium,Hard}
        set CustomUI.MaxPoints=MinPoints

    SetUpItemMeshVFX():void=
        set Plate.Mesh=PlateMesh
        if(Name:=CurrentLevel.LevelName?,Name="Level 1: The Basics"):
            set Plate.MeshFull=PlateMeshFull
        else:
            set Plate.MeshFull=PlateMeshFullSushi
        set Plate.MeshDirty=PlateMeshDirty
        set Plate.VFX=PlateVFX
        if(LevelTag:=CurrentLevel.LevelTag?):
            TaggedDevices:=GetCreativeObjectsWithTag(LevelTag)
            for(Device:TaggedDevices):
                DeviceTags:=Device.GetTags()
                if(FullPlateVFX:=visual_effect_powerup_device[Device]):
                    set Plate.VFXFull=FullPlateVFX
        set Plate.VFXDirty=PlateVFXDirty
        set CookingPot1.SoupMesh=option{Soup}
        set CookingPot1.BellRing=BellRing
        set CookingPot2.SoupMesh=option{Soup}
        set CookingPot2.BellRing=BellRing
        set CookingPot3.SoupMesh=option{RiceBoiling}
        set CookingPot3.BellRing=BellRing
        set CookingPot4.SoupMesh=option{RiceBoiling}
        set CookingPot4.BellRing=BellRing
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
        set Cucumber.Mesh=CucumberMesh
        set Cucumber.MeshChopped=CucumberMeshChopped
        set Cucumber.VFX=CucumberVFX
        set Cucumber.VFXChopped=CucumberVFXChopped
        set Cucumber.IconVFX=option{Niagara.NS_IconCarrot}
        set Fish.Mesh=FishMesh
        set Fish.MeshChopped=FishMeshChopped
        set Fish.VFX=FishVFX
        set Fish.VFXChopped=FishVFXChopped
        set Fish.IconVFX=option{Niagara.NS_IconCarrot}
        set Potato.Mesh=PotatoMesh
        set Potato.MeshChopped=PotatoMeshChopped
        set Potato.VFX=PotatoVFX
        set Potato.VFXChopped=PotatoVFXChopped
        set Potato.IconVFX=option{Niagara.NS_IconPotato}
        set Rice.Mesh=RiceMesh
        set Rice.MeshChopped=RiceMeshChopped
        set Rice.VFX=RiceVFX
        set Rice.VFXChopped=RiceVFXChopped
        set Rice.IconVFX=option{Niagara.NS_IconPotato}
        set Seaweed.Mesh=SeaweedMesh
        set Seaweed.MeshChopped=SeaweedMeshChopped
        set Seaweed.VFX=SeaweedVFX
        set Seaweed.VFXChopped=SeaweedVFXChopped
        set Seaweed.IconVFX=option{Niagara.NS_IconPotato}

    ButtonEnabler()<suspends>:void=
        DropInputTrigger.Enable()
        PickUpInputTrigger.Enable()
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

    ButtonFunctionality():void=
        DropInputTrigger.PressedEvent.Subscribe(DropItem)
        PickUpInputTrigger.PressedEvent.Subscribe(PickUpItem)
        TaggedDevices:=GetCreativeObjectsWithTag(buttondevice{})
        for(Device:TaggedDevices):
            DeviceTags:=Device.GetTags()
            if(DeviceTags.Has[carrot{}],ButtonCarrot:=button_device[Device]):
                ButtonCarrot.Enable()
                ButtonCarrot.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Carrot}.HandlerFunction)
            if(DeviceTags.Has[chicken{}],ButtonChicken:=button_device[Device]):
                ButtonChicken.Enable()
                ButtonChicken.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Chicken}.HandlerFunction)
            if(DeviceTags.Has[cucumber{}],ButtonCucumber:=button_device[Device]):
                ButtonCucumber.Enable()
                ButtonCucumber.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Cucumber}.HandlerFunction)
            if(DeviceTags.Has[potato{}],ButtonPotato:=button_device[Device]):
                ButtonPotato.Enable()
                ButtonPotato.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Potato}.HandlerFunction)
            if(DeviceTags.Has[rice{}],ButtonRice:=button_device[Device]):
                ButtonRice.Enable()
                ButtonRice.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Rice}.HandlerFunction)
            if(DeviceTags.Has[seaweed{}],ButtonSeaweed:=button_device[Device]):
                ButtonSeaweed.Enable()
                ButtonSeaweed.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Seaweed}.HandlerFunction)
            if(DeviceTags.Has[fishzone{}],ButtonFishZone:=fishing_zone_device[Device]):
                ButtonFishZone.Enable()
                ButtonFishZone.CaughtEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Fish}.HandlerFunction)
            if(DeviceTags.Has[cuttingboard{}],ButtonCuttingBoard:=button_device[Device]):
                ButtonCuttingBoard.Enable()
                ButtonCuttingBoard.InteractedWithEvent.Subscribe(ChoppingItemInteraction)
            if(DeviceTags.Has[stove{}],Stove:=button_device[Device]):
                Stove.Enable()
                if(DeviceTags.Has[pot1{}],ButtonStove1:=button_device[Device]):
                    ButtonStove1.InteractedWithEvent.Subscribe(CookingPotInteraction_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,CookingPot:=CookingPot1}.HandlerFunction)
                if(DeviceTags.Has[pot2{}],ButtonStove2:=button_device[Device]):
                    ButtonStove2.InteractedWithEvent.Subscribe(CookingPotInteraction_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,CookingPot:=CookingPot2}.HandlerFunction)
                if(DeviceTags.Has[pot3{}],ButtonStove3:=button_device[Device]):
                    ButtonStove3.InteractedWithEvent.Subscribe(CookingPotInteraction_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,CookingPot:=CookingPot3}.HandlerFunction)
                if(DeviceTags.Has[pot4{}],ButtonStove4:=button_device[Device]):
                    ButtonStove4.InteractedWithEvent.Subscribe(CookingPotInteraction_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,CookingPot:=CookingPot4}.HandlerFunction)
            if(DeviceTags.Has[cleanplate{}],ButtonCleanPlate:=button_device[Device]):
                ButtonCleanPlate.Enable()
                ButtonCleanPlate.InteractedWithEvent.Subscribe(NewItemPickup_Handler{Device:=Self,CustomPlayerArray:=CustomPlayers,Item:=Plate}.HandlerFunction)
            if(DeviceTags.Has[dirtyplate{}],ButtonDirtyPlate:=button_device[Device]):
                ButtonDirtyPlate.Enable()
                ButtonDirtyPlate.InteractedWithEvent.Subscribe(DirtyPlate)
            if(DeviceTags.Has[sink{}],ButtonSink:=button_device[Device]):
                ButtonSink.Enable()
                ButtonSink.InteractedWithEvent.Subscribe(WashDish)
            if(DeviceTags.Has[trashcan{}],ButtonTrashCan:=button_device[Device]):
                ButtonTrashCan.Enable()
                ButtonTrashCan.InteractedWithEvent.Subscribe(TrashcanInteraction)
            if(DeviceTags.Has[waiter{}],DeviceWaiter:=character_device[Device]):
                if(LevelTag:=CurrentLevel.LevelTag?,DeviceTags.Has[LevelTag]):
                    set WaiterDevice=DeviceWaiter
                DeviceWaiter.InteractedWithEvent.Subscribe(WaiterInteraction)

    PickUpItem(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player],FortChar:=Agent.GetFortCharacter[],PlayerPosition:=FortChar.GetTransform().Translation):
            var ClosestItemDistance:float=10000.0
            var M:int=-1
            for(N:=0..DroppedItemsArray.Length-1,DroppedItem:=DroppedItemsArray[N],ItemPosition:=DroppedItem.Position,not CustomPlayer.InventoryFull? or (ContainerCarrying:=CustomPlayer.ItemCarrying[0],CarryingPlate:=container[ContainerCarrying])):
                if(ItemDistance:=Pow((ItemPosition.X - PlayerPosition.X),2.0) + Pow((ItemPosition.Y - PlayerPosition.Y),2.0),ItemDistance<=Pow(PickUpRange,2.0),ItemDistance<ClosestItemDistance):
                    set ClosestItemDistance=ItemDistance
                    set M=N
            if(ClosestItem:=DroppedItemsArray[M].Item):
                ItemPickedUp:=CustomPlayer.PickingUpItem(ClosestItem)
                if(ItemPickedUp?,NewDroppedItemsArray:=DroppedItemsArray.RemoveElement[M],set DroppedItemsArray=NewDroppedItemsArray){}

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
                if(IngredientItem.ItemBoilable?,IngredientItem.Chopped? or not IngredientItem.ItemChoppable?):
                    CookingPot.Fill(array{IngredientItem},CustomPlayer)
            if(Item.Type="Container",PlateItem:=container[Item]):
                for(Ingredient:CookingPot.Contains):
                    PlateItem.Fill(CookingPot.Contains,CustomPlayer)
                CookingPot.Empty()
                if(Tick:=CookingPot.SpawnedTickVFX?):
                    Tick.Cancel()

    WaiterInteraction(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            if(ItemCarrying:=CustomPlayer.ItemCarrying[0],PlateItem:=container[ItemCarrying],PlateItem.Contains.Length=PlateItem.Size):
                DeliverOrder(CustomPlayer,PlateItem)

    DeliverOrder(CustomPlayer:custom_player,PlateItem:container):void=
        var FoundOrder:logic=false
        for(K:=0..CustomUI.ArrayOfRecipes.Length-1,OrderRecipe:=CustomUI.ArrayOfRecipes[K],not FoundOrder?):
            var TempPlate:[int]ingredient=map{}
            for(L:=0..PlateItem.Contains.Length-1,PlateIngredient:=PlateItem.Contains[L]):
                if(set TempPlate[L]=PlateIngredient){}
            for(M:=0..OrderRecipe.Ingredients.Length,Ingredient:=OrderRecipe.Ingredients[M]):
                var SecondTempPlate:[int]ingredient=map{}
                var IngredientMatch:logic=false
                for(Spot->PlateIngredient:TempPlate,not IngredientMatch?):
                    if(Ingredient.ItemName=PlateIngredient.ItemName,PlateIngredient.Prepared?,not PlateIngredient.Overcooked?):
                        if(set SecondTempPlate[Spot]=PlateIngredient){}
                        set IngredientMatch=true
                for(Spot->PlateIngredient:SecondTempPlate):
                    var NewTempPlate:[int]ingredient=map{}
                        for(Key->Value:TempPlate,Key<>Spot):
                            set NewTempPlate=ConcatenateMaps(NewTempPlate,map{Key=>Value})
                        set TempPlate=NewTempPlate
            if(TempPlate.Length=0):
                set FoundOrder = true
                CustomUI.DisposeRecipe(OrderRecipe)
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

    TrashcanInteraction(Agent:agent):void=
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

    CompleteRound(Agent:?agent):void=
        Print("Round completed, counting game.")
        set RoundEnded=true
        BellFinal.Play()
        DisableButtons()
        CookingPot1.Empty()
        CookingPot2.Empty()
        CookingPot3.Empty()
        CookingPot4.Empty()
        CustomUI.AnounceScore(PointsGathered)
        for(DroppedItem:DroppedItemsArray,Item:=DroppedItem.Item):
            Item.Dispose()
        set DroppedItemsArray=array{}
        for(AwardCustomPlayer:CustomPlayers,AwardPlayer:=AwardCustomPlayer.Player,AwardAgent:=agent[AwardPlayer]):
            if(PointsGathered>MaxPoints):
                AwardMaxXP.Award(AwardAgent)
            else if(PointsGathered>MidPoints):
                AwardMidXP.Award(AwardAgent)
            else if(PointsGathered>MinPoints):
                AwardMinXP.Award(AwardAgent)
        for(Player:CustomPlayers):
            Player.DiscardingItem()
            set Player.GamesPlayed+=1
        if(IsAgent:=Agent?):
            spawn{End(IsAgent)}
        
    End(Agent:agent)<suspends>:void=
        Sleep(10.0)
        EndGameDevice.Activate(Agent)

    DisableButtons():void=
        TaggedDevices:=GetCreativeObjectsWithTag(buttondevice{})
        for(Device:TaggedDevices):
            if(Button:=button_device[Device]) then Button.Disable()
