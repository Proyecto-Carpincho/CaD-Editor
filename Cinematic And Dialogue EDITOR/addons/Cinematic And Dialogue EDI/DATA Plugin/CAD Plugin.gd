@tool
extends EditorPlugin
class_name CaDPlugin

var GraphEditorNode = preload("res://addons/Cinematic And Dialogue EDI/Scenes/GraphEditor.tscn")
var ControlInstanciate:Control
func _enter_tree() -> void:
	CinematicEditor.pluginEditor = self

func _exit_tree() -> void:
	CinematicEditor.pluginEditor = null
	OffPanel()

func OnPanel() -> Control:
	if not ControlInstanciate:
		ControlInstanciate = GraphEditorNode.instantiate()
		add_control_to_bottom_panel(ControlInstanciate,"Cinematic Editor")
		make_bottom_panel_item_visible(ControlInstanciate)
	return ControlInstanciate

func OffPanel() -> void:
	if ControlInstanciate:
		remove_control_from_bottom_panel(ControlInstanciate) 
		ControlInstanciate.queue_free()

func Interface() -> Array:
	return get_editor_interface().get_selection().get_selected_nodes()
