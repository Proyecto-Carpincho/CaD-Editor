@tool
extends CinematicNode


var aniPlayer:AnimationPlayer
var listAnimationPlayer:Array[NodePath]
var indexNode:int
@export var animationName:String
@export var waitPreAnimation:bool
@export var waitNextAnimation:bool


@onready var OptionPlayer:OptionButton=get_node("TabContainer/Node/OptionMenu/OptionNode")
@onready var OptionAnimation:OptionButton=get_node("TabContainer/Animation/OptionMenu/OptionAnimation")
@onready var WaitPre:CheckBox=get_node("TabContainer/Awaits/Wait PreAnimation/Await")
@onready var WaitAni:CheckBox=get_node("TabContainer/Awaits/Wait Ani/Await")

func _get_property_list() -> Array[Dictionary]:
	var property:Array[Dictionary]
	property.append({
		"name":"aniPlayer",
		"type": TYPE_OBJECT,
		"usage":PROPERTY_USAGE_NO_EDITOR,})
	property.append({
		"name": "listAnimationPlayer",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	property.append({
		"name":"indexNode",
		"type":TYPE_INT,
		"usage":PROPERTY_USAGE_NO_EDITOR})
	return property

func GetGraph() -> Control:
	var auxParent:Node=get_parent().get_parent()
	return  auxParent if get_parent() is GraphEdit else null
func _ready() -> void:
	WaitPre.button_pressed=waitPreAnimation
	WaitAni.button_pressed=waitNextAnimation
	if aniPlayer != null and listAnimationPlayer != []:
		if not aniPlayer.is_inside_tree():
			await aniPlayer.tree_entered
		var aniIndex:int=listAnimationPlayer.find(aniPlayer.get_path())
		aniIndex=aniIndex if aniIndex!=-1 else 0
		SetAniplayerOptions()
		OptionPlayer.select(aniIndex)
		_NodeOption_Selected(aniIndex)
		SetAnimationOptions()
		if animationName != "":
			OptionAnimation.select(aniPlayer.get_animation_list().find(animationName))

func _process(delta: float) -> void:
	if GetGraph():
		if not ecualsList():
			listAnimationPlayer.clear()
			listAnimationPlayer = CinematicEditor.absAniPlayer.duplicate(true)
			
			OptionPlayer.select(0)
			_NodeOption_Selected(0)
			SetAnimationOptions()
		
		if aniPlayer and listAnimationPlayer and OptionAnimation.get_item_count() != aniPlayer.get_animation_list().size():
			_NodeOption_Selected(listAnimationPlayer.find(aniPlayer.get_path()))
		

func ecualsList() -> bool:
	var list = CinematicEditor.absAniPlayer.duplicate(true)
	if listAnimationPlayer.size() == list.size():
		for i in range(list.size()):
			if list[i] != listAnimationPlayer[i]:
				return false
	else:
		return false
	return true

func SetAniplayerOptions() -> void:
	OptionPlayer.clear()
	for path:NodePath in listAnimationPlayer:
		if not path.is_empty():
			var node=CinematicEditor.GetNode(path)
			if node:
				OptionPlayer.add_item(node.name)

func SetAnimationOptions() -> void:
	OptionAnimation.clear()
	for animation:String in aniPlayer.get_animation_list():
		OptionAnimation.add_item(animation)

#region coneccted methods
func _NodeOption_Selected(index: int) -> void:
	if listAnimationPlayer != [] and index >= 0:
		aniPlayer=CinematicEditor.GetNode(listAnimationPlayer[index])
		indexNode=index
		SetAnimationOptions()

func _Animation_Selected(index: int) -> void:
	animationName = aniPlayer.get_animation_list()[index]

func _WaitPre_toggled(toggled_on: bool) -> void:
	waitPreAnimation=toggled_on

func _WaitAni_toggled(toggled_on: bool) -> void:
	waitNextAnimation=toggled_on
#endregion

func StartAction()->void:
	listAnimationPlayer=CinematicEditor.absAniPlayer.duplicate(true)
	aniPlayer=CinematicEditor.GetNode(listAnimationPlayer[indexNode])
	if aniPlayer and aniPlayer.get_animation_list().find(animationName) != -1:
		if aniPlayer.is_playing() and waitPreAnimation:
			await aniPlayer.animation_finished
		
		if aniPlayer.get_animation_list().find(animationName) !=-1:
			aniPlayer.play(animationName)
		
		if waitNextAnimation:
			await aniPlayer.animation_finished
	elif not aniPlayer:
		push_error("No exist animation player to play animation, Self Name: ", name)
	CinematicEditor.connect("Timeout",Timeout)
	CinematicEditor.AwaitTime(0.05,name)
	emit_signal("NextNode")


func Timeout(TimerCreator:String):
	if TimerCreator == name:
		emit_signal("NextNode")
