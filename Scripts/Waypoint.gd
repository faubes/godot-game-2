extends Spatial

onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	var err = timer.connect("timeout", self, "_on_Timer_timeout")
	if err:
		print(err)

func _on_Timer_timeout():
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
