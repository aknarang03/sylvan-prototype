extends StaticBody2D

var speed : int = 100
var moveDistance : int = 100
var xTarget : int = position.x + moveDistance

func _process(delta):
	position.x = move(position.x, xTarget, speed * delta)
