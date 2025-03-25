"""
This script controls the chain.
"""
extends Node2D

@onready var links = $Links		# A slightly easier reference to the links
var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# The global position the tip should be in
								# We use an extra var for this, because the chain is 
								# connected to the player and thus all .position
								# properties would get messed with when the player
								# moves.

const SPEED = 50	# The speed with which the chain moves
const MAX_DISTANCE = 200.0
var current_distance = 0.0

var flying = false	# Whether the chain is moving through the air
var hooked = false	# Whether the chain has connected to a wall
var hooked_body = null

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2) -> void:
	direction = dir.normalized()	# Normalize the direction and save it
	flying = true					# Keep track of our current scan
	tip = self.global_position		# reset the tip position to the player's position
	current_distance = 0.0
	
# release() the chain
func release() -> void:
	flying = false	# Not flying anymore	
	hooked = false	# Not attached anymore

# Every graphics frame we update the visuals
func _process(delta: float) -> void:
	if Global.game_over:
		return
	
	#self.visible = flying or hooked	# Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	var tip_loc = to_local(tip)	# Easier to work in local coordinates
	
	# We rotate the links (= chain) and the tip to fit on the line between self.position (= origin = player.position) and the tip
	links.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(-90)
	#$Tip.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(-90)
	links.position = tip_loc						# The links are moved to start at the tip
	#links.region_rect.size.y = tip_loc.length()		# and get extended for the distance between (0,0) and the tip
	links.region_rect.size.y = get_global_position().distance_to($Tip.get_global_position()) * 2
	
	
func _physics_process(delta: float) -> void:
	# update the raycast
	# switch between using mouse or gamepad
	var dir: Vector2
	if Global.gamepad_input:
		dir = Global.last_gamepad_input
	else:
		dir = (get_global_mouse_position() - get_global_position()).normalized()
	
	$RayCast2D.set_target_position(dir * MAX_DISTANCE)
	
	if $RayCast2D.is_colliding():
		$TilesetOf5.set_global_position($RayCast2D.get_collision_point())
		#$TilesetOf5.show()
		$TilesetOf5.rotate(delta * 10)
		$TilesetOf5.set_modulate(Color.WHITE)
	else:
		#$TilesetOf5.hide()
		$TilesetOf5.set_global_position(get_global_position() + dir * MAX_DISTANCE)
		$TilesetOf5.set_modulate(Color("#757575"))
	
	$Tip.global_position = tip	# The player might have moved and thus updated the position of the tip -> reset it
	
	if flying:
		current_distance = get_global_position().distance_to($Tip.get_global_position())
		if current_distance >= MAX_DISTANCE:
			release()
		
		# `if move_and_collide()` always moves, but returns true if we did collide
		var result = $Tip.move_and_collide(direction * SPEED)
		if result:
			print(result.get_collider().name)
			if result.get_collider() in [CharacterBody2D, AnimatableBody2D]:
				hooked_body = result.get_collider()
			else:
				hooked_body = null
			
			hooked = true	# Got something!
			flying = false	# Not flying anymore
			
			$Tip/AudioStreamPlayer2D.play()
	
	if not flying and not hooked:
		$Tip.set_global_position(lerp($Tip.get_global_position(), get_global_position(), delta * 20))
	
	if hooked and hooked_body:
		pass
	
	tip = $Tip.global_position	# set `tip` as starting position for next frame
