@tool
extends VBoxContainer

var ChooserParent:Node

func _ready() -> void:
	ChooserParent = get_parent().get_parent()

func _Pressed_NewID()->void:
	ChooserParent.setNewID(get_node("New ID/LineEdit").text)
	get_node("New ID/LineEdit").text = ""
	get_node("New ID").set_visible(false)
	get_node("Actual ID").set_visible(true)


func _Pressed_CancelNewID()->void:
	get_node("New ID").set_visible(false)
	get_node("Actual ID").set_visible(true)
	get_node("New ID/LineEdit").text=""

func _Pressed_ChangeID()->void:
	get_node("New ID").set_visible(true)
	get_node("Actual ID").set_visible(false)
