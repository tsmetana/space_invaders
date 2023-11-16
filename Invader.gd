extends Area2D

var shot_sc = preload("res://InvaderShot.tscn")

@onready var main_scene = get_parent()
const INVADER4_SPEED : int = 100
var placement : Vector2i

var invader4_direction : float

func _ready():
	if name.match("*Invader4*"):
		if position.x == 316:
			invader4_direction = -1.0
		else:
			invader4_direction = 1.0
		

func move(vector):
	position += vector
	# indicate we're at the edge of the screen
	if position.x <= 4 || position.x >= 316:
		main_scene.edge_hit(get_meta("Placement").y)

func move_invader4(delta):
	if position.x <= 316 && position.x >= 4:
		position.x += INVADER4_SPEED * delta * invader4_direction
	else:
		queue_free()
		main_scene.invader4_exited()
		
func change_color(col : Color):
	set_modulate(col)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if name.match("*Invader4*"):
		# Invader4 is special
		move_invader4(delta)
	elif get_meta("Shooter"):
		if randf() > 0.996: # FIXME: this is silly
			var shot

			shot = shot_sc.instantiate()
			shot.position = position + Vector2(0, 8.0)
			main_scene.add_child(shot)
			$ShotSound.play()

func _on_area_entered(area):
	if area.get_name().match("*PlayerShot*"):
		var animation = get_node("AnimatedSprite2D")
		var collision_body = get_node("CollisionShape2D")
		
		$ExplosionSound.play()
		area.queue_free() # delete the shot
		collision_body.queue_free() # delete collision shape to prevent any further collisions
		main_scene.score_add(get_meta("Value"))
		set_modulate(Color.WHITE) # explosion should be always white
		animation.set_animation("explosion") # explode
		animation.connect("animation_finished", Callable(self, "_on_explosion_animation_finished"))
		animation.play()
		main_scene.decrease_invaders_count()
		# Invader 4 never shoots, check the metadata
		if has_meta("Shooter") && has_meta("Placement") && get_meta("Shooter"):
			main_scene.shooter_died(get_meta("Placement"))


func _on_explosion_animation_finished():
	if not is_queued_for_deletion():
		queue_free() # delete the invader


func _on_body_entered(body):
	if body.get_name().match("*Player*"):
		main_scene.game_over()
