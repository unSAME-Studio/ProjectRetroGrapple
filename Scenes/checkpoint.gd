extends Area2D


var particle = preload("res://Scenes/coin_particle.tscn")


func _ready():
	if get_global_position() in Global.used_check_point:
		#for i in get_children():
			#if i is CollisionShape2D:
				#i.set_deferred("disabled", true)
		
		$GPUParticles2D.set_emitting(false)
		
		$AnimationPlayer.play("up")
		
		if get_global_position() == Global.check_point:
			$AudioStreamPlayer2D.play()
			$AudioStreamPlayer2D2.play()
			
			$GPUParticles2D2.set_emitting(false)
			
			var p = particle.instantiate()
			p.sound = false
			get_parent().add_child(p)
			p.set_global_position($GPUParticles2D.get_global_position())


func _on_body_entered(body):
	#for i in get_children():
		#if i is CollisionShape2D:
			#i.set_deferred("disabled", true)
	
	# only save location and cutscene onces
	if get_global_position() not in Global.used_check_point:
		Global.check_point = get_global_position()
		Global.used_check_point.append(get_global_position())
	
		$AnimationPlayer.play("up")
		$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D2.play()
		$GPUParticles2D.set_emitting(false)
		
		$GPUParticles2D2.set_emitting(false)
		
		var p = particle.instantiate()
		p.sound = false
		get_parent().add_child(p)
		p.set_global_position($GPUParticles2D.get_global_position())
	
	# but save the coins everytime you enter
	Global.save_game(body)
