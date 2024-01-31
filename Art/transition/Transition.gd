extends CanvasLayer


signal blackout


var reversed = true


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
			get_tree().reload_current_scene()
		"FadeOut":
			queue_free()
