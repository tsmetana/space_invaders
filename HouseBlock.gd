extends Area2D

var max_hits = 4

func _on_area_entered(area):
	var sprite = get_node("Sprite2D")
	if area.get_name().match("*Shot*"):
		max_hits -= 1
		if max_hits == 0 && not is_queued_for_deletion():
			queue_free()
		else:
			var sprite_rect = sprite.get_region_rect()
			sprite_rect.position += Vector2(8,0)
			sprite.set_region_rect(sprite_rect)
		if not area.is_queued_for_deletion():
			area.queue_free()
	elif area.get_name().match("*Invader*"):
		if not area.is_queued_for_deletion():
			area.queue_free()
