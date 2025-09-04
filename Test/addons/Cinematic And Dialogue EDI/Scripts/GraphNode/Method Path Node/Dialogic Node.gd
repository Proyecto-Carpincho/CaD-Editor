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
		labelAutoload.text = "Autoload Node: "+cinematicData.dialogAutoload
		labelSignal.text = "Signal: "+cinematicData.dialogSignal
		labelMethod.text = "Method: "+cinematicData.dialogMethod
	optionNode = get_node("NodeContainer/Node To Exe/DialogicNode/Node/Node Method/HBoxContainer/OptionNode")
	optionMethod = get_node("NodeContainer/Node To Exe/DialogicNode/Node/Node Method/HBoxContainer2/OptionMethod")
	setNodePathsOptions()

func _process(_delta: float) -> void:
	if not cinematicData:
		setCinematicData()

	if cinematicData and not equalsList():
		setNodePathsOptions()
	
	if cinematicData:
		if labelAutoload.text.replace("Autoload Node: ","") != cinematicData.dialogAutoload:
			labelAutoload.text = "Autoload Node: "+cinematicData.dialogAutoload
		
		if labelSignal.text.replace("Signal: ","") != cinematicData.dialogSignal:
			labelSignal.text = "Signal: "+cinematicData.dialogSignal
		
		if labelMethod.text.replace("Method: ","") != cinematicData.dialogMethod:
			labelMethod.text = "Method: "+cinematicData.dialogMethod


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
		if file_path.is_empty():
			PushErrorLog("The file path is empty")
		else:
			PushErrorLog("This file no exist, file path:\""+ file_path+" \"")
		return []
	# Read a CSV file line by line, splitting on commas
	var result:Array = []
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return result

	while not file.eof_reached():
		var line := file.get_line()
		var row := line.strip_edges().split(",", false)
		result.append(row)

	file.close()
	
	return result

func _KeyEdit_changed(newText: String) -> void:
	for line:Array in LoadCVS(cinematicData.dialogFile):
		if line.size() <= 2:
			continue
		if line[0] == newText:
			get_node("KeyContainer/Key/Text/RichText Display").text = line[1]
			keyName = newText
			return
	
	get_node("KeyContainer/Key/Text/RichText Display").text = "Invalid Key"
	keyName = newText

func StartAction()->void:
	
	var methodPath:NodePath = cinematicData.listNodePaths[indexNode]
	match typeNode:
		0:#Autoload
			var auxAutoload:Node=CinematicEditor.getNode("/root/"+cinematicData.dialogAutoload)
			auxAutoload.call(cinematicData.dialogMethod,keyName)
			if waitSignal:
				await Signal(auxAutoload,cinematicData.dialogSignal)
		1:#Nodes
			var node = CinematicEditor.getNode(methodPath)
			
			node.call(methodName,keyName)
			if waitSignal:
				var signalOfNode:String = get_node("NodeContainer/Node To Exe/DialogicNode/Signals/Line Signal").text
				if node.has_signal(signalOfNode):
					await Signal(node,signalOfNode)
				else:
					push_error("No exist the signal: \"", signalOfNode, "\" in node: ",node.name)
	EmitNextNodeSignal()
