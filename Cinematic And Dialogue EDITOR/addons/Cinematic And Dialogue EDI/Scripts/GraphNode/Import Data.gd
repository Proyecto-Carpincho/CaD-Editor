@tool
extends CinematicNode
class_name ImportData

@onready var OtherType:VBoxContainer= get_node("HBoxContainer/VBoxContainer/Other type")
@onready var NormalType:VBoxContainer= get_node("HBoxContainer/VBoxContainer/Normal Type")
@onready var RichType:RichTextLabel=get_node("HBoxContainer/VBoxContainer/Other type/Rich Type")
const Type:Array[String] = [
	"Nil",        # 0
	"Bool",       # 1
	"Int",        # 2
	"Float",      # 3
	"String",     # 4
	"Vector2",    # 5
	"Vector2i",   # 6
	"Rect2",      # 7
	"Rect2i",     # 8
	"Vector3",    # 9
	"Vector3i",   #10
	"Transform2D",#11
	"Vector4",    #12
	"Vector4i",   #13
	"Plane",      #14
	"Quaternion", #15
	"AABB",       #16
	"Basis",      #17
	"Transform3D",#18
	"Projection", #19
	"Color",      #20
	"StringName", #21
	"NodePath",   #22
	"RID",        #23
	"Object",     #24
	"Callable",   #25
	"Signal",     #26
	"Dictionary", #27
	"Array",      #28
	"PackedByteArray",  #29
	"PackedInt32Array", #30
	"PackedInt64Array", #31
	"PackedFloat32Array", #32
	"PackedFloat64Array", #33
	"PackedStringArray",  #34
	"PackedVector2Array", #35
	"PackedVector3Array", #36
	"PackedColorArray"    #37
]


func _OptionType_Selected(index: int) -> void:
	OtherType.set_visible(index == 6)
	NormalType.set_visible(index != 6)


func _SpinType_valueChange(value: float) -> void:
	print(value,Type[value])
	RichType.set_text("[wave]Type: "+Type[value]+"[/wave]")
