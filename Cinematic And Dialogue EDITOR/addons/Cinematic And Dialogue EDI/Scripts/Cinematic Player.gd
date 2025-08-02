@tool
extends Node
class_name CinematicPlayer


#region Variables and Signals
signal CinematicEnd
@export var CinematicResorse:Cinematic
#region EXPORT GRUOP Path
@export_group("Paths")

#region var NodePaths
@export var NodePaths: Array[NodePath]

func setNodePaths(Var:Array[NodePath]):
	NodePaths=Var
	if (is_inside_tree() and get_tree().current_scene) or Engine.is_editor_hint():
		absolutePaths.clear()
		if not Engine.is_editor_hint() and not get_tree().current_scene.is_node_ready():
			await get_tree().current_scene.ready
		
		for path:NodePath in Var:
			if path.is_empty():
				continue
			absolutePaths.append(get_node(path).get_path())

var absolutePaths:Array[NodePath]
#endregion

#region var AnimationPlayers
@export var AnimationPlayers: Array[NodePath]

func setAnimationPlayers(Var:Array[NodePath]):
	if (is_inside_tree() and get_tree().current_scene) or Engine.is_editor_hint():
		absoluteAniPath.clear()
		if not Engine.is_editor_hint() and not get_tree().current_scene.is_node_ready():
			await get_tree().current_scene.ready
		for path:NodePath in Var:
			
			if path.is_empty():
				continue
			
			if not (get_node_or_null(path) is AnimationPlayer):
				push_error("Eso no es un animation player")
				continue
			
			absoluteAniPath.append(get_node(path).get_path())
	AnimationPlayers=Var

var absoluteAniPath:Array[NodePath]=[]
#endregion
#endregion

#region get list var
var dicImportTypeVar:Dictionary[String,int]
var dicImportVar:Dictionary[String,Variant]
var autoloadDialog:int
var dialogMethold:int
var SignalName:String
var listAutoload:Array[Node]
var methodName:String


func setCinematicData():
	if is_inside_tree():
		var auxAutoload
		if listAutoload!=[]:
			auxAutoload= listAutoload[autoloadDialog]
		setNodePaths(NodePaths)
		setAnimationPlayers(AnimationPlayers)
		CinematicEditor.SetDataNode(absoluteAniPath,absolutePaths,SignalName,auxAutoload,methodName)
		OneTime=true

##variable de mierda para el get properety list para que no ejecute 20 veces la parte de dialogos por que genera un lag mortal
var OneTime:bool
var MetholdEnum:String
func _get_property_list() -> Array[Dictionary]:
	var property:Array[Dictionary]
	#region Create a group (All Data)
	property.append({
		"name": "All Data",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP})
	for key in dicImportVar.keys():
		if dicImportTypeVar.has(key):
			property.append({
				"name": key,
				"type": dicImportTypeVar[key],
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_NONE})
		else:
			dicImportVar.erase(key) 
		#endregion
	
	#region Create a group (Autoload Dialogue)
	if is_inside_tree():
		property.append({
		"name": "Autoload Dialogue",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP})
		
		var AutoloadENUM:StringName
		var lisRoot=get_tree().root.get_children()
		listAutoload.clear()
		for i in range(lisRoot.size()):
			if get_tree().get_current_scene() != lisRoot[i] and not lisRoot[i].name in ["@EditorNode@21269","@ProgressDialog@13"]: #despues poner CinematicEditor 
				listAutoload.append(lisRoot[i])
				AutoloadENUM += lisRoot[i].name
				if lisRoot.size() - 1 > i:
					AutoloadENUM += ","
		property.append({
			"name":"autoloadDialog",
			"type":TYPE_INT,
			"usage":PROPERTY_USAGE_DEFAULT,
			"hint":PROPERTY_HINT_ENUM,
			"hint_string":AutoloadENUM})
		
		if OneTime:
			MetholdEnum=""
			var auxSize:int =lisRoot[autoloadDialog].get_method_list().size()
			var auxload:Node=lisRoot[autoloadDialog]
			methodName=auxload.get_method_list()[dialogMethold]["name"]
			for method:Dictionary in lisRoot[autoloadDialog].get_method_list():
				MetholdEnum+=method["name"]
				if auxSize  -1 > auxload.get_method_list().find(method):
					MetholdEnum+=","
			OneTime=false
		property.append({
			"name":"dialogMethold",
			"type": TYPE_INT,
			"usage":PROPERTY_USAGE_DEFAULT,
			"hint":PROPERTY_HINT_ENUM,
			"hint_string":MetholdEnum
			})
		property.append({
			"name": "SignalName",
			"type": TYPE_STRING,
			"usage":PROPERTY_USAGE_DEFAULT})
		#endregion
	return property

func _get(property) -> Variant:
	if dicImportVar.has(property):
		return dicImportVar[property]
	return null

func _set(property, value) -> bool:
	if dicImportVar.has(property):
		print("A")
		dicImportVar[property] = value
		return true
	return false
#endregion
var EditorGraph:Control
var NodeEditor:GraphEdit
var isCredible:bool = true 
var errorPushed:bool
#endregion

#region normal method
func _ready() -> void:
	if not is_inside_tree():
		await tree_entered
	setNodePaths(NodePaths)
	setAnimationPlayers(AnimationPlayers)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and CinematicResorse:
		errorPushed = false
		if isCredible and CinematicEditor.SelfSelected(self):
			EditorGraph=CinematicEditor.OnPanel(self) as Control
			NodeEditor=EditorGraph.get_node("GraphEdit")
			isCredible = false
			LoadData() 
		if not isCredible and not CinematicEditor.SelfSelected(self):
			SaveData()
			OneTime = true
			CinematicEditor.OffPanel()
			isCredible = true
	elif not CinematicResorse and not errorPushed:
		errorPushed = true
		push_error("no existe el recuso porfa crealo, nodo ", name)
#endregion

#region Save And Load
var IsLoading:bool
func SaveData() -> void:
	#print("SAVE --- SAVE --- SAVE --- SAVE --- SAVE --- SAVE --- SAVE --- SAVE")
	if EditorGraph and not IsLoading:
		var auxListNode:Array[Node]
		for node in NodeEditor.get_children():
			if node is GraphNode or node is CinematicNode:
				var dupNode=node.duplicate()
				auxListNode.append(dupNode)
			
		var auxConnections:Array = NodeEditor.get_connection_list() as Array
		CinematicResorse.SaveNodes(auxListNode,auxConnections)
		SaveVariables()

func LoadData() -> void:
	IsLoading=true
	setCinematicData()
	#print("LOAD --- LOAD --- LOAD --- LOAD --- LOAD --- LOAD --- LOAD --- LOAD")
	var auxlistNode = CinematicResorse.LoadNode()
	for node:Node in auxlistNode:
		if NodeEditor.find_child(node.name) != null:
			NodeEditor.get_node(NodePath(node.name)).set_position_offset(node.position_offset)
		else:
			if node.get_parent():
				node.get_parent().remove_child(node)
				NodeEditor.add_child(node)
			if not node.is_inside_tree():
				NodeEditor.add_child(node)
			else:
				push_error("esta dentro del arbol guebon")
	
	#Wait one frame to ensure exist childs of "NodeEditor"
	await get_tree().process_frame
	LoadVariablesInEditor()
	
	#While frame for ensure ALL CinematicNode is "READY" 
	while  NodeEditor.connections != CinematicResorse.allConecction and NodeEditor:
		await get_tree().process_frame
		NodeEditor.connections = CinematicResorse.allConecction
	IsLoading=false
	

func SaveVariables() -> void:
	CinematicResorse.dicVarData = dicImportVar
	CinematicResorse.dicVarType = dicImportTypeVar

func LoadVariablesInEditor() -> void:
	#Set dicImportVar and dicImportTypeVar make sure creator of vars (Import Data)
	var listVarName:Array[String]=EditorGraph.GetVarsName()
	for Key:String in CinematicResorse.dicVarData.keys():
		if listVarName.find(Key) != -1 and CinematicResorse.dicVarType.has(Key):
			dicImportVar.set(Key,CinematicResorse.dicVarData[Key])
			dicImportTypeVar.set(Key,CinematicResorse.dicVarType[Key])
		else:
			dicImportVar.erase(Key)
			dicImportTypeVar.erase(Key)
	notify_property_list_changed()

func LoadVariables() -> void:
	dicImportVar = CinematicResorse.dicVarData 
	dicImportTypeVar = CinematicResorse.dicVarType

func _exit_tree() -> void:
	if not isCredible and Engine.is_editor_hint() and CinematicResorse:
		SaveData()
		CinematicEditor.OffPanel()
		isCredible = true
		OneTime=true

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE and  CinematicEditor.SelfSelected(self) and CinematicResorse and EditorGraph:
		SaveData()
		CinematicEditor.SetTextInEditor("Save!")
#endregion

#region StartCinematic
func StartCinematic() -> void:
	LoadVariables()
	setCinematicData()
	StartImport()
	ExecutionLine("Start Node",1)

func ExecutionLine(from:String,step:int) -> void:
	var allNodeToExe:Array[String]=GetListConection(from)
	for nodeName in allNodeToExe:
		if nodeName == "End Node":
			emit_signal("CinematicEnd")
		else:
			var packedNode:PackedScene=CinematicResorse.allNodes[FindNode(nodeName)]
			var node=packedNode.instantiate()
			ExeNode(node,step+1)

func FindNode(Name:String) -> int:
	for i:int in range(CinematicResorse.allNodes.size()):
		var node =CinematicResorse.allNodes[i].instantiate()
		if node.name==Name:
			return i
	return -1

func ExeNode(node:CinematicNode,step:int) -> void:
	node.StartAction()
	await node.NextNode
	ExecutionLine(node.name,step)

func GetListConection(from:String) -> Array[String]:
	var auxConecctions:Array[Dictionary] = CinematicResorse.allConecction.duplicate(true)
	var allToNodes:Array[String]
	for connection:Dictionary in auxConecctions:
		if connection["from_node"] == from:
			allToNodes.append(connection["to_node"])
	return allToNodes

func StartImport():
	var auxConecctions:Array[Dictionary] = CinematicResorse.allConecction
	for connection in auxConecctions:
		var auxFromIndex:int = FindNode(connection["from_node"])
		var packedFromNode:PackedScene=CinematicResorse.allNodes[auxFromIndex]
		var fromNode:Node=packedFromNode.instantiate()
		if fromNode is ImportData:
			var auxToIndex:int = FindNode(connection["to_node"])
			var packedToNode:PackedScene=CinematicResorse.allNodes[auxToIndex]
			var toNode:Node=packedToNode.instantiate()
			if toNode.has_method("SetSlotData") and not fromNode.GetNameVar().is_empty():
				toNode.SetSlotData(dicImportVar.get(fromNode.GetNameVar()),connection["to_port"])
#endregion
