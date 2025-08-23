@tool
extends Resource
class_name Cinematic

var listPackedNodes:Array[PackedScene]
var listConnections:Array[Dictionary]

#region var to ImportData
##Each variable created through import data stores its own data (the variables themselves contain the data)
var dicVarData:Dictionary[String,Variant]
##It stores the data type of each variable contained in 'dicVarData' (e.g., bool, int, float, etc.).
var dicVarType:Dictionary[String,int]
##Variable encargada de que no se guarden los datos en medido del cargado de estos, una verificacion en el dado caso que se llamen muy rapido
var isLoading:bool
#endregion

func _get_property_list():
	var properties = []
	#Create var AllNodes
	properties.append({
		"name": "listPackedNodes",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	#Create var AllConecction
	properties.append({
		"name":"listConnections",
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

#region Save

func SaveData(TypeVar:Dictionary,Vars:Dictionary,nodesToSave:Array[Node],Connections:Array[Dictionary]) -> void:
	if isLoading:
		return
	##Save ImportVars
	dicVarData = Vars
	dicVarType = TypeVar
	
	##Save Nodes
	var auxListGraphNodes:Array[Node]
	for node in nodesToSave:
		if node is GraphNode or node is CinematicNode:
			auxListGraphNodes.append(node)
	SaveNodes(auxListGraphNodes)
	
	##Save Connections
	listConnections=Connections

func SaveNodes(nodesToSave:Array[Node]):
	listPackedNodes.clear()
	for node:Node in nodesToSave:
		setChildOwner(node, node)
		
		var auxPack = PackedScene.new()
		var error:Error = auxPack.pack(node)
		listPackedNodes.append(auxPack)

		if error != OK:
			push_error("Error in packed of node: ",node.name)

func setChildOwner(node: Node, owner: Node):
	for child in node.get_children():
		if child is Node:
			child.owner = owner
			setChildOwner(child, owner)
#endregion Save

#region Load
func LoadData(nodeEditor:GraphEdit,CinemaPlayer:CinematicPlayer,tree:SceneTree):
	isLoading = true
	for node:GraphNode in LoadNode():
		if nodeEditor.find_child(node.name):
			nodeEditor.get_node(NodePath(node.name)).set_position_offset(node.position_offset)
		else:
			if node.get_parent():
				node.get_parent().remove_child(node)
			nodeEditor.add_child(node)
	await tree.process_frame
	setEditorVariable(nodeEditor.get_parent(),CinemaPlayer)
	
	while listConnections != nodeEditor.connections:
		await tree.process_frame
		nodeEditor.connections = listConnections
	isLoading = false


func setEditorVariable(editorGraph:Control,CinemaPlayer:CinematicPlayer):
	#Set dicImportVar and dicImportTypeVar make sure creator of vars (Import Data)
	var auxListVarName:Array[String]=editorGraph.getVarsName()
	for Key:String in dicVarData.keys():
		if auxListVarName.find(Key) != -1 and dicVarType.has(Key):
			CinemaPlayer.dicImportVar.set(Key,dicVarData[Key])
			CinemaPlayer.dicImportTypeVar.set(Key,dicVarType[Key])
		else:
			CinemaPlayer.dicImportVar.erase(Key)
			CinemaPlayer.dicImportTypeVar.erase(Key)
	CinemaPlayer.notify_property_list_changed()



func LoadNode() -> Array[Node]:
	var auxListNode:Array[Node]
	for packedNode:PackedScene in listPackedNodes:
		var node:Node=packedNode.instantiate()
		auxListNode.append(node)
	return auxListNode

#endregion

func LoadVariables(CinemaPlayer:CinematicPlayer) -> void:
	CinemaPlayer.dicImportVar = dicVarData 
	CinemaPlayer.dicImportTypeVar = dicVarType
