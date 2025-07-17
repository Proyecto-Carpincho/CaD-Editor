@tool
extends GraphNode
class_name CinematicNode
signal NextNode

var EditorGraph:Control

func StartAction() -> void:
	push_error("This node no have a Action")
	emit_signal("NextNode")
