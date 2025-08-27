@tool
extends GraphNode

@export var creatorName:String

func _ready() -> void:
	setSelfName(name)
	setCreatorID(creatorName)

func setSelfName(newName:String)->void:
	name=newName
	get_node("Self Name").text="Name: "+name

func setCreatorID(ID:String)->void:
	creatorName=ID
	get_node("Creator Name").text="Creator ID: "+creatorName

func eraseSelf():
	queue_free()
