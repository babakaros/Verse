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
    
    var CustomPlayers:[player]custom_player=map{}
    var CustomUI:custom_ui_creator=custom_ui_creator{PlayerToCustomPlayerMap:=map{}}
    #var SavedPlayerCustomPlayer:weak_map(player,custom_player)=map{}

    var GlassesArray:[]glasses=array{}
    @editable VFXGlasses00:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses01:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses01:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses02:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses02:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses03:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses03:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses04:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses04:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses05:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses05:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses06:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses06:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses07:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses07:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses08:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses08:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses09:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses09:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses10:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses10:visual_effect_powerup_device=visual_effect_powerup_device{}
    @editable CollectibleGlasses11:collectible_object_device=collectible_object_device{}
    @editable VFXGlasses11:visual_effect_powerup_device=visual_effect_powerup_device{}

    @editable Ouji:character_device=character_device{}
    @editable Dialog1:popup_dialog_device=popup_dialog_device{}
    @editable Dialog2:popup_dialog_device=popup_dialog_device{}
    @editable Dialog3:popup_dialog_device=popup_dialog_device{}
    @editable Barrier:barrier_device=barrier_device{}

    @editable PickaxeTrigger:input_trigger_device=input_trigger_device{}
    @editable GlassPreviewer:cinematic_sequence_device=cinematic_sequence_device{}

    @editable AccoladeSmall:accolades_device=accolades_device{}
    @editable AccoladeMedium:accolades_device=accolades_device{}
    @editable AccoladeLarge:accolades_device=accolades_device{}

    @editable EndGame:end_game_device=end_game_device{}
        
    OnBegin<override>()<suspends>:void=
        Print("Game Started")
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        InitSpawners()
        Sleep(1.0)
        set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
        CustomUI.Assign()
        Sleep(1.0)
        GlassesInit()
        set CustomUI.GlassPreviewer=GlassPreviewer
        set CustomUI.GlassesArray=GlassesArray
        Ouji.InteractedWithEvent.Subscribe(OujiInteraction)
        Dialog1.DismissedEvent.Subscribe(ShowInventory)
        PickaxeTrigger.PressedEvent.Subscribe(OpenInventoryMenu)
        CollectibleGlasses01.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=1}.HandlerFunction)
        CollectibleGlasses02.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=2}.HandlerFunction)
        CollectibleGlasses03.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=3}.HandlerFunction)
        CollectibleGlasses04.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=4}.HandlerFunction)
        CollectibleGlasses05.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=5}.HandlerFunction)
        CollectibleGlasses06.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=6}.HandlerFunction)
        CollectibleGlasses07.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=7}.HandlerFunction)
        CollectibleGlasses08.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=8}.HandlerFunction)
        CollectibleGlasses09.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=9}.HandlerFunction)
        CollectibleGlasses10.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=10}.HandlerFunction)
        CollectibleGlasses11.CollectedEvent.Subscribe(Collectible_Handler{Device:=Self,N:=11}.HandlerFunction)
        Dialog3.RespondingButtonEvent.Subscribe(MaybeReset)

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
            if(not CustomPlayers[Player]):
                Print("Adding player to map...")
                if:
                    #not SavedPlayerCustomPlayer[Player]
                    CustomPlayer:=custom_player{Player:=Player}
                    #set SavedPlayerCustomPlayer[Player]=CustomPlayer
                    set CustomPlayers[Player]=CustomPlayer
                then:
                    CustomPlayer.Init()
                <#else if:
                    SavedCustomPlayer:=SavedPlayerCustomPlayer[Player]
                    set CustomPlayers[Player]=SavedCustomPlayer
                then:
                    SavedCustomPlayer.Init()#>
                
    OnPlayerLeftServer(PlayerLeaving:player):void=
        if(CustomPlayer:=CustomPlayers[PlayerLeaving]):
            CustomPlayer.Dispose()
            var NewCustomPlayerMap:[player]custom_player=map{}
            for(Key->Value:CustomPlayers,Key<>PlayerLeaving):
                set NewCustomPlayerMap=ConcatenateMaps(NewCustomPlayerMap,map{Key=>Value})
            set CustomPlayers=NewCustomPlayerMap
    
    GlassesInit():void=
        Glasses00:glasses=glasses{GlassesName:="White",VFX:=VFXGlasses00,Frame:=0,Thumbnail:=Icons.IC_GlassesWhite,GlassPreviewer:=GlassPreviewer,Collectible:=collectible_object_device{}}#White
        Glasses01:glasses=glasses{GlassesName:="Black",VFX:=VFXGlasses05,Frame:=300,Thumbnail:=Icons.IC_GlassesBlack,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses01}#Black
        Glasses02:glasses=glasses{GlassesName:="TransClear",VFX:=VFXGlasses06,Frame:=360,Thumbnail:=Icons.IC_GlassesClear,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses02}#TransClear
        Glasses03:glasses=glasses{GlassesName:="Trans",VFX:=VFXGlasses01,Frame:=120,Thumbnail:=Icons.IC_GlassesTransclucent,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses03}#Trans
        Glasses04:glasses=glasses{GlassesName:="TransGreen",VFX:=VFXGlasses03,Frame:=180,Thumbnail:=Icons.IC_GlassesGreen,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses04}#TransGreen
        Glasses05:glasses=glasses{GlassesName:="TransOrange",VFX:=VFXGlasses04,Frame:=240,Thumbnail:=Icons.IC_GlassesOrange,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses05}#TransOrange
        Glasses06:glasses=glasses{GlassesName:="TransRed",VFX:=VFXGlasses07,Frame:=420,Thumbnail:=Icons.IC_GlassesRed,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses06}#TransRed
        Glasses07:glasses=glasses{GlassesName:="TransBlue",VFX:=VFXGlasses08,Frame:=480,Thumbnail:=Icons.IC_GlassesBlue,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses07}#TransBlue
        Glasses08:glasses=glasses{GlassesName:="Silver",VFX:=VFXGlasses02,Frame:=60,Thumbnail:=Icons.IC_GlassesSilver,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses08}#Silver
        Glasses09:glasses=glasses{GlassesName:="Bronze",VFX:=VFXGlasses09,Frame:=540,Thumbnail:=Icons.IC_GlassesBronze,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses09}#Bronze
        Glasses10:glasses=glasses{GlassesName:="Gold",VFX:=VFXGlasses10,Frame:=600,Thumbnail:=Icons.IC_GlassesGold,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses10}#Gold
        Glasses11:glasses=glasses{GlassesName:="Galaxy",VFX:=VFXGlasses11,Frame:=660,Thumbnail:=Icons.IC_GlassesGalaxy,GlassPreviewer:=GlassPreviewer,Collectible:=CollectibleGlasses11}#Galaxy
        set GlassesArray=array{Glasses00,Glasses01,Glasses02,Glasses03,Glasses04,Glasses05,Glasses06,Glasses07,Glasses08,Glasses09,Glasses10,Glasses11}
        for(CustomPlayer:CustomPlayers):
            for(Glass:CustomPlayer.GlassesFound):
                for(Pair:GlassesArray):
                    if(Glass.GlassesName=Pair.GlassesName):
                        set Pair.Found=true
                        Pair.Collectible.Hide()

    UISetUp(UI:custom_ui_creator,PlayerToCanvasMap:[player][int]?canvas):void=
        set UI.PlayerToCustomPlayerMap=CustomPlayers
        set UI.PlayerToCanvasMap=PlayerToCanvasMap
    
    OujiInteraction(Agent:agent):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            if(not CustomPlayer.HasSpokenToOuji?):
                Dialog1.Show(Agent)
                set CustomPlayer.HasSpokenToOuji=true
            else:
                if(CustomPlayer.GlassesFound.Length<12):
                    Dialog2.Show(Agent)
                else:
                    Dialog3.Show(Agent)

    ShowInventory(Agent:agent):void=
        GlassCollected(Agent,0)
        VFXGlasses00.Pickup(Agent)
        CustomUI.ShowInventoryTextUI(false,1,option{Agent})
        PickaxeTrigger.Enable()
        Barrier.Disable()

    OpenInventoryMenu(Agent:agent):void=
        CustomUI.ShowInventoryMenuUI(true,2,option{Agent})

    GlassCollected(Agent:agent,N:int):void=
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            AccoladeSmall.Award(Agent)
            if(Glass:=GlassesArray[N]):
                set Glass.Found=true
                set CustomPlayer.GlassesFound+=array{Glass}
            if(CustomPlayer.GlassesFound.Length=12):
                AccoladeLarge.Award(Agent)

    MaybeReset(Agent:agent,Button:int):void=
        if(Button=0):
            Print("Cool")
        if(Button=1):
            for(Pair:GlassesArray):
                set Pair.Found=false
            if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
                set CustomPlayer.HasSpokenToOuji=false
            EndGame.Activate(Agent)
