@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"
@export var typeNode:int
@export var waitSignal:bool
@export var autoloadSignal:String
@export var autoloadName:String


func _ready() -> void:
	OptionNode = get_node("NodeContainer/Node To Exe/DialogicNode/Node/Node Method/HBoxContainer/OptionNode")
	OptionMethod = get_node("NodeContainer/Node To Exe/DialogicNode/Node/Node Method/HBoxContainer2/OptionMethod")
	SetNodePathsOptions()

func _ButtonKey_Pressed() -> void:
	get_node("KeyContainer").visible=false
	get_node("NodeContainer").visible=true

func _ButtonNode_Pressed() -> void:
	get_node("KeyContainer").visible=true
	get_node("NodeContainer").visible=false

func _CheckWait_Toggled(toggled_on: bool) -> void:
	get_node("NodeContainer/Node To Exe/DialogicNode/Signals").set_visible(toggled_on)
	waitSignal=toggled_on

func _OptionLocation_Selected(index: int) -> void:
	typeNode=index
	get_node("NodeContainer/Node To Exe/DialogicNode/Node/Label Autoload").set_visible(index==0)
	get_node("NodeContainer/Node To Exe/DialogicNode/Signals/Label Signal").set_visible(index==0)
	get_node("NodeContainer/Node To Exe/DialogicNode/Node/Node Method").set_visible(index==1)
	get_node("NodeContainer/Node To Exe/DialogicNode/Signals/Line Signal").set_visible(index==1)
