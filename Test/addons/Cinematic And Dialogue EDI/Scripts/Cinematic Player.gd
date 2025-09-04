@tool
extends Node
class_name CinematicPlayer


#region Variables and Signals
signal CinematicEnd
@export var CinematicResource:Cinematic
#region EXPORT GRUOP Path
@export_group("Paths")

@export var NodePaths: Array[NodePath]:
	set(list):
		NodePaths = list
		if Engine.is_editor_hint():
			setCinematicData()
@export var AnimationPlayers: Array[NodePath]:
	set(list):
		AnimationPlayers = list
		if Engine.is_editor_hint():
			setCinematicData()

func getAbolutePaths(Var:Array[NodePath], IsForAnima:bool=false) -> Array[NodePath]:
	var listPaths:Array[NodePath]
	if (is_inside_tree() and get_tree().current_scene) or Engine.is_editor_hint():
		for path:NodePath in Var:
			if path.is_empty():
				continue
			if IsForAnima:
				if not (get_node_or_null(path) is AnimationPlayer):
					if get_node_or_null(path):
						push_error("this node is not AnimationPlayer")
						AnimationPlayers[AnimationPlayers.find(path)] = NodePath("")
					continue
			
			listPaths.append(get_node(path).get_path())
	return listPaths

#endregion

#region get list var
var dicImportTypeVar:Dictionary[String,int]
var dicImportVar:Dictionary[String,Variant]

var autoloadDialog:int:
	set(Int):
		OneTime=true
		autoloadDialog = Int
		setCinematicData()
var dialogMethold:int:
	set(Int):
		dialogMethold = Int
		setCinematicData()
var SignalName:String:
	set(str):
		SignalName=str
		setCinematicData()
var listAutoload:Array[String]
var methodName:String

var allDataCinematic:DataCinematic

func setCinematicData():
	if not allDataCinematic:
		allDataCinematic = DataCinematic.new()
	if is_inside_tree():
		var auxAutoload:String
		if listAutoload!=[]:
			auxAutoload= listAutoload[autoloadDialog]
		
		allDataCinematic.listAnimationPaths = getAbolutePaths(AnimationPlayers,true)
		allDataCinematic.listNodePaths = getAbolutePaths(NodePaths)
		
		allDataCinematic.dialogAutoload = auxAutoload
		allDataCinematic.dialogMethod = methodName
		allDataCinematic.dialogFile = dialogueFile
		allDataCinematic.dialogSignal = SignalName
		
		OneTime=true

##variable de mierda para el get properety list para que no ejecute 20 veces la parte de dialogos por que genera un lag mortal
var OneTime:bool
var MetholdEnum:String
func _get_property_list() -> Array[Dictionary]:
	var property:Array[Dictionary]
	if not CinematicResource:
		return property
	CinematicResource.LoadVariables(self)
	
	property.append({
		"name":"allDataCinematic",
		"type": TYPE_OBJECT,
		"usage":PROPERTY_USAGE_NO_EDITOR})
	
	property.append({
		"name":"listAutoload",
		"type":TYPE_PACKED_STRING_ARRAY,
		"usage":PROPERTY_USAGE_NO_EDITOR})
	
	property.append({
		"name":"methodName",
		"type":TYPE_STRING,
		"usage":PROPERTY_USAGE_NO_EDITOR})
	
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
		#endregion All Data
	
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
@export_file(".csv") var dialogueFile:String:
	set(a):
		dialogueFile = a
		setCinematicData()

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
	setCinematicData()
	if not Engine.is_editor_hint():
		LazyLoad()

var isCredible:bool = true 
var previousSelected:bool
var errorPushed:bool
func _process(delta: float) -> void:
	if CinematicEditor.NodeIsSelected(self) != previousSelected:
		#CinematicEditor.NodeIsSelected(self) == true then errorPushed = not CinematicEditor.NodeIsSelected(self) else errorPushed = errorPushed
		errorPushed =  not CinematicEditor.NodeIsSelected(self) if CinematicEditor.NodeIsSelected(self) else errorPushed
	
	if Engine.is_editor_hint() and CinematicResource:
		
		errorPushed = false
		
		if isCredible and CinematicEditor.NodeIsSelected(self):
			if CinematicEditor.isPanel():
				await CinematicEditor.sigPanelOFF
			await get_tree().process_frame
			editorGraph=CinematicEditor.OnPanel(self) as Control
			nodeEditor=editorGraph.get_node("GraphEdit")
			isCredible = false
			LoadData() 
		
		if not isCredible and not CinematicEditor.NodeIsSelected(self):
			SaveData()
			OneTime = true
			CinematicEditor.OffPanel()
			isCredible = true
	
	elif not CinematicResource and not errorPushed:
		errorPushed = true
		push_error("The node \"", name, "\" It doesn't have the \"Cinematic\" resource, please create it.")
	
	#Close the menu if it was created and the resource was removed.
	if not isCredible and not CinematicResource:
		CinematicEditor.OffPanel()
		isCredible = true
	
	previousSelected = CinematicEditor.NodeIsSelected(self)
#endregion

#region Save And Load
func SaveData() -> void:
	if editorGraph:
		CinematicResource.SaveData(dicImportTypeVar,dicImportVar,nodeEditor.get_children(),nodeEditor.connections)

func LoadData() -> void:
	CinematicResource.LoadData(nodeEditor,self,get_tree())

func _exit_tree() -> void:
	if not isCredible and Engine.is_editor_hint() and CinematicResource and previousSelected:
		SaveData()
		CinematicEditor.OffPanel()
		isCredible = true
		OneTime=true

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE and  CinematicEditor.NodeIsSelected(self) and CinematicResource and editorGraph:
		SaveData()
		CinematicEditor.setConsoleEditor("Save!")
#endregion

#region StartCinematic
signal EndImport
func StartCinematic() -> void:
	if Engine.is_editor_hint():
		LazyLoad()
	CinematicResource.LoadVariables(self)
	setCinematicData()
	StartImport()
	await EndImport
	ExecutionLine("Start Node", 1)

func ExecutionLine(from:String,step:int) -> void:
	var allNodeToExe:Array[String]=getListConections(from)
	for nodeName in allNodeToExe:
		if nodeName == "End Node":
			emit_signal("CinematicEnd")
		else:
			
			var node =listUnpackedNodes[FindNode(nodeName)]
			if node is MethodNode or node is ChooserNode:
				StartImport()
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
	
	if node as ChooserNode:
		for choiseName:String in node.arrayFlag:
			ExecutionLine(choiseName,step)
	
	ExecutionLine(node.name,step)

func getListConections(from:String) -> Array[String]:
	var auxConecctions:Array[Dictionary] = CinematicResource.listConnections.duplicate(true)
	var allToNodes:Array[String]
	for connection:Dictionary in auxConecctions:
		if connection["from_node"] == from:
			allToNodes.append(connection["to_node"])
	return allToNodes

func StartImport():
	var auxConecctions:Array[Dictionary] = CinematicResource.listConnections.duplicate(true)
	for connection in auxConecctions:
		var auxFromIndex:int = FindNode(connection["from_node"])
		var fromNode=listUnpackedNodes[auxFromIndex]
		if fromNode is ImportData:
			var auxToIndex:int = FindNode(connection["to_node"])
			var toNode=listUnpackedNodes[auxToIndex]
			#IF SHIT
			if toNode.has_method("setSlotData") and not fromNode.getNameVar().is_empty():
				toNode.setSlotData(dicImportVar.get(fromNode.getNameVar()),connection["to_port"])
	await get_tree().process_frame
	emit_signal("EndImport")

var listUnpackedNodes:Array[Node]
func LazyLoad():
	listUnpackedNodes = CinematicResource.LoadNode()
#endregion
