@tool
extends Panel

const path:String = "res://addons/Cinematic And Dialogue EDI/Scenes/GraphNode/"
const listNode:Array[PackedScene] = [\
preload(path+"Animation Node.tscn"),\
preload(path+"Await Node.tscn"),\
preload(path+"Import Data.tscn"),\
preload(path+"Method Path Node/Method Node.tscn"),\
preload(path+"Method Path Node/Dialogic Node.tscn"),
preload(path+"Method Path Node/Wait Signal.tscn"),\
preload(path+"Chooser Node.tscn")]

const listType:Array[String]=["Animation","Await","Import Data","Method","Dialogic","Wait Signal","Chooser Node"]
@onready var timer:Timer=get_node("Timer")
var MouseInside:bool
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not MouseInside:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			set_scale(Vector2.ONE)
			set_global_position(get_viewport().get_mouse_position() - Vector2(106,25))
			set_visible(true)
		elif event.button_index != MOUSE_BUTTON_RIGHT:
			HideMenu()

func CreateNode_pressed(Type:String) -> void:
	var auxType:int = listType.find(Type)
	var auxNode:GraphNode=listNode[auxType].instantiate()
	get_parent().add_child(auxNode)
	auxNode.position_offset =  get_parent().size / 2 + get_parent().scroll_offset
	HideMenu()
	

func HideMenu()->void:
	await get_tree().process_frame
	set_pivot_offset(get_size()/2)
	get_tree().create_tween().tween_property(self,"scale",Vector2.ZERO,0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	timer.start()
	await timer.timeout
	set_visible(false)
	MouseInside=false
	set_global_position(Vector2.ZERO)
	set_pivot_offset(Vector2(1000,25))
	get_node("VBoxContainer/ScrollContainer").scroll_vertical = 0

func _Mouse_Entered() -> void:
	MouseInside=true

func _Mouse_Exited() -> void:
	MouseInside=false
