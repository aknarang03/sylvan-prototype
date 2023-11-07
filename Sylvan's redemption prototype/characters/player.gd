extends CharacterBody2D

@export var speed : float = 300.0
@export var jump_velocity : float = -300.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var timer : Timer = $Timer
@onready var line : Line2D = $Line2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2 = Vector2.ZERO
var animation_locked : bool = false
var was_in_air : bool = false
var possess : bool = false
var time_possessed : float = 0
var time_since_possess : float = 0
var falling : bool = false
var timer_set : bool = false
var possess_anim_finished : bool = false
@onready var enemy = $"../Enemy"

func _physics_process(delta):
	
	print(timer.time_left)
	possess_system()
	
	if timer.time_left == 0 and possess == true:
		animation_locked = false
		possess = false
		enemy.show()
		enemy.set_position(position)
		if not is_on_floor():
			animation_locked = false
			
	if not is_on_floor():
		print(velocity.y)
		velocity.y += gravity * delta
		was_in_air = true
		if velocity.y > -15 and velocity.y < 1:
			falling = true
		if falling == true:
			if Input.is_action_pressed("jump"):
				gravity = 50
			else:
				gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
				
	else: 
		if was_in_air == true:
			land()
			falling = false
			gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		was_in_air = false

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if not possess:
			if is_on_floor():
				jump()
		if possess:
			jump()
		
	if Input.is_key_label_pressed(KEY_P):
		if !possess:
			animation_locked = false
			var distance = sqrt(pow(position.x-enemy.get_global_pos().x,2)+pow(position.y-enemy.get_global_pos().y,2))
			if abs(distance) < 100:
				on_possess()
				
	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	update_animation()
	update_facing_direction()

func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
		

func update_animation():
	if !possess:
		if not animation_locked:
			if direction.x != 0:
				animated_sprite.play("walk")
			else:
				animated_sprite.play("idle")
	if possess:
		if not animation_locked:
			if direction.x != 0:
				animated_sprite.play("bird_fly")
			else:
				animated_sprite.play("bird_idle")
	
func jump():
	velocity.y = jump_velocity
	if not possess:
		animated_sprite.play("jump")
	else:
		animated_sprite.play("bird_fly")
	animation_locked = true
	
func land():
	if not possess:
		animated_sprite.play("land")
		animation_locked = true
	if possess:
		animated_sprite.play("bird_idle")
		animation_locked = false

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "land":
		animation_locked = false

func on_possess():
	line.add_point(to_local(position))
	line.add_point(to_local(enemy.get_global_position()))
	possess = true
	possess_anim_finished = false
	animated_sprite.play("possess_ground")
	timer_set = false
	
func possess_system():
	if possess and (timer_set == false):
		position = enemy.get_global_position()
		enemy.hide()
		timer.one_shot = true
		timer_set = true
		timer.start(5)
		line.clear_points()

func get_global_pos():
	return position
