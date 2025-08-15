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

AFKZone_Device := class(creative_device):
    @editable{Categories := array{Currency}} CurrencyManager:Currency_Manager=Currency_Manager{}
    @editable AFK_Mutator : mutator_zone_device = mutator_zone_device{}
    @editable AFK_AwardInterval : float = 1.0

    var AgentInZone : [agent]logic = map{}
    AgentExitedEvent : event(agent) = event(agent){}

    OnBegin<override>()<suspends>:void=
        AFK_Mutator.AgentEntersEvent.Subscribe(AgentEntered)
        AFK_Mutator.AgentExitsEvent.Subscribe(AgentExited)

    AgentEntered(Agent : agent) : void = 
        if(set AgentInZone[Agent] = true) then Print("Brought him in")
        spawn{RewardGranting(Agent)}

    RewardGranting(Agent : agent)<suspends> : void =
        loop:
            race:
                Sleep(AFK_AwardInterval)
                LoopKiller(Agent)
            if(Check := AgentInZone[Agent], not Check?) then break
            CurrencyManager.CurrencyGrant(Agent, currency_grant_type.AFKZone)

    LoopKiller(Agent : agent)<suspends> : void = 
        TestAgent := AgentExitedEvent.Await()
        if(TestAgent = Agent) then return

    AgentExited(Agent : agent) : void = 
        if(set AgentInZone[Agent] = false) then Print("Kicked him out")
        AgentExitedEvent.Signal(Agent)

