@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"
@export var typeNode:int
@export var waitSignal:bool

@export var keyName:String
@onready var labelSignal:Label  = $"NodeContainer/Node To Exe/DialogicNode/Signals/Label Signal"
@onready var labelAutoload:Label = $"NodeContainer/Node To Exe/DialogicNode/Node/Node Autoload/Label Autoload"
@onready var labelMethod:Label = $"NodeContainer/Node To Exe/DialogicNode/Node/Node Autoload/Label Method"


func _get_property_list() -> Array[Dictionary]:
	return [setCinematicProperty()]

func _ready() -> void:
	setCinematicData()
	if getGraph():
		_KeyEdit_changed(keyName)
		get_node("KeyContainer/Key/Text/KeyEdit").text = keyName
	
	if cinematicData:
		labelAutoload.text = "Autoload Node: "+cinematicData.DialogAutoload
		labelSignal.text = "Signal: "+cinematicData.DialogSignal
		labelMethod.text = "Method: "+cinematicData.DialogMethod
	OptionNode = get_node("NodeContainer/Node To Exe/DialogicNode/Node/Node Method/HBoxContainer/OptionNode")
	OptionMethod = get_node("NodeContainer/Node To Exe/DialogicNode/Node/Node Method/HBoxContainer2/OptionMethod")
	setNodePathsOptions()

func _process(_delta: float) -> void:
	if not cinematicData:
		setCinematicData()

	if cinematicData and not equalsList():
		setNodePathsOptions()
	
	if cinematicData:
		if labelAutoload.text.replace("Autoload Node: ","") != cinematicData.DialogAutoload:
			labelAutoload.text = "Autoload Node: "+cinematicData.DialogAutoload
		
		if labelSignal.text.replace("Signal: ","") != cinematicData.DialogSignal:
			labelSignal.text = "Signal: "+cinematicData.DialogSignal
		
		if labelMethod.text.replace("Method: ","") != cinematicData.DialogMethod:
			labelMethod.text = "Method: "+cinematicData.DialogMethod


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
	const Path:String = "NodeContainer/Node To Exe/DialogicNode/"
	get_node(Path+"Node/Node Autoload").set_visible(index==0)
	get_node(Path+"Signals/Label Signal").set_visible(index==0)
	get_node(Path+"Node/Node Method").set_visible(index==1)
	get_node(Path+"Signals/Line Signal").set_visible(index==1)
	size = Vector2(0,225)

func LoadCVS(file_path: String) -> Array:
	if not FileAccess.file_exists(file_path):
		return []
	# Read a CSV file line by line, splitting on commas
	var result:Array = []
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("The file was not found, FileName: " + file_path)
		return result

	while not file.eof_reached():
		var line := file.get_line()
		var row := line.strip_edges().split(",", false)
		result.append(row)

	file.close()
	return result

func _KeyEdit_changed(newText: String) -> void:
	for line:Array in LoadCVS(cinematicData.DialogFile):
		if line.size() <= 2:
			continue
		if line[0] == newText:
			get_node("KeyContainer/Key/Text/RichText Display").text = line[1]
			keyName = newText
			return
	
	get_node("KeyContainer/Key/Text/RichText Display").text = "Invalid Key"

func StartAction()->void:
	
	var methodPath:NodePath = cinematicData.listNodePaths[indexNode]
	match typeNode:
		0:#Autoload
			var auxAutoload:Node=CinematicEditor.getNode("/root/"+cinematicData.DialogAutoload)
			auxAutoload.call(cinematicData.DialogMethod,keyName)
			if waitSignal:
				await Signal(auxAutoload,cinematicData.DialogSignal)
		1:#Nodes
			CinematicEditor.getNode(methodPath).call(methodName,keyName)
			if waitSignal:
				await Signal(CinematicEditor.getNode(methodPath),get_node("NodeContainer/Node To Exe/DialogicNode/Signals/Line Signal").text)
	EmitNextNodeSignal()
