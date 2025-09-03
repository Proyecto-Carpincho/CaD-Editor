@tool
extends EditorPlugin
class_name CaDPlugin

var graphEditorNode = preload("res://addons/Cinematic And Dialogue EDI/Scenes/GraphEditor.tscn")
var controlInstanciate:Control
func _enter_tree() -> void:
	CinematicEditor.pluginEditor = self

func _exit_tree() -> void:
	CinematicEditor.pluginEditor = null
	OffPanel()

func OnPanel() -> Control:
	if not controlInstanciate:
		controlInstanciate = graphEditorNode.instantiate()
		add_control_to_bottom_panel(controlInstanciate,"Cinematic Editor")
		make_bottom_panel_item_visible(controlInstanciate)
	return controlInstanciate

func OffPanel() -> void:
	if controlInstanciate:
		remove_control_from_bottom_panel(controlInstanciate) 
		controlInstanciate.queue_free()

func Interface() -> Array:
	return get_editor_interface().get_selection().get_selected_nodes()
