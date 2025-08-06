@tool
extends Node2D

signal Test1

func _ready() -> void:
	get_node("CinematicPlayer").connect("CinematicEnd",EndCinematic)

func _process(_delta: float) -> void:
	get_node("Fps").text = "FPS = "+ str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("ui_up"):
		var cine =get_node("CinematicPlayer")
		cine.StartCinematic()

func TestDialog(Key:String)->void:
	var Text = tr(Key)
	get_node("Dialogue").text=Text + " " + Key
	
	await get_tree().create_timer(2 if Key in ["Ky1","Ky2"]else 2.2).timeout
	emit_signal("Test1")

func TestMethodNode(Type:String)->void:
	get_node("RichTextLabel").text = "Metodo: "+Type
	print(Type)

func EndCinematic()->void:
	print("Cinematic END")
