extends Node2D

const SHOT_SPEED : int = 200

func _process(delta):
	if position.y > 0:
		position.y -= SHOT_SPEED * delta
	elif not is_queued_for_deletion():
		queue_free()
