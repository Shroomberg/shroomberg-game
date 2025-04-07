class_name World extends Node

func _ready():
	$Camera2D.slideToPosition($CameraStartPosition.global_position, 1.5)
