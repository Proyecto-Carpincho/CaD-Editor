@tool
extends Resource
class_name Cinematic

var allNodes:Array
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


func SaveNodes(nodesToSave:Array,Conections:Array[Dictionary],varData:Dictionary[String,Variant],varType:Dictionary[String,int]):
	allNodes.clear()
	for list:Array in nodesToSave:
		allNodes.append(SaveChildNodes(list))
	allConecction=Conections
	dicVarData=varData
	dicVarType=varType

func SaveChildNodes(node:Array) -> Array:
	var list:Array = node
	#[node, nodename [childnode,childname]]
	for child:Node in node[0].get_children():
		if child.get_child_count() == 0:
			list.append([child,child.name])
		else:
			list.append(SaveChildNodes([child,child.name]))
	return list

func LoadNode() -> Array[Node]:
	return LoadChildNodes(allNodes,false)

func LoadChildNodes(listNode:Array, internalcall:bool) -> Array[Node]:
	var list:Array[Node]=[]
	for preNode:Array in listNode:
		var node:Node = preNode[0]
		node.name = preNode[1]
		if preNode.size() >= 3:
			var preChildrens:Array= preNode.slice(2, preNode.size())
			for child:Node in LoadChildNodes(preChildrens,true):
				if not child.get_parent() and not node.find_child(child.name) and not node.has_node(NodePath(child.name)):
					
					node.add_child(child)
		list.append(node)
	return list
