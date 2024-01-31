extends CharacterBody2D
## This character controller was created with the intent of being a decent starting point for Platformers.
## 
## Instead of teaching the basics, I tried to implement more advanced considerations.
## That's why I call it 'Movement 2'. This is a sequel to learning demos of similar a kind.
## Beyond coyote time and a jump buffer I go through all the things listed in the following video:
## https://www.youtube.com/watch?v=2S3g8CgBG1g
## Except for separate air and ground acceleration, as I don't think it's necessary.


# BASIC MOVEMENT VARAIABLES ---------------- #
var face_direction := 1
var x_dir := 1

@export var max_speed: float = 560
@export var acceleration: float = 2880
@export var turning_acceleration : float = 9600
@export var deceleration: float = 3200
# ------------------------------------------ #

# GRAVITY ----- #
@export var gravity_acceleration : float = 3840
@export var gravity_max : float = 1020
# ------------- #

# JUMP VARAIABLES ------------------- #
@export var jump_force : float = 1400
@export var jump_cut : float = 0.25
@export var jump_gravity_max : float = 500
@export var jump_hang_treshold : float = 2.0
@export var jump_hang_gravity_mult : float = 0.1
# Timers
@export var jump_coyote : float = 0.08
@export var jump_buffer : float = 0.1

@export var CHAIN_PULL = 80
var chain_velocity := Vector2(0,0)

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false
# ----------------------------------- #

var coins = 0
var particle = preload("res://Scenes/coin_particle.tscn")
var transition = preload("res://Art/transition/Transition.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			$Chain.shoot(get_local_mouse_position())
			$Hook.play()
		else:
			# We released the mouse -> release()
			$Chain.release()
	
	if Input.is_action_just_pressed("retry"):
		kill()
		#get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("hook"):
		$Chain.shoot(Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)))
		$Hook.play()
	elif Input.is_action_just_released("hook"):
		$Chain.release()


# All iputs we want to keep track of
func get_input() -> Dictionary:
	return {
		"x": int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		"y": int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")),
		"just_jump": Input.is_action_just_pressed("jump") == true,
		"jump": Input.is_action_pressed("jump") == true,
		"released_jump": Input.is_action_just_released("jump") == true
	}


func _physics_process(delta: float) -> void:
	#x_movement(delta)
	#set_direction(clamp(velocity.x, -1, 1)) # This is purely for visuals
	ski(delta)	
	
	jump_logic(delta)
	apply_chain_force (delta)
	apply_gravity(delta)
	
	
	timers(delta)
	move_and_slide()


func ski(delta: float):
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 1 * delta)

func x_movement(delta: float) -> void:
	x_dir = get_input()["x"]
	
	# Stop if we're not doing movement inputs.
	if x_dir == 0: 
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), deceleration * delta).x
		return
	
	# If we are doing movement inputs and above max speed, don't accelerate nor decelerate
	# Except if we are turning
	# (This keeps our momentum gained from outside or slopes)
	if abs(velocity.x) >= max_speed and sign(velocity.x) == x_dir:
		return
	
	# Are we turning?
	# Deciding between acceleration and turn_acceleration
	var accel_rate : float = acceleration if sign(velocity.x) == x_dir else turning_acceleration
	
	# Accelerate
	velocity.x += x_dir * accel_rate * delta
	
	set_direction(x_dir) # This is purely for visuals


func set_direction(hor_direction) -> void:
	# This is purely for visuals
	# Turning relies on the scale of the player
	# To animate, only scale the sprite
	if hor_direction == 0:
		return
	apply_scale(Vector2(hor_direction * face_direction, 1)) # flip
	face_direction = hor_direction # remember direction


func jump_logic(_delta: float) -> void:
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if $Chain.hooked:
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if get_input()["just_jump"]:
		jump_buffer_timer = jump_buffer
		if $Chain.hooked:
			$Chain.release()
	
	# Jump if grounded, there is jump input, and we aren't jumping already
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping:
		is_jumping = true
		$Jump.play()
		jump_coyote_timer = 0
		jump_buffer_timer = 0
		# If falling, account for that lost speed
		if velocity.y > 0:
			velocity.y -= velocity.y
		
		velocity.y = -jump_force
	
	if is_jumping:
		$"../CanvasLayer2/Control/CenterContainer/Label".set_text("CAN JUMP")
	else:
		$"../CanvasLayer2/Control/CenterContainer/Label".set_text("NOPE")
	
	# We're not actually interested in checking if the player is holding the jump button
#	if get_input()["jump"]:pass
	
	# Cut the velocity if let go of jump. This means our jumpheight is varaiable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to studder our player mid falling
	if get_input()["released_jump"] and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	
	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the treshold is arbritary,
	# But it solves a problem where jumping into 
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0


func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0
	
	# No gravity if we are grounded
	#if jump_coyote_timer > 0:
	#	return
	
	# Normal gravity limit
	if velocity.y <= gravity_max:
		applied_gravity = gravity_acceleration * delta
	
	# If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	# Lower the gravity at the peak of our jump (where velocity is the smallest)
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	
	velocity.y += applied_gravity
	
	


func apply_chain_force(delta: float):
	# Hook physics
	if $Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		#if sign(chain_velocity.x) != sign(x_dir):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
		#	chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity


func timers(delta: float) -> void:
	# Using timer nodes here would mean unnececary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta


func kill():
	var p = particle.instantiate()
	p.sound = false
	get_parent().add_child(p)
	p.set_global_position(get_global_position())
	
	$Sprite.hide()
	$Chain.hide()
	
	$GPUParticles2D.set_emitting(false)
	$AudioStreamPlayer2D2.play()
	
	set_physics_process(false)
	set_process_input(false)
	
	await get_tree().create_timer(0.5).timeout
	
	var t = transition.instantiate()
	t.reversed = false
	get_tree().get_current_scene().add_child(t)
