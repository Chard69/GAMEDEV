extends CharacterBody2D

@export var speed = 4000
var direction = Vector2.ZERO

func _physics_process(delta: float):
	position += direction * speed * delta
	rotation = direction.angle()
	
func _on_timer_timeout():
	queue_free()
