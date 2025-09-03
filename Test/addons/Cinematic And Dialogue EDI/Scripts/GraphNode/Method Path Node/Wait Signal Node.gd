@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"

@export var signalName:StringName

func _ready() -> void:
	setCinematicData()
	optionNode = get_node("HBoxContainer/VBoxContainer/HBoxContainer/OptionButton")

func _get_property_list() -> Array[Dictionary]:
	return [setCinematicProperty()]

func _process(delta: float) -> void:
	if cinematicData:
		setCinematicData()
	
	if not equalsList() and cinematicData:
		setNodePathsOptions()

func StartAction()->void:
	var methodPath:NodePath = cinematicData.listNodePaths[indexNode]
	var nodeToWait:Node = CinematicEditor.getNode(methodPath)
	
	if nodeToWait.has_signal(signalName):
		await Signal(nodeToWait,signalName)
		
	else:
		var errorTextSignal:String = "The signal \""+ signalName +"\"" + " does not exist in the node \""+ nodeToWait.name + "\""
		PushErrorLog(errorTextSignal)

	EmitNextNodeSignal()


func _LineEdit_Change(newText: String) -> void:
	signalName=newText
