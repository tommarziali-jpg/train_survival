extends Button
class_name KeyBindButton

## A button that shows the key bound to `action_name` and, when clicked,
## waits for the next key press and rebinds the action to it.
##
## While listening: Escape cancels the change, any other key is assigned.

@export var action_name: String = ""

var _listening: bool = false


func _ready() -> void:
	pressed.connect(_on_pressed)
	refresh_text()


## Updates the displayed key from the current binding.
func refresh_text() -> void:
	text = Controls.get_key_label(action_name)


func _on_pressed() -> void:
	_listening = true
	text = "Press a key..."
	# Drop focus so the button does not react to the key we are about to capture.
	release_focus()


func _input(event: InputEvent) -> void:
	if not _listening:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_listening = false
		if event.keycode == KEY_ESCAPE:
			refresh_text()
		else:
			Controls.set_keycode(action_name, event.physical_keycode)
			refresh_text()
		accept_event()
