extends Node2D

@onready var anim = $AnimationPlayer
var anim_active := true

func _physics_process(delta):
	if anim_active == true:
		if Input.is_action_just_pressed("right_click"):
			anim.play("zoom out")
			anim_active = false
