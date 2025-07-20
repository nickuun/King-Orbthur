extends Control
class_name CheatManager

@onready var input_field: TextEdit = $TextEdit

var command_history: Array = []
var history_index: int = -1

var command_map: Dictionary = {
	"/heal_full": func(): _heal_player(),
	"/autoplay_on": func(): Game.player.autoplay = true,
	"/autoplay_off": func(): Game.player.autoplay = false
}

func _ready():
	visible = false
	input_field.visible = false
	input_field.clear()
	input_field.grab_focus()

func _input(event):
	if event is InputEventKey and not event.echo:
		match event.keycode:
			KEY_SLASH:
				if event.pressed:
					_toggle_console()
			KEY_ESCAPE:
				if visible:
					_hide_console()
			KEY_UP:
				if visible:
					_navigate_history(-1)
			KEY_DOWN:
				if visible:
					_navigate_history(1)
			KEY_ENTER:
				if visible:
					_execute_command()

func _toggle_console():
	visible = !visible
	input_field.visible = visible
	if visible:
		input_field.text = ""
		input_field.grab_focus()
		history_index = command_history.size()
		get_tree().paused = true  # Pause game while console is open
	else:
		get_tree().paused = false

func _hide_console():
	visible = false
	input_field.visible = false
	input_field.release_focus()
	get_tree().paused = false

func _navigate_history(direction: int):
	if command_history.is_empty():
		return

	history_index = clamp(history_index + direction, 0, command_history.size() - 1)
	input_field.text = command_history[history_index]
	input_field.set_caret_column(input_field.text.length())

func _execute_command():
	var command = input_field.text.strip_edges().to_lower()
	if command.is_empty():
		_hide_console()
		return

	if command_history.is_empty() or command_history[-1] != command:
		command_history.append(command)
	history_index = command_history.size()

	if command_map.has(command):
		command_map[command].call()
		print("✅ Executed cheat:", command)
	else:
		print("❌ Unknown cheat command:", command)

	_hide_console()

func _heal_player():
	if is_instance_valid(Game.player):
		Game.player.current_health = Game.player.max_health
		Game.player.update_lifebar()
		print("❤️ Full HP restored.")
