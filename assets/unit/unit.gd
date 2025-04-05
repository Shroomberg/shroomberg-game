class_name Unit extends Node2D

enum UnitState { Idle, Moving, PreparingAction, ExecutingAction, Dead }
enum UnitEvent { ActionPrepared, ActionExecuted, TargetDetected, UnitDied }

const WALK_SPEED = 200.0

@export var max_hp: float = 10
@export var max_speed: float = 100.0
@export var damage: float = 1.0
@export var vision_range: float = 100.0
@export var direction = 1

var hp: float = 10

var state: UnitState = UnitState.Idle
var target: Unit = null

func _ready():
	hp = max_hp
	$VisionArea/Shape.scale = Vector2(vision_range, vision_range)
	set_state(UnitState.Idle)
	$Sprite2D.scale = Vector2(direction, 1)
	
func _physics_process(delta: float) -> void:
	match state:
		UnitState.Moving: 
			position.x += direction * WALK_SPEED * delta;	

func set_state(new_state: UnitState):	
	state = new_state
	print("%s: %s " % [self.get_instance_id(), UnitState.keys()[new_state]])
	$Animation.play(UnitState.keys()[new_state])
	$HealthBar.visible = new_state != UnitState.Dead

func take_damage(amount: int):
	if hp > amount:
		hp -= amount
		$HealthBar.value = hp/max_hp
	else:
		process_event(UnitEvent.UnitDied)

func can_use_target(node: Node2D) -> bool:
	return node != self and node is Unit and node.state != UnitState.Dead	

func process_event(event: UnitEvent):
	if state == UnitState.Dead:
		return
	
	match event:
		UnitEvent.TargetDetected:			
			if !target:
				choose_new_target()				
		UnitEvent.ActionExecuted:					
			if can_use_target(target):			
				set_state(UnitState.PreparingAction)
			else:
				choose_new_target()
		UnitEvent.ActionPrepared:
			set_state(UnitState.ExecutingAction)
			if can_use_target(target):
				execute_action()
		UnitEvent.UnitDied:				
			target = null
			hp = 0
			set_state(UnitState.Dead)

func execute_action():
	target.take_damage(damage)	

func choose_new_target():
	target = scan_for_target()
	if target:
		set_state(UnitState.PreparingAction)
	else:
		set_state(UnitState.Moving)		

func scan_for_target() -> Unit:
	print("%s: scanning for targets " % [self.get_instance_id()])
	for node in $VisionArea.get_overlapping_bodies():
		if can_use_target(node):
			return node
	return null

func _on_body_entered(node: Node2D):
	process_event(UnitEvent.TargetDetected)

func _on_animation_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"PreparingAction":
			process_event(UnitEvent.ActionPrepared)
		"ExecutingAction":
			process_event(UnitEvent.ActionExecuted)
