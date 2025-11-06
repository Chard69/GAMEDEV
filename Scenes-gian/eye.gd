extends CharacterBody2D

var player: CharacterBody2D

func _ready():
	# Find the player in the scene automatically
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	if player:
		look_at(player.global_position)
