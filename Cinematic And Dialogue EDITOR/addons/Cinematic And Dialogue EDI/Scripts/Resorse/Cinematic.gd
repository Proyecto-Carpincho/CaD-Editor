@tool
extends Resource
class_name Cinematic

var allNodes:Array[PackedScene]
var allNameNode:Array[String]
var allConecction:Array[Dictionary]

#region var to ImportData
##Each variable created through import data stores its own data (the variables themselves contain the data)
var dicVarData:Dictionary[String,Variant]
##It stores the data type of each variable contained in 'dicVarData' (e.g., bool, int, float, etc.).
var dicVarType:Dictionary[String,int]
#endregion

func _get_property_list():
	var properties = []
	#Create var AllNodes
	properties.append({
		"name": "allNodes",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	#Create var AllConecction
	properties.append({
		"name":"allConecction",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	#Create var dicVarData
	properties.append({
		"name": "dicVarData",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	#Create var dicVarType
	properties.append({
		"name": "dicVarType",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	return properties

func SaveNodes(nodesToSave:Array[Node],Conections:Array[Dictionary]):
	allNodes.clear()
	allNameNode.clear()
	for node:Node in nodesToSave:
		SetNameList(node)
		SetChildOwner(node, node)
		
		var auxPack = PackedScene.new()
		var error:Error = auxPack.pack(node)
		allNodes.append(auxPack)

		if error != OK:
			push_error("Error in packed of node: ",node.name)
	allConecction=Conections

func SetNameList(node:Node) -> void:
	var auxName:StringName = node.name
	allNameNode.append(auxName)

func LoadNode() -> Array[Node]:
	return LoadChildNodes()

func LoadChildNodes() -> Array[Node]:
	var auxListNode:Array[Node]
	for packedNode:PackedScene in allNodes:
		var node:Node=packedNode.instantiate()
		auxListNode.append(node)
		if node.get_child_count() == 0:
			push_error("el errrrror esta en load talvez", node.name)
	return auxListNode


func SetChildOwner(node: Node, owner: Node):
	for child in node.get_children():
		if child is Node:
			child.owner = owner
			SetChildOwner(child, owner)
