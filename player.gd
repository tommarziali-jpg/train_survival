extends CharacterBody3D

const SPEED := 6.0
const JUMP_VELOCITY := 6.0
var can_jump: bool = true
var can_move: bool = true
var inverted_controls : bool = false
var speed_multiplier: float = 1.0

var mouse_sensitivity: float = 0.003
var camera_pitch: float = 0.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Horizontal: Spieler dreht sich
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Vertikal: Kamera dreht sich
		camera_pitch += -event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-60), deg_to_rad(60))
		$Camera3D.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
	#print(position)
	# damit der spieler nach einem sprung wieder zurück fällt
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#Vektor 2 definieren (x und z) y wird nur bem springen verändert
	#um dann in ein vektor 3 umzuwandeln (durch keybinds)
	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))

	if input_dir == Vector2.ZERO:
		velocity.x = 0.0
		velocity.z = 0.0
	


	var cam: Camera3D = $Camera3D
	if cam == null:
		return

	var forward: Vector3 = -transform.basis.z
	var right: Vector3 = transform.basis.x

	var move_dir: Vector3 = (forward * input_dir.y + right * input_dir.x).normalized()

	velocity.x = move_dir.x * SPEED * speed_multiplier
	velocity.z = move_dir.z * SPEED * speed_multiplier

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()
