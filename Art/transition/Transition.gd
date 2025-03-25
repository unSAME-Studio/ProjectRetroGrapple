extends CanvasLayer


signal blackout


var reversed = true

var target = null

func _ready():
	match (reversed):
		true:
			$ColorRect/AnimationPlayer.play("FadeOut")
		false:
			$ColorRect/AnimationPlayer.play("FadeIn")


func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"FadeIn":
			emit_signal("blackout")
			if target != null:
				Global.reset_game()
				get_tree().change_scene_to_file(target)
				
			else:
				get_tree().reload_current_scene()
		"FadeOut":
			queue_free()
