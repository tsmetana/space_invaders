class_name UserInterface extends Control

enum UiType {
	UI_ANDROID = 0,
	UI_GAMEPAD = 1,
	UI_PC = 2
}

var high_score = 0

const invaders_label: String = "SPACE INVADERS 2023"
const hi_score_label: String = "High score: "

var label_text_keyboard : Array = [
	invaders_label,
	"Cursor keys to move\n'Space' to fire\n'Esc' to exit",
	"Press 'S' to start\n'Esc' to quit",
	hi_score_label
	]
var label_text_gamepad : Array = [
	invaders_label,
	"Press 'A' button to start\n'B' button to quit",
	hi_score_label
	]
var label_text_touch : Array = [
	invaders_label,
	"Touch screen to start\n 'Back' button to exit",
	hi_score_label
	]

var label_text : Array
var label_index : int = 1

func set_ui_type(t : UiType):
	match t:
		UiType.UI_ANDROID: label_text = label_text_touch
		UiType.UI_PC: label_text = label_text_keyboard
		UiType.UI_GAMEPAD: label_text = label_text_gamepad
		_: label_text = label_text_keyboard

func _ready():
	$LabelTimer.start()

func _on_label_timer_timeout():
	if label_index == label_text.size() - 1:
		# last element in the label array is the score, so update it
		$Label.set_text(label_text[label_index] + String.num_int64(high_score))
	else:
		$Label.set_text(label_text[label_index])
	label_index += 1
	if label_index == label_text.size():
		label_index = 0

func game_over(score : int):
	var txt = "GAME OVER\nSCORE: " + String.num_int64(score)
	if high_score < score:
		high_score = score
		txt += "\nNEW HIGH SCORE!"
	$Label.set_text(txt)
	label_index = 0
	$LabelTimer.start()
