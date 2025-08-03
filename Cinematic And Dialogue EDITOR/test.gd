@tool
extends Node2D

signal Test1


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		var cine =get_node("CinematicPlayer")
		cine.StartCinematic()


func PruebaMethod(a)->void:
	print("funciono: ", a)
	await get_tree().create_timer(1).timeout
	emit_signal("Test1")
