extends CharacterBody2D


@export var speed : float = 300.0
@export var jump_velocity : float = -300.0
@export var float_velocity : float = -300.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2 = Vector2.ZERO
var animation_locked : bool = false
var was_in_air : bool = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
		was_in_air = true
	else: 
		if was_in_air == true:
			land()
		was_in_air = false

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()

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
	if not animation_locked:
		if direction.x != 0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	
## possibly change it so that velocity depends on how long you hold down space 
func jump():
	velocity.y = jump_velocity
	animated_sprite.play("jump")
	animation_locked = true
	
func glide():
	## doesn't do anything yet; need to somehow make it so once he reaches full jump height he falls slower
	velocity.y = float_velocity
	
	
func land():
	animated_sprite.play("land")
	animation_locked = true

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "land":
		animation_locked = false
		
