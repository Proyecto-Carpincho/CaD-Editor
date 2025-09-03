@tool
extends CinematicNode

@export var waitTime:float:
	set(value):
		waitTime = value if value != 0 else 0.1

func _ready() -> void:
	get_node("VBoxContainer/HBoxContainer/SpinBox").value=waitTime


func StartAction():
	if not CinematicEditor.is_connected("Timeout",Timeout):
		CinematicEditor.connect("Timeout",Timeout)
	CinematicEditor.AwaitTime(waitTime,name)

func Timeout(timerCreator:String):
	if timerCreator == name:
		emit_signal("NextNode")


func _SpinTime_ValueChange(value: float) -> void:
	waitTime=value
