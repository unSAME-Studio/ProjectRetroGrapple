extends Area2D

@export var text = ""


func _ready():
	$CanvasLayer2/Control/CenterContainer/Label.set_text(text)


func _on_body_entered(body):
	if "Player" in body.name:
		$CanvasLayer2.show()
		
		$CanvasLayer2/Control/CenterContainer/Label.set_visible_ratio(0.0)
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property($CanvasLayer2/Control/CenterContainer/Label, "visible_ratio", 1.0, 0.25)


func _on_body_exited(body):
	if "Player" in body.name:
		$CanvasLayer2.hide()
