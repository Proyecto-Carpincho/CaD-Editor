@tool
extends CinematicNode


@export var aniPlayer:AnimationPlayer
@export var animationName:String
@export var waitPreAnimation:bool
@export var waitNextAnimation:bool
var lisAnimationPlayer:Array[AnimationPlayer]=[]

@onready var OptionPlayer:OptionButton=get_node("TabContainer/Node/OptionMenu/OptionNode")
@onready var OptionAnimation:OptionButton=get_node("TabContainer/Animation/OptionMenu/OptionAnimation")

func GetGraph() -> Control:
	var auxParent:Node=get_parent().get_parent()
	return  auxParent if get_parent() is GraphEdit else null



func _process(delta: float) -> void:
	
	if GetGraph():
		if lisAnimationPlayer!=CinematicEditor.listAnimationPlayers:
			lisAnimationPlayer=CinematicEditor.listAnimationPlayers
			OptionPlayer.clear()
			for node:AnimationPlayer in lisAnimationPlayer:
				if node:
					OptionPlayer.add_item(node.name)
			OptionPlayer.select(0)
			_NodeOption_Selected(0)
		if aniPlayer and lisAnimationPlayer and OptionAnimation.get_item_count() != aniPlayer.get_animation_list().size():
			_NodeOption_Selected(lisAnimationPlayer.find(aniPlayer))

func _NodeOption_Selected(index: int) -> void:
	if lisAnimationPlayer != []:
		aniPlayer=lisAnimationPlayer[index]
		OptionAnimation.clear()
		for animation:String in aniPlayer.get_animation_list():
			OptionAnimation.add_item(animation)


func _WaitPre_toggled(toggled_on: bool) -> void:
	waitPreAnimation=toggled_on

func _WaitAni_toggled(toggled_on: bool) -> void:
	waitNextAnimation=toggled_on
