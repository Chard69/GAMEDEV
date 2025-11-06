extends CharacterBody2D

@export var enemy_npc: Node2D
@export var projectile_scene: PackedScene

var target_position = Vector2()
var target_angle
var detected_enemy = null

var is_attacking = false
var is_shooting = false

var can_shoot = true
var shoot_cooldown = 0

var move_cooldown_timer = 0.0

var combo_count = 0
var combo_timer = 0.0
const COMBO_WINDOW = 0.5


func _ready():
	target_position = position
	$AnimatedSprite2D.play("idle")
	
func _physics_process(delta):
	var speed = 100
	
	if Input.is_action_just_pressed("right_click"):
		target_position = get_global_mouse_position()
		is_attacking = false
		$AnimatedSprite2D.play("move")
		
	if position.distance_to(target_position) < 10:
		if is_attacking == false:
			$AnimatedSprite2D.play("idle")
			
			
		
	if Input.is_action_just_pressed("attack"):
		if combo_timer > 0:
			combo_count +=1
		else:
			combo_count = 1 
			
		velocity = Vector2.ZERO  # 🔹 stop any sliding immediately
		target_position = position  # 🔹 cancel current move target
		
	
			
		match combo_count:
			1:
				$AnimatedSprite2D.play("slash1")
			2:
				$AnimatedSprite2D.play("slash2")
			3:
				$AnimatedSprite2D.play("slash3")
				combo_count = 0  # reset after final slash
		
		combo_timer = COMBO_WINDOW
		is_attacking = true
		is_shooting = true
		shoot()
			
	if Input.is_action_just_pressed("attack_move"):
		target_position = get_global_mouse_position()
		if detected_enemy != null:
			is_attacking = true
			is_shooting = true
			shoot()
			
	if Input.is_action_just_pressed("Dash"):
		target_position = get_global_mouse_position()
		dash()
			
	if is_attacking and detected_enemy != null:
		var to_enemy = detected_enemy.global_position - position
		var angle_to_enemy = to_enemy.angle()
		rotation = lerp_angle(rotation, angle_to_enemy, 25 * delta)
		
		return
		
	if move_cooldown_timer >0:
		move_cooldown_timer -= delta

	# ONLY MOVE TOWARD CLICK IF NOT ATTACKING
	if !is_attacking and !is_shooting and move_cooldown_timer <= 0:
		# Flip horizontally based on mouse click direction
		if target_position.x < position.x:
			$AnimatedSprite2D.flip_h = true   # face left
		else:
			$AnimatedSprite2D.flip_h = false  # face right

		# MOVEMENT
		var direction = (target_position - position).normalized()
		var distanced = position.distance_to(target_position)

		if distanced > 10:
			position += direction * speed * delta
			
	if combo_timer > 0:
		combo_timer -= delta
		return
	else:
		combo_count = 0 
	
	move_and_slide()

func shoot():
	if not can_shoot:
		# If can't shoot, don't block movement
		is_shooting = false
		return

	is_shooting = true
	can_shoot = false

	# Optional short windup before firing
	await get_tree().create_timer(0.1).timeout

	# FIRE projectile
	if detected_enemy != null:
		var projectile = projectile_scene.instantiate()
		projectile.position = global_position
		projectile.direction = Vector2.RIGHT.rotated(rotation).normalized()
		get_tree().current_scene.add_child(projectile)

	# Lock movement briefly after shooting
	move_cooldown_timer = 0.1
	is_shooting = false

	# Wait for cooldown before allowing next shot
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func dash():
	var dash_speed = 400
	var dash_duration = 0.1
	var dash_direction = (get_global_mouse_position() - global_position).normalized()

	var dash_time = 0.0
	while dash_time < dash_duration:
		velocity = dash_direction * dash_speed
		move_and_slide()
		dash_time += get_process_delta_time()
		await get_tree().process_frame
	velocity = Vector2.ZERO
		
	
func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		detected_enemy = body

func _on_area_2d_body_exited(body: Node2D):
	if body == detected_enemy:
		detected_enemy = null
		is_attacking = false
	
func _on_animated_sprite_2d_animation_finished() -> void:
	var a_name = $AnimatedSprite2D.animation

	# If any slash animation finished...
	if a_name.begins_with("slash"):
		is_attacking = false
	
	
		if combo_count == 0 or combo_timer <= 0.0:
			$AnimatedSprite2D.play("idle")
