extends Sprite2D

@onready var camera = get_node("../Player/Camera2D")

func _process(delta):
	global_position = camera.global_position
