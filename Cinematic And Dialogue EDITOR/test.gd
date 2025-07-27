@tool
extends Node2D




func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		var cine =get_node("CinematicPlayer")
		cine.StartCinematic()

func PruebaMethod(a)->void:
	print("funciono: ", a)
