@tool
extends Control

@onready var GraphEditor:GraphEdit = get_node("GraphEdit")
enum CONSOLE_ENUM {COMMENTARY,WARNING,ERROR}

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
	var ConsolaTest:RichTextLabel=get_node("GraphEdit/ConsolaText")
	ConsolaTest.set_modulate(Color(1,1,1,1))
	ConsolaTest.set_text("[wave amp=50.0 freq=5.0 connected=1]"+text+"[/wave]")
	get_tree().create_tween().tween_property(ConsolaTest,"modulate:a",0,0.5)

func getVarsName() -> Array[String]:
	var listName:Array[String]
	for node:Node in get_node("GraphEdit").get_children():
		if node is ImportData:
			listName.append(node.varName)
	return listName

func logConsole(text:String,Push:CONSOLE_ENUM)->void:
	var Console:RichTextLabel = get_node("GraphEdit/LogText")
	match Push:
		0: #COMMENTARY
			Console.text = text
		1: #WARNING
			Console.text = "[color=#ECE81A] WARNING: " + text + "[/color]"
		2: #ERROR
			Console.text = "[color=#FF0000] ERROR: " + text + "[/color]"
