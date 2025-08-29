@tool
extends Node2D

signal NextDialog
signal sigAnimation
var A:int

func _process(_delta: float) -> void:
	get_node("Fps").text = "FPS = "+ str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("ui_up"):
		var cine =get_node("CinematicPlayer")
		cine.StartCinematic()


func _ready() -> void:
	get_node("CinematicPlayer").connect("CinematicEnd",EndCinematic)

func DialogTest(key:String)->void:
	match key:
		"Cinema2":
			get_node("Control/HBoxContainer").set_visible(true)
		_:
			get_node("Control/Button").set_visible(true)
	
	get_node("Dialog/RichTextLabel2").text = ""
	get_node("Dialog/RichTextLabel").text = ""
	match key:
		
		"Cinema2", "Cinema1","election2-1","election1-2":
			
			if "Cinema2" == key:
				get_node("Dialog/RichTextLabel2").position = Vector2(608,0)
			elif "Cinema1" == key:
				get_node("Dialog/RichTextLabel2").position = Vector2(269,40)
			get_node("Dialog/RichTextLabel2").text = tr(key)
		_:
			get_node("Dialog/RichTextLabel").text = tr(key)

func EndCinematic()->void:
	print("Cinematic END")


func _on_button_pressed() -> void:
	var ci = get_node("CinematicPlayer") as CinematicPlayer
	get_node("Control/HBoxContainer").set_visible(false)
	ci.dicImportVar["Choise"] = 1
	await get_tree().process_frame
	await get_tree().process_frame
	emit_signal("sigAnimation")


func _on_button_2_pressed() -> void:
	var ci = get_node("CinematicPlayer") as CinematicPlayer
	get_node("Control/HBoxContainer").set_visible(false)
	ci.dicImportVar["Choise"] = 2
	await get_tree().process_frame
	await get_tree().process_frame
	emit_signal("sigAnimation")

func _on_button_presseda() -> void:
	emit_signal("NextDialog")
	get_node("Control/Button").set_visible(false)
	emit_signal("sigAnimation")
