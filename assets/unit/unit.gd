class_name Unit extends Node2D

signal unit_died();

enum UnitAction { Idle, Moving, Attacking }

const WALK_SPEED = 200.0
@onready var animation := $Animation as AnimationPlayer
@onready var sprite := $Sprite2D as Sprite2D
@onready var vision_area := $VisionArea as Area2D
@onready var vision_shape := $VisionArea/Shape as CollisionShape2D

@export var max_hp: int = 10
@export var max_speed: float = 100.0
@export var damage: float = 1.0
@export var vision_range: float = 100.0
@export var direction = 1

var hp: int = 10

var action: UnitAction = UnitAction.Idle
var target: Unit = null

var action_handlers = {
	UnitAction.Idle: process_idle,
	UnitAction.Moving: process_moving,
	UnitAction.Attacking: process_attacking
}

func _physics_process(delta: float) -> void:
	action_handlers[action].call(delta)	

func _ready():
	hp = max_hp
	vision_shape.scale = Vector2(vision_range, vision_range)
	set_action(UnitAction.Moving)
	sprite.scale = Vector2(direction, 1)
	
func set_action(new_action: UnitAction):
	action = new_action
	print(UnitAction.keys()[action])
	animation.play(UnitAction.keys()[action])
	
func process_idle(delta: float):
	pass
	
func process_moving(delta: float):		
	position.x += direction * WALK_SPEED * delta;		
	
func process_attacking(delta: float):
	if !target or target.is_queued_for_deletion():
		scan_for_targets()
		return
	var target_died = target.take_damage(damage)
	if target_died:
		scan_for_targets()

func take_damage(amount: int) -> bool:
	hp -= amount
	if hp <= 0:
		die()
		return true
	return false		

func can_use_target(node: Node2D) -> bool:
	return node != self and node is Unit

func set_target(node: Node2D):
	target = node
	set_action(UnitAction.Attacking)

func scan_for_targets():
	target = null
	for node in vision_area.get_overlapping_bodies():
		if can_use_target(node):
			set_target(node)
	if !target:
		set_action(UnitAction.Moving)

func _on_body_entered(node: Node2D):
	if !target && can_use_target(node):
		set_target(node)

func die() -> void:	
	unit_died.emit()
	queue_free()
