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
prop_interaction:=class(tag){}

## Custom player ##
custom_player:=class<unique>():
    Player:player
    var HasSpokenToOuji:logic=false
    var GlassesCollected:int=0
    var GlassesFound:[]glasses=array{}
    var Position:transform=transform{}

    Init():void=
        if(Agent:=agent[Player],FortChar:=Agent.GetFortCharacter[]){}
    
    Dispose():void=
        Print("Cleaning up.")

glasses:=class():
    StringToMessage<localizes>(S:string):message="{S}"
    GlassesName:string
    var Found:logic=false
    Thumbnail:texture
    var PreviewThumbnail:texture=Icons.IC_Locked
    Size:vector2=vector2{X:=170.0,Y:=136.0}
    var PreviewSize:vector2=vector2{X:=170.0,Y:=170.0}
    Padding:margin=margin{Top:=32.0,Left:=10.0,Bottom:=32.0,Right:=10.0}
    var PreviewPadding:margin=margin{Top:=15.0,Left:=10.0,Bottom:=15.0,Right:=10.0}
    VFX:visual_effect_powerup_device
    Frame:int
    var GlassPreviewer:cinematic_sequence_device=cinematic_sequence_device{}
    Collectible:collectible_object_device
    MakeStackBoxSlot():stack_box_slot=
        if(Found?):
            set PreviewThumbnail=Thumbnail
            set PreviewSize=Size
            set PreviewPadding=Padding
        GlassesTextureBlock := texture_block:
            DefaultImage:=PreviewThumbnail
            DefaultDesiredSize:=PreviewSize 
        SelectButton:button_regular=button_regular{}
        SelectButton.SetText(StringToMessage("Select"))
        SelectButton.OnClick().Subscribe(SelectGlasses)
        GlassesStackBox:stack_box=stack_box:
            Orientation := orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=GlassesTextureBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=PreviewPadding
                stack_box_slot:
                    Widget:=SelectButton
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
        StackBoxSlot:stack_box_slot=stack_box_slot:
            Widget:=GlassesStackBox
            Padding:=margin{Top:=0.0,Left:=10.0,Bottom:=0.0,Right:=10.0}
        return StackBoxSlot

    SelectGlasses(Wdata:widget_message):void=
        if(Found?,Player:=Wdata.Player,Agent:=agent[Player]):
            Print("{Frame}")
            VFX.Pickup(Agent)
            spawn{GlassPlayback(Agent)}
            
    GlassPlayback(Agent:agent)<suspends>:void=
        var Stopped:logic=false
        GlassPreviewer.SetPlaybackFrame(Frame)
        GlassPreviewer.Play(Agent)
        loop:
            CurrentFrame:=GlassPreviewer.GetPlaybackFrame()
            for(N:=1..12):
                if(CurrentFrame=60*N-1):
                    GlassPreviewer.Pause(Agent)
                    set Stopped=true
                    break
            if(Stopped=true):
                break
            Sleep(1.0/6.0)