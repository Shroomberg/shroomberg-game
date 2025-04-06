class_name Spore extends Unit

enum UnitState { Idle, PreparingAction, ExecutingAction, Dead }

var state: UnitState = UnitState.Idle

func _ready():
	sprite = $Sprite2D
	set_state(UnitState.PreparingAction)
	super._ready()	
	
func _physics_process(delta: float) -> void:
	pass

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
	hp = 0
	set_state(UnitState.Dead)
			
func on_action_prepared():	
	if state == UnitState.Dead:
		return
	set_state(UnitState.ExecutingAction)
	execute_action()
		
func on_action_executed():
	if state == UnitState.Dead:
		return						
	set_state(UnitState.PreparingAction)
	
func execute_action():
	on_unit_died()
	pass

func _on_animation_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"PreparingAction":
			on_action_prepared()
		"ExecutingAction":
			on_action_executed()
