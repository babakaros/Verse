using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Vehicles}
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
Player1:=class(tag){}
Player2:=class(tag){}
Player3:=class(tag){}
Player4:=class(tag){}
Player5:=class(tag){}
Player6:=class(tag){}
Player7:=class(tag){}
Player8:=class(tag){}
Player9:=class(tag){}
Player10:=class(tag){}
Player11:=class(tag){}
Player12:=class(tag){}
Bike:=class(tag){}
SportBike:=class(tag){}
ATV:=class(tag){}
RallyCar:=class(tag){}
RacingTruck:=class(tag){}
BigRig:=class(tag){}
MovementModulatorTag:=class(tag){}
PropTag:=class(tag){}
LastLapHUDTag:=class(tag){}

## Custom player ##
custom_player:=class<unique>():
    Player:player
    var Tag:?tag=false
    var Position:transform=transform{}
    var GamesPlayed:int=0
    var CurrentClass:vehicle_class
    var VehicleSpawner:?vehicle_spawner_device=false
    var PlayerTags:[]creative_object_interface=array{}
    var LapsDone:int=0
    var TotalLaps:int=0

    Init():void=
        if(Agent:=agent[Player],FortChar:=Agent.GetFortCharacter[]){}
        if(CurrentTag:=Tag?):
            set PlayerTags=GetCreativeObjectsWithTag(CurrentTag)

    GetTransform():transform=
        if(FortChar:=Player.GetFortCharacter[]):
            set Position=FortChar.GetTransform()
        return Position
    
    GetPlayerVehicle(Agent:agent):void=
        var Found:logic=false
        CurrentClass.ClassSelector.ChangeClass(Agent)
        for(PlayerTaggedDevice:PlayerTags,not Found?):
            PlayerTaggedDeviceTags:=PlayerTaggedDevice.GetTags()
            if(PlayerTaggedDeviceTags.Has[CurrentClass.Tag],TrueVehicleSpawner:=vehicle_spawner_device[PlayerTaggedDevice]):
                set Found=true
                set VehicleSpawner=option{TrueVehicleSpawner}
                TrueVehicleSpawner.Enable()
                TrueVehicleSpawner.RespawnVehicle()
        spawn{Assign(Agent)}

    Assign(Agent:agent)<suspends>:void=
        Sleep(2.0)
        if(TrueVehicleSpawner:=VehicleSpawner?):
            TrueVehicleSpawner.AssignDriver(Agent)
        if:
            ClassTag:=CurrentClass.Tag
            MovementPropTagged:=GetCreativeObjectsWithTags(
                    tag_search_criteria:
                        RequiredTags:=array{PropTag{},MovementModulatorTag{},ClassTag}
            )
            MovementProp:=creative_prop[MovementPropTagged[0]]
        then:
            Print("Prop found")
            PlayerPosition:=GetTransform().Translation+vector3{Z:=-300.0}
            if(MovementProp.TeleportTo[PlayerPosition,rotation{}]):
                Print("Prop to vehicle")
            Sleep(0.01)
            if(MovementProp.TeleportTo[vector3{X:=-19905.0, Y:=24433.0, Z:=5050.0},rotation{}]):
                Print("Prop reset")
        #Let's hope at some point this get fixed
        <#if:
            MovementModulatorTagged:=GetCreativeObjectsWithTags(
                    tag_search_criteria:
                        RequiredTags:=array{CurrentClass.Tag,MovementModulatorTag{}}
            )
            MovementModulator:=movement_modulator_device[MovementModulatorTagged[0]]
        then:
            Print("Assigning speed")
            MovementModulator.Activate(Agent)
            if(FortChar:=Player.GetFortCharacter[]):
                Print("Fort Char found")
                if(PlayerVehicle:=FortChar.GetVehicle[],VehicleLocation:=PlayerVehicle.GetTransform()):
                    Print(" Player Vehicle found")
                    if(VehicleAgent:=agent[PlayerVehicle]):
                        Print("Vehicle Agent found")
                        MovementModulator.Activate(VehicleAgent)#>

    UpdateLaps(Agent:agent):int=
        Print("Lap completed")
        set LapsDone+=1
        if:
            LapsDone=2
            LapsDoneHUDs:=GetCreativeObjectsWithTag(LastLapHUDTag{})
        then:
            Print("Last Lap!!!")
            for(LapsDoneHUD:LapsDoneHUDs,HUD:=hud_message_device[LapsDoneHUD]):
                HUD.Show(Agent)
        return LapsDone

    Dispose():void=
        Print("Cleaning up.")

vehicle_class:=class<unique>():
    var Tag:tag
    var VehicleSpawners:[]creative_object_interface=array{}
    var ClassSelector:class_and_team_selector_device=class_and_team_selector_device{}
    
    Init():void=
        set VehicleSpawners=GetCreativeObjectsWithTags(
            tag_search_criteria:
                RequiredTags:=array{Tag}
                ExclusionTags:=array{MovementModulatorTag{}}
            )
