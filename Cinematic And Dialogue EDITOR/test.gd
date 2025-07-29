@tool
extends Node2D




func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		var cine =get_node("CinematicPlayer")
		cine.StartCinematic()
	if Input.is_action_just_pressed("ui_down"):
		get_node("AnimationPlayer").play("test animation")

func PruebaMethod(a)->void:
	print("funciono: ", a)
