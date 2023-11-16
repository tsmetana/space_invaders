extends Control

const UserInterface = preload("res://UserInterface.gd")
var game_sc = preload("res://GameScene.tscn")
var ui_sc = preload("res://UserInterface.tscn")
var game_running = false
var game
var ui
var ui_type = UserInterface.UiType.UI_PC

func _show_game_controls(val : bool):
	$RightMarginContainer/RightContainer.set_visible(val)
	$LeftMarginContainer/LeftContainer.set_visible(val)

func _show_interface():
	ui = ui_sc.instantiate()
	ui.set_ui_type(ui_type)
	$MiddleContainer.add_child(ui)

func _ready():
	if len(Input.get_connected_joypads()) > 0:
		ui_type = UserInterface.UiType.UI_GAMEPAD
		print_debug("Using gamepad")
	elif OS.has_feature("android"):
		ui_type = UserInterface.UiType.UI_ANDROID
		print_debug("Running on Android")
	else:
		print_debug("Using PC keyboard")
	get_tree().set_quit_on_go_back(false)
	_show_interface()

func _on_game_ended():
	var score
	game_running = false
	score = game.get_score()
	_show_game_controls(false)
	_show_interface()
	ui.game_over(score)

func _game_start():
	ui.queue_free()
	game = game_sc.instantiate()
	game.connect("tree_exited", Callable(self, "_on_game_ended"))
	game_running = true
	$MiddleContainer.add_child(game)
	_show_game_controls(true)

func _process(_delta):
	if !game_running:
		if Input.is_action_pressed("quit"):
			get_tree().quit()
		if Input.is_action_just_released("start"):
			_game_start()

func _on_gui_input(event: InputEvent):
	if not game_running and event is InputEventScreenTouch and event.is_pressed():
		_game_start()

func _notification(what):
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if not game_running:
				get_tree().quit()
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			get_tree().set_pause(true)
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			get_tree().set_pause(false)
