@tool
extends Node

var pluginEditor:CaDPlugin
var Clipboard:Array[CinematicNode]
var EditorGraph:Control
var creatorOfUi:Node

#region Varable of data to nodes
var absAniPlayer:Array[NodePath]=[]
var listNodePaths:Array[NodePath]

var DialogSignal:String
var DialogAutoload:Node
var DialogMethod:String
#endregion

func SetDataNode(AniPlayers:Array[NodePath],NodePaths:Array[NodePath],DiaSignal:String,Autoload:Node,DiaMethod:String) -> void:
	absAniPlayer=AniPlayers
	listNodePaths=NodePaths
	DialogSignal=DiaSignal
	DialogAutoload=Autoload
	DialogMethod=DiaMethod

func GetNode(path:NodePath) -> Node:
	if not Engine.is_editor_hint():
		return get_tree().current_scene.get_node(path)
	return get_node(path)

func OnPanel(emisor:Node) -> Control:
	if not creatorOfUi and pluginEditor:
		creatorOfUi=emisor
		EditorGraph=pluginEditor.OnPanel()
		return EditorGraph
	return null

func OffPanel() -> void:
	creatorOfUi=null
	if pluginEditor:
		pluginEditor.OffPanel()

func SelfSelected(emisor:Node) ->bool:
	if pluginEditor:
		return pluginEditor.Interface().find(emisor) != -1
	return false
#region
func _input(event: InputEvent) -> void:
	if EditorGraph:
		var auxLisNode:Array[CinematicNode]=EditorGraph.NodeIsSelected()
		if auxLisNode.size() != 0:
			if event.is_action_pressed("ui_copy"):
				Copy(auxLisNode, false)
			if event.is_action_pressed("ui_cut"):
				Cut(auxLisNode)
			if event.is_action_pressed("ui_graph_delete"):
				Delente(auxLisNode)
	if event.is_action_pressed("ui_paste") and Clipboard != [] and EditorGraph:
		Paste(Clipboard)

func Copy(auxLisNode,internalCall:bool) -> void:
	Clipboard.clear()
	for nodo:CinematicNode in auxLisNode:
		Clipboard.append(nodo.duplicate())
	if not internalCall:
		SetTextInEditor("Copy!")

func Cut(auxLisNode) -> void:
	Copy(auxLisNode, true)
	Delente(auxLisNode)
	SetTextInEditor("Cut!")

func Delente(auxLisNode) -> void:
	for node:CinematicNode in auxLisNode:
		node.queue_free()
	SetTextInEditor("Delente!")

func Paste(auxLisNode) -> void:
	var newClipboard:Array[CinematicNode]
	for node:CinematicNode in auxLisNode:
		var dupNode:=node.duplicate()
		EditorGraph.get_node("GraphEdit").add_child(dupNode)
		dupNode.position_offset += Vector2(25,10)
		newClipboard.append(dupNode.duplicate())
	Clipboard=newClipboard
	SetTextInEditor("Paste!")

func SetTextInEditor(text):
	EditorGraph.setText(text)

#endregion
signal Timeout(creator:String)
func AwaitTime(time:float,creator:String):
	await get_tree().create_timer(time).timeout
	emit_signal("Timeout",creator)
