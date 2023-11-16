extends Node2D

var shot_sc = preload("res://PlayerShot.tscn")
var invader1_sc = preload("res://Invader1.tscn")
var invader2_sc = preload("res://Invader2.tscn")
var invader3_sc = preload("res://Invader3.tscn")
var invader4_sc = preload("res://Invader4.tscn")

@onready var player = get_node("Player")

const player_start_pos : Vector2i = Vector2i(60, 220)
var player_locked : bool = false

var shot_timer
var invader4_timer
var can_shoot : bool = true
var invaders_count : int
var invaders_wave : int = 0
var moving_row : int = 4
var delta_acc : float = 0.0
var score : int = 0
var invaders_array : Array = []
var lives_count = 3

# zig-zag movement, change color on every second descend
const invaders_directions : PackedVector2Array = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.DOWN]
var movement_step : int = 0
var rows_to_move : int = 4
const invaders_colors: Array = [Color.RED, Color.CYAN, Color.YELLOW, Color.GREEN]
var current_color : int = 0

func score_add(val : int):
	var score_value_label = get_node("ScoreValueLabel")
	score += val
	score_value_label.text = String.num_int64(score)

func get_score():
	return score

func edge_hit(row : int):
	rows_to_move = row - 1

func get_round():
	return invaders_wave

func shooter_died(which : Vector2i):
	var new_y : int = which.y - 1
	# find the next invader above the dead shooter an make him a shooter
	while new_y >= 0:
		if invaders_array[which.x][new_y] != null:
			invaders_array[which.x][new_y].set_meta("Shooter", true)
			break
		new_y -= 1

func decrease_invaders_count():
	invaders_count -= 1
	if invaders_count == 0:
		place_invaders()

func shot_timer_cb():
	can_shoot = true

func invader4_exited():
	# reset timer to random value again
	invader4_timer.set_wait_time(randf_range(1.0, 5.0))
	invader4_timer.start()

# place the special invader at the top
func invader4_timer_cb():
	var invader4
	var x_position
	
	invader4_timer.stop()
	invader4 = invader4_sc.instantiate()
	if randf() < 0.5:
		x_position = 4
	else:
		x_position = 316
	invader4.position = Vector2(x_position,20)
	add_child(invader4)

func place_invaders():
	var invaders_row : Array = [invader3_sc, invader1_sc, invader2_sc, invader3_sc, invader1_sc]
	
	# let's keep the array coords orientation the same as the screen: columns first
	for i in range(11):
		invaders_array.append([])
	
	for i in range(5):
		for j in range(11):
			var invader
			invader = invaders_row[i].instantiate()
			invader.position = Vector2(12 + j * 16, 36 + i * 16)
			invader.placement = Vector2i(j, i)
			invader.add_to_group("row" + String.num_int64(i))
			invaders_array[j].append(invader)
			invader.set_meta("Placement", Vector2i(j, i))
			invader.set_modulate(Color.RED)
			if i != 4:
				invader.set_meta("Shooter", false)
			else:
				invader.set_meta("Shooter", true)
			add_child(invader)
	invaders_count = 5 * 11
	invaders_wave += 1

func place_player():
	player.position = player_start_pos

func game_over():
	queue_free()

func player_hit():
	var player_animation
	var player_animation_timer = Timer.new()
	
	if player_locked:
		return
	player_locked = true
	player.explode()
	lives_count -= 1
	player_animation = player.get_node("AnimatedSprite2D")
	player_animation.set_animation("blinking")
	player_animation_timer.set_wait_time(1.0)
	player_animation_timer.set_one_shot(true)
	add_child(player_animation_timer)
	player_animation.play()
	player_animation_timer.start()
	await player_animation_timer.timeout
	player_animation.stop()
	player_animation.set_animation("default")
	if lives_count <= 0:
		game_over()
	else:
		var indicator
		indicator = get_node("LifeIndicator" + String.num_int64(lives_count))
		if indicator != null and not indicator.is_queued_for_deletion():
			indicator.queue_free()
		place_player()
	player_locked = false

func _ready():
	randomize()
	# allow max one shot per 0.5 sec
	shot_timer = Timer.new()
	shot_timer.set_wait_time(0.5)
	shot_timer.connect("timeout", Callable(self, "shot_timer_cb"))
	add_child(shot_timer)
	# place the special invader on screen with random breaks after it disappeared
	invader4_timer = Timer.new()
	invader4_timer.connect("timeout", Callable(self, "invader4_timer_cb"))
	add_child(invader4_timer)
	invader4_exited()
	place_invaders()

func _process(delta):
	if delta_acc >= 1.0: # jump by 8 pixels every second
		var move_dir : Vector2
		
		if rows_to_move < 0:
			movement_step += 1
			if movement_step == invaders_directions.size():
				movement_step = 0
			if movement_step == 1 || movement_step == 3:
				current_color += 1
				if current_color == invaders_colors.size():
					current_color = 0
			rows_to_move = 4
		move_dir = invaders_directions[movement_step] * 8
		$InvadersMoveSound.play()
		get_tree().call_group("row" + String.num_int64(moving_row), "move", move_dir)
		if movement_step == 1 || movement_step == 3:
			get_tree().call_group("row" + String.num_int64(moving_row), "change_color", invaders_colors[current_color])
		if moving_row > 0:
			moving_row -= 1
		else:
			moving_row = 4
		delta_acc = 0.0
	else:
		delta_acc += delta
	if Input.is_action_just_pressed("fire") and can_shoot and !player_locked:
		var shot
		
		player.shoot()
		can_shoot = false
		shot = shot_sc.instantiate()
		shot.position = player.position
		shot.position -= Vector2(0, 15.0)
		add_child(shot)
		shot_timer.start()
	if Input.is_action_just_released("quit"):
		if not is_queued_for_deletion():
			queue_free()

func _notification(what):
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if not is_queued_for_deletion():
				queue_free()
