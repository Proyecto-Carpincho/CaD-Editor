@tool
extends Node
class_name CinematicPlayer


#region Variables
@export var CinematicResorse:Cinematic
@export_group("Paths")
@export var NodePaths: Array[NodePath]:
	set(Var):
		NodePaths=Var
		SetCinematicData()
@export var AnimationPlayers: Array[AnimationPlayer]:
	set(Var):
		AnimationPlayers=Var
		SetCinematicData()

#region get list var
var dicImportTypeVar:Dictionary[String,int]
var dicImportVar:Dictionary[String,Variant]:
	set(dic):
		dicImportVar=dic
		notify_property_list_changed()
		SetCinematicData()
var autoloadDialog:int:
	set(Int):
		autoloadDialog=Int
		notify_property_list_changed()
		SetCinematicData()
var dialogMethold:int:
	set(Var):
		dialogMethold=Var
		SetCinematicData()
var SignalName:String:
	set(Var):
		SignalName=Var
		SetCinematicData()
var listAutoload:Array[Node]
var methodName:String
#endregion

func SetCinematicData():
	if is_inside_tree() and listAutoload != []:
		var auxAutoload= listAutoload[autoloadDialog]
		CinematicEditor.SetDataNode(AnimationPlayers,NodePaths,SignalName,auxAutoload,methodName)

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
		
		var MetholdEnum:String
		var auxSize:int =lisRoot[autoloadDialog].get_method_list().size()
		var auxload:Node=lisRoot[autoloadDialog]
		methodName=auxload.get_method_list()[dialogMethold]["name"]
		for method:Dictionary in lisRoot[autoloadDialog].get_method_list():
			MetholdEnum+=method["name"]
			if auxSize  -1 > auxload.get_method_list().find(method):
				MetholdEnum+=","
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
		dicImportVar[property] = value
		return true
	return false

var EditorGraph:Control
var NodeEditor:GraphEdit

var isCredible:bool = true 
#endregion

var errorPushed:bool
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
			CinematicEditor.OffPanel()
			isCredible = true
	elif not CinematicResorse and not errorPushed:
		errorPushed = true
		push_error("no existe el recuso porfa crealo, nodo ", name)

func _exit_tree() -> void:
	if not isCredible and Engine.is_editor_hint() and CinematicResorse:
		SaveData()
		CinematicEditor.OffPanel()
		isCredible = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE and  CinematicEditor.SelfSelected(self):
		SaveData()
		CinematicEditor.SetTextInEditor("Save!")

func SaveData() -> void:
	print("SAVE --- SAVE --- SAVE --- SAVE --- SAVE --- SAVE --- SAVE --- SAVE")
	if EditorGraph:
		var auxListNode:Array[Node]
		for node in NodeEditor.get_children():
			if node is GraphNode or node is CinematicNode:
				var dupNode=node.duplicate()
				auxListNode.append(dupNode)
			
		var auxConnections:Array = NodeEditor.get_connection_list() as Array
		CinematicResorse.SaveNodes(auxListNode,auxConnections,dicImportVar,dicImportTypeVar)

func LoadData() -> void:
	print("LOAD --- LOAD --- LOAD --- LOAD --- LOAD --- LOAD --- LOAD --- LOAD")
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
	NodeEditor.connections = CinematicResorse.allConecction
	dicImportVar = CinematicResorse.dicVarData
	dicImportTypeVar = CinematicResorse.dicVarType
