@tool
extends GraphNode
class_name CinematicNode
signal NextNode

var EditorGraph:Control

func StartAction() -> void:
	push_error("This node no have a Action")
	emit_signal("NextNode")

func getGraph() -> Control:
	var auxParent:Node=get_parent().get_parent()
	return  auxParent if get_parent() is GraphEdit else null
