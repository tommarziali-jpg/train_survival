extends Control
class_name MainMenu

## Main menu: Play starts the game, Settings opens the key-rebinding page and
## Exit quits. The two pages are shown/hidden inside this scene.

const GAME_SCENE := "res://train_wagon.tscn"

# Preloaded explicitly (rather than via class_name) so this scene parses even
# before the editor has re-indexed the global script class cache.
const KeyBindButtonScript: GDScript = preload("res://scripts/key_bind_button.gd")

@onready var main_panel: CenterContainer = $MainPanel
@onready var settings_panel: CenterContainer = $SettingsPanel
@onready var bind_list: VBoxContainer = $SettingsPanel/VBox/BindList

@onready var play_button: Button = $MainPanel/VBox/PlayButton
@onready var settings_button: Button = $MainPanel/VBox/SettingsButton
@onready var exit_button: Button = $MainPanel/VBox/ExitButton
@onready var back_button: Button = $SettingsPanel/VBox/Actions/BackButton
@onready var reset_button: Button = $SettingsPanel/VBox/Actions/ResetButton


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

	play_button.grab_focus()

	_build_bind_rows()
	_show_page(false)


## Builds one row (label + rebind button) per rebindable action.
func _build_bind_rows() -> void:
	for action: String in Controls.get_action_names():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 24)

		var label := Label.new()
		label.text = Controls.get_action_label(action)
		label.custom_minimum_size = Vector2(240, 0)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var button: Button = KeyBindButtonScript.new()
		button.action_name = action
		button.custom_minimum_size = Vector2(220, 44)

		row.add_child(label)
		row.add_child(button)
		bind_list.add_child(row)


func _show_page(settings: bool) -> void:
	main_panel.visible = not settings
	settings_panel.visible = settings
	if settings:
		back_button.grab_focus()
	else:
		play_button.grab_focus()


func _refresh_bind_rows() -> void:
	for row: Node in bind_list.get_children():
		for child: Node in row.get_children():
			if child.has_method("refresh_text"):
				child.refresh_text()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_settings_pressed() -> void:
	_show_page(true)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_show_page(false)


func _on_reset_pressed() -> void:
	Controls.reset_to_defaults()
	_refresh_bind_rows()
