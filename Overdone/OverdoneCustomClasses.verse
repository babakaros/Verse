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
start:=class(tag){}
level1:=class(tag){}
level2:=class(tag){}
buttondevice:=class(tag){}
trashcan:=class(tag){}
cuttingboard:=class(tag){}
cleanplate:=class(tag){}
dirtyplate:=class(tag){}
stove:=class(tag){}
pot1:=class(tag){}
pot2:=class(tag){}
pot3:=class(tag){}
pot4:=class(tag){}
sink:=class(tag){}
carrot:=class(tag){}
chicken:=class(tag){}
cucumber:=class(tag){}
potato:=class(tag){}
rice:=class(tag){}
seaweed:=class(tag){}
fishzone:=class(tag){}
waiter:=class(tag){}

## Custom player ##
custom_player:=class<unique>():
    Player:player
    var InventoryFull:logic=false
    var ItemCarrying:[]item=array{}
    var Position:transform=transform{}
    ClearVFXTrigger:trigger_device
    var GamesPlayed:int=0
    ChefsHat:visual_effect_powerup_device
    GoldChefsHat:visual_effect_powerup_device

    Init():void=
        if(Agent:=agent[Player],FortChar:=Agent.GetFortCharacter[]){}
        if(Agent:=agent[Player],GamesPlayed<10):
            ChefsHat.Pickup(Agent)
        else if(Agent:=agent[Player]):
            GoldChefsHat.Pickup(Agent)

    PickingUpItem(Item:item):logic=
        if(not InventoryFull?):
            Item.Dispose()
            set InventoryFull = true
            set ItemCarrying += array{Item}
            spawn{Carry()}
            return true
        if:
            InventoryFull?
            ContainerCarrying:=ItemCarrying[0]
            Plate:=container[ContainerCarrying]
            Plate.Contains.Length<Plate.Size
            PreparedIngredient:=ingredient[Item]
            PreparedIngredient.Prepared?
        then:
            Item.Dispose()
            Plate.Fill(array{PreparedIngredient},Self)
            return true
        return false

    Carry<private>()<suspends>:void=
        loop:
            if(Agent:=agent[Player]):
                if(Item:=ItemCarrying[0]):
                    Item.ItemVFX().Pickup(Agent)
                Sleep(0.25)
                ClearVFXTrigger.Trigger(Agent)
            if(not InventoryFull?):
                break

    DiscardingItem():void=
        if(InventoryFull?):
            if(Agent:=agent[Player]):
                ClearVFXTrigger.Trigger(Agent)
            set InventoryFull = false
            set ItemCarrying = array{}
    
    Dispose():void=
        Print("Cleaning up.")

## Levels ##
custom_level:=class():
    StringToMessage<private><localizes>(S:string):message="{S}"
    var LevelName:?string
    var TrueLevelName<private>:string=""
    var LevelIcon:?texture
    var TrueLevelIcon<private>:texture=Icons.IC_MapCode
    var RecipeIcon:?texture
    var TrueRecipeIcon:texture=Icons.IC_MapCode
    ButtonClickedEvent<public> : event(widget_message) = event(widget_message){}
    var WdataArray:[]widget_message=array{}
    var LevelTag:?tag
    var TrueLevelTag<private>:tag=start{}
    var PlayersSpawner:[]player_spawner_device=array{}
    var Camera:gameplay_camera_fixed_point_device=gameplay_camera_fixed_point_device{}
    var Teleporter:teleporter_device=teleporter_device{}
    var LevelRandomIngredients:?[]ingredient
    var TrueLevelRandomIngredients:[]ingredient=array{}
    var StandardSlots:?[]ingredient
    var MaxIngredients:int
    #recipe template: ?type

    StackBoxCreator():stack_box=
        if(Name:=LevelName?,Icon:=LevelIcon?,IconRecipe:=RecipeIcon?,Tag:=LevelTag?,Ingredients:=LevelRandomIngredients?):
            set TrueLevelName=Name
            set TrueLevelIcon=Icon
            set TrueRecipeIcon=IconRecipe
            set TrueLevelTag=Tag
            set TrueLevelRandomIngredients=Ingredients
        Print("Creating {TrueLevelName}'s stack box.")

        #### Setting up stacks variables ####
        TrueLevelNameText := text_block:
            DefaultText:=StringToMessage(TrueLevelName) 
            DefaultTextColor:=White
            DefaultShadowColor:=Black
            DefaultShadowOffset:=option{vector2{X:=2.0,Y:=2.0}}
        TrueLevelNameText.SetShadowOpacity(1.0)
        LevelTextureBlock := texture_block:
            DefaultImage:= TrueLevelIcon
            DefaultDesiredSize := vector2{X := 250.0, Y := 250.0}
        Button := button_regular:
            DefaultText:=StringToMessage("Vote")
        Button.OnClick().Subscribe(HandleButton)
        
        #### Creating stack ####
        LevelStack := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Widget := LevelTextureBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=0.0,Left:=0.0,Bottom:=5.0,Right:=0.0}
                stack_box_slot:
                    Widget := TrueLevelNameText
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=0.0,Left:=0.0,Bottom:=10.0,Right:=0.0}
                stack_box_slot:
                    Widget := Button
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
        return LevelStack
    
    HandleButton(Wdata:widget_message):void=
        Print("{TrueLevelName} button clicked!")
        if(set WdataArray[0]=Wdata):
            Print("Done")
        else:
            Print("WdataArray is empty. Adding first element...")
            set WdataArray += array{Wdata}
        ButtonClickedEvent.Signal(Wdata)

    Start():void=
        Print("Start")
        TaggedLevelDevices:=GetCreativeObjectsWithTag(TrueLevelTag)
        for(TaggedDevice:TaggedLevelDevices):
            Print("Device found")
            if(PlayerTeleporter:=teleporter_device[TaggedDevice]):
                Print("Teleporter Enabled")
                PlayerTeleporter.Enable()
                set Teleporter=PlayerTeleporter
            if(CameraDevice:=gameplay_camera_fixed_point_device[TaggedDevice]):
                Print("Camera found")
                set Camera=CameraDevice
                Camera.Enable()
                Camera.AddToAll()

## Difficulty 
difficulty:=class():
    DifficultyName:string
    ExpireOrder:float  
    DeliverOrderPoints:int
    var MinAwardingXP:accolades_device=accolades_device{}
    var MidAwardingXP:accolades_device=accolades_device{}
    var MaxAwardingXP:accolades_device=accolades_device{}

## Items ##
dropped_item:=class():
    Item:item
    Position:vector3

item := class():
    Type : string ="Null"
    ItemName : string
    var DroppedProp:creative_prop=creative_prop{}
    var Mesh:creative_prop_asset = DefaultCreativePropAsset
    var VFX:visual_effect_powerup_device=visual_effect_powerup_device{}

    ItemMesh():creative_prop_asset=
        return Mesh
    
    ItemVFX():visual_effect_powerup_device=
        return VFX

    Clone():item=
        var NewItem:item=item{ItemName:=ItemName}
        case(Type):
            "Ingredient"=>
                if(IngredientItem:=ingredient[Self]):
                    NewIngredient:ingredient=ingredient{
                        ItemName:=IngredientItem.ItemName
                        ItemChoppable:=IngredientItem.ItemChoppable
                        ItemBoilable:=IngredientItem.ItemBoilable
                        Prepared:=IngredientItem.Prepared
                        Mesh:=IngredientItem.Mesh
                        ItemIcon:=IngredientItem.ItemIcon
                        VFX:=IngredientItem.VFX
                        MeshChopped:=IngredientItem.MeshChopped
                        VFXChopped:=IngredientItem.VFXChopped
                        IconVFX:=IngredientItem.IconVFX
                        }
                    set NewItem = NewIngredient
            "Container"=>
                if(ContainerItem:=container[Self]):
                    NewContainer:container=container{
                        ItemName:=ContainerItem.ItemName
                        Mesh:=ContainerItem.Mesh
                        VFX:=ContainerItem.VFX
                        MeshFull:=ContainerItem.MeshFull
                        MeshDirty:=ContainerItem.MeshDirty
                        VFXFull:=ContainerItem.VFXFull
                        VFXDirty:=ContainerItem.VFXDirty
                        Deliverable:=true
                        }
                    set NewItem = NewContainer
            _=>
                Item:item=item{ItemName:=ItemName}
                set NewItem=Item
        return NewItem
    
    Dropped(Position:vector3,Rotation:rotation):void=
        SpawnedProp:=SpawnProp(ItemMesh(),Position-vector3{X:=0.0,Y:=0.0,Z:=50.0},Rotation)
        if(MaybeDroppedProp:=SpawnedProp(0)?):
            set DroppedProp=MaybeDroppedProp

    Dispose():void=
        DroppedProp.Dispose()

ingredient:=class(item):
    Type<override>:string="Ingredient"
    ItemIcon:texture
    ItemChoppable:logic
    ItemBoilable:logic
    var IconVFX:?particle_system=false
    var MeshChopped:creative_prop_asset
    var VFXChopped:visual_effect_powerup_device
    var Chopped:logic=false
    var Prepared:logic=false
    var Overcooked:logic=false
    var SpawnedVFX:?cancelable=false

    ItemMesh<override>():creative_prop_asset=
        if(Chopped?):
            return MeshChopped
        return Mesh

    ItemVFX<override>():visual_effect_powerup_device=
        if(Chopped?):
            return VFXChopped
        return VFX

    SpawnVFXInPot(Position:vector3):void=
        if(IsIconVFX:=IconVFX?):
            set SpawnedVFX=option{SpawnParticleSystem(IsIconVFX,Position)}

    Chopping():void=
        if(ItemChoppable?,not Chopped?):
            set Chopped = true
            ItemMesh()
            if(not ItemBoilable?):
                set Prepared=true
                
container:=class(item):
    Type<override>:string="Container"
    Deliverable:logic
    var Contains:[]ingredient=array{}
    Size:int=3
    var Dirty:logic=false
    var MeshFull :creative_prop_asset = DefaultCreativePropAsset
    var MeshDirty :creative_prop_asset = DefaultCreativePropAsset
    var VFXFull:visual_effect_powerup_device=visual_effect_powerup_device{}
    var VFXDirty:visual_effect_powerup_device=visual_effect_powerup_device{}
    
    ItemMesh<override>():creative_prop_asset=
        if(Dirty?):
            return MeshDirty
        else if(Contains.Length>0):
            return MeshFull
        return Mesh

    ItemVFX<override>():visual_effect_powerup_device=
        if(Dirty?):
            return VFXDirty
        else if(Contains.Length>0):
            return VFXFull
        return VFX

    Fill(IngredientArray:[]ingredient,Player:custom_player):void=#If i am holding a semifull plate and I interact with the pot it takes all the ingredients, find a workaround
        if(Contains.Length<Size):
            set Contains += IngredientArray
            if(Player.ItemCarrying[0].Type="Ingredient"):
                Player.DiscardingItem()
            if(PotContainer:=pot[Self]):
                PotContainer.IngredientVFX()
                if(Contains.Length = Size):
                    spawn{PotContainer.Boil(Contains)}

    WashDish(Player:custom_player):void=
        Print("Dish washed.")
        Player.DiscardingItem()
        set Dirty=false
        SpawnProp(ItemMesh(),vector3{X:=693.0,Y:=411.0,Z:=100.0},rotation{})
        
    Empty():void=
        Print("Emptying {Self.ItemName}...")
        set Contains = array{}

pot:=class(container):
    Type<override>:string="Pot"
    Position:vector3
    BoilTime:float=8.0
    var Boiled:logic=false
    var Burnt:logic=false
    var SpawnedTickVFX:?cancelable=false
    var SoupProp<private>:creative_prop=creative_prop{}
    var SoupMesh:?creative_prop_asset
    var BellRing:audio_player_device=audio_player_device{}

    IngredientVFX():void=
        N:=Contains.Length-1
        SoupProp.Dispose()
        if(Soup:=SoupMesh?,SpawnedSoup:=SpawnProp(Soup,Position+vector3{Z:=12.0+N*7.0},rotation{})):
            if(MaybeSpawnedSoup:=SpawnedSoup(0)?,set SoupProp=MaybeSpawnedSoup){}
            if(LastIngredient:=Contains[N]):
                VFXPosition:=Position+vector3{X:=(N-1)*70.0,Y:=20.0,Z:=80.0}
                LastIngredient.SpawnVFXInPot(VFXPosition)
                Print("We got last ingredient too")

    Boil(Ingredients:[]ingredient)<suspends>:void= #when the pot becomes full change text to serv soup
        Print("Start boiling.")
        Sleep(BoilTime)
        set SpawnedTickVFX=option{SpawnParticleSystem(Niagara.NS_Tick,vector3{X:=Position.X,Y:=Position.Y+80.0,Z:=Position.Z+75.0})}
        set Boiled = true
        for(Ingredient:Ingredients):
            set Ingredient.Prepared = true
        BellRing.Play()
        Sleep(8.0)
        if(Tick:=SpawnedTickVFX?):
            Tick.Cancel()
        if(Contains.Length=Size):
            set SpawnedTickVFX=option{SpawnParticleSystem(Niagara.NS_Ex,vector3{X:=Position.X,Y:=Position.Y+80.0,Z:=Position.Z+75.0})}
            set Burnt = true
            for(Ingredient:Ingredients):
                set Ingredient.Overcooked = true

    Empty<override>():void=
        Print("Emptying {Self.ItemName}...")
        for(Ingredient:Contains):
            if(HasVFX:=Ingredient.SpawnedVFX?):
                HasVFX.Cancel()
            SoupProp.Dispose()
        set Contains = array{}

recipe:=class<unique>():
    BGTexture:texture=Icons.IC_OrderBG
    var RecipeIcon:texture
    var Ingredients:[]ingredient=array{}
    var Completed:logic=false
    var RecipeCanvas:canvas=canvas{}
    var MaxTime:float
    var RecipeUniqueID:int
    TimeOutEvent<public>:event(float)=event(float){}
    MakeRecipeCanvas(Stack:widget):canvas=
        var UrgencyColorBlock:color_block=color_block{DefaultColor:=color{G:=1.0},DefaultDesiredSize:=vector2{X:=145.0,Y:=235.0}}
        Canvas:canvas=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=Stack
                    Anchors := anchors:
                        Minimum := vector2{X := 0.75, Y := 0.5}
                        Maximum := vector2{X := 0.75, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    ZOrder:=4
                canvas_slot:
                    Widget:=texture_block{DefaultImage:=RecipeIcon,DefaultDesiredSize:=vector2{X:=150.0,Y:=150.0}}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.5}
                        Maximum := vector2{X := 0.0, Y := 0.5}
                    Alignment := vector2{X := 0.45, Y := 0.5}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    ZOrder:=3
                canvas_slot:
                    Widget:=texture_block{DefaultImage:=Icons.IC_OrderSoupBG,DefaultDesiredSize:=vector2{X:=120.0,Y:=120.0}}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0, Y := 0.5}
                        Maximum := vector2{X := 0.0, Y := 0.5}
                    Alignment := vector2{X := 0.45, Y := 0.5}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    ZOrder:=2
                canvas_slot:
                    Widget:=UrgencyColorBlock
                    Anchors := anchors:
                        Minimum := vector2{X := 0.57, Y := 0.5}
                        Maximum := vector2{X := 0.57, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    ZOrder:=1
                canvas_slot:
                    Widget:=texture_block{DefaultImage:=BGTexture,DefaultDesiredSize:=vector2{X:=160.0,Y:=250.0}}
                    Anchors := anchors:
                        Minimum := vector2{X := 0.57, Y := 0.5}
                        Maximum := vector2{X := 0.57, Y := 0.5}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    ZOrder:=0
        UrgencyColorBlock.SetOpacity(0.5)
        set RecipeCanvas=Canvas
        spawn{RefreshRecipe(UrgencyColorBlock)}
        return Canvas

    RefreshRecipe<private>(UrgencyColorBlock:color_block)<suspends>:void =
        var TotalTime:float = 0.0
        Interval:=MaxTime/100.0
        var Color:color=color{}
        var N:int=1
        loop:
            set TotalTime+=Interval
            set Color=color{R:=0.02*N,G:=0.02*(100-N)}
            UpdateUI(UrgencyColorBlock,Color)
            set N+=1
            if(TotalTime>=MaxTime):
                break
            Sleep(Interval)
       
    UpdateUI<private>(UrgencyColorBlock:color_block,Color:color):void=
        UrgencyColorBlock.SetColor(Color)

    KillRecipe()<suspends>:void=
        Sleep(MaxTime)
        TimeOutEvent.Signal(MaxTime)
