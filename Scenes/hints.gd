extends Area2D

@export var text = ""
@export var gamepad_text = ""


func find_matching_text(is_gamepad):
	if is_gamepad and gamepad_text != "":
		return gamepad_text
	else:
		return text


func update_text(is_gamepad):
	$CanvasLayer2/Control/CenterContainer/Label.set_text(find_matching_text(is_gamepad))


func _ready():
	update_text(Global.gamepad_input)
	
	Global.connect("on_input_switched", update_text)


func _on_body_entered(body):
	if "Player" in body.name:
		$CanvasLayer2.show()
		
		$CanvasLayer2/Control/CenterContainer/Label.set_visible_ratio(0.0)
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property($CanvasLayer2/Control/CenterContainer/Label, "visible_ratio", 1.0, 0.25)


func _on_body_exited(body):
	if "Player" in body.name:
		$CanvasLayer2.hide()
