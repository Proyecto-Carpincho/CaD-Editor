@tool
extends CinematicNode
class_name ChooserNode

@onready var optionNode:OptionButton = get_node("TabContainer/Create/OptionNode")
@onready var listVBox:VBoxContainer = get_node("TabContainer/List/VBoxContainer")
@onready var parent:Node = get_parent()
var choiseNode:PackedScene=preload("res://addons/Cinematic And Dialogue EDI/Scenes/GraphNode/Choice Node.tscn")
@export var listChoice:Array[String]
@export var nameComprobation:String
var flags:int

func _ready() -> void:
	if not is_inside_tree():
		await tree_entered
	
	if nameComprobation != name:
		nameComprobation = name
		listChoice.clear()
		for richtext:RichTextLabel in listVBox.get_children():
			richtext.queue_free()
		setNewID(name,false)
	
	if "@" in name:
		setNewID(name.replace("@",""))

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not parent:
			return
		if not parent.is_node_ready():
			await parent.ready
		
		if not equals():
			optionNode.clear()
			for i in range(listVBox.get_child_count()):
				var richName:String = listVBox.get_child(i).text
				richName=richName.replace("[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]","")
				richName=richName.replace("[/color] [/pulse]","")
				optionNode.add_item(richName)

func equals()->bool:
	if listVBox.get_child_count() != optionNode.item_count:
		return false
	
	for i:int in range(listVBox.get_child_count()):
		var richName:String = listVBox.get_child(i).text
		richName = richName.replace("[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]","")
		richName = richName.replace("[/color] [/pulse]","")
		if optionNode.get_item_text(i) != richName:
			return false
	
	
	return true

@export var indexOption:int
func _Selected_optionNode(index: int) -> void:
	indexOption=index

func _ButtonDelete_Pressed() -> void:
	if listChoice.size() == 0:
		return
	
	var nodeNameToDelete:String= listChoice[indexOption]
	var graphEditor:GraphEdit = parent
	
	graphEditor.remove_child(graphEditor.get_node(nodeNameToDelete))
	listChoice.erase(nodeNameToDelete)
	listVBox.get_child(indexOption).queue_free()

	optionNode.select(listChoice.size()-1)
	indexOption=0
	
	for i in range(listChoice.size()):
		
		var previousName=listChoice[i]
		var choiseNode = graphEditor.get_node(previousName)
		
		i +=1
		choiseNode.setSelfName("Choise " + str(i))
		choiseNode.setCreatorID(name)
		listChoice[i-1] = choiseNode.name
		listVBox.get_child(i).text = "[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]"+ ("Choise " + str(i)) + "[/color] [/pulse]"

func _ButtonCreate_Pressed() -> void:
	
	var graphEditor:GraphEdit=parent
	var NewchoiseNode:GraphNode = choiseNode.instantiate()
	graphEditor.add_child(NewchoiseNode)
	
	
	NewchoiseNode.position_offset = position_offset + Vector2(size.x+10,0)
	NewchoiseNode.setSelfName("Choise " + str(listChoice.size() + 1))
	NewchoiseNode.setCreatorID(name)
	
	listChoice.append(NewchoiseNode.name)
	setNewRich(NewchoiseNode.name.replace(name,""))

func setNewRich(text:String):
	var newChoiseRich = RichTextLabel.new()
	listVBox.add_child(newChoiseRich)
	newChoiseRich.custom_minimum_size = Vector2(0,30)
	newChoiseRich.bbcode_enabled = true
	
	newChoiseRich.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	newChoiseRich.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	newChoiseRich.text = "[pulse freq=5 color=#00ff84 ease=-1][color=#00ffea]"+ text + "[/color] [/pulse]"

func Erasing()->void:
	for nameNode:String in listChoice:
		var node:Node = parent.get_node_or_null(nameNode)
		if node:
			node.queue_free()

func Duplicating()->CinematicNode:
	var listTextChoise:Array[RichTextLabel]
	for richText:RichTextLabel in listVBox.get_children():
		listTextChoise.append(richText.duplicate())
		richText.free()
	var dupNode = self.duplicate()
	
	for DuprichText:RichTextLabel in listTextChoise:
		listVBox.add_child(DuprichText)
	return dupNode

func setNewID(newName:String, changeName:bool=true)->void:
	var previousName:String = name
	if newName.is_empty():
		return
	if changeName:
		name = newName
		nameComprobation = name
		if name != newName:
			CinematicEditor.setLogConsole("That ID already exists for another node",CinematicEditor.CONSOLE_ENUM.WARNING)
	
	get_node("TabContainer/ID/Actual ID/RichTextLabel").text = name
	if listChoice.size() == 0:
		return
	for nodeName:String in listChoice:
		var graphEditor:GraphEdit=parent
		var choiceNode = graphEditor.get_node(nodeName)
		choiceNode.setCreatorID(name)
		if changeName:
			listChoice[listChoice.find(nodeName)] = listChoice[listChoice.find(nodeName)].replace(previousName, name)

func setSlotData(Var:Variant,slot:int)->void:
	if typeof(Var) == TYPE_INT:
		flags = Var
	else:
		PushErrorLog("The data type that reaches \" "+ name + "\" is not an int, type (in enum): "+ str(typeof(Var)))

func StartAction():
	arrayFlag = getSelectedFlag(flags,listChoice)
	EmitNextNodeSignal()
	
var arrayFlag:Array[String]
func getSelectedFlag(mask: int, array: Array[String]) -> Array:
	var result:Array[String] = []
	var maxMask = (1 << array.size()) - 1
	if maxMask < mask:
		return array

	for i in range(array.size()):
		if mask & (1 << i):
			result.append(array[i])
	return result
