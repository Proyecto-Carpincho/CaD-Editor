@tool
extends Node
signal TestSignal

var pluginEditor:CaDPlugin
var clipboard:Array[CinematicNode]
var editorGraph:Control
var creatorOfUi:Node

func getNode(path:NodePath) -> Node:
	if not Engine.is_editor_hint():
		return get_tree().current_scene.get_node(path)
	return get_node(path)

func OnPanel(emisor:Node) -> Control:
	if not creatorOfUi and pluginEditor:
		creatorOfUi=emisor
		editorGraph=pluginEditor.OnPanel()
		return editorGraph
	return null

func OffPanel() -> void:
	creatorOfUi=null
	if pluginEditor:
		pluginEditor.OffPanel()

func NodeIsSelected(emisor:Node) ->bool:
	if pluginEditor:
		return pluginEditor.Interface().find(emisor) != -1
	return false
#region InputEditor
func _input(event: InputEvent) -> void:
	if editorGraph:
		var auxLisNode:Array[CinematicNode]=editorGraph.NodeIsSelected()
		if auxLisNode.size() != 0:
			if event.is_action_pressed("ui_copy"):
				Copy(auxLisNode, false)
			if event.is_action_pressed("ui_cut"):
				Cut(auxLisNode)
			if event.is_action_pressed("ui_graph_delete"):
				Delete(auxLisNode)
	if event.is_action_pressed("ui_paste") and clipboard != [] and editorGraph:
		Paste(clipboard)

func Copy(auxLisNode,internalCall:bool) -> void:
	clipboard.clear()
	
	for node:CinematicNode in auxLisNode:
		var dupNode:CinematicNode 
		if node.has_method("Duplicating"):
			dupNode = node.Duplicating()
		else:
			dupNode = node.duplicate()
		clipboard.append(dupNode)
	if not internalCall:
		setConsoleEditor("Copy!")

func Cut(auxLisNode) -> void:
	Copy(auxLisNode, true)
	Delete(auxLisNode)
	setConsoleEditor("Cut!")

func Delete(auxLisNode) -> void:
	for node:CinematicNode in auxLisNode:
		if node.has_method("Erasing"):
			node.Erasing()
		node.queue_free()
	setConsoleEditor("Delete!")

func Paste(auxLisNode) -> void:
	var newclipboard:Array[CinematicNode]
	for node:CinematicNode in auxLisNode:
		var dupNode:=node.duplicate()
		editorGraph.get_node("GraphEdit").add_child(dupNode)
		dupNode.position_offset += Vector2(25,10)
		newclipboard.append(dupNode.duplicate())
	clipboard=newclipboard
	setConsoleEditor("Paste!")
#endregion

#region Text in Editor
func setConsoleEditor(text):
	if editorGraph:
		editorGraph.setText(text)

enum CONSOLE_ENUM {COMMENTARY,WARNING,ERROR}
func setLogConsole(text:String,log:CONSOLE_ENUM,waitTime:float)->void:
	if editorGraph:
		editorGraph.logConsole(text,log)
		await get_tree().create_timer(waitTime).timeout
		editorGraph.logConsole("",CONSOLE_ENUM.COMMENTARY)
#endregion

signal Timeout(creator:String)
func AwaitTime(time:float,creator:String):
	await get_tree().create_timer(time).timeout
	emit_signal("Timeout",creator)
