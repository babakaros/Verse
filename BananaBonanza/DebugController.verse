
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

DebugController := class(creative_device):

    @editable IntroCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable BathroomDoor : lock_device = lock_device{}

    OnBegin<override>()<suspends>:void=
        Print("Debug Run")

    SetDebugMode(Enabled : logic) : void = 
        Players := GetPlayspace().GetPlayers()
        if (FirstPlayer := Players[0], Agent := agent[FirstPlayer]) :
            if:
                Enabled = true
            then:
                BathroomDoor.Unlock(Agent)
                IntroCinematic.GoToEndAndStop()

