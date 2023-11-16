extends CharacterBody2D

const MOVE_SPEED : int = 150
var can_move : bool = true


func shoot():
	$ShotSound.play()

func explode():
	$ExplosionSound.play()

func set_can_move(val : bool):
	can_move = val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_move:
		if Input.is_action_pressed("right") && position.x < 316:
			position = position + Vector2(MOVE_SPEED, 0) * delta
			if position.x > 316:
				position.x = 316
		if Input.is_action_pressed("left") && position.x > 4:
			position = position - Vector2(MOVE_SPEED, 0) * delta
			if position.x < 4:
				position.x = 4 
