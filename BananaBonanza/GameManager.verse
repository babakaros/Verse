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

var SavedPlayerData:weak_map(player, saved_data) = map{}

Game_Manager := class(creative_device):

    ## Variables ## 
    var CustomUI:custom_ui_creator=custom_ui_creator{PlayerToCustomPlayerMap:=map{},RealTimeProp:=false}
    var CustomPlayers:[player]custom_player=map{}
    var LevelsToArrayCustomPlayersMap:[custom_level][]custom_player=map{}
    var GameRunning:logic=false
    var StartingItems:[]item=array{}
    var AllItems:[]item=array{}
    var StartingAbilities:[]item=array{}

    ## Type Casting ##
    IntToMessage<localizes>(I:int):message="{I}"
    StringToMessage<localizes>(S:string):message="{S}"

    ## Editables ## 
    @editable RealTimeProp:creative_prop=creative_prop{}
    @editable IntroCinematic:cinematic_sequence_device=cinematic_sequence_device{}
    @editable BasementPulse:objective_device=objective_device{}
    @editable ShopPulse:objective_device=objective_device{}
    @editable ClearInventory:item_remover_device=item_remover_device{}
    @editable ItemShopButton:button_device=button_device{}
    @editable BackInput:input_trigger_device=input_trigger_device{}
    @editable EndGameMessage:hud_message_device=hud_message_device{}
    @editable EndGameDialog:popup_dialog_device=popup_dialog_device{}

    ## Currency functionality ##
    @editable CurrencyCheck:conditional_button_device=conditional_button_device{}
    @editable CurrencyGranter:item_granter_device=item_granter_device{}
    @editable CurrencyRemover:item_remover_device=item_remover_device{}

    ## Rarities ##
    Common:rarity=rarity{Order:=1, BGIcon:= Icons.IC_V1_BG}
    Uncommon:rarity=rarity{Order:=2, BGIcon:= Icons.IC_V2_BG}
    Rare:rarity=rarity{Order:=3, BGIcon:= Icons.IC_V3_BG}
    Epic:rarity=rarity{Order:=4, BGIcon:= Icons.IC_V4_BG}
    Legendary:rarity=rarity{Order:=5, BGIcon:= Icons.IC_V5_BG}
    Exotic:rarity=rarity{Order:=6, BGIcon:= Icons.IC_V6_BG}
    Mythic:rarity=rarity{Order:=7, BGIcon:= Icons.IC_V7_BG}


    ### Item Granters ###
    #Pistol
    #Tactical Pistol
    @editable Pistol_Tactical_Common:item_granter_device=item_granter_device{}
    @editable Pistol_Tactical_Uncommon:item_granter_device=item_granter_device{}
    @editable Pistol_Tactical_Rare:item_granter_device=item_granter_device{}
    @editable Pistol_Tactical_Epic:item_granter_device=item_granter_device{}
    @editable Pistol_Tactical_Legendary:item_granter_device=item_granter_device{}
    #SMG
    #Combat SMG
    @editable SMG_Recoil_Common:item_granter_device=item_granter_device{}
    @editable SMG_Recoil_Uncommon:item_granter_device=item_granter_device{}
    @editable SMG_Recoil_Rare:item_granter_device=item_granter_device{}
    @editable SMG_Recoil_Epic:item_granter_device=item_granter_device{}
    @editable SMG_Recoil_Legendary:item_granter_device=item_granter_device{}
    #Shotgun
    #Auto Shotgun
    @editable Shotgun_CoreDPS_Common:item_granter_device=item_granter_device{}
    @editable Shotgun_CoreDPS_Uncommon:item_granter_device=item_granter_device{}
    @editable Shotgun_CoreDPS_Rare:item_granter_device=item_granter_device{}
    @editable Shotgun_CoreDPS_Epic:item_granter_device=item_granter_device{}
    @editable Shotgun_CoreDPS_Legendary:item_granter_device=item_granter_device{}
    #Assault Rifle
    #Assault Auto
    @editable Assault_Auto_Common:item_granter_device=item_granter_device{}
    @editable Assault_Auto_Uncommon:item_granter_device=item_granter_device{}
    @editable Assault_Auto_Rare:item_granter_device=item_granter_device{}
    @editable Assault_Auto_Epic:item_granter_device=item_granter_device{}
    @editable Assault_Auto_Legendary:item_granter_device=item_granter_device{}
    #Sniper
    #Hunter Bolt Action Sniper
    @editable Hunter_Bolt_Action_Sniper_Common:item_granter_device=item_granter_device{}
    @editable Hunter_Bolt_Action_Sniper_Uncommon:item_granter_device=item_granter_device{}
    @editable Hunter_Bolt_Action_Sniper_Rare:item_granter_device=item_granter_device{}
    @editable Hunter_Bolt_Action_Sniper_Epic:item_granter_device=item_granter_device{}
    @editable Hunter_Bolt_Action_Sniper_Legendary:item_granter_device=item_granter_device{}
    #RPG
    #Rocket Launcher
    @editable Rocket_Launcher_Common:item_granter_device=item_granter_device{}
    @editable Rocket_Launcher_Uncommon:item_granter_device=item_granter_device{}
    @editable Rocket_Launcher_Rare:item_granter_device=item_granter_device{}
    @editable Rocket_Launcher_Epic:item_granter_device=item_granter_device{}
    @editable Rocket_Launcher_Legendary:item_granter_device=item_granter_device{}
    #Exotic
    #Heisted Accelerant Shotgun
    @editable Heisted_Accelerant_Shotgun_Exotic:item_granter_device=item_granter_device{}
    #Shadow Tracker
    @editable Shadow_Tracker_Exotic:item_granter_device=item_granter_device{}

    <#Misc
    @editable Misc_Common:item_granter_device=item_granter_device{}
    @editable Misc_Uncommon:item_granter_device=item_granter_device{}
    @editable Misc_Rare:item_granter_device=item_granter_device{}
    @editable Misc_Epic:item_granter_device=item_granter_device{}
    @editable Misc_Legendary:item_granter_device=item_granter_device{} #>

    ## Methods ## 
    OnBegin<override>()<suspends>:void=
        Print("Game Started")
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        InitItems()
        InitSpawners()
        InitLevels()
        Sleep(5.0)
        InitCustomUI()
        set GameRunning = true
        EndGameDialog.RespondingButtonEvent.Subscribe(EndGameFunctionality)

    OnPlayerLeftServer(PlayerLeaving:player):void=
        if(CustomPlayer:=CustomPlayers[PlayerLeaving]):
            UpdatePlayerUnlockedWeapons(CustomPlayer.Player)
            CustomPlayer.Dispose()
            var NewCustomPlayerMap:[player]custom_player=map{}
            for(Key->Value:CustomPlayers,Key<>PlayerLeaving):
                set NewCustomPlayerMap=ConcatenateMaps(NewCustomPlayerMap,map{Key=>Value})
            set CustomPlayers=NewCustomPlayerMap

    ############################################################################################################
    #Init Items ################################################################################################
    InitItems():void=
        set StartingItems = array{PistolTacticalCommon(), ShotgunCoreDPSCommon(), SMGRecoilCommon()}
        set AllItems = array{
            PistolTacticalCommon()
            PistolTacticalUncommon()
            PistolTacticalRare()
            PistolTacticalEpic()
            PistolTacticalLegendary()
            ShotgunCoreDPSCommon()
            ShotgunCoreDPSUncommon()
            ShotgunCoreDPSRare()
            ShotgunCoreDPSEpic()
            ShotgunCoreDPSLegendary()
            SMGRecoilCommon()
            SMGRecoilUncommon()
            SMGRecoilRare()
            SMGRecoilEpic()
            SMGRecoilLegendary()
            AssaultAutoCommon()
            AssaultAutoUncommon()
            AssaultAutoRare()
            AssaultAutoEpic()
            AssaultAutoLegendary()
            HunterBoltActionCommon()
            HunterBoltActionUncommon()
            HunterBoltActionRare()
            HunterBoltActionEpic()
            HunterBoltActionLegendary()
            RocketLauncherCommon()
            RocketLauncherUncommon()
            RocketLauncherRare()
            RocketLauncherEpic()
            RocketLauncherLegendary()
        }
        set CustomUI.LTOArray = array{
            RocketLauncherEpic()
            RocketLauncherLegendary()
            HeistedAccelerantShotgunExotic()
            ShadowTrackerExotic()
        }

    #PistolTactical
    PistolTacticalCommon():pistol_tactical=pistol_tactical{Granter:=Pistol_Tactical_Common,Rarity:=Common,Price:=50}
    PistolTacticalUncommon():pistol_tactical=pistol_tactical{Granter:=Pistol_Tactical_Uncommon,Rarity:=Uncommon,Price:=100}
    PistolTacticalRare():pistol_tactical=pistol_tactical{Granter:=Pistol_Tactical_Rare,Rarity:=Rare,Price:=200}
    PistolTacticalEpic():pistol_tactical=pistol_tactical{Granter:=Pistol_Tactical_Epic,Rarity:=Epic,Price:=400}
    PistolTacticalLegendary():pistol_tactical=pistol_tactical{Granter:=Pistol_Tactical_Legendary,Rarity:=Legendary,Price:=600}
    #ShotgunCoreDPS
    ShotgunCoreDPSCommon():shotgun_coredps=shotgun_coredps{Granter:=Shotgun_CoreDPS_Common,Rarity:=Common,Price:=80}
    ShotgunCoreDPSUncommon():shotgun_coredps=shotgun_coredps{Granter:=Shotgun_CoreDPS_Uncommon,Rarity:=Uncommon,Price:=160}
    ShotgunCoreDPSRare():shotgun_coredps=shotgun_coredps{Granter:=Shotgun_CoreDPS_Rare,Rarity:=Rare,Price:=320}
    ShotgunCoreDPSEpic():shotgun_coredps=shotgun_coredps{Granter:=Shotgun_CoreDPS_Epic,Rarity:=Epic,Price:=500}
    ShotgunCoreDPSLegendary():shotgun_coredps=shotgun_coredps{Granter:=Shotgun_CoreDPS_Legendary,Rarity:=Legendary,Price:=700}
    #SMGRecoil
    SMGRecoilCommon():smg_recoil=smg_recoil{Granter:=SMG_Recoil_Common,Rarity:=Common,Price:=100}
    SMGRecoilUncommon():smg_recoil=smg_recoil{Granter:=SMG_Recoil_Uncommon,Rarity:=Uncommon,Price:=200}
    SMGRecoilRare():smg_recoil=smg_recoil{Granter:=SMG_Recoil_Rare,Rarity:=Rare,Price:=400}
    SMGRecoilEpic():smg_recoil=smg_recoil{Granter:=SMG_Recoil_Epic,Rarity:=Epic,Price:=600}
    SMGRecoilLegendary():smg_recoil=smg_recoil{Granter:=SMG_Recoil_Legendary,Rarity:=Legendary,Price:=800}
    #AssaultAuto
    AssaultAutoCommon():assault_auto=assault_auto{Granter:=Assault_Auto_Common,Rarity:=Common,Price:=200}
    AssaultAutoUncommon():assault_auto=assault_auto{Granter:=Assault_Auto_Uncommon,Rarity:=Uncommon,Price:=400}
    AssaultAutoRare():assault_auto=assault_auto{Granter:=Assault_Auto_Rare,Rarity:=Rare,Price:=600}
    AssaultAutoEpic():assault_auto=assault_auto{Granter:=Assault_Auto_Epic,Rarity:=Epic,Price:=800}
    AssaultAutoLegendary():assault_auto=assault_auto{Granter:=Assault_Auto_Legendary,Rarity:=Legendary,Price:=1000}
    #HunterBoltActionSniper
    HunterBoltActionCommon():sniper_coresniper=sniper_coresniper{Granter:=Hunter_Bolt_Action_Sniper_Common,Rarity:=Common,Price:=400}
    HunterBoltActionUncommon():sniper_coresniper=sniper_coresniper{Granter:=Hunter_Bolt_Action_Sniper_Uncommon,Rarity:=Uncommon,Price:=800}
    HunterBoltActionRare():sniper_coresniper=sniper_coresniper{Granter:=Hunter_Bolt_Action_Sniper_Rare,Rarity:=Rare,Price:=1000}
    HunterBoltActionEpic():sniper_coresniper=sniper_coresniper{Granter:=Hunter_Bolt_Action_Sniper_Epic,Rarity:=Epic,Price:=1300}
    HunterBoltActionLegendary():sniper_coresniper=sniper_coresniper{Granter:=Hunter_Bolt_Action_Sniper_Legendary,Rarity:=Legendary,Price:=1600}
    #RocketLauncher
    RocketLauncherCommon():launcher_rocket=launcher_rocket{Granter:=Rocket_Launcher_Common,Rarity:=Common,Price:=1200}
    RocketLauncherUncommon():launcher_rocket=launcher_rocket{Granter:=Rocket_Launcher_Uncommon,Rarity:=Uncommon,Price:=2400}
    RocketLauncherRare():launcher_rocket=launcher_rocket{Granter:=Rocket_Launcher_Rare,Rarity:=Rare,Price:=3600}
    RocketLauncherEpic():launcher_rocket=launcher_rocket{Granter:=Rocket_Launcher_Epic,Rarity:=Epic,Price:=4800}
    RocketLauncherLegendary():launcher_rocket=launcher_rocket{Granter:=Rocket_Launcher_Legendary,Rarity:=Legendary,Price:=6000}
    #HeistedAccelerantShotgun
    HeistedAccelerantShotgunExotic():heisted_accelerant_shotgun=heisted_accelerant_shotgun{Granter:=Heisted_Accelerant_Shotgun_Exotic,Rarity:=Exotic,Price:=5000}
    #WaffleTruck Pistol
    ShadowTrackerExotic():shadow_tracker=shadow_tracker{Granter:=Shadow_Tracker_Exotic,Rarity:=Exotic,Price:=5000}

    ######################################################################################################################
    # Init Spawners ######################################################################################################
    InitSpawners():void=
        Spawners:=FindCreativeObjectsWithTag(spawner{})
        for(Obj:Spawners):
            if(Spawner:=player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        if(Player:=player[Agent]):
            InitPlayer(Player)

    InitPlayer(Player:player):void=
        if:
            Agent:=agent[Player]
            FortChar:=Agent.GetFortCharacter[]
            Player.IsActive[]
        then:
            if:
                not SavedPlayerData[Player]
                set SavedPlayerData[Player] = saved_data{} 
            if(not CustomPlayers[Player]):
                CustomPlayer:=MakeCustomPlayer(Player, StartingItems, CurrencyCheck, CurrencyRemover)
                OldSavedPlayerData:=GetPlayerData(Player)
                CustomPlayer.Init(OldSavedPlayerData.NewPlayer, OldSavedPlayerData.TimesCompleted, OldUnlockedItems(OldSavedPlayerData.UnlockedItems))
                if(set CustomPlayers[Player]=CustomPlayer){}
            if(GameRunning?): 
                set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
                CustomUI.ApplyGlobalExistingUIs(Player)
            FortChar.EliminatedEvent().Subscribe(OnEliminatedEvent)
            PlayIntro(Agent)

    GetPlayerData(Player : player) : saved_data=
        var NewSavedData : saved_data = saved_data{}
        if:
            PlayerTable := SavedPlayerData[Player]
        then:
            set NewSavedData = PlayerTable
        return NewSavedData

    UpdatePlayerData(Player : player, DataToUpdate : string, Value : int) : void=
        if:
            Player.IsActive[]
            PlayerTable := SavedPlayerData[Player]
            CustomPlayer:=CustomPlayers[Player]
            case(DataToUpdate):
                "NewPlayer"=> 
                    if(Value = 0):
                        set SavedPlayerData[Player] = saved_data:
                            MakeSavedData<constructor>(PlayerTable)
                            NewPlayer := false
                        set CustomPlayer.NewPlayer = false
                    else:
                        set SavedPlayerData[Player] = saved_data:
                            MakeSavedData<constructor>(PlayerTable)
                            NewPlayer := true
                        set CustomPlayer.NewPlayer = true
                        Print("Maybe both are running")
                "TimesCompleted"=>
                    CurrentTimesCompleted := PlayerTable.TimesCompleted  
                    set SavedPlayerData[Player] = saved_data:
                        MakeSavedData<constructor>(PlayerTable)
                        TimesCompleted :=  CurrentTimesCompleted + 1
                    set CustomPlayer.TimesCompleted = CurrentTimesCompleted + 1
                _=>
        return

    UpdatePlayerUnlockedWeapons(Agent:agent) :void =
        var PlayerUnlockedItemsNames:[]string=array{}
        if(Player := player[Agent]):
            if:
                CustomPlayer:=CustomPlayers[Player]
            then:
                for(Item:CustomPlayer.UnlockedItems):
                    ItemName:="{Item.Name} {Item.Rarity.Order}"
                    set PlayerUnlockedItemsNames += array{ItemName}
            if:
                Player.IsActive[]
                PlayerTable := SavedPlayerData[Player]
                set SavedPlayerData[Player] = saved_data:
                    MakeSavedData<constructor>(PlayerTable)
                    UnlockedItems:= PlayerUnlockedItemsNames

    OldUnlockedItems(OldUnlockedItemsNames:[]string):[]item=
        var ItemArray:[]item=array{}
        for(OldItemName:OldUnlockedItemsNames):
            OldNameLength:=OldItemName.Length
            var OldName:string=""
            var OldOrder:string=""
            if:
                Name:=OldItemName.Slice[0, OldItemName.Length-2]
                NumInStr:=OldItemName.Slice[OldItemName.Length-1]
            then:
                set OldName = Name
                set OldOrder=NumInStr
            for(Item:AllItems):
                if:
                    Item.Name = OldName
                    ToString(Item.Rarity.Order) = OldOrder
                then:
                    Print(Item.Name + " " + ToString(Item.Rarity.Order))
                    set ItemArray += array{Item}
        return ItemArray

    PlayIntro(Agent:agent):void=
        if:
            Player:=player[Agent]
            CustomPlayer:=CustomPlayers[Player]
        then:
            if:
                CustomPlayer.NewPlayer?
            then:
                IntroCinematic.SetPlaybackFrame(0)
                IntroCinematic.Play(Agent)
                BasementPulse.ActivateObjectivePulse(Agent)
                UpdatePlayerData(Player, "NewPlayer", 0)
            else:
                ShopPulse.ActivateObjectivePulse(Agent)
                #Play some loading screen until everything is ready 

    OnEliminatedEvent(ElimResult:elimination_result):void=
        DeadChar:=ElimResult.EliminatedCharacter
        if(Agent:=DeadChar.GetAgent[],Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            ClearInventory.Remove(Agent)
            CustomUI.RemoveSomeHUDS(option{Agent},false)
            set CustomPlayer.LevelReached = -1
            UpdatePlayerUnlockedWeapons(Player)

    ############################################################################################################
    #Init Levels################################################################################################
    InitLevels():void=
        Level1:custom_level=MakeLevel(level1{},1)
        Level2:custom_level=MakeLevel(level2{},2)
        Level3:custom_level=MakeLevel(level3{},3)
        Level4:custom_level=MakeLevel(level4{},4)
        Level5:custom_level=MakeLevel(level5{},5)
        Level6:custom_level=MakeLevel(level6{},6)
        Level7:custom_level=MakeLevel(level7{},7)
        Level8:custom_level=MakeLevel(level8{},8)
        Level9:custom_level=MakeLevel(level9{},9)
        Level10:custom_level=MakeLevel(level10{},10)
        set LevelsToArrayCustomPlayersMap = map{
            Level1=>array{}
            Level2=>array{}
            Level3=>array{}
            Level4=>array{}
            Level5=>array{}
            Level6=>array{}
            Level7=>array{}
            Level8=>array{}
            Level9=>array{}
            Level10=>array{}
            }
        MutatorZones:=FindCreativeObjectsWithTag(mutatorzone{})
        for(Obj:MutatorZones, MutatorZone:=mutator_zone_device[Obj]):
            MutatorTags:=MutatorZone.GetTags()
            MutatorZone.AgentEntersEvent.Subscribe(MutatorEvent_Handler{Device:=Self, Enters:=true, MutatorTags:=MutatorTags}.HandlerFunction)
            MutatorZone.AgentExitsEvent.Subscribe(MutatorEvent_Handler{Device:=Self, Enters:=false, MutatorTags:=MutatorTags}.HandlerFunction)
        CompletedLevelTriggers:=FindCreativeObjectsWithTag(trigger{})
        for(Obj:CompletedLevelTriggers, CompletedLevelTrigger:=trigger_device[Obj]):
            TriggerTags:=CompletedLevelTrigger.GetTags()
            CompletedLevelTrigger.TriggeredEvent.Subscribe(TriggerEvent_Handler{Device:=Self, TriggerTags:=TriggerTags}.HandlerFunction)
        CurrencyCheck.ActivatedEvent.Subscribe(UpdatePlayerUnlockedWeapons)
        #Here add the parameters for gold granting
        ItemShopButton.InteractedWithEvent.Subscribe(ShopUI)

    ResetLevel(Level:custom_level,Agent:agent)<suspends>:void=
        LevelTag:=Level.Tag
        Sleep(1.0)
        Print("Resetting Level")
        LevelDevices:=FindCreativeObjectsWithTag(LevelTag)
        #This resets guard spawner
        for(GuardSpanwer:LevelDevices, Guards:=guard_spawner_device[GuardSpanwer]):
            Print("Resetting guards")
            Guards.Reset()
            Guards.Disable()
            Guards.Enable()
        #This resets all cinematics
        for(Cinematic:LevelDevices, CinematicDevice:=cinematic_sequence_device[Cinematic]):
            Print("Resetting cinematics")
            CinematicDevice.Stop()
            CinematicDevice.SetPlaybackFrame(0)
        #This resets broken props
        for(PropManip:LevelDevices, PropManDev:=prop_manipulator_device[PropManip]):
            Print("Resetting Props")
            PropManDev.ShowProps()
        #This resets trigger for broken props
        for(PropTrigger:LevelDevices):
            PropTriggerTags:=PropTrigger.GetTags()
            if:
                TriggerDevice:=trigger_device[PropTrigger]
            then:
                Print("Resetting trigger count")
                TriggerDevice.Reset()
        #This resets locks
        for(LockTrigger:LevelDevices, LockDevice:=lock_device[LockTrigger]):
            Print("Resetting lock")
            LockDevice.Close(Agent)
            LockDevice.Lock(Agent)
        #This resets switches
        for(SwitchTrigger:LevelDevices, SwitchDevice:=switch_device[SwitchTrigger]):
            SwitchDevice.TurnOff(Agent)
        #This resets VFX
        for(VFXSpawner:LevelDevices, VFXSpawnerDevice:=vfx_spawner_device[VFXSpawner]):
            VFXSpawnerDevice.Disable()
        #This resets Teleporter
        for(Teleporter:LevelDevices, TeleporterDevice:=teleporter_device[Teleporter]):
            TeleporterDevice.Disable()
        #This resets Character Devices
        for(Character:LevelDevices, CharacterDevice:=character_device[Character]):
            CharacterDevice.Show()
        #This resets Collectibles
        for(Collectible:LevelDevices, CollectibleDevice:=collectible_object_device[Collectible]):
            CollectibleDevice.RespawnForAll()
        set Level.Completed=false

    ShopUI(Agent:agent):void=
        CustomUI.ShowItemShopUI(true,4,option{Agent},AllItems)
        ShopPulse.DeactivateObjectivePulse(Agent)

    ############################################################################################################
    #Init Custom UI ############################################################################################
    InitCustomUI():void=
        set CustomUI.PlayerToCustomPlayerMap=CustomPlayers
        set CustomUI.RealTimeProp=option{RealTimeProp}
        CustomUI.Assign()
        CustomUI.ShowCurrencyTextUI(false,20,false)
        CustomUI.ShowProgressBarUI(false,21,false,LevelsToArrayCustomPlayersMap.Length)

    GrantItem(Agent:agent):void=
        if:
            Player:=player[Agent]
            CustomPlayer:=CustomPlayers[Player]
            Index:=GetRandomInt(0, CustomPlayer.UnlockedItems.Length)
            SelectedItem:=CustomPlayer.UnlockedItems[Index]
        then:
            SelectedItem.Granter.GrantItem(Agent)

    SelectItemUI(Agent:agent)<suspends>:void=
        Print("Spawning Item Selection")
        Sleep(0.5)
        CustomUI.ShowItemSelectionUI(true,2,option{Agent})
    
    EmptyInventory(Agent:agent):void=
        ClearInventory.Remove(Agent)

    #############################################################################################################
    #End Game ###################################################################################################
    EndGameFunctionality(Agent:agent,ButtonIndex:int):void=
        if (FortCharacter := Agent.GetFortCharacter[]):
            FortCharacter.Damage(1000.0)
        if(Player:=player[Agent],CustomPlayer:=CustomPlayers[Player]):
            set CustomPlayer.LevelReached = -1

    #We can also have on the first room 3 guns and after that same number minus one plus one ability or one heal 
    #inspiration by tychoon games on the price tags
