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
# Classes #
## Tags ##
spawner:=class(tag){}
mutatorzone:=class(tag){}
trigger:=class(tag){}
prop:=class(tag){}
level1:=class(tag){}
level2:=class(tag){}
level3:=class(tag){}
level4:=class(tag){}
level5:=class(tag){}
level6:=class(tag){}
level7:=class(tag){}
level8:=class(tag){}
level9:=class(tag){}
level10:=class(tag){}

## Persistable Data ##
saved_data:=class<final><persistable>():
    NewPlayer : logic = true
    TimesCompleted : int = 0
    UnlockedItems: []string = array{"AUTO SHOTGUN 1", "COMBAT SMG 1", "COMBAT PISTOL 1"}

MakeSavedData<constructor>(OldData : saved_data)<transacts> := saved_data:
    NewPlayer := OldData.NewPlayer
    TimesCompleted := OldData.TimesCompleted
    UnlockedItems := OldData.UnlockedItems

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
    var NewPlayer:logic=true

    var LevelReached:int=-1
    var TimesCompleted:int=0
    var UnlockedItems: []item
    var Currency:int=0
    var CurrencyCheck:conditional_button_device
    var CurrencyRemover:item_remover_device

    Init(OldNewPlayer:logic, OldTimesCompleted:int, OldUnlockedItems:[]item):void=
        if(Agent:=agent[Player],FortChar:=Agent.GetFortCharacter[]){}
        set NewPlayer=OldNewPlayer
        set TimesCompleted=OldTimesCompleted
        set UnlockedItems=OldUnlockedItems

    GetCurrency():int=
        if(Agent:=agent[Player]):
            set Currency=CurrencyCheck.GetItemCount(Agent,0)
            CurrencyCheck.Activate(Agent)
        return Currency
    
    Dispose():void=
        Print("Cleaning up.")

MakeCustomPlayer<constructor>(Player:player,AvailableItems:[]item,CurrencyCheck:conditional_button_device,CurrencyRemover:item_remover_device):=custom_player:
    Player:=Player
    UnlockedItems:=AvailableItems
    CurrencyCheck:=CurrencyCheck
    CurrencyRemover:=CurrencyRemover

## Levels ##
custom_level:=class<unique>():
    Tag:tag
    Index:int
    var Completed:logic=false

MakeLevel<constructor>(LevelTag:tag,LevelIndex:int)<transacts>:=custom_level:
    Tag:=LevelTag
    Index:=LevelIndex

## Guns & Abilities ##
rarity:=class<unique>():
    Order:int
    BGIcon:texture

item:=class():
    Name:string
    Icon:texture
    Rarity:rarity
    Price:int
    Granter:item_granter_device

    PriceCalculator():void=
        Print("Calculating price")

    DiscountPrice():int=
        if(DiscountedPriceRat:=Price / 2):
            DiscountedPrice:=Floor(DiscountedPriceRat)
            return DiscountedPrice
        return 10000 

pistol_tactical:=class(item){Name<override>:string="COMBAT PISTOL",Icon<override>:texture=Icons.IC_PistolTactical}
smg_recoil:=class(item){Name<override>:string="COMBAT SMG",Icon<override>:texture=Icons.IC_SMGRecoil}
shotgun_coredps:=class(item){Name<override>:string="AUTO SHOTGUN",Icon<override>:texture=Icons.IC_ShotgunCoreDPS}
assault_auto:=class(item){Name<override>:string="ASSAULT RIFLE",Icon<override>:texture=Icons.IC_AssaultAuto}
sniper_coresniper:=class(item){Name<override>:string="HUNTER BOLT ACTION",Icon<override>:texture=Icons.IC_SniperCoreSniper}
launcher_rocket:=class(item){Name<override>:string="ROCKET LAUNCHER",Icon<override>:texture=Icons.IC_LauncherRocket}
heisted_accelerant_shotgun:=class(item){Name<override>:string="HEISTED ACCELERANT SHOTGUN",Icon<override>:texture=Icons.IC_LauncherRocket} #To change
shadow_tracker:=class(item){Name<override>:string="SHADOW TRACKER",Icon<override>:texture=Icons.IC_LauncherRocket}#To change