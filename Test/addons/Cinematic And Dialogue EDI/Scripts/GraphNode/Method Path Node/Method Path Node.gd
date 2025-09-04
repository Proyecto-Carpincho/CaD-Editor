@tool
extends CinematicNode

@export var indexNode:int
@export var methodName:String
@export var listMethod:Array[String]
@export var useMethod:bool = true
var optionNode:OptionButton
var optionMethod:OptionButton

var errorPushed:bool
func setNodePathsOptions() -> void:
	print("Cambio de opciones")
	setCinematicData()
	if not cinematicData:
		return
	
	if cinematicData.listNodePaths == [] and not errorPushed:
		PushErrorLog("No path is associated with the array. Please assign one in the cinematic player")
		errorPushed = true
	
	errorPushed = false
	if not optionNode:
		push_error("optionNode is Null")
		return
	optionNode.clear()
	for path:NodePath in cinematicData.listNodePaths:
		var node=CinematicEditor.getNode(path)
		if node:
			optionNode.add_item(node.name)
	
	if optionNode.get_item_count() == 0:
		return
	

	
	optionNode.select(indexNode)
	_optionNode_Selected(indexNode)



func equalsList() -> bool:
	if not optionNode:
		return true
	
	if not cinematicData:
		return false
	
	var list = optionNode.item_count
	if cinematicData.listNodePaths.size() == list:
		for i in range(cinematicData.listNodePaths.size()):
			var path:NodePath  = cinematicData.listNodePaths[i]
			if optionNode.get_item_text(i) != path.get_name(path.get_name_count() - 1):
				return false
	else:
		return false
	return true

func _optionNode_Selected(index:int) -> void:
	if cinematicData.listNodePaths!=[]:
		indexNode = index
		
		SetMetholsOptions()

func SetMetholsOptions() -> void:
	if not useMethod:
		return 
	
	if not optionMethod:
		push_error("optionMethod is Null")
		return
	
	optionMethod.clear()
	listMethod.clear()
	
	for method:Dictionary in CinematicEditor.getNode(cinematicData.listNodePaths[indexNode]).get_method_list():
		optionMethod.add_item(method["name"])
		listMethod.append(method["name"])
	
	if optionMethod.get_item_count() > 0:
		if methodName.is_empty() or listMethod.find(methodName) == -1:
			optionMethod.select(0)
			_OptionMethod_Selected(0)
		
		else:
			print(listMethod.find(methodName),methodName)
			optionMethod.select(listMethod.find(methodName))
			_OptionMethod_Selected(listMethod.find(methodName))

func _OptionMethod_Selected(index:int) -> void:
	if listMethod==[]:
		return
	
	methodName = listMethod[index]
	print(listMethod[index])
