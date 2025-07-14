@tool
extends Panel

const path:String = "res://addons/Cinematic And Dialogue EDI/Scenes/GraphNode/"
const listNode:Array[PackedScene] = [preload(path+"Animation Node.tscn"),preload(path+"Await Node.tscn"),preload(path+"Import Data.tscn"),preload(path+"Method Node.tscn"),preload(path+"Dialogic Node.tscn")]
const listType:Array[String]=["Animation","Await","Import Data","Method","Dialogic"]
@onready var timer:Timer=get_node("Timer")
var MouseInside:bool
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not MouseInside:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			set_pivot_offset(Vector2(77.0,18.0))
			set_global_position(get_viewport().get_mouse_position())
			#set_scale(Vector2.ONE)
			set_visible(true)
		elif event.button_index != MOUSE_BUTTON_RIGHT:
			#set_pivot_offset(Vector2(77.0,105.0))
			#get_tree().create_tween().tween_property(self,"scale",Vector2.ZERO,0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			timer.start()
			await timer.timeout
			set_visible(false)

func CreateNode_pressed(Type:String) -> void:
	var auxType:int = listType.find(Type)
	var auxNode:GraphNode=listNode[auxType].instantiate()
	get_parent().add_child(auxNode)
	auxNode.position_offset =  get_parent().size / 2 + get_parent().scroll_offset


func _Mouse_Entered() -> void:
	MouseInside=true

func _Mouse_Exited() -> void:
	MouseInside=false
