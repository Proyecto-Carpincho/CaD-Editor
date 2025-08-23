@tool
extends "res://addons/Cinematic And Dialogue EDI/Scripts/GraphNode/Method Path Node/Method Path Node.gd"
@export var typeNode:int
@export var waitSignal:bool

@export var autoloadSignal:String
@export var autoload:String
@export var autoloadMethod:String
@export var filePath:String
@export var keyName:String
@onready var labelSignal:Label  = $"NodeContainer/Node To Exe/DialogicNode/Signals/Label Signal"
@onready var labelAutoload:Label = $"NodeContainer/Node To Exe/DialogicNode/Node/Node Autoload/Label Autoload"
@onready var labelMethod:Label = $"NodeContainer/Node To Exe/DialogicNode/Node/Node Autoload/Label Method"

func _ready() -> void:
	if getGraph():
		filePath = CinematicEditor.DialogFile
		autoloadSignal = CinematicEditor.DialogSignal
		autoload = CinematicEditor.DialogAutoload
		autoloadMethod = CinematicEditor.DialogMethod
		_KeyEdit_changed(keyName)
		get_node("KeyContainer/Key/Text/KeyEdit").text = keyName
	labelAutoload.text = "Autoload Node: "+autoload
	labelSignal.text = "Signal: "+autoloadSignal
	labelMethod.text = "Method: "+autoloadMethod
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
	const Path:String = "NodeContainer/Node To Exe/DialogicNode/"
	get_node(Path+"Node/Node Autoload").set_visible(index==0)
	get_node(Path+"Signals/Label Signal").set_visible(index==0)
	get_node(Path+"Node/Node Method").set_visible(index==1)
	get_node(Path+"Signals/Line Signal").set_visible(index==1)
	size = Vector2(0,225)

func LoadCVS(file_path: String) -> Array:
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
	for line:Array in LoadCVS(filePath):
		if line.size() <= 2:
			continue
		if line[0] == newText:
			get_node("KeyContainer/Key/Text/RichText Display").text = line[1]
			keyName = newText
			return
	
	get_node("KeyContainer/Key/Text/RichText Display").text = "Invalid Key"

func StartAction()->void:
	var indexNode=listNode.find(methodNode)
	if listNode.size() == CinematicEditor.listNodePaths.size():
		listNode=CinematicEditor.listNodePaths
		methodNode=listNode[indexNode]
	match typeNode:
		0:#Autoload
			var auxAutoload:Node=CinematicEditor.getNode("/root/"+autoload)
			auxAutoload.call(autoloadMethod,keyName)
			if waitSignal:
				await Signal(auxAutoload,autoloadSignal)
		1:#Nodes
			CinematicEditor.getNode(methodNode).call(methodName,keyName)
			if waitSignal:
				await Signal(CinematicEditor.getNode(methodNode),get_node("NodeContainer/Node To Exe/DialogicNode/Signals/Line Signal").text)
	EmitNextNode()
