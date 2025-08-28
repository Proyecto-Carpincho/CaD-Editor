@tool
extends GraphNode

@export var creatorName:String


func _ready() -> void:
	setSelfName(name)
	setCreatorID(creatorName)

func setSelfName(newName:String)->void:
	name=newName
	get_node("Self Name").text="Name: "+name.replace(creatorName,"")

func setCreatorID(ID:String)->void:
	if not creatorName.is_empty():
		name = name.replace(" "+creatorName, "")
	creatorName=ID
	get_node("Creator Name").text="Creator ID: "+creatorName

	setSelfName(name + " " + creatorName)

func eraseSelf():
	queue_free()
