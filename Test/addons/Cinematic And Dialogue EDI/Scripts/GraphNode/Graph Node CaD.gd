@tool
extends GraphNode
class_name CinematicNode
signal NextNode


var editorGraph:Control
var cinematicData:DataCinematic

func StartAction() -> void:
	push_error("This node no have a Action")
	emit_signal("NextNode")

func getGraph() -> Control:
	if not get_parent():
		return null
	
	var auxParent:Node=get_parent().get_parent()
	return  auxParent if get_parent() is GraphEdit else null

func Timeout(TimerCreator:String):
	if TimerCreator == name:
		emit_signal("NextNode")

func EmitNextNodeSignal():
	if not CinematicEditor.is_connected("Timeout",Timeout):
		CinematicEditor.connect("Timeout",Timeout)
	CinematicEditor.AwaitTime(0.01,name)
	emit_signal("NextNode")

func setCinematicProperty()->Dictionary:
	return {
		"name":"cinematicData",
		"type":TYPE_INT,
		"usage":PROPERTY_USAGE_NO_EDITOR}

func setCinematicData()->void:
	if Engine.is_editor_hint() and getGraph():
		cinematicData=CinematicEditor.creatorOfUi.allDataCinematic

func PushErrorLog(error:String)->void:
	if CinematicEditor.editorGraph:
		CinematicEditor.setLogConsole(error, CinematicEditor.CONSOLE_ENUM.ERROR, 3)
	else:
		push_error(error)
