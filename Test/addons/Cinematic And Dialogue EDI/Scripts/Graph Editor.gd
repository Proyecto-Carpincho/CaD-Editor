@tool
extends Control

@onready var GraphEditor:GraphEdit = get_node("GraphEdit")
enum CONSOLE_ENUM {COMMENTARY,WARNING,ERROR}

func _ready() -> void:
	var Console: RichTextLabel = get_node("GraphEdit/Error Console/HBoxContainer2/LogText")
	Console.size_flags_vertical = Control.SIZE_SHRINK_END

func Conection_Request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	GraphEditor.connect_node(from_node, from_port, to_node, to_port)

func Disconect_Recuest(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	GraphEditor.disconnect_node(from_node, from_port, to_node, to_port)

func NodeIsSelected() -> Array[CinematicNode]:
	var lisNode:Array[CinematicNode]
	for node in GraphEditor.get_children():
		if node is CinematicNode and node.selected:
			lisNode.append(node)
	return lisNode

func setText(text:String) -> void:
	var ConsolaTest:RichTextLabel=get_node("GraphEdit/ConsoleText")
	ConsolaTest.set_modulate(Color(1,1,1,1))
	ConsolaTest.set_text("[wave amp=50.0 freq=5.0 connected=1]"+text+"[/wave]")
	get_tree().create_tween().tween_property(ConsolaTest,"modulate:a",0,0.5)

func getVarsName() -> Array[String]:
	var listName:Array[String]
	for node:Node in get_node("GraphEdit").get_children():
		if node is ImportData:
			listName.append(node.varName)
	return listName

#region Console Error
#WARNING This crap was made by AI because I was too lazy to make a proper console, so I wouldn’t bet on this.
var blocks: Array = []

func logConsole(text:String, Push:CONSOLE_ENUM, waitTime:float = 10.0) -> void:
	var Console: RichTextLabel = get_node("GraphEdit/Error Console/HBoxContainer2/LogText")

	match Push:
		CONSOLE_ENUM.COMMENTARY: pass
		CONSOLE_ENUM.WARNING: text = "[color=#ECE81A] WARNING: " + text + "[/color]"
		CONSOLE_ENUM.ERROR:   text = "[color=#FF0000] ERROR: " + text + "[/color]"

	var clean_text := text
	while clean_text.ends_with("\n"):
		clean_text = clean_text.substr(0, clean_text.length() - 1)

	var block:Dictionary = {
		"id": Time.get_ticks_usec(),
		"txt": clean_text + "\n"}
	blocks.append(block)

	# Reconstuyo el contenido del RichTextLabel desde la cola
	RebuildConsoleText(Console)

	# Espero y luego elimino por ID
	var blockId = block["id"]
	await get_tree().create_timer(waitTime).timeout
	RemoveBlock(blockId)
	RebuildConsoleText(Console)

func RebuildConsoleText(console: RichTextLabel) -> void:
	# Si no hay bloques, vacío el label
	if blocks == []:
		console.text = "" 
		return

	var s := "\n"
	for b in blocks:
		s += b["txt"]

	console.text = s

func RemoveBlock(id:int) -> void:
	for i in range(blocks.size()):
		if blocks[i]["id"] == id:
			blocks.remove_at(i)
			return

var A:bool = true
func _Pressed_ConsoleButton() -> void:
	A = not  A
	var Console = get_node("GraphEdit/Error Console")
	var RichConsole = get_node("GraphEdit/Error Console/HBoxContainer2/LogText")
	if not A:
		get_tree().create_tween().tween_property(Console,"position",Console.position - Vector2(0,RichConsole.size.y),0.2)
	else:
		get_tree().create_tween().tween_property(Console,"position",Console.position + Vector2(0,RichConsole.size.y),0.2)
#endregion
