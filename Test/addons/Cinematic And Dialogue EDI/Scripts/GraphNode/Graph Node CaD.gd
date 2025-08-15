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

func Timeout(TimerCreator:String):
	if TimerCreator == name:
		emit_signal("NextNode")

func emitNextNode():
	if not CinematicEditor.is_connected("Timeout",Timeout):
		CinematicEditor.connect("Timeout",Timeout)
	CinematicEditor.AwaitTime(0.05,name)
	emit_signal("NextNode")
