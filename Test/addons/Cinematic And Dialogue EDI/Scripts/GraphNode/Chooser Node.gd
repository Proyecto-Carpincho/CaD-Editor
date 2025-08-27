@tool
extends CinematicNode

@onready var OptionNode:OptionButton = get_node("TabContainer/Create/OptionNode")
@onready var ListVBox:VBoxContainer = get_node("TabContainer/List/VBoxContainer")
@onready var Parent:Node = get_parent()
var ChoiseNode:PackedScene=preload("res://addons/Cinematic And Dialogue EDI/Scenes/GraphNode/Choice Node.tscn")
@export var listChoice:Array[String]


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not Parent:
			return
		if not Parent.is_node_ready():
			await Parent.ready
		
		if not equals():
			OptionNode.clear()
			for i in range(ListVBox.get_child_count()):
				var richName:String = ListVBox.get_child(i).text
				richName=richName.replace("[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]","")
				richName=richName.replace("[/color] [/pulse]","")
				OptionNode.add_item(richName)

func equals()->bool:
	if ListVBox.get_child_count() != OptionNode.item_count:
		return false
	
	for i:int in range(ListVBox.get_child_count()):
		var richName:String = ListVBox.get_child(i).text
		richName = richName.replace("[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]","")
		richName = richName.replace("[/color] [/pulse]","")
		if OptionNode.get_item_text(i) != richName:
			return false
	
	
	return true

@export var IndexOption:int
func _Selected_OptionNode(index: int) -> void:
	IndexOption=index

func _ButtonDelete_Pressed() -> void:
	if listChoice.size() == 0:
		return
	
	var nodeNameToDelete:String= listChoice[IndexOption]
	var GraphEditor:GraphEdit = Parent
	
	GraphEditor.remove_child(GraphEditor.get_node(nodeNameToDelete))
	listChoice.erase(nodeNameToDelete)
	ListVBox.get_child(IndexOption).queue_free()

	OptionNode.select(listChoice.size()-1)
	IndexOption=0
	

func _ButtonCreate_Pressed() -> void:
	
	var GraphEditor:GraphEdit=Parent
	var NewChoiseNode:GraphNode = ChoiseNode.instantiate()
	GraphEditor.add_child(NewChoiseNode)
	NewChoiseNode.pivot_offset = pivot_offset
	
	NewChoiseNode.setSelfName("Choise " + str(listChoice.size() + 1))
	
	
	listChoice.append(NewChoiseNode.name)
	
	
	var newChoiseRich = RichTextLabel.new()
	ListVBox.add_child(newChoiseRich)
	
	setNewID(name, false)
	ListVBox.move_child(newChoiseRich,-1)
	newChoiseRich.custom_minimum_size = Vector2(0,30)
	newChoiseRich.bbcode_enabled = true
	newChoiseRich.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	newChoiseRich.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	newChoiseRich.text = "[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]"+ "Choise   -"+ str(listChoice.size()) + "[/color] [/pulse]"

func _exit_tree():
	for nameNode:String in listChoice:
		var node:Node = Parent.get_node_or_null(nameNode)
		if node:
			node.queue_free()

func setNewID(newName:String, ChangeName:bool=true)->void:
	if newName.is_empty():
		return
	if ChangeName:
		name = newName
		if name != newName:
			CinematicEditor.setLogConsole("That ID already exists for another node",CinematicEditor.CONSOLE_ENUM.WARNING,3)
	
	get_node("TabContainer/ID/Actual ID/RichTextLabel").text = name
	if listChoice.size() == 0:
		return
	for nodeName:String in listChoice:
		var GraphEditor:GraphEdit=Parent
		var ChoiceNode = GraphEditor.get_node(nodeName)
		ChoiceNode.setCreatorID(name)
