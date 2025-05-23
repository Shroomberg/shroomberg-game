class_name MainMenu extends Control

@export var world: World

@export var fade_in_duration := 0.3
@export var fade_out_duration := 0.2

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var resume_button := center_cont.get_node(^"VBoxContainer/HBoxContainer/VBoxContainer/ResumeButton") as Button
@onready var newgame_button := center_cont.get_node(^"VBoxContainer/HBoxContainer/VBoxContainer/NewGameButton") as Button
@onready var restart_button := center_cont.get_node(^"VBoxContainer/HBoxContainer/VBoxContainer/RestartButton") as Button
@onready var label := center_cont.get_node(^"VBoxContainer/HBoxContainer/VBoxContainer/Label") as Label


func _ready() -> void:
	hide()

func close() -> void:
	var tween := create_tween()
	get_tree().paused = false
	tween.tween_property(
		self,
		^"modulate:a",
		0.0,
		fade_out_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(
		center_cont,
		^"anchor_bottom",
		0.5,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(hide)

func open() -> void:

	show()
	#resume_button.grab_focus()

	modulate.a = 0.0
	center_cont.anchor_bottom = 0.5
	var tween := create_tween()
	tween.tween_property(
		self,
		^"modulate:a",
		1.0,
		fade_in_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		center_cont,
		^"anchor_bottom",
		1.0,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	resume_button.show()
	restart_button.show()
	newgame_button.hide()


func _on_resume_button_pressed() -> void:
	close()

func _on_quit_button_pressed() -> void:
	if visible:
		get_tree().quit()

func _on_restart_button_pressed() -> void:
	resume_button.show()
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_music_check_box_toggled(toggled_on: bool) -> void:
	var player = get_tree().current_scene.find_child("Music") as AudioStreamPlayer2D
	if toggled_on:
		player.play()
	else:
		player.stop()

func _unhandled_input(event: InputEvent) -> void:
	var tree := get_tree()
	if event.is_action_pressed(&"toggle_pause"):
		if tree.paused:
			#tree.paused = not tree.paused
			close()
			get_tree().root.set_input_as_handled()


func open_win():
	open()
	label.text = "You win!"
	resume_button.hide()
	restart_button.show()
	newgame_button.hide()
	
func open_loose():
	open()
	label.text = "You loose!"
	resume_button.hide()
	restart_button.show()
	newgame_button.hide()

func open_start():
	open()
	label.text = "Menu"
	resume_button.hide()
	restart_button.hide()
	newgame_button.show()
	

func _on_new_game_button_pressed() -> void:
	close()

func _on_x_speed_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 5
	else:
		Engine.time_scale = 1
