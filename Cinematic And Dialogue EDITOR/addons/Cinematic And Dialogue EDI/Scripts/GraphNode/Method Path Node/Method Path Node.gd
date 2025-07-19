@tool
extends CinematicNode

@export var methodNode:NodePath
@export var listNode:Array[NodePath]
@export var methodName:String
@export var listMethod:Array[String]
var OptionNode:OptionButton
var OptionMethod:OptionButton

func SetNodePathsOptions() -> void:
	listNode = CinematicEditor.listNodePaths
	if not OptionNode:
		push_error("OptionNode is Null")
		return
	
	OptionNode.clear()
	for preNode:NodePath in listNode:
		var node=CinematicEditor.GetNode(preNode)
		if node:
			OptionNode.add_item(node.name)
	OptionNode.select(0)
	_OptionNode_Selected(0)

func _OptionNode_Selected(index:int) -> void:
	if listMethod != []:
		methodNode=listMethod[index]
		SetMetholsOptions()
		_OptionMethod_Selected(0)

func SetMetholsOptions():
	if not OptionMethod:
		push_error("OptionMethod is Null")
		return
	
	OptionMethod.clear()
	for method:Dictionary in CinematicEditor.GetNode(methodNode):
		OptionMethod.add_item(method["name"])
	OptionMethod.select(0)
	_OptionMethod_Selected(0)

func _OptionMethod_Selected(index:int) -> void:
	if listMethod==[]:
		return
	methodName = listMethod[index]
