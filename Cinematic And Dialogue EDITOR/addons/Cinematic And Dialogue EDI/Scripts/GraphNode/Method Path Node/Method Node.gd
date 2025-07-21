@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"

@onready var TabCon:TabContainer = get_node("TabContainer")
@onready var Parameter:Node = get_node("Param 1")
@export var ExtraParam:int=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OptionNode = get_node("TabContainer/Node/HBoxContainer/OptionNode")
	OptionMethod = get_node("TabContainer/Method/HBoxContainer/OptionMethod")
	SetNodePathsOptions()


func _ViewMethods_pressed() -> void:
	get_node("Create Parm/View Methods").set_visible(false)
	print(TabCon)
	TabCon.set_visible(true)
	TabCon.current_tab = 1

func _TabContiner_Pressed(tab: int) -> void:
	if tab == 2:
		get_node("Create Parm/View Methods").set_visible(true)
		TabCon.set_visible(false)
		TabCon.current_tab = 1

func _AddButton_pressed() -> void:
	var TuputaMadre:int = -1 if not TabCon.is_visible() else 0
	ExtraParam+=1
	if ExtraParam > 1:
		add_child(Parameter.duplicate())
		get_child(ExtraParam+3).get_node("Panel/Param").text="[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]  Parameter   -"+str(ExtraParam)+ "- [/color] [/pulse]"
		get_child(ExtraParam+3).set_visible(true)
		get_child(ExtraParam+3).name = "Param "+ str(ExtraParam)
	else:
		Parameter.set_visible(true)
	set_slot(ExtraParam+2+TuputaMadre,true,1,Color(0.0, 0.529, 0.502),false,0,Color.BLACK)
		
	
func _RemoveButton_pressed() -> void:
	if ExtraParam-1 >= 0:
		var TuputaMadre:int = -1 if not TabCon.is_visible() else 0	
		if ExtraParam > 1:
			get_node("param "+ str(ExtraParam)).queue_free()
		else:
			Parameter.set_visible(false)
		set_slot(ExtraParam+2+TuputaMadre,false,1,Color.BLACK,false,0,Color.BLACK)
		ExtraParam-=1
		size.y = 165.0
