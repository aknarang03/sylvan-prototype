extends CharacterBody2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
#@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var direction = Vector2.RIGHT
var vel = Vector2.ZERO
var move = -1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	animated_sprite.play("fly")
	
	#idk why it starts out with the wrong flip
	position.x += move
	
	if (position.x >= 600):
		animated_sprite.flip_h = false
		move -= 1
	if (position.x <= 0):
		animated_sprite.flip_h = true
		move += 1
	
	#position = position.move_toward(Vector2(0,0), delta*speed)
	#move_and_slide()
	
func get_global_pos():
	return position




