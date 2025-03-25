extends Node

signal on_input_switched(is_gamepad)

var world

var game_over = false

var gamepad_input = false
var last_gamepad_input : Vector2 = Vector2.ZERO
var check_point
var used_check_point = []

var coins : int = 0
var total_coins : int = 0
var collected_coins = []

var death_count : int = 0
var player_time : float = 0.0


func _input(event: InputEvent) -> void:
	if gamepad_input:
		# update the last input here again
		if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
			last_gamepad_input = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		
		if event is InputEventMouse:
			print("Using Keyboard Mouse Input")
			gamepad_input = false
			
			emit_signal("on_input_switched", false)
	else:
		if event is InputEventJoypadButton:
			print("Using Gamepad Input")
			gamepad_input = true
			emit_signal("on_input_switched", true)
		
		elif Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
			print("Using Gamepad Joystick Input")
			gamepad_input = true
			emit_signal("on_input_switched", true)


func reset_game():
	game_over = false
	
	check_point = null
	used_check_point = []

	coins = 0
	collected_coins = []
	
	death_count = 0
	player_time = 0


func save_game(player: Player_Controller):
	coins = player.coins
	collected_coins = player.collected_coins.duplicate()

func load_game(player: Player_Controller):
	player.coins = coins
	player.collected_coins = collected_coins.duplicate()
