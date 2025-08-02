@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"

@onready var TabCon:TabContainer = get_node("VBoxContainer/TabContainer")
@onready var Parameter:Node = get_node("Param 1")
@export var ExtraParam:int=0
var SlotData:Dictionary[int,Variant]={}

func _get_property_list() -> Array[Dictionary]:
	var properties:Array[Dictionary]
	properties.append({
		"name": "SlotData",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	return properties

func _ready() -> void:
	OptionNode = get_node("VBoxContainer/TabContainer/Node/HBoxContainer/OptionNode")
	OptionMethod = get_node("VBoxContainer/TabContainer/Method/HBoxContainer/OptionMethod")
	SetNodePathsOptions()

func _ViewMethods_pressed() -> void:
	get_node("Create Parm/View Methods").set_visible(false)
	TabCon.set_visible(true)
	TabCon.current_tab = 1

func _TabContiner_Pressed(tab: int) -> void:
	if tab == 2:
		get_node("Create Parm/View Methods").set_visible(true)
		TabCon.set_visible(false)
		TabCon.current_tab = 1

func _AddButton_pressed() -> void:
	ExtraParam+=1
	if ExtraParam > 1:
		add_child(Parameter.duplicate())
		get_child(ExtraParam+3).get_node("Panel/Param").text="[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]  Parameter   -"+str(ExtraParam)+ "- [/color] [/pulse]"
		get_child(ExtraParam+3).set_visible(true)
		get_child(ExtraParam+3).name = "Param "+ str(ExtraParam)
	else:
		Parameter.set_visible(true)
	set_slot(ExtraParam+2,true,1,Color(0.0, 0.529, 0.502),false,0,Color.BLACK)

func _RemoveButton_pressed() -> void:
	if ExtraParam-1 >= 0:
		if ExtraParam > 1:
			get_node("Param "+ str(ExtraParam)).queue_free()
		else:
			Parameter.set_visible(false)
		set_slot(ExtraParam+2,false,1,Color.BLACK,false,0,Color.BLACK)
		ExtraParam-=1
		size.y = 165.0

func SetSlotData(Var:Variant,Slot:int)->void:
	print(Var, " aaa")
	SlotData[Slot]=Var
	SlotData.set(Slot,Var)

func StartAction()->void:
	var indexNode=listNode.find(methodNode)
	if listNode.size() == CinematicEditor.listNodePaths.size():
		listNode=CinematicEditor.listNodePaths
		methodNode=listNode[indexNode]
	var ParametersList:Array
	for i in range(SlotData.size()):
		if ExtraParam -1 > i:
			if SlotData.has(i+1):
				ParametersList.append(SlotData[i+1])
				prints(SlotData, i,ExtraParam -1 > i)
			else:
				push_error("no estan bien asignado los parametros todos los datos: ",SlotData)
				emit_signal("NextNode")
				return
	
	var node:Node=CinematicEditor.GetNode(methodNode)
	node.callv(methodName,ParametersList)
	
	CinematicEditor.connect("Timeout",Timeout)
	CinematicEditor.AwaitTime(0.05,name)
	emit_signal("NextNode")

func Timeout(TimerCreator:String):
	if TimerCreator == name:
		emit_signal("NextNode")
