using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

# A handler function to use on interactedwithevent
# create an array to keep track of everything and have a max amount og each object in the scene!!!
NewItemPickup_Handler := class():
    Device:Game_Manager
    CustomPlayerArray:[player]custom_player
    Item:item
    HandlerFunction(Agent:agent) : void=
        if(Player:=CustomPlayerArray[player[Agent]]):
            Print("Creating {Item.ItemName}...")
            NewItem:=Item.Clone()
            Player.PickingUpItem(NewItem)
        if(Item.Type="Container"):
            set Device.PlatesTaken+=1

CookingPotInteraction_Handler := class():
    Device:Game_Manager
    CustomPlayerArray : [player]custom_player
    CookingPot:pot
    HandlerFunction(Agent:agent) : void=
        if(Player:=CustomPlayerArray[player[Agent]]):
            Device.CookingPotInteraction(Agent,CookingPot)

DifficultyButton_Handler := class():
    Difficulty:string
    CustomUI:custom_ui_creator
    HandlerFunction(Wdata:widget_message) : void=
        CustomUI.DifficultyVote(Difficulty,Wdata)