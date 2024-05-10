using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

Collectible_Handler := class():
    Device:Game_Manager
    N:int
    HandlerFunction(Agent:agent):void=
        Device.GlassCollected(Agent,N)