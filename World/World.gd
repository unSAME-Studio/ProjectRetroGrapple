extends Node2D

var transition = preload("res://Art/transition/Transition.tscn")
var can_exit = false

## Switching between fullscreen and not fullscreen by pressing esc
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		#swap_fullscreen_mode()
		get_tree().quit()
	
	if Input.is_action_just_pressed("fullscreen"):
		swap_fullscreen_mode()
	
	if Input.is_action_just_pressed("jump"):
		if can_exit:
			can_exit = false
			
			var t = transition.instantiate()
			t.target = "res://World/Menu.tscn"
			t.reversed = false
			get_tree().get_current_scene().add_child(t)


func _process(delta: float) -> void:
	update_time()


func convert_time_to_string(time: float) -> String:
	# player time is seconds in float
	# convert to 00:00:00 format
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int(time * 100) % 100
	var time_string = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + ":" + str(milliseconds).pad_zeros(2)
	
	return time_string


func update_time():
	var time_string = convert_time_to_string(Global.player_time)

	$CanvasLayer2/Control/TimerLabel.set_text(time_string)


func swap_fullscreen_mode():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func game_over():
	var time_string = convert_time_to_string(Global.player_time)
	
	$CanvasLayer2/Control/CenterContainer/VBoxContainer/FinalScore.set_text("TIME: %s\nDEATH: %d\nCOINS: %d/%d\n\nPRESS [%s] TO CONTINUE" % [time_string, Global.death_count, Global.coins, Global.total_coins, "A" if Global.gamepad_input else "SPACE"])
	
	$CanvasLayer2/Control/TimerLabel.hide()
	$CanvasLayer2/Control/CenterContainer/VBoxContainer.show()
	$CanvasLayer2/Control/Darker.show()
	
	# preset
	$CanvasLayer2/Control/Darker.color = Color("00000000")
	$CanvasLayer2/Control/CenterContainer/VBoxContainer/FinalScore.visible_ratio = 0.0
	
	# anim
	var tween = create_tween()
	tween.tween_property($CanvasLayer2/Control/Darker, "color", Color("000000c1"), 1.0)
	tween.parallel().tween_property($CanvasLayer2/Control/CenterContainer/VBoxContainer/FinalScore, "visible_ratio", 1.0, 2.0)
	
	await(tween.finished)
	
	can_exit = true


func _ready() -> void:
	update_time()
	
	Global.world = self
	Global.total_coins = get_tree().get_nodes_in_group("coins").size()
	
	MusicPlayer.play_music()
	MusicPlayer.fade_in()
	
	# move player position
	if Global.check_point:
		$Player.set_global_position(Global.check_point)
