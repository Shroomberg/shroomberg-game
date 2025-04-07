extends Camera2D

# Movement speed in pixels per second
var speed := 400

# Panning
var dragging := false
var last_mouse_position := Vector2.ZERO
var completedCentering := true
var centerOnPosition := Vector2.ZERO
var centerTimeRemaining

func slideToPosition(newPosition: Vector2, time: float):
	completedCentering = false
	centerTimeRemaining = time
	centerOnPosition = newPosition

func _process(delta):
	if !completedCentering:
		position += (centerOnPosition - position)/centerTimeRemaining * delta
		centerTimeRemaining -= delta
		if (position - centerOnPosition).length() < 10:
			completedCentering = true
		return
	
	var velocity := Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	# Normalize to prevent faster diagonal movement
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Move the camera
	position += velocity * delta
	

var zoom_step := 0.1
var min_zoom := 0.5
var max_zoom := 3.0

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = clamp(zoom - Vector2(zoom_step, zoom_step), Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = clamp(zoom + Vector2(zoom_step, zoom_step), Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
			last_mouse_position = get_viewport().get_mouse_position()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		var delta = event.relative
		position -= delta / zoom # Zoom-scaled dragging
