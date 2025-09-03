@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"
class_name MethodNode

@onready var tabCon:TabContainer = get_node("VBoxContainer/TabContainer")
@onready var parameter:Node = get_node("Param 1")
@export var extraParam:int=0
var slotData:Dictionary[int,Variant]

func _get_property_list() -> Array[Dictionary]:
	var properties:Array[Dictionary]
	properties.append({
		"name": "slotData",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	properties.append(setCinematicProperty())
	return properties

func _ready() -> void:
	setCinematicData()
	optionNode = get_node("VBoxContainer/TabContainer/Node/HBoxContainer/OptionNode")
	optionMethod = get_node("VBoxContainer/TabContainer/Method/HBoxContainer/OptionMethod")
	setNodePathsOptions()

func _process(delta: float) -> void:
	if not cinematicData:
		setCinematicData()
	
	if cinematicData and not equalsList():
		setNodePathsOptions()


func _ViewMethods_pressed() -> void:
	get_node("Create Parm/View Methods").set_visible(false)
	tabCon.set_visible(true)
	tabCon.current_tab = 1

func _TabContiner_Pressed(tab: int) -> void:
	if tab == 2:
		get_node("Create Parm/View Methods").set_visible(true)
		tabCon.set_visible(false)
		tabCon.current_tab = 1

func _AddButton_pressed() -> void:
	extraParam+=1
	if extraParam > 1:
		add_child(parameter.duplicate())
		get_child(extraParam+3).get_node("Panel/Param").text="[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]  parameter   -"+str(extraParam)+ "- [/color] [/pulse]"
		get_child(extraParam+3).set_visible(true)
		get_child(extraParam+3).name = "Param "+ str(extraParam)
	else:
		parameter.set_visible(true)
	set_slot(extraParam+2,true,1,Color(0.0, 0.529, 0.502),false,0,Color.BLACK)

func _RemoveButton_pressed() -> void:
	if extraParam-1 >= 0:
		if extraParam > 1:
			get_node("Param "+ str(extraParam)).queue_free()
		else:
			parameter.set_visible(false)
		set_slot(extraParam+2,false,1,Color.BLACK,false,0,Color.BLACK)
		extraParam-=1
		size.y = 165.0

func setSlotData(Var:Variant,Slot:int)->void:
	slotData[Slot]=Var
	slotData.set(Slot,Var)

func StartAction()->void:
	var methodPath:NodePath = cinematicData.listNodePaths[indexNode]
	var parametersList:Array
	
	for i in range(slotData.size()):
		if extraParam < i:
			continue
		if not slotData.has(i+1):
			var errorTextparameters:String = "The parameters are not assigned correctly, all the data: "+ str(slotData)
			PushErrorLog(errorTextparameters)
			EmitNextNodeSignal()
			return
		parametersList.append(slotData[i+1])
	
	var node:Node=CinematicEditor.getNode(methodPath)
	node.callv(methodName,parametersList)

	EmitNextNodeSignal()
