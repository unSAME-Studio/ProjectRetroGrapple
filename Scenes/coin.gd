extends Area2D

var particle = preload("res://Scenes/coin_particle.tscn")

func _on_body_entered(body):
	if "Player" in body.name:
		body.coins += 1
		
		var p = particle.instantiate()
		get_parent().add_child(p)
		p.set_global_position(get_global_position())
		
		queue_free()