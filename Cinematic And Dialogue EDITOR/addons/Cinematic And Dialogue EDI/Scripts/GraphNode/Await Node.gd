@tool
extends CinematicNode

@export var WaitTime:float:
	set(value):
		WaitTime = value if value != 0 else 0.1

func _ready() -> void:
	get_node("VBoxContainer/HBoxContainer/SpinBox").value=WaitTime


func StartAction():
	CinematicEditor.connect("Timeout",Timeout)
	CinematicEditor.AwaitTime(WaitTime,name)
	

func Timeout(TimerCreator:String):
	if TimerCreator == name:
		emit_signal("NextNode")


func _SpinTime_ValueChange(value: float) -> void:
	WaitTime=value
