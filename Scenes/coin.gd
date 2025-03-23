extends Area2D

var particle = preload("res://Scenes/coin_particle.tscn")

# delete if already collected
func _ready() -> void:
	if self.name in Global.collected_coins:
		queue_free()


func _on_body_entered(body):
	if "Player" in body.name:
		body.coins += 1
		body.collected_coins.append(self.name)
		
		var p = particle.instantiate()
		get_parent().add_child(p)
		p.set_global_position(get_global_position())
		
		queue_free()
