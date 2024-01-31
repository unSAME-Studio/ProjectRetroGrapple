extends Node2D

var sound = true

func _ready():
	$GPUParticles2D.set_emitting(true)
	
	if sound:
		$AudioStreamPlayer2D.play()


func _on_animation_player_animation_finished(anim_name):
	queue_free()
