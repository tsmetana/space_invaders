extends Node2D

const SHOT_SPEED : int = 200

@onready var main_scene = get_parent()

func _process(delta):
	if position.y < 232:
		position.y += SHOT_SPEED * delta
	elif not is_queued_for_deletion():
		queue_free()

func _on_body_entered(body):
	if body.get_name().match("*Player*"):
		main_scene.player_hit()
		if not is_queued_for_deletion():
			queue_free()
