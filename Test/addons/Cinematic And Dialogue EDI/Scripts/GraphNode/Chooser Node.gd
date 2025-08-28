@tool
extends CinematicNode
class_name ChooserNode

@onready var OptionNode:OptionButton = get_node("TabContainer/Create/OptionNode")
@onready var ListVBox:VBoxContainer = get_node("TabContainer/List/VBoxContainer")
@onready var Parent:Node = get_parent()
var ChoiseNode:PackedScene=preload("res://addons/Cinematic And Dialogue EDI/Scenes/GraphNode/Choice Node.tscn")
@export var listChoice:Array[String]
@export var nameComprobation:String
var Flags:int

func _ready() -> void:
	if not is_inside_tree():
		await tree_entered
	
	if nameComprobation != name:
		nameComprobation = name
		listChoice.clear()
		for richtext:RichTextLabel in ListVBox.get_children():
			richtext.queue_free()
		setNewID(name,false)
	
	if "@" in name:
		setNewID(name.replace("@",""))

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
	
	for i in range(listChoice.size()):
		
		var previousName=listChoice[i]
		var ChoiseNode = GraphEditor.get_node(previousName)
		
		i +=1
		ChoiseNode.setSelfName("Choise " + str(i))
		ChoiseNode.setCreatorID(name)
		listChoice[i-1] = ChoiseNode.name
		ListVBox.get_child(i).text = "[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]"+ ("Choise " + str(i)) + "[/color] [/pulse]"

func _ButtonCreate_Pressed() -> void:
	
	var GraphEditor:GraphEdit=Parent
	var NewChoiseNode:GraphNode = ChoiseNode.instantiate()
	GraphEditor.add_child(NewChoiseNode)
	
	
	NewChoiseNode.position_offset = position_offset + Vector2(size.x+10,0)
	NewChoiseNode.setSelfName("Choise " + str(listChoice.size() + 1))
	NewChoiseNode.setCreatorID(name)
	
	listChoice.append(NewChoiseNode.name)
	setNewRich(NewChoiseNode.name.replace(name,""))

func setNewRich(text:String):
	var newChoiseRich = RichTextLabel.new()
	ListVBox.add_child(newChoiseRich)
	newChoiseRich.custom_minimum_size = Vector2(0,30)
	newChoiseRich.bbcode_enabled = true
	
	newChoiseRich.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	newChoiseRich.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	newChoiseRich.text = "[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]"+ text + "[/color] [/pulse]"

func Erasing()->void:
	for nameNode:String in listChoice:
		var node:Node = Parent.get_node_or_null(nameNode)
		if node:
			node.queue_free()

func Duplicating()->CinematicNode:
	var listTextChoise:Array[RichTextLabel]
	for richText:RichTextLabel in ListVBox.get_children():
		listTextChoise.append(richText.duplicate())
		richText.free()
	var dupNode = self.duplicate()
	
	for DuprichText:RichTextLabel in listTextChoise:
		ListVBox.add_child(DuprichText)
	return dupNode

func setNewID(newName:String, ChangeName:bool=true)->void:
	var A:String = name
	if newName.is_empty():
		return
	if ChangeName:
		name = newName
		nameComprobation = name
		if name != newName:
			CinematicEditor.setLogConsole("That ID already exists for another node",CinematicEditor.CONSOLE_ENUM.WARNING,3)
	
	get_node("TabContainer/ID/Actual ID/RichTextLabel").text = name
	if listChoice.size() == 0:
		return
	for nodeName:String in listChoice:
		var GraphEditor:GraphEdit=Parent
		var ChoiceNode = GraphEditor.get_node(nodeName)
		ChoiceNode.setCreatorID(name)
		if ChangeName:
			listChoice[listChoice.find(nodeName)] = listChoice[listChoice.find(nodeName)].replace(A, name)

func setSlotData(Var:Variant,slot:int)->void:
	if typeof(Var) == TYPE_INT:
		Flags = Var
	else:
		PushErrorLog("The data type that reaches \" "+ name + "\" is not an int, type (in enum): "+ str(typeof(Var)))

func StartAction():
	ArrayFlag = getSelectedFlag(Flags,listChoice)
	EmitNextNodeSignal()
	
var ArrayFlag:Array[String]
func getSelectedFlag(mask: int, array: Array[String]) -> Array:
	var result:Array[String] = []
	var max_mask = (1 << array.size()) - 1
	if max_mask < mask:
		return array

	for i in range(array.size()):
		if mask & (1 << i):
			result.append(array[i])
	return result
