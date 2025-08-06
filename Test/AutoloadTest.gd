@tool
extends Node
signal TestSignal

func DialogTest(Key:String)->void:
	var Text:String = tr(Key)
	prints(Text,"Editor Hint:", Engine.is_editor_hint())
	await get_tree().create_timer(1).timeout
	emit_signal("TestSignal")
