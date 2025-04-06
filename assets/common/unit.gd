class_name Unit extends CharacterBody2D

enum Player { Left, Right }

@export var max_hp: float = 10
@export var player: Player = Player.Left

var hp: float = max_hp
var sprite: Sprite2D

func _ready():
	hp = max_hp
	if player == Player.Right:
		sprite.scale.x = -1
	
func on_damage_recieved(amount: float):
	pass
		
func is_dead():
	return hp <= 0
