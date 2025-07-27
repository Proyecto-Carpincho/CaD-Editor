@tool
extends CinematicNode


@export var aniPlayer:AnimationPlayer
@export var aniPlayerPath:NodePath
@export var animationName:String
@export var waitPreAnimation:bool
@export var waitNextAnimation:bool
@export var lisAnimationPlayer:Array[NodePath]

@onready var OptionPlayer:OptionButton=get_node("TabContainer/Node/OptionMenu/OptionNode")
@onready var OptionAnimation:OptionButton=get_node("TabContainer/Animation/OptionMenu/OptionAnimation")
@onready var WaitPre:CheckBox=get_node("TabContainer/Awaits/Wait PreAnimation/Await")
@onready var WaitAni:CheckBox=get_node("TabContainer/Awaits/Wait Ani/Await")

func GetGraph() -> Control:
	var auxParent:Node=get_parent().get_parent()
	return  auxParent if get_parent() is GraphEdit else null

func _ready() -> void:
	WaitPre.button_pressed=waitPreAnimation
	WaitAni.button_pressed=waitNextAnimation
	if aniPlayerPath != NodePath(""):
		aniPlayer=get_node(aniPlayerPath)
	if aniPlayer != null and lisAnimationPlayer != []:
		var aniIndex:int=lisAnimationPlayer.find(aniPlayer.get_path())
		SetAniplayerOptions()
		OptionPlayer.select(aniIndex)
		_NodeOption_Selected(aniIndex)
		SetAnimationOptions()
		if animationName != "":
			OptionAnimation.select(aniPlayer.get_animation_list().find(animationName))

func _process(delta: float) -> void:
	if GetGraph():
		if not aniPlayer and aniPlayerPath != NodePath(""):
			aniPlayer=get_node(aniPlayerPath)
		if not ecualsList():
			lisAnimationPlayer.clear()
			for node:AnimationPlayer in CinematicEditor.listAnimationPlayers:
				if node:
					lisAnimationPlayer.append(node.get_path())
			OptionPlayer.select(0)
			_NodeOption_Selected(0)
			SetAnimationOptions()
		if aniPlayer and lisAnimationPlayer and OptionAnimation.get_item_count() != aniPlayer.get_animation_list().size():
			_NodeOption_Selected(lisAnimationPlayer.find(aniPlayer.get_path()))

func ecualsList() -> bool:
	var list=CinematicEditor.listAnimationPlayers
	if lisAnimationPlayer.size() == list.size():
		for i in range(list.size()):
			if list[i].get_path() != lisAnimationPlayer[i]:
				return false
	else:
		return false
	return true

func SetAniplayerOptions() -> void:
	OptionPlayer.clear()
	for preNode:NodePath in lisAnimationPlayer:
		var node = get_node(preNode)
		if node:
			OptionPlayer.add_item(node.name)

func SetAnimationOptions() -> void:
	OptionAnimation.clear()
	for animation:String in aniPlayer.get_animation_list():
		OptionAnimation.add_item(animation)

#region coneccted methods
func _NodeOption_Selected(index: int) -> void:
	if lisAnimationPlayer != [] and index >= 0:
		aniPlayer=get_node(lisAnimationPlayer[index])
		aniPlayerPath=aniPlayer.get_path()
		SetAnimationOptions()

func _Animation_Selected(index: int) -> void:
	animationName = aniPlayer.get_animation_list()[index]

func _WaitPre_toggled(toggled_on: bool) -> void:
	waitPreAnimation=toggled_on

func _WaitAni_toggled(toggled_on: bool) -> void:
	waitNextAnimation=toggled_on
#endregion

func StartAction()->void:
	if aniPlayerPath != NodePath(""):
		aniPlayer=CinematicEditor.GetNode(aniPlayerPath)
	
	if aniPlayer:
		if aniPlayer.is_playing() and waitPreAnimation:
			await aniPlayer.animation_finished
		else:
			aniPlayer.stop()
		aniPlayer.play(animationName)
		
		if waitNextAnimation:
			await aniPlayer.animation_finished
	else:
		push_error("No exist animation player to play animation, Self Name: ", name)
	CinematicEditor.connect("Timeout",Timeout)
	CinematicEditor.AwaitTime(0.05,name)
	emit_signal("NextNode")


func Timeout(TimerCreator:String):
	if TimerCreator == name:
		emit_signal("NextNode")
