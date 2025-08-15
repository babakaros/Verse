using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
# Classes 
## Persistable Data ##
saved_data:=class<final><persistable>():
    NewPlayer : logic = true
    TimesCompleted : int = 0
    BestRunTime : float = 0.0
    UnlockedItems: []string = array{"AUTO SHOTGUN 1", "COMBAT SMG 1", "COMBAT PISTOL 1", "SUPPRESED PISTOL 1", "BANDAGE 1", "50 GOLD 2", "DAMAGE INC 3", "25 HP 2", "GRENADE 1", "BANANA 1"}
    UnlockedItemsV2: [string]int = map{
        "COMBAT PISTOL" => 1
        "SUPPRESED PISTOL" => 1
        "SURGE FIRE SMG" => 1
        "CHARGE SMG" => 1
        "AUTO SHOTGUN" => 1
        "BURST ASSAULT RIFLE" => 1
        "BANDAGE" => 1
        "BANANA" => 1
        "GRENADE" => 1
        "COW CATCHER" => 1
        "50 GOLD" => 2
        "DAMAGE INC" => 3
        "25 HP" => 2}

MakeSavedData<constructor>(OldData : saved_data)<transacts> := saved_data:
    NewPlayer := OldData.NewPlayer
    TimesCompleted := OldData.TimesCompleted
    BestRunTime := OldData.BestRunTime
    UnlockedItemsV2 := OldData.UnlockedItemsV2

## Current Time ##
current_time:=class<final><concrete>:
    var Hours:int=-1
    var Minutes:int=-1
    var Seconds:int=-1

MakeCurrentTime<constructor>(Hours:int, Minutes:int,Seconds:int):=current_time:
    Hours:=Hours
    Minutes:=Minutes
    Seconds:=Seconds

MakeCurrentTime(Prop:creative_prop):current_time=
    Transform:=Prop.GetTransform()
    if:
        Hours:=Int[Transform.Translation.X]
        Minutes:=Int[Transform.Translation.Y]
        Seconds:=Int[Transform.Translation.Z]
    then:
        return MakeCurrentTime(Hours, Minutes, Seconds)
    return current_time{}

## Custom player ##
custom_player:=class<unique>():
    Player:player
    PlayerAlive:logic=true
    var NewPlayer:logic=true
    var StartingMaxHealth : float = 1000.0

    var PlayerStats : player_stats = player_stats{}
    var PlayerAbilities : player_abilities = player_abilities{}

    var CurrencyManager : Currency_Manager
    var CurrentLevelsCleared_StatCreator:stat_creator_device
    var HighestLevelClearedUI_StatCreator : stat_creator_device
    var BestRunTimeUI_Timer : timer_device

    var UnlockedWeaponArray: []item
    var UnlockedHealArray: []item
    var UnlockedThrowableArray: []item
    var UnlockedAbilityArray: []item
    var UnlockedSpecialArray: []item
    var UnlockedItemArray : []item = array{}

    Init(OldNewPlayer : logic, OldTimesCompleted : int, OldBestRunTime : float, OldUnlockedItems : [string]int) : void=
        if(Agent := agent[Player], FortChar := Agent.GetFortCharacter[]):
            set StartingMaxHealth = FortChar.GetMaxHealth()
        set NewPlayer = OldNewPlayer
        set PlayerStats.TimesCompleted = OldTimesCompleted
        set PlayerStats.BestRunTime = OldBestRunTime
        set UnlockedItemArray = UnlockedWeaponArray + UnlockedHealArray + UnlockedThrowableArray + UnlockedAbilityArray + UnlockedSpecialArray
        InitItems(OldUnlockedItems)
        GetCurrencyValue()

    InitItems<private>(OldUnlockedItems : [string]int) : void = 
        allRarities :[]rarity= array{locked{}, common{}, uncommon{}, rare{}, epic{}, legendary{}, exotic{}, mythic{}}
        var TempArray : []item = array{}
        for(Item : UnlockedItemArray):
            for(ItemName -> ItemRarityOrder : OldUnlockedItems):
                if(Item.Name = ItemName, NewRarity := allRarities[ItemRarityOrder]):
                    set Item.Rarity = NewRarity
        UpdateArray(UnlockedWeaponArray)
        UpdateArray(UnlockedHealArray)
        UpdateArray(UnlockedThrowableArray)
        UpdateArray(UnlockedAbilityArray)
        UpdateArray(UnlockedItemArray)

    UpdateArray<private>(ItemArray : []item): void = #We might not need this as it supposedely are referenced in the all items
        for(Item:ItemArray):
            var Found : logic = false
            for(ProperItem:UnlockedItemArray,not Found?):
                if(Item.Name = ProperItem.Name):
                    set Found = true 
                    set Item.Rarity = ProperItem.Rarity

    GetCurrencyValue():int=
        if(Agent:=agent[Player]):
            CurrentCurrencyValue := CurrencyManager.Currency_Conditional.GetItemCount(Agent,0)
            Print("Currency: { CurrentCurrencyValue}")
            if(CurrencyManager.Currency_StatCreator.SetValue[Agent, CurrentCurrencyValue]){}
            set PlayerStats.CurrencyValue = CurrentCurrencyValue
        return PlayerStats.CurrencyValue

    <# GetLevelsClearedValue():int=
        if:
            Agent:=agent[Player]
            Value := LevelsCleared_StatCreator.GetValue[Agent]
        then:
            set LevelsClearedValue = Value
        return LevelsClearedValue #>

    GetHighestLevelClearedValue():int=
        if:
            Agent:=agent[Player]
            Value := HighestLevelClearedUI_StatCreator.GetValue[Agent]
        then:
            return Value
        return 0 

    SetCurrentLevelsClearedValue(NewLevelsCleared : int):void=
        if:
            Agent:=agent[Player]
            CurrentLevelsCleared_StatCreator.SetValue[Agent, NewLevelsCleared]
        then:
            set PlayerStats.CurrentLevelsCleared = NewLevelsCleared
        return 

    GetRunTimeValue() : float = 
        if(Agent:=agent[Player]) then return BestRunTimeUI_Timer.GetActiveDuration(Agent) 
        return 0.0

    SetBestRunTimeValue(NewBestRunTime : float) : void =  
        CurrentLevelClearedValue := PlayerStats.CurrentLevelsCleared
        HighestLevelClearedValue := GetHighestLevelClearedValue()
        if:
            Agent:=agent[Player]
            CurrentLevelClearedValue > HighestLevelClearedValue or (CurrentLevelClearedValue = HighestLevelClearedValue and 3600.0 - NewBestRunTime < 3600.0 - PlayerStats.BestRunTime)
            HighestLevelClearedUI_StatCreator.SetValue[Agent, CurrentLevelClearedValue]
        then: 
            set PlayerStats.HighestLevelCleared = CurrentLevelClearedValue
            BestRunTimeUI_Timer.SetActiveDuration(NewBestRunTime, Agent)
            set PlayerStats.BestRunTime = NewBestRunTime
        return

    Reset() : void =
        if:
            Agent := agent[Player]
            FortChar := Player.GetFortCharacter[]
            CurrentHealth := FortChar.GetHealth()
        then:
            FortChar.SetMaxHealth(StartingMaxHealth)
            SetCurrentLevelsClearedValue(0)
            set PlayerAbilities.HealthRegenMultiplier = 0
            set PlayerAbilities.LifeStealRate = 0
            set PlayerAbilities.GoldDiggerRate = 0
            set PlayerAbilities.DamageMultiplier = 0
        
    Dispose():void=
        Print("Cleaning up.")

MakeCustomPlayer<constructor>(Player : player, UnlockedWeaponArray : []item, UnlockedHealArray: []item, UnlockedThrowableArray : []item, UnlockedAbilityArray : []item, UnlockedSpecialArray: []item, CurrentLevelsCleared_StatCreator : stat_creator_device, BestRunTimeUI_Timer : timer_device, HighestLevelClearedUI_StatCreator : stat_creator_device ,CurrencyManager : Currency_Manager):=custom_player:
    Player := Player
    UnlockedWeaponArray := UnlockedWeaponArray
    UnlockedHealArray := UnlockedHealArray
    UnlockedThrowableArray := UnlockedThrowableArray
    UnlockedAbilityArray := UnlockedAbilityArray
    UnlockedSpecialArray := UnlockedSpecialArray
    BestRunTimeUI_Timer := BestRunTimeUI_Timer
    HighestLevelClearedUI_StatCreator := HighestLevelClearedUI_StatCreator
    CurrentLevelsCleared_StatCreator := CurrentLevelsCleared_StatCreator
    CurrencyManager := CurrencyManager
## Stats ##
player_stats:=class():
    var CurrencyValue:int=0
    var CurrentLevelsCleared:int=0
    var HighestLevelCleared:int=0
    var BestRunTime:float=0.0
    var TimesCompleted:int=0
    var OpEliminated:int=0
    var BossEliminated:int=0
    var RelicsCollected:int=0
    var TimePlayed:int=0
    var TotalLevelsCleared:int=0
## Ablities ##
player_abilities:=class():
    var HealthRegenMultiplier:int=0
    var LifeStealRate:int=0
    var GoldDiggerRate:int=0
    var DamageMultiplier:int=0
## Levels ##
custom_level:=class<unique>():
    Tag:tag
    Index:int
    var Cleared:logic=false

    <# In order to use the findcreativeobjectswithtag we have to reference a device
    
    ResetLevel(Agent:agent)<suspends>:void=
        Sleep(1.0)
        Print("Resetting Level")
        LevelDevices:=FindCreativeObjectsWithTag(Tag)
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
        set Cleared=false #>

MakeLevel<constructor>(LevelTag:tag,LevelIndex:int)<transacts>:=custom_level:
    Tag:=LevelTag
    Index:=LevelIndex

## Guns & Abilities ##
rarity:=class<unique>():
    Order:int
    BGIcon:texture


## Rarities ##
locked:=class(rarity){Order<override>:int=0, BGIcon<override>:texture= Icons.IC_Error}
common:=class(rarity){Order<override>:int=1, BGIcon<override>:texture= Icons.IC_V1_BG}
uncommon:=class(rarity){Order<override>:int=2, BGIcon<override>:texture= Icons.IC_V2_BG}
rare:=class(rarity){Order<override>:int=3, BGIcon<override>:texture= Icons.IC_V3_BG}
epic:=class(rarity){Order<override>:int=4, BGIcon<override>:texture= Icons.IC_V4_BG}
legendary:=class(rarity){Order<override>:int=5, BGIcon<override>:texture= Icons.IC_V5_BG}
exotic:=class(rarity){Order<override>:int=6, BGIcon<override>:texture= Icons.IC_V6_BG}
mythic:=class(rarity){Order<override>:int=7, BGIcon<override>:texture= Icons.IC_V7_BG}
maxxed:=class(rarity){Order<override>:int=8, BGIcon<override>:texture= Icons.IC_Error}


item:=class<unique>():
    Name:string
    Icon:texture
    BasePrice:int
    var Rarity: rarity=locked{}
    MinRarity:rarity=common{}
    MaxRarity:rarity=legendary{}
    Granter : item_granter_device = item_granter_device{}
    allRarities :[]rarity= array{locked{}, common{}, uncommon{}, rare{}, epic{}, legendary{}, exotic{}, mythic{}}

    Clone() : item = 
        return newItem := item{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter}

    PriceCalculator(Discount:logic):int=
        Multipliers : []float = array{1.0, 2.0, 2.0, 1.6, 1.35}

        var Multiplier: []float = array{}

        RarityIndex := Rarity.Order-1
        var TotalMultiplier:float= 1.0
        Print("{RarityIndex}")
        for (i:=0..RarityIndex, Mul:=Multipliers[i]):
            set TotalMultiplier *= Mul

        if (Discount=true) then set TotalMultiplier /= 2.0
        if (CurrentPrice:=Round[TotalMultiplier*BasePrice]) then return CurrentPrice

        return BasePrice

    UpgradeRarity():void =
        var StopFor : logic = false
        for(Index -> possibleRarity: allRarities, possibleRarity.Order=Rarity.Order, not StopFor?):
            if(tempRarity := allRarities[Index+1], tempRarity.Order <= MaxRarity.Order) then set Rarity = tempRarity
            if (Rarity.Order >= MinRarity.Order) then set StopFor = true

    NextRarity():item = 
        newItem := item{
                Name := Name,
                Icon := Icon,
                BasePrice := BasePrice,
                Rarity := Rarity,
                MinRarity := MinRarity,
                MaxRarity := MaxRarity,
                Granter := Granter
            }
        var StopFor : logic = false
        for(Index -> possibleRarity: allRarities, possibleRarity.Order=newItem.Rarity.Order, not StopFor?):
            if(tempRarity := allRarities[Index+1], tempRarity.Order <= MaxRarity.Order) then set newItem.Rarity = tempRarity
            if (newItem.Rarity.Order >= MinRarity.Order) then set StopFor = true
        return newItem
        
    GrantItem(CustomPlayer : custom_player) : void = 
        MaybeAgent := CustomPlayerToAgent(CustomPlayer)
        if(Agent := MaybeAgent?):
            Granter.GrantItem(Agent) 
            
weapon:=class(item):
    Clone<override>() : weapon = 
        return newItem := weapon{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter}

    GrantItem<override>(CustomPlayer : custom_player) :  void = 
        MaybeAgent := CustomPlayerToAgent(CustomPlayer)
        if(Agent := MaybeAgent?):
            Granter.GrantItemIndex(Agent, Rarity.Order-1)

pistol:=class(weapon){}
smg:=class(weapon){}
shotgun:=class(weapon){}
assault:=class(weapon){}
sniper:=class(weapon){}
explosive:=class(weapon){}

special:=class(weapon):
    Clone<override>() : special = 
        return newItem := special{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter}  

    GrantItem<override>(CustomPlayer : custom_player) : void = 
        MaybeAgent := CustomPlayerToAgent(CustomPlayer)
        if(Agent := MaybeAgent?):
            Granter.GrantItem(Agent)

heal:=class(item):

throwable:=class(item):

ability:=class(item):
    Clone<override>() : ability = 
        return newItem := ability{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter} 

    GrantItem<override>(CustomPlayer : custom_player) : void = 
        MaybeAgent := CustomPlayerToAgent(CustomPlayer)
        if(Agent := MaybeAgent?):
            Print("Ability granted")
            ApplyAbility(CustomPlayer)

    ApplyAbility(CustomPlayer : custom_player) : void =
        Print("custom didn't run")
        return


grant_gold:=class(ability):
    Name<override>:string="50 GOLD"
    Icon<override>:texture=Icons.IC_GrantGold
    BasePrice<override>:int=500
    CurrencyManager : Currency_Manager
    CurrencyGrantType : currency_grant_type 

    Clone<override>() : grant_gold = 
        return newItem := grant_gold{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter,
            CurrencyManager := CurrencyManager,
            CurrencyGrantType := CurrencyGrantType }

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
        then:
           CurrencyManager.CurrencyGrant(Agent, CurrencyGrantType)
        return

grant_health:=class(ability):
    Name<override>:string="+25 HP"
    Icon<override>:texture=Icons.IC_GrantHealth
    BasePrice<override>:int=500

    Clone<override>() : grant_health = 
        return newItem := grant_health{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter} 

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
            FortChar := Player.GetFortCharacter[]
            CurrentHealth := FortChar.GetHealth()
        then:
            if(Rarity.Order = 2):
                FortChar.SetHealth(CurrentHealth + 25.0)
            else:
                FortChar.SetHealth(CurrentHealth + 100.0)
        return

increase_max_health:=class(ability):
    Name<override>:string="+100 Max HP"
    Icon<override>:texture=Icons.IC_MaxHpUp
    BasePrice<override>:int=500

    Clone<override>() : increase_max_health = 
        return newItem := increase_max_health{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter} 

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
            FortChar := Player.GetFortCharacter[]
            CurrentMaxHealth := FortChar.GetMaxHealth()
        then:
            FortChar.SetMaxHealth(CurrentMaxHealth + 100.0)
        return

health_regen:=class(ability):
    Name<override>:string="HEALTH REGEN"
    Icon<override>:texture=Icons.IC_HealthRegen
    BasePrice<override>:int=1250

    Clone<override>() : health_regen = 
        return newItem := health_regen{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter} 

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
            set CustomPlayer.PlayerAbilities.HealthRegenMultiplier += 1
            spawn{HealthRegen(CustomPlayer)}
        return

    HealthRegen(CustomPlayer : custom_player)<suspends> : void = 
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
            FortChar := Player.GetFortCharacter[] 
        then:
            CurrentHealthRegenMultiplier := CustomPlayer.PlayerAbilities.HealthRegenMultiplier
            loop:
                CurrentHealth := FortChar.GetHealth()
                FortChar.SetHealth(CurrentHealth + 1.0*CurrentHealthRegenMultiplier)
                Sleep(5.0)
                if(CustomPlayer.PlayerAbilities.HealthRegenMultiplier <> CurrentHealthRegenMultiplier) then break

damage_inc:=class(ability):
    Name<override>:string="DAMAGE INC"
    Icon<override>:texture=Icons.IC_DamageInc
    BasePrice<override>:int=1000
    DamageMultiplier : damage_amplifier_powerup_device

    Clone<override>() : damage_inc = 
        return newItem := damage_inc{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter,
            DamageMultiplier := DamageMultiplier} 

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
        then:
            set CustomPlayer.PlayerAbilities.LifeStealRate += 1
            CurrentDamage := DamageMultiplier.GetMagnitude()
            DamageMultiplier.SetMagnitude(CurrentDamage + 0.1 * CustomPlayer.PlayerAbilities.DamageMultiplier)
            DamageMultiplier.Pickup()
        return

life_steal:=class(ability):
    Name<override>:string="LIFESTEAL"
    Icon<override>:texture=Icons.IC_LifeSteal
    BasePrice<override>:int=2000

    Clone<override>() : life_steal = 
        return newItem := life_steal{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter}

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
        then:
            set CustomPlayer.PlayerAbilities.LifeStealRate += 1
        return

gold_digger:=class(ability):
    Name<override>:string="GOLD DIGGER"
    Icon<override>:texture=Icons.IC_GoldDigger
    BasePrice<override>:int=1000

    Clone<override>() : gold_digger = 
        return newItem := gold_digger{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter}

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
        then:
            set CustomPlayer.PlayerAbilities.GoldDiggerRate += 1
        return

respawn:=class(ability):
    Name<override>:string="RESPAWN"
    Icon<override>:texture=Icons.IC_Respawn
    BasePrice<override>:int=2000

    Clone<override>() : respawn = 
        return newItem := respawn{
            Name := Name,
            Icon := Icon,
            BasePrice := BasePrice,
            Rarity := Rarity,
            MinRarity := MinRarity,
            MaxRarity := MaxRarity,
            Granter := Granter}

    ApplyAbility<override>(CustomPlayer : custom_player) : void =
        if:
            Player := CustomPlayer.Player
            Agent := agent[Player]
        then:
        return
