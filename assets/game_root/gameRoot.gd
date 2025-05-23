class_name GameRoot extends Node

@onready var _game_menu := $Interface/MainMenu as MainMenu

func _ready() -> void:
	var tree := get_tree()
	tree.paused = true
	_game_menu.open_start()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()

	elif event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_game_menu.open()
		else:
			_game_menu.close()
		get_tree().root.set_input_as_handled()


func _on_world_on_loose() -> void:
	_game_menu.open_loose()

func _on_world_on_win() -> void:
	_game_menu.open_win()
	
