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
		listAbsolutePaths.clear()
		if not Engine.is_editor_hint() and not get_tree().current_scene.is_node_ready():
			await get_tree().current_scene.ready
		
		for path:NodePath in Var:
			if path.is_empty():
				continue
			listAbsolutePaths.append(get_node(path).get_path())

var listAbsolutePaths:Array[NodePath]
#endregion

#region var AnimationPlayers
@export var AnimationPlayers: Array[NodePath]

func setAnimationPlayers(Var:Array[NodePath]):
	if (is_inside_tree() and get_tree().current_scene) or Engine.is_editor_hint():
		listAbsoluteAniPaths.clear()
		if not Engine.is_editor_hint() and not get_tree().current_scene.is_node_ready():
			await get_tree().current_scene.ready
		for path:NodePath in Var:
			
			if path.is_empty():
				continue
			
			if not (get_node_or_null(path) is AnimationPlayer):
				push_error("Eso no es un animation player")
				continue
			
			listAbsoluteAniPaths.append(get_node(path).get_path())
	AnimationPlayers=Var

var listAbsoluteAniPaths:Array[NodePath]=[]
#endregion
#endregion

#region get list var
var dicImportTypeVar:Dictionary[String,int]
var dicImportVar:Dictionary[String,Variant]
var autoloadDialog:int
var dialogMethold:int
var SignalName:String
var listAutoload:Array[String]
var methodName:String


func setCinematicData():
	if is_inside_tree():
		var auxAutoload:String
		if listAutoload!=[]:
			auxAutoload= listAutoload[autoloadDialog]
		setNodePaths(NodePaths)
		setAnimationPlayers(AnimationPlayers)
		CinematicEditor.SetDataNode(listAbsoluteAniPaths,listAbsolutePaths,SignalName,auxAutoload,methodName,dialogueFile)
		OneTime=true

##variable de mierda para el get properety list para que no ejecute 20 veces la parte de dialogos por que genera un lag mortal
var OneTime:bool
var MetholdEnum:String
func _get_property_list() -> Array[Dictionary]:
	var property:Array[Dictionary]
	if not CinematicResorse:
		return property
	CinematicResorse.LoadVariables(self)
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
			var auxName:String = lisRoot[i].name
			if get_tree().get_current_scene() != lisRoot[i] and not auxName in ["@EditorNode@21272","@ProgressDialog@13"]: #despues poner CinematicEditor 
				listAutoload.append(auxName)
				AutoloadENUM += auxName
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
			var auxAutoload = get_node("/root/"+listAutoload[autoloadDialog])
			var auxSize:int =auxAutoload.get_method_list().size()
			methodName=auxAutoload.get_method_list()[dialogMethold]["name"]
			for method:Dictionary in auxAutoload.get_method_list():
				MetholdEnum+=method["name"]
				if auxSize  -1 > auxAutoload.get_method_list().find(method):
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
@export_group("Autoload Dialogue")
@export_file("csv") var dialogueFile:String

func _get(property) -> Variant:
	if dicImportVar.has(property):
		return dicImportVar[property]
	return null

func _set(property, value) -> bool:
	if dicImportVar.has(property):
		dicImportVar[property] = value
		return true
	return false
#endregion
var editorGraph:Control
var nodeEditor:GraphEdit
#endregion

#region normal method
func _ready() -> void:
	if not is_inside_tree():
		await tree_entered
	setNodePaths(NodePaths)
	setAnimationPlayers(AnimationPlayers)

var listUnpackedNodes:Array[Node]
func LazyLoad():
	listUnpackedNodes = CinematicResorse.LoadNode()


var isCredible:bool = true 
var previousSelected:bool
var errorPushed:bool
func _process(delta: float) -> void:
	if CinematicEditor.NodeIsSelected(self) != previousSelected:
		#CinematicEditor.NodeIsSelected(self) == true then errorPushed = not CinematicEditor.NodeIsSelected(self) else errorPushed = errorPushed
		errorPushed =  not CinematicEditor.NodeIsSelected(self) if CinematicEditor.NodeIsSelected(self) else errorPushed
	
	if Engine.is_editor_hint() and CinematicResorse:
		
		errorPushed = false
		
		if isCredible and CinematicEditor.NodeIsSelected(self):
			editorGraph=CinematicEditor.OnPanel(self) as Control
			nodeEditor=editorGraph.get_node("GraphEdit")
			isCredible = false
			LoadData() 
		
		if not isCredible and not CinematicEditor.NodeIsSelected(self):
			SaveData()
			OneTime = true
			CinematicEditor.OffPanel()
			isCredible = true
	
	elif not CinematicResorse and not errorPushed:
		errorPushed = true
		push_error("The node \"", name, "\" It doesn't have the \"Cinematic\" resource, please create it.")
	
	#If this node create menu, previous delete the resourse. Then closed the menu
	if not isCredible and not CinematicResorse:
		CinematicEditor.OffPanel()
	
	previousSelected = CinematicEditor.NodeIsSelected(self)
#endregion

#region Save And Load
func SaveData() -> void:
	if editorGraph:
		CinematicResorse.SaveData(dicImportTypeVar,dicImportVar,nodeEditor.get_children(),nodeEditor.connections)

func LoadData() -> void:
	CinematicResorse.LoadData(nodeEditor,self,get_tree())
#endregion

func _exit_tree() -> void:
	if not isCredible and Engine.is_editor_hint() and CinematicResorse and previousSelected:
		SaveData()
		CinematicEditor.OffPanel()
		isCredible = true
		OneTime=true

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE and  CinematicEditor.NodeIsSelected(self) and CinematicResorse and editorGraph:
		SaveData()
		CinematicEditor.setTextInEditor("Save!")
#endregion

#region StartCinematic
signal EndImport
func StartCinematic() -> void:
	LazyLoad()
	CinematicResorse.LoadVariables(self)
	setCinematicData()
	StartImport()
	await EndImport
	ExecutionLine("Start Node",1)

func ExecutionLine(from:String,step:int) -> void:
	var allNodeToExe:Array[String]=getListConections(from)
	for nodeName in allNodeToExe:
		if nodeName == "End Node":
			emit_signal("CinematicEnd")
		else:
			
			var node=listUnpackedNodes[FindNode(nodeName)]
			ExeNode(node,step+1)

func FindNode(Name:String) -> int:
	for i:int in range(listUnpackedNodes.size()):
		var node:Node = listUnpackedNodes[i]
		if node.name==Name:
			return i
	return -1

func ExeNode(node:CinematicNode,step:int) -> void:
	node.StartAction()
	await node.NextNode
	ExecutionLine(node.name,step)

func getListConections(from:String) -> Array[String]:
	var auxConecctions:Array[Dictionary] = CinematicResorse.listConnections.duplicate(true)
	var allToNodes:Array[String]
	for connection:Dictionary in auxConecctions:
		if connection["from_node"] == from:
			allToNodes.append(connection["to_node"])
	return allToNodes

func StartImport():
	var auxConecctions:Array[Dictionary] = CinematicResorse.listConnections
	for connection in auxConecctions:
		var auxFromIndex:int = FindNode(connection["from_node"])
		var fromNode=listUnpackedNodes[auxFromIndex]
		if fromNode is ImportData:
			var auxToIndex:int = FindNode(connection["to_node"])
			var toNode=listUnpackedNodes[auxToIndex]
			if toNode.has_method("SetSlotData") and not fromNode.getNameVar().is_empty():
				toNode.SetSlotData(dicImportVar.get(fromNode.getNameVar()),connection["to_port"])
	await get_tree().process_frame
	emit_signal("EndImport")
#endregion
