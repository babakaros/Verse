using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

# A handler function to use on interactedwithevent
ClassSelectionButton_Handler := class():
    Frame:int
    CustomUI:custom_ui_creator
    HandlerFunction(Wdata:widget_message):void=
        CustomUI.CSButtonPressed(Wdata,Frame)