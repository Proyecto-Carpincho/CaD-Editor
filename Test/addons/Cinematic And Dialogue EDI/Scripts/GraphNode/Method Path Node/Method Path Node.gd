@tool
extends CinematicNode

@export var indexNode:int
@export var methodName:String
@export var listMethod:Array[String]
@export var useMethod:bool = true
var OptionNode:OptionButton
var OptionMethod:OptionButton

func setNodePathsOptions() -> void:
	setCinematicData()
	if not cinematicData:
		return
	
	cinematicData.listNodePaths 
	if not OptionNode:
		push_error("OptionNode is Null")
		return
	
	OptionNode.clear()
	for path:NodePath in cinematicData.listNodePaths:
		var node=CinematicEditor.getNode(path)
		if node:
			OptionNode.add_item(node.name)
	
	if OptionNode.get_item_count() == 0:
		return
	

	
	OptionNode.select(indexNode)
	_OptionNode_Selected(indexNode)



func equalsList() -> bool:
	if not OptionNode:
		return true
	
	if not cinematicData:
		return false
	
	var list = OptionNode.item_count
	if cinematicData.listNodePaths.size() == list:
		for i in range(cinematicData.listNodePaths.size()):
			var path:NodePath  = cinematicData.listNodePaths[i]
			if OptionNode.get_item_text(i) != path.get_name(path.get_name_count() - 1):
				return false
	else:
		return false
	return true

func _OptionNode_Selected(index:int) -> void:
	if cinematicData.listNodePaths!=[]:
		indexNode = index
		
		SetMetholsOptions()

func SetMetholsOptions() -> void:
	if not useMethod:
		return 
	
	if not OptionMethod:
		push_error("OptionMethod is Null")
		return
	
	OptionMethod.clear()
	listMethod.clear()
	
	for method:Dictionary in CinematicEditor.getNode(cinematicData.listNodePaths[indexNode]).get_method_list():
		OptionMethod.add_item(method["name"])
		listMethod.append(method["name"])
	
	if OptionMethod.get_item_count() > 0:
		if methodName == "" or not listMethod.find(methodName):
			OptionMethod.select(0)
			_OptionMethod_Selected(0)
		
		else:
			OptionMethod.select(listMethod.find(methodName))
			_OptionMethod_Selected(listMethod.find(methodName))

func _OptionMethod_Selected(index:int) -> void:
	if listMethod==[]:
		return
	
	methodName = listMethod[index]
