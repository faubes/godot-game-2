extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	print("gun creation")
	tween.interpolate_property(self, "translation", Vector3.ZERO, Vector3(0, 0.5, 2), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
