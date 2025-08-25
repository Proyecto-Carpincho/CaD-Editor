@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"

@export var SignalName:StringName

func _ready() -> void:
	setCinematicData()
	OptionNode = get_node("HBoxContainer/VBoxContainer/HBoxContainer/OptionButton")

func _get_property_list() -> Array[Dictionary]:
	return [setCinematicProperty()]

func _process(delta: float) -> void:
	if cinematicData:
		setCinematicData()
	
	if not equalsList() and cinematicData:
		setNodePathsOptions()

func StartAction()->void:
	var methodPath:NodePath = cinematicData.listNodePaths[indexNode]
	print("A",SignalName)
	await Signal(CinematicEditor.getNode(methodPath),SignalName)
	print("v")
	
	EmitNextNodeSignal()


func _LineEdit_Change(new_text: String) -> void:
	SignalName=new_text
