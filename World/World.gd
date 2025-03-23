extends Node2D

## Switching between fullscreen and not fullscreen by pressing esc

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		#swap_fullscreen_mode()
		get_tree().quit()
	
	if Input.is_action_just_pressed("fullscreen"):
		swap_fullscreen_mode()


func _process(delta: float) -> void:
	update_time()


func update_time():
	# player time is seconds in float
	# convert to 00:00:00 format
	var minutes = int(Global.player_time) / 60
	var seconds = int(Global.player_time) % 60
	var milliseconds = int(Global.player_time * 100) % 100
	var time_string = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + ":" + str(milliseconds).pad_zeros(2)

	$CanvasLayer2/Control/TimerLabel.set_text(time_string)


func swap_fullscreen_mode():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _ready() -> void:
	update_time()
	
	# move player position
	if Global.check_point:
		$Player.set_global_position(Global.check_point)
