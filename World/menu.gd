extends Node2D

var transition = preload("res://Art/transition/Transition.tscn")

func _ready() -> void:
	MusicPlayer.fade_out()
	
	#var t = transition.instantiate()
	#t.reversed = true
	#get_tree().get_current_scene().add_child(t)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		#swap_fullscreen_mode()
		get_tree().quit()
	
	if Input.is_action_just_pressed("fullscreen"):
		swap_fullscreen_mode()
	
	if Input.is_action_just_pressed("jump"):
		var t = transition.instantiate()
		t.target = "res://World/World.tscn"
		t.reversed = false
		get_tree().get_current_scene().add_child(t)


func swap_fullscreen_mode():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
