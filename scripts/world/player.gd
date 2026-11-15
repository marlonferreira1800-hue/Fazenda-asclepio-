extends CharacterBody2D

const SPEED: float = 85.0
const ANIM_FPS: float = 8.0

var facing_dir: Vector2i = Vector2i(0, 1)
var can_move: bool = true
var external_input_dir: Vector2 = Vector2.ZERO
var world_bounds: Rect2 = Rect2(8.0, 12.0, 624.0, 364.0)

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D

var _anim_time: float = 0.0


func _ready() -> void:
	var tex: Texture2D = _load_texture_safe("res://assets/sprites/farmer_sheet.png")
	if tex != null:
		sprite.texture = tex
	sprite.hframes = 4
	sprite.vframes = 4
	_update_animation(0.0, Vector2.ZERO)


func _load_texture_safe(res_path: String) -> Texture2D:
	if FileAccess.file_exists(res_path + ".import") or not OS.has_feature("editor"):
		if ResourceLoader.exists(res_path):
			var res: Resource = load(res_path)
			if res is Texture2D:
				return res
	var abs_path: String = ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var img: Image = Image.load_from_file(abs_path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null


func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		_update_animation(delta, Vector2.ZERO)
		return

	var manual_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_dir: Vector2 = manual_dir
	if manual_dir.length_squared() <= 0.01 and external_input_dir.length_squared() > 0.0001:
		input_dir = external_input_dir.normalized() if external_input_dir.length_squared() > 1.0 else external_input_dir
	velocity = input_dir * SPEED
	move_and_slide()

	global_position = Vector2(
		clampf(global_position.x, world_bounds.position.x, world_bounds.end.x),
		clampf(global_position.y, world_bounds.position.y, world_bounds.end.y)
	)

	if input_dir.length_squared() > 0.01:
		if absf(input_dir.x) > absf(input_dir.y):
			facing_dir = Vector2i(1 if input_dir.x > 0.0 else -1, 0)
		else:
			facing_dir = Vector2i(0, 1 if input_dir.y > 0.0 else -1)

	_update_animation(delta, input_dir)


func set_facing_toward(world_pos: Vector2) -> void:
	var diff: Vector2 = world_pos - global_position
	if diff.length_squared() < 1.0:
		return
	if absf(diff.x) > absf(diff.y):
		facing_dir = Vector2i(1 if diff.x > 0.0 else -1, 0)
	else:
		facing_dir = Vector2i(0, 1 if diff.y > 0.0 else -1)
	_update_animation(0.0, Vector2.ZERO)


func set_camera_limits(bounds: Rect2i) -> void:
	if camera == null:
		return
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y
	camera.limit_right = bounds.end.x
	camera.limit_bottom = bounds.end.y
	world_bounds = Rect2(
		float(bounds.position.x) + 8.0,
		float(bounds.position.y) + 12.0,
		float(bounds.size.x) - 16.0,
		float(bounds.size.y) - 20.0
	)


func _update_animation(delta: float, input_dir: Vector2) -> void:
	var row: int = 0
	if facing_dir == Vector2i(0, 1):
		row = 0
	elif facing_dir == Vector2i(0, -1):
		row = 1
	elif facing_dir == Vector2i(-1, 0):
		row = 2
	elif facing_dir == Vector2i(1, 0):
		row = 3

	var col: int = 0
	if input_dir.length_squared() > 0.01:
		_anim_time += delta * ANIM_FPS
		col = int(_anim_time) % 4
	else:
		_anim_time = 0.0
		col = 0

	sprite.frame_coords = Vector2i(col, row)
