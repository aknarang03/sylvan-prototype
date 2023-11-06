extends CharacterBody2D


@export var speed : float = 300.0
@export var jump_velocity : float = -300.0
@export var float_velocity : float = -300.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var timer : Timer = $Timer
@onready var canvas : CanvasLayer = $CanvasLayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2 = Vector2.ZERO
var animation_locked : bool = false
var was_in_air : bool = false
var possess : bool = false
var time_possessed : float = 0
var time_since_possess : float = 0
@onready var enemy = $"../Enemy"


func _physics_process(delta):
	
	#print(possess)
	# Add the gravity.
	
	print(timer.time_left)
	if timer.time_left == 0 and possess == true:
		animation_locked = false
		possess = false
		enemy.show()
		enemy.set_position(position)
	
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else: 
		if was_in_air == true:
			land()
		was_in_air = false

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if not possess:
			if is_on_floor():
				jump()
		if possess:
			jump()
		
		
	if Input.is_key_label_pressed(KEY_P):
		#animated_sprite.play("possess_ground")
		if !possess:
			#print(position.x)
			#print(enemy.get_global_pos().x)
			var distance = sqrt(pow(position.x-enemy.get_global_pos().x,2)+pow(position.y-enemy.get_global_pos().y,2))
			#print(distance)
			if abs(distance) < 100:
				on_possess()
				#time_possessed = get_physics_process_delta_time()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
	
## possibly change it so that velocity depends on how long you hold down space 
func jump():
	velocity.y = jump_velocity
	if not possess:
		animated_sprite.play("jump")
	else:
		animated_sprite.play("bird_fly")
	animation_locked = true
	
func glide():
	## doesn't do anything yet; need to somehow make it so once he reaches full jump height he falls slower
	velocity.y = float_velocity
	
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
	#animation_locked = true
	#animated_sprite.play("possess_ground")
	#animation_locked = false
	#animated_sprite.play("bird_idle")
	possess = true
	position = enemy.get_global_position()
	enemy.hide()
	timer.one_shot = true
	timer.start(5)

func get_global_pos():
	return position
