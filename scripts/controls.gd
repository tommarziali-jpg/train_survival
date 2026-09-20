extends Node
class_name GameControls

## Global input-binding manager.
## Registered as the `Controls` autoload. It owns the keyboard bindings for the
## gameplay actions, applies them to the InputMap at startup and persists any
## change the player makes in the Settings menu to user://controls.cfg.

const CONFIG_PATH := "user://controls.cfg"
const SECTION := "controls"

## Action name -> default physical keycode. Physical keycodes keep WASD in the
## same spot regardless of keyboard layout.
const DEFAULT_BINDINGS := {
	"move_forward": KEY_W,
	"move_backward": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"jump": KEY_SPACE,
}

## Action name -> human readable label used by the settings UI.
const ACTION_LABELS := {
	"move_forward": "Move Forward",
	"move_backward": "Move Backward",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
}


func _ready() -> void:
	load_bindings()


## Ordered list of the actions the player can rebind.
func get_action_names() -> Array:
	return DEFAULT_BINDINGS.keys()


func get_action_label(action: String) -> String:
	return ACTION_LABELS.get(action, action)


## Reads the saved config (falling back to the defaults) and pushes it into the
## InputMap. Safe to call even when no config file exists yet.
func load_bindings() -> void:
	var config := ConfigFile.new()
	var has_config: bool = config.load(CONFIG_PATH) == OK
	for action: String in DEFAULT_BINDINGS.keys():
		var keycode: int = DEFAULT_BINDINGS[action]
		if has_config:
			keycode = int(config.get_value(SECTION, action, keycode))
		_apply_binding(action, keycode)


## Changes one action's key and immediately saves the whole set.
func set_keycode(action: String, keycode: int) -> void:
	_apply_binding(action, keycode)
	save_bindings()


## Restores every action to its default key and saves the result.
func reset_to_defaults() -> void:
	for action: String in DEFAULT_BINDINGS.keys():
		_apply_binding(action, DEFAULT_BINDINGS[action])
	save_bindings()


## The physical keycode currently bound to an action (KEY_NONE if unbound).
func get_keycode(action: String) -> int:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.physical_keycode
	return KEY_NONE


## Display name of the key bound to an action, e.g. "W" or "Space".
func get_key_label(action: String) -> String:
	var keycode: int = get_keycode(action)
	if keycode == KEY_NONE:
		return "-"
	return OS.get_keycode_string(keycode)


func save_bindings() -> void:
	var config := ConfigFile.new()
	for action: String in DEFAULT_BINDINGS.keys():
		config.set_value(SECTION, action, get_keycode(action))
	config.save(CONFIG_PATH)


## Makes `action` respond to exactly one key (the given physical keycode).
func _apply_binding(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode as Key
	InputMap.action_add_event(action, event)
