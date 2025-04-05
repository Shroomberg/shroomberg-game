class_name Unit extends Node2D


signal coin_collected()

const WALK_SPEED = 200.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 700

@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var sprite := $Sprite2D as Sprite2D
var direction = 1

func _physics_process(delta: float) -> void:
	position.x += direction * WALK_SPEED * delta;
	if position.x > 600:
		direction = -1
	if position.x < 0:
		direction = 1		
		
	sprite.scale.x = direction
			
	animation_player.play('new_animation')
