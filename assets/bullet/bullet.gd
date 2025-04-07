class_name Bullet extends Node2D

@export var speed: float = 2000
@export var radius: float = 10
@export var damage: float = 1

var target: Mushroom

func _ready():
	$AnimationPlayer.play("Moving")
	pass
	
func _physics_process(delta: float):
	if !target or is_queued_for_deletion():
		queue_free()		
		return		
		
	var direction = get_direction()
	var offset = delta * direction.normalized() * speed;	
	
	if direction.length() < offset.length():
		on_hit()
	else:				
		global_position += offset;

func get_direction():
	return target.get_bullet_hit_point() - global_position

func on_hit():
	target.recieve_damage(damage)
	queue_free()
