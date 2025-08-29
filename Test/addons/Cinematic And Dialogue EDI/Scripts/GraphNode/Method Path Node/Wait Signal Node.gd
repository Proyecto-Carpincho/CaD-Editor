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
	var nodeToWait:Node = CinematicEditor.getNode(methodPath)
	
	if nodeToWait.has_signal(SignalName):
		
		await Signal(nodeToWait,SignalName)
	else:
		var errorTextSignal:String = "The signal \""+ SignalName +"\"" + " does not exist in the node \""+ nodeToWait.name + "\""
		if CinematicEditor.editorGraph:
			CinematicEditor.setLogConsole(errorTextSignal, CinematicEditor.CONSOLE_ENUM.ERROR)
		else:
			push_error(errorTextSignal)
	
	EmitNextNodeSignal()


func _LineEdit_Change(new_text: String) -> void:
	SignalName=new_text
