extends Node2D

## Switching between fullscreen and not fullscreen by pressing esc

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		#swap_fullscreen_mode()
		get_tree().quit()

func swap_fullscreen_mode():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _ready():
	if Global.check_point:
		$Player.set_global_position(Global.check_point)
		
