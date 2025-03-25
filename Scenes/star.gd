extends Area2D

var particle = preload("res://Scenes/coin_particle.tscn")

func _on_body_entered(body):
	if "Player" in body.name:
		var p = particle.instantiate()
		get_parent().add_child(p)
		p.set_global_position(get_global_position())
		
		# disable time count too
		body.set_process(false)
		body.set_process_input(false)
		
		# call global game over
		Global.game_over = true
		Global.world.game_over()
		
		queue_free()
