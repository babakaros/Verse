using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

## Type Casting ##
IntToMessage<localizes>(I:int) : message = "{I}"
StringToMessage<localizes>(S:string) : message = "{S}"
AgentToMessage<localizes>(A:agent) : message = "{A}"

IntToString(I:int) : string = "{I}"
FloatToString(F:float) : string ="{F}"

CustomPlayerToAgent(CustomPlayer : custom_player) : ?agent = 
    if(Player := CustomPlayer.Player, Agent := agent[Player]) then return option{Agent}
    return false

FloatToTime(F:float): string =
    if:
        Minutes := Floor[F / 60.0]
        RoundedF := Floor[F]
        Seconds := Mod[RoundedF, 60]
    then:
        var MinutesText : string = IntToString(Minutes)
        var SecondsText : string = IntToString(Seconds)
        if (MinutesText.Length = 1) then set MinutesText = "0{MinutesText}"
        if (SecondsText.Length = 1) then set SecondsText = "0{SecondsText}"
        return "{MinutesText}:{SecondsText}"
    return "Error Processing Time"

ClipString(Str : string, StartClip : int):string=
    var OutputStr : string = ""
    if:
        Str.Length > StartClip
        Y := Str.Slice[0, StartClip]
    then:
        set OutputStr = Y 
        loop:
            if(OutputStr[OutputStr.Length-1] = " "):
                if(NewStr := OutputStr.RemoveElement[OutputStr.Length-1]) then set OutputStr = NewStr
            else:
                break
        set OutputStr += "."
    else:
        set OutputStr = Str
    return OutputStr


## Organization ##
Special<localizes>:message = "Special"
Pistol<localizes>:message = "Pistol"
SMG<localizes>:message = "SMG"
Shotgun<localizes>:message = "Shotgun"
Assault<localizes>:message = "Assault"
Sniper<localizes>:message = "Sniper"
Misc<localizes>:message = "Miscellanious"
Heals<localizes>:message = "Heals"
Throwables<localizes>:message = "Throwables"

Currency<localizes>:message = "Currency"

ParkourCoin<localizes>:message = "Parkour Coin"

StatCreator<localizes>:message = "Stat Creator"

UI<localizes>:message = "UI"

## Enums ##
currency_grant_type := enum {
    AFKZone
    GuardEliminated
    LevelCleared
    BossLevelCleared
    ChallengeCompletedSmall
    ChallengeCompletedLarge
    AbilityGoldUncommon
    AbilityGoldRare
    ParkourFirst
    ParkourSecond
}

item_type := enum {
    Weapon
    Heal
    Throwable
    Ability
    SpecialItem
}

stat_type := enum {
    OpElim
    BossElim
    TimePlayed
    LevelsCleared
    RelicsCollected
}

## Tags ##
### Device Type ###
spawner:=class(tag){}
mutatorzone:=class(tag){}
trigger:=class(tag){}
guardspawner:=class(tag){}
bossspawner:=class(tag){}
prop:=class(tag){}
relic:=class(tag){}
secondary:=class(tag){}
### Levels ###
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
level11:=class(tag){}
level12:=class(tag){}
level13:=class(tag){}
level14:=class(tag){}
level15:=class(tag){}
level16:=class(tag){}
level17:=class(tag){}
level18:=class(tag){}
level19:=class(tag){}
level20:=class(tag){}
