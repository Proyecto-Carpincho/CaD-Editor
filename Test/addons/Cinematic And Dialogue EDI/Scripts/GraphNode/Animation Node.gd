@tool
extends CinematicNode


var aniPlayer:AnimationPlayer
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
		"name": "cinematicData",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_NO_EDITOR})
	property.append(setCinematicProperty())
	return property



func _ready() -> void:
	setCinematicData()
	
	WaitPre.button_pressed=waitPreAnimation
	WaitAni.button_pressed=waitNextAnimation
	if cinematicData:
		if aniPlayer != null and cinematicData.listAnimationPaths != []:
			if not aniPlayer.is_inside_tree():
				await aniPlayer.tree_entered
			var aniIndex:int=cinematicData.listAnimationPaths.find(aniPlayer.get_path())
			aniIndex=aniIndex if aniIndex!=-1 else 0
			setAniplayerOptions()
			OptionPlayer.select(aniIndex)
			_NodeOption_Selected(aniIndex)
			setAnimationOptions()
			if animationName != "":
				OptionAnimation.select(aniPlayer.get_animation_list().find(animationName))

var PushedError:bool
var a = true
func _process(delta: float) -> void:
	if a:
		a = false
		return
	if getGraph() and cinematicData:
		if not equalsList():
			if cinematicData.listAnimationPaths == []:
				if not PushedError:
					PushedError = true
					PushErrorLog("You don’t have any listed Animation player in the cinematic player")
				return
			PushedError = false
			
			_NodeOption_Selected(0)
			setAniplayerOptions()
			setAnimationOptions()
		
		if aniPlayer and cinematicData.listAnimationPaths and OptionAnimation.get_item_count() != aniPlayer.get_animation_list().size():
			_NodeOption_Selected(cinematicData.listAnimationPaths.find(aniPlayer.get_path()))
		

func equalsList() -> bool:
	var list = OptionPlayer.item_count
	if cinematicData.listAnimationPaths.size() == list:
		for i in range(cinematicData.listAnimationPaths.size()):
			var path:NodePath  = cinematicData.listAnimationPaths[i]
			if OptionPlayer.get_item_text(i) != path.get_name(path.get_name_count() - 1):
				return false
	else:
		return false
	return true

func setAniplayerOptions() -> void:
	OptionPlayer.clear()
	for path:NodePath in cinematicData.listAnimationPaths:
		if not path.is_empty():
			OptionPlayer.add_item(path.get_name(path.get_name_count() - 1))

func setAnimationOptions() -> void:
	OptionAnimation.clear()
	for animation:String in aniPlayer.get_animation_list():
		OptionAnimation.add_item(animation)

#region connected methods
func _NodeOption_Selected(index: int) -> void:
	if cinematicData.listAnimationPaths != [] and index >= 0:
		aniPlayer=CinematicEditor.getNode(cinematicData.listAnimationPaths[index])
		indexNode=index
		setAnimationOptions()

func _Animation_Selected(index: int) -> void:
	animationName = aniPlayer.get_animation_list()[index]

func _WaitPre_toggled(toggled_on: bool) -> void:
	waitPreAnimation=toggled_on

func _WaitAni_toggled(toggled_on: bool) -> void:
	waitNextAnimation=toggled_on
#endregion

func StartAction()->void:
	aniPlayer = CinematicEditor.getNode(cinematicData.listAnimationPaths[indexNode])
	if aniPlayer and aniPlayer.get_animation_list().find(animationName) != -1:
		if aniPlayer.is_playing() and waitPreAnimation:
			await aniPlayer.animation_finished
		
		if aniPlayer.get_animation_list().find(animationName) !=-1:
			aniPlayer.play(animationName)
		
		if waitNextAnimation:
			await aniPlayer.animation_finished
	elif not aniPlayer:
		push_error("No exist animation player to play animation, Self Name: ", name)
	EmitNextNodeSignal()
