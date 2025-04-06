class_name Warrior extends Unit

enum UnitState { Idle, Moving, PreparingAction, ExecutingAction, Dead }

@export var max_speed: float = 100.0
@export var damage: float = 1.0
@export var vision_range: float = 100.0

var state: UnitState = UnitState.Idle
var target: Unit = null

func _ready():
	sprite = $Sprite2D
	$VisionArea/Shape.scale = Vector2(vision_range, vision_range)
	set_state(UnitState.Moving)
	super._ready()	
	
func _physics_process(delta: float) -> void:
	if state == UnitState.Moving:
		if player == Player.Left:
			position.x += max_speed * delta
		else:
			position.x -= max_speed * delta

func set_state(new_state: UnitState):	
	state = new_state
	print("%s: %s " % [self.get_instance_id(), UnitState.keys()[new_state]])
	$Animation.play(UnitState.keys()[new_state])
	$HealthBar.visible = new_state != UnitState.Dead

func on_damage_recieved(amount: float):
	if hp > amount:
		hp -= amount
		$HealthBar.value = hp/max_hp
	else:
		on_unit_died()

func on_unit_died():
	target = null
	hp = 0
	set_state(UnitState.Dead)
			
func on_action_prepared():	
	if state == UnitState.Dead:
		return
	set_state(UnitState.ExecutingAction)
	if can_use_target(target):
		execute_action()
		
func on_action_executed():
	if state == UnitState.Dead:
		return					
	if can_use_target(target):			
		set_state(UnitState.PreparingAction)
	else:
		choose_new_target()
	
func on_unit_detected(unit: Unit):
	if state == UnitState.Dead:
		return		
	if !target:
		choose_new_target()

func can_use_target(unit: Unit) -> bool:
	return unit.player != player and !unit.is_dead()
	
func execute_action():
	target.on_damage_recieved(damage)	

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

func _on_animation_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"PreparingAction":
			on_action_prepared()
		"ExecutingAction":
			on_action_executed()
