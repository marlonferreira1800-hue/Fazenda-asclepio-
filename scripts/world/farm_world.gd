extends Node2D

signal demo_mode_changed(active: bool)

const TILE_SIZE: int = 16
const MAP_WIDTH: int = 40
const MAP_HEIGHT: int = 24

# Atlas coordinates in res://assets/sprites/terrain_tileset.png (4 cols x 2 rows)
const TILE_GRASS := Vector2i(0, 0)
const TILE_FLOWERS := Vector2i(1, 0)
const TILE_PATH := Vector2i(2, 0)
const TILE_WATER := Vector2i(3, 0)
const TILE_SOIL_DRY := Vector2i(0, 1)
const TILE_SOIL_WET := Vector2i(1, 1)
const TILE_FENCE := Vector2i(2, 1)
const TILE_SHIPPING_BIN := Vector2i(3, 1)

# Key world positions in tile coordinates
const ARABLE_RECT := Rect2i(12, 9, 12, 7)
const SHIPPING_BIN_TILE := Vector2i(10, 5)
const SHOP_SIGN_TILE := Vector2i(12, 5)
const WELL_TILE := Vector2i(15, 5)
const HOUSE_DOOR_POS := Vector2(128.0, 96.0)
const ANIMAL_PEN_BOUNDS := Rect2(456.0, 88.0, 112.0, 64.0)

const REACH_TILES: int = 2
const ANIMAL_INTERACT_REACH: float = 28.0

# Demo AI navigation waypoints & starter plots
const DEMO_CORRIDOR_Y: float = 104.0
const DEMO_GARDEN_BOUNDS_PX := Rect2(192.0, 144.0, 192.0, 112.0)
const DEMO_PEN_BOUNDS_PX := Rect2(448.0, 80.0, 128.0, 80.0)
const DEMO_GARDEN_CORRIDOR_WP := Vector2(280.0, 104.0)
const DEMO_GARDEN_ENTRY_WP := Vector2(280.0, 152.0)
const DEMO_PEN_CORRIDOR_WP := Vector2(424.0, 104.0)
const DEMO_PEN_ENTRY_WP := Vector2(456.0, 104.0)
const DEMO_WELL_WP := Vector2(248.0, 104.0)
const DEMO_BIN_WP := Vector2(168.0, 104.0)
const DEMO_SIGN_WP := Vector2(200.0, 104.0)
const DEMO_DOOR_WP := Vector2(136.0, 104.0)
const DEMO_PLOTS: Array[Vector2i] = [
	Vector2i(15, 10),
	Vector2i(16, 10),
	Vector2i(17, 10),
	Vector2i(18, 10),
	Vector2i(19, 10),
	Vector2i(20, 10),
]

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var soil_layer: TileMapLayer = $SoilLayer
@onready var obstacle_layer: TileMapLayer = $ObstacleLayer
@onready var day_night_modulate: CanvasModulate = $DayNightModulate
@onready var player: CharacterBody2D = $Player
@onready var tile_cursor: Line2D = $TileCursor
@onready var hud: CanvasLayer = get_node_or_null("HUD")

var demo_active: bool = false

var _game_state: Node = null
var _props_texture: Texture2D = null
var _crops_texture: Texture2D = null
var _animal_scene: PackedScene = null

# tile Vector2i -> { "crop_id": String, "days_grown": int, "stage": int, "sprite": Sprite2D }
var _crops: Dictionary = {}
var _animals: Array[CharacterBody2D] = []

var _mouse_active: bool = false
var _cursor_fill: ColorRect = null
var _prompt_label: Label = null
var _current_target_tile: Vector2i = Vector2i.ZERO
var _target_in_reach: bool = true

var _demo_waypoints: Array[Vector2] = []
var _demo_action: String = ""
var _demo_target_tile: Vector2i = Vector2i.ZERO
var _demo_target_slot: int = -1
var _demo_target_animal: CharacterBody2D = null
var _demo_pause_timer: float = 0.0
var _demo_stuck_timer: float = 0.0
var _demo_last_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	_game_state = get_node_or_null("/root/GameState")
	_props_texture = _load_texture_safe("res://assets/sprites/props_buildings.png")
	_crops_texture = _load_texture_safe("res://assets/sprites/crops_sheet.png")
	_animal_scene = load("res://scenes/animal.tscn") as PackedScene

	var shared_tileset: TileSet = _build_tileset()
	ground_layer.tile_set = shared_tileset
	soil_layer.tile_set = shared_tileset
	obstacle_layer.tile_set = shared_tileset

	_setup_cursor()
	_setup_prompt_label()
	_build_farm_map()
	_spawn_buildings_and_props()
	_spawn_animals()

	if player != null:
		player.global_position = Vector2(136.0, 118.0)
		if player.has_method("set_camera_limits"):
			player.call("set_camera_limits", Rect2i(0, 0, MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE))

	if _game_state != null:
		if _game_state.has_signal("day_advanced"):
			_game_state.day_advanced.connect(_on_day_advanced)
		if _game_state.has_signal("day_changed"):
			_game_state.day_changed.connect(_on_day_changed)
		if _game_state.has_method("register_world_provider"):
			_game_state.call("register_world_provider", Callable(self, "export_world_state"))
		if _game_state.has_method("consume_pending_world_save"):
			var pending_save: Variant = _game_state.call("consume_pending_world_save")
			if pending_save is Dictionary and not (pending_save as Dictionary).is_empty():
				_restore_world_state(pending_save as Dictionary)

	_update_day_night_tint()


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


func _process(_delta: float) -> void:
	var shop_open: bool = _is_shop_open()
	if player != null:
		player.set("can_move", not shop_open)

	var manual_move: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if manual_move.length_squared() > 0.01:
		_mouse_active = false
		if demo_active:
			set_demo_active(false)
			_show_toast("Modo manual ativado")

	if demo_active:
		_mouse_active = false

	_update_target_cursor(shop_open)
	_update_prompt_label(shop_open)
	_update_day_night_tint()


func _physics_process(delta: float) -> void:
	if not demo_active or _is_shop_open() or player == null:
		if player != null:
			player.set("external_input_dir", Vector2.ZERO)
		return
	_mouse_active = false
	_tick_demo_ai(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not demo_active:
			_mouse_active = true
		return

	var is_demo_key: bool = (
		(InputMap.has_action("toggle_demo") and event.is_action_pressed("toggle_demo"))
		or (event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_P)
	)
	if is_demo_key:
		toggle_demo_mode()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("toggle_shop"):
		if hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
			get_viewport().set_input_as_handled()
		return

	if _is_shop_open():
		if event.is_action_pressed("ui_cancel") and hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("sleep_day"):
		if _game_state != null:
			_game_state.call("advance_day")
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("action_interact"):
		_handle_interact()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("action_use"):
		var tile: Vector2i = _get_keyboard_target_tile()
		_handle_use_on_tile(tile)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos: Vector2 = get_global_mouse_position()
		var clicked_animal: CharacterBody2D = _find_animal_at_click(click_pos)
		if clicked_animal != null:
			if player != null and player.global_position.distance_to(clicked_animal.global_position) <= ANIMAL_INTERACT_REACH + 4.0:
				_interact_with_animal(clicked_animal)
			else:
				_show_toast("Aproxime-se mais do animal!")
				_play_sfx("play_error")
			get_viewport().set_input_as_handled()
			return

		var mouse_tile: Vector2i = _world_to_tile(click_pos)
		if _is_tile_in_reach(mouse_tile):
			_handle_use_on_tile(mouse_tile)
		else:
			_show_toast("Aproxime-se mais para usar!")
			_play_sfx("play_error")
		get_viewport().set_input_as_handled()


func _build_tileset() -> TileSet:
	var tex: Texture2D = _load_texture_safe("res://assets/sprites/terrain_tileset.png")
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)

	var source := TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	for row in range(2):
		for col in range(4):
			source.create_tile(Vector2i(col, row))

	ts.add_source(source, 0)

	var full_box := PackedVector2Array([
		Vector2(-8, -8),
		Vector2(8, -8),
		Vector2(8, 8),
		Vector2(-8, 8),
	])
	for solid_tile in [TILE_WATER, TILE_FENCE, TILE_SHIPPING_BIN]:
		var data: TileData = source.get_tile_data(solid_tile, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, full_box)

	return ts


func _setup_cursor() -> void:
	tile_cursor.points = PackedVector2Array([
		Vector2(0.5, 0.5),
		Vector2(15.5, 0.5),
		Vector2(15.5, 15.5),
		Vector2(0.5, 15.5),
	])
	tile_cursor.closed = true
	tile_cursor.width = 1.0
	tile_cursor.default_color = Color(1.0, 0.95, 0.4, 0.92)

	_cursor_fill = ColorRect.new()
	_cursor_fill.size = Vector2(TILE_SIZE, TILE_SIZE)
	_cursor_fill.color = Color(1.0, 0.96, 0.55, 0.14)
	_cursor_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile_cursor.add_child(_cursor_fill)


func _setup_prompt_label() -> void:
	_prompt_label = Label.new()
	_prompt_label.z_index = 25
	_prompt_label.visible = false
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.add_theme_font_size_override("font_size", 8)
	_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.98, 0.85))
	_prompt_label.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05, 0.95))
	_prompt_label.add_theme_constant_override("outline_size", 3)
	add_child(_prompt_label)


func _build_farm_map() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42026

	# Base grass and wildflowers outside the tillable plot
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var cell := Vector2i(x, y)
			var in_arable: bool = ARABLE_RECT.has_point(cell)
			var tile_coord: Vector2i = TILE_GRASS
			if not in_arable and rng.randf() < 0.14:
				tile_coord = TILE_FLOWERS
			ground_layer.set_cell(cell, 0, tile_coord)

	# Dirt paths connecting house, shipping bin, shop sign, well, arable field, pen, and pond
	for x in range(7, 29):
		ground_layer.set_cell(Vector2i(x, 6), 0, TILE_PATH)
	for y in range(6, 9):
		ground_layer.set_cell(Vector2i(17, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(18, y), 0, TILE_PATH)
	for y in range(6, 13):
		ground_layer.set_cell(Vector2i(26, y), 0, TILE_PATH)
	for x in range(26, 33):
		ground_layer.set_cell(Vector2i(x, 11), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(x, 12), 0, TILE_PATH)
	ground_layer.set_cell(Vector2i(8, 5), 0, TILE_PATH)

	# Lake in bottom-right corner
	for y in range(14, 20):
		for x in range(29, 36):
			var is_corner: bool = (y == 14 or y == 19) and (x == 29 or x == 35)
			if not is_corner:
				ground_layer.set_cell(Vector2i(x, y), 0, TILE_WATER)

	# Fenced border around the 12x7 arable garden (x=11..24, y=8..16) with 2-tile gates
	for x in range(11, 25):
		for y in range(8, 17):
			var on_edge: bool = (x == 11 or x == 24 or y == 8 or y == 16)
			if not on_edge:
				continue
			var is_gate: bool = (
				((y == 8 or y == 16) and (x == 17 or x == 18))
				or ((x == 11 or x == 24) and (y == 11 or y == 12))
			)
			if not is_gate:
				obstacle_layer.set_cell(Vector2i(x, y), 0, TILE_FENCE)

	# Fenced animal pen (x=27..36, y=4..10) with 2-tile gates at west (27, 6..7) and south (31..32, 10)
	for x in range(27, 37):
		for y in range(4, 11):
			var on_edge: bool = (x == 27 or x == 36 or y == 4 or y == 10)
			if not on_edge:
				continue
			if y == 10 and (x == 31 or x == 32):
				continue
			if x == 27 and (y == 6 or y == 7):
				continue
			obstacle_layer.set_cell(Vector2i(x, y), 0, TILE_FENCE)

	# Shipping bin next to house
	obstacle_layer.set_cell(SHIPPING_BIN_TILE, 0, TILE_SHIPPING_BIN)


func _spawn_buildings_and_props() -> void:
	# Casinha (32x32) occupying tiles x=7..8, y=4..5
	_spawn_prop_sprite(
		"Farmhouse",
		Rect2(0, 0, 32, 32),
		Vector2(8.0 * TILE_SIZE, 92.0),
		Vector2(0.0, -12.0),
		Rect2(0.0, -11.0, 30.0, 22.0)
	)

	# Placa da Loja (16x16) at tile (12, 5)
	_spawn_prop_sprite(
		"ShopSign",
		Rect2(80, 16, 16, 16),
		Vector2(SHOP_SIGN_TILE.x * TILE_SIZE + 8.0, SHOP_SIGN_TILE.y * TILE_SIZE + 13.0),
		Vector2(0.0, -5.0),
		Rect2(0.0, -4.0, 12.0, 10.0)
	)

	# Poço d'água (16x16) at tile (15, 5)
	_spawn_prop_sprite(
		"WaterWell",
		Rect2(64, 16, 16, 16),
		Vector2(WELL_TILE.x * TILE_SIZE + 8.0, WELL_TILE.y * TILE_SIZE + 13.0),
		Vector2(0.0, -5.0),
		Rect2(0.0, -4.0, 14.0, 10.0)
	)

	# Perimeter trees (32x32)
	var tree_positions: Array[Vector2i] = [
		Vector2i(2, 2), Vector2i(5, 2), Vector2i(18, 2), Vector2i(22, 2),
		Vector2i(25, 2), Vector2i(37, 2),
		Vector2i(2, 6), Vector2i(2, 11), Vector2i(2, 16), Vector2i(3, 20),
		Vector2i(7, 21), Vector2i(12, 21), Vector2i(19, 21), Vector2i(24, 21),
		Vector2i(37, 8), Vector2i(37, 13), Vector2i(37, 19),
		Vector2i(5, 14), Vector2i(26, 17),
	]
	for tp in tree_positions:
		_spawn_prop_sprite(
			"Tree_%d_%d" % [tp.x, tp.y],
			Rect2(32, 0, 32, 32),
			Vector2(tp.x * TILE_SIZE + 8.0, tp.y * TILE_SIZE + 13.0),
			Vector2(0.0, -13.0),
			Rect2(0.0, -4.0, 16.0, 10.0)
		)

	# Rocks (16x16)
	var rock_tiles: Array[Vector2i] = [
		Vector2i(4, 5), Vector2i(4, 10), Vector2i(8, 17),
		Vector2i(22, 5), Vector2i(28, 20), Vector2i(36, 16),
	]
	for rt in rock_tiles:
		_spawn_prop_sprite(
			"Rock_%d_%d" % [rt.x, rt.y],
			Rect2(64, 0, 16, 16),
			Vector2(rt.x * TILE_SIZE + 8.0, rt.y * TILE_SIZE + 13.0),
			Vector2(0.0, -5.0),
			Rect2(0.0, -4.0, 12.0, 8.0)
		)

	# Bushes (16x16)
	var bush_tiles: Array[Vector2i] = [
		Vector2i(6, 5), Vector2i(9, 4), Vector2i(14, 4),
		Vector2i(6, 12), Vector2i(9, 18), Vector2i(15, 19),
		Vector2i(22, 18), Vector2i(27, 14), Vector2i(35, 12),
	]
	for bt in bush_tiles:
		_spawn_prop_sprite(
			"Bush_%d_%d" % [bt.x, bt.y],
			Rect2(80, 0, 16, 16),
			Vector2(bt.x * TILE_SIZE + 8.0, bt.y * TILE_SIZE + 13.0),
			Vector2(0.0, -5.0),
			Rect2(0.0, -4.0, 12.0, 8.0)
		)


func _spawn_prop_sprite(
	prop_name: String,
	region: Rect2,
	world_pos: Vector2,
	sprite_offset: Vector2,
	collider_rect: Rect2
) -> void:
	if _props_texture == null:
		return
	var body := StaticBody2D.new()
	body.name = prop_name
	body.position = world_pos
	body.collision_layer = 1
	body.collision_mask = 0

	var spr := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = _props_texture
	atlas.region = region
	spr.texture = atlas
	spr.offset = sprite_offset
	body.add_child(spr)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = collider_rect.size
	col.shape = shape
	col.position = collider_rect.position
	body.add_child(col)

	add_child(body)


func _spawn_animals() -> void:
	if _animal_scene == null:
		return
	var specs: Array[Dictionary] = [
		{"type": "chicken", "pos": Vector2(476.0, 108.0)},
		{"type": "chicken", "pos": Vector2(520.0, 124.0)},
		{"type": "chicken", "pos": Vector2(496.0, 138.0)},
		{"type": "cow", "pos": Vector2(544.0, 106.0)},
	]
	for i in range(specs.size()):
		var animal := _animal_scene.instantiate() as CharacterBody2D
		if animal == null:
			continue
		animal.name = "Animal_%d" % i
		animal.position = specs[i]["pos"]
		if animal.has_method("setup"):
			animal.call("setup", str(specs[i]["type"]), ANIMAL_PEN_BOUNDS)
		add_child(animal)
		_animals.append(animal)


func _handle_use_on_tile(target_tile: Vector2i) -> void:
	if _game_state == null or player == null:
		return

	if player.has_method("set_facing_toward"):
		player.call("set_facing_toward", _tile_center(target_tile))

	# 1. Harvest mature crop first regardless of held tool
	if _crops.has(target_tile) and int(_crops[target_tile]["stage"]) == 4:
		_harvest_crop(target_tile)
		return

	# 2. Direct click/use on interactable world objects
	if target_tile == SHIPPING_BIN_TILE:
		_sell_at_shipping_bin()
		return
	if target_tile == SHOP_SIGN_TILE:
		if hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
		return

	var slot: Dictionary = _game_state.call("get_selected_slot")
	var slot_id: String = str(slot.get("id", ""))
	var slot_type: String = str(slot.get("type", ""))

	if slot_id == "hoe":
		_use_hoe(target_tile)
	elif slot_id == "watering_can":
		_use_watering_can(target_tile)
	elif slot_type == "seed":
		_plant_seed(target_tile, str(slot.get("crop_id", "")))


func _handle_interact() -> void:
	if _game_state == null or player == null:
		return

	var p_pos: Vector2 = player.global_position

	# Check proximity to Shipping Bin
	if p_pos.distance_to(_tile_center(SHIPPING_BIN_TILE)) <= 28.0:
		_sell_at_shipping_bin()
		return

	# Check proximity to House Door
	if p_pos.distance_to(HOUSE_DOOR_POS) <= 28.0:
		_game_state.call("advance_day")
		return

	# Check proximity to Shop Sign
	if p_pos.distance_to(_tile_center(SHOP_SIGN_TILE)) <= 28.0:
		if hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
		return

	# Check proximity to Well or Pond -> refill water
	if _is_near_water_source(p_pos, _get_keyboard_target_tile()):
		_refill_watering_can()
		return

	# Check nearby animal before crop tiles
	var nearby_animal: CharacterBody2D = _find_nearby_animal(p_pos, ANIMAL_INTERACT_REACH)
	if nearby_animal != null:
		_interact_with_animal(nearby_animal)
		return

	# Check mature crop on target tile or player's current tile
	var target_tile: Vector2i = _get_active_target_tile()
	var player_tile: Vector2i = _world_to_tile(p_pos)
	for check_tile in [target_tile, player_tile]:
		if _crops.has(check_tile):
			var crop_info: Dictionary = _crops[check_tile]
			if int(crop_info["stage"]) == 4:
				_harvest_crop(check_tile)
			else:
				var crop_def: Dictionary = _game_state.CROPS.get(crop_info["crop_id"], {})
				var crop_name: String = str(crop_def.get("name", "Planta"))
				var days_needed: int = int(crop_def.get("days_to_grow", 2))
				_show_toast("%s: %d/%d dias" % [crop_name, int(crop_info["days_grown"]), days_needed])
			return


func _interact_with_animal(animal: CharacterBody2D) -> void:
	if animal == null or not is_instance_valid(animal):
		return
	if player != null and player.has_method("set_facing_toward"):
		player.call("set_facing_toward", animal.global_position)

	var a_type: String = str(animal.get("animal_type"))
	_play_sfx("play_animal", [a_type])

	var ready: bool = animal.has_method("can_collect") and bool(animal.call("can_collect"))
	if ready and animal.has_method("collect_product"):
		var prod: String = str(animal.call("collect_product"))
		if not prod.is_empty():
			if _game_state != null and _game_state.has_method("add_animal_product"):
				_game_state.call("add_animal_product", prod, 1)
			var float_lbl: String = "+1 Ovo" if prod == "egg" else "+1 Leite"
			var toast_msg: String = "Coletou 1 Ovo fresco!" if prod == "egg" else "Ordenhou 1 Leite fresco!"
			_spawn_floating_text(animal.global_position + Vector2(0.0, -14.0), float_lbl, Color(1.0, 0.96, 0.62))
			_spawn_particles(animal.global_position + Vector2(0.0, -6.0), Color(1.0, 0.94, 0.72))
			_show_toast(toast_msg)
			return

	var already_msg: String = "Galinha já botou ovo hoje!" if a_type == "chicken" else "Vaca já foi ordenhada hoje!"
	_show_toast(already_msg)
	_spawn_floating_text(animal.global_position + Vector2(0.0, -14.0), "♥", Color(1.0, 0.45, 0.6))


func _find_nearby_animal(world_pos: Vector2, max_dist: float) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = max_dist
	for animal in _animals:
		if not is_instance_valid(animal):
			continue
		var d: float = world_pos.distance_to(animal.global_position)
		if d <= best_dist:
			best_dist = d
			best = animal
	return best


func _find_animal_at_click(click_pos: Vector2) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = 16.0
	for animal in _animals:
		if not is_instance_valid(animal):
			continue
		var d: float = click_pos.distance_to(animal.global_position + Vector2(0.0, -5.0))
		if d <= best_dist:
			best_dist = d
			best = animal
	return best


func _use_hoe(target_tile: Vector2i) -> void:
	if not ARABLE_RECT.has_point(target_tile):
		_show_toast("Are apenas dentro do canteiro cercado!")
		_play_sfx("play_error")
		return
	if obstacle_layer.get_cell_source_id(target_tile) != -1 or _crops.has(target_tile):
		return
	if soil_layer.get_cell_source_id(target_tile) != -1:
		return

	if not bool(_game_state.call("consume_stamina", 2)):
		return

	soil_layer.set_cell(target_tile, 0, TILE_SOIL_DRY)
	_play_sfx("play_hoe")
	_spawn_particles(_tile_center(target_tile), Color(0.58, 0.38, 0.22))


func _use_watering_can(target_tile: Vector2i) -> void:
	var is_soil: bool = soil_layer.get_cell_source_id(target_tile) != -1
	var is_water_target: bool = (
		target_tile == WELL_TILE
		or (ground_layer.get_cell_source_id(target_tile) != -1 and ground_layer.get_cell_atlas_coords(target_tile) == TILE_WATER)
	)
	if is_water_target or (not is_soil and _is_near_water_source(player.global_position, target_tile)):
		_refill_watering_can()
		return

	if not is_soil:
		_show_toast("Use o regador em terra arada!")
		_play_sfx("play_error")
		return

	if soil_layer.get_cell_atlas_coords(target_tile) == TILE_SOIL_WET:
		return

	if int(_game_state.get("water_level")) <= 0:
		_show_toast("Regador vazio! Encha no poço ou lago.")
		_play_sfx("play_error")
		return

	if not bool(_game_state.call("consume_stamina", 1)):
		return

	if bool(_game_state.call("use_water", 1)):
		soil_layer.set_cell(target_tile, 0, TILE_SOIL_WET)
		_play_sfx("play_water")
		_spawn_particles(_tile_center(target_tile), Color(0.35, 0.72, 1.0))


func _plant_seed(target_tile: Vector2i, crop_id: String) -> void:
	if crop_id.is_empty():
		return
	if soil_layer.get_cell_source_id(target_tile) == -1:
		_show_toast("Are a terra com a enxada antes de plantar!")
		_play_sfx("play_error")
		return
	if _crops.has(target_tile):
		_show_toast("Já existe uma planta aqui!")
		_play_sfx("play_error")
		return

	var seeds_dict: Dictionary = _game_state.get("seeds")
	var current_seeds: int = int(seeds_dict.get(crop_id, 0))
	if current_seeds <= 0:
		_show_toast("Sem sementes! Compre na Loja (B).")
		_play_sfx("play_error")
		return

	seeds_dict[crop_id] = current_seeds - 1
	if _game_state.has_signal("inventory_changed"):
		_game_state.inventory_changed.emit()

	var spr: Sprite2D = _create_crop_sprite(crop_id, 0, target_tile, true)
	_crops[target_tile] = {
		"crop_id": crop_id,
		"days_grown": 0,
		"stage": 0,
		"sprite": spr,
	}
	_play_sfx("play_plant")


func _create_crop_sprite(crop_id: String, stage: int, tile: Vector2i, animate_pop: bool) -> Sprite2D:
	var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
	var row: int = int(crop_def.get("row", 0))

	var spr := Sprite2D.new()
	if _crops_texture != null:
		spr.texture = _crops_texture
	spr.hframes = 5
	spr.vframes = 3
	spr.frame_coords = Vector2i(clampi(stage, 0, 4), row)
	spr.position = Vector2(tile.x * TILE_SIZE + 8.0, tile.y * TILE_SIZE + 13.0)
	spr.offset = Vector2(0.0, -5.0)
	add_child(spr)

	if animate_pop:
		spr.scale = Vector2(0.55, 0.55)
		var tw := create_tween()
		tw.tween_property(spr, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	return spr


func _compute_crop_stage(crop_id: String, days_grown: int) -> int:
	var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
	var days_to_grow: int = maxi(int(crop_def.get("days_to_grow", 2)), 1)
	var progress: float = clampf(float(days_grown) / float(days_to_grow), 0.0, 1.0)
	return 4 if days_grown >= days_to_grow else clampi(roundi(progress * 4.0), 0, 3)


func _harvest_crop(target_tile: Vector2i) -> void:
	if not _crops.has(target_tile):
		return
	var crop_info: Dictionary = _crops[target_tile]
	var crop_id: String = str(crop_info["crop_id"])
	var spr: Sprite2D = crop_info.get("sprite")
	if is_instance_valid(spr):
		spr.queue_free()
	_crops.erase(target_tile)

	_game_state.call("add_harvested", crop_id, 1)
	_play_sfx("play_harvest")
	var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
	var crop_name: String = str(crop_def.get("name", crop_id))
	var center: Vector2 = _tile_center(target_tile)
	_spawn_particles(center, Color(1.0, 0.85, 0.25))
	_spawn_floating_text(center + Vector2(0.0, -10.0), "+1 %s" % crop_name, Color(1.0, 0.94, 0.35))


func _sell_at_shipping_bin() -> void:
	if _game_state == null:
		return
	var earned: int = int(_game_state.call("sell_all_harvested"))
	if earned > 0:
		_spawn_floating_text(_tile_center(SHIPPING_BIN_TILE) + Vector2(0.0, -12.0), "+$%d" % earned, Color(1.0, 0.88, 0.2))


func _refill_watering_can() -> void:
	if _game_state == null:
		return
	_game_state.call("refill_water")
	var well_center: Vector2 = _tile_center(WELL_TILE)
	var center: Vector2 = well_center if player.global_position.distance_to(well_center) <= 36.0 else player.global_position
	_spawn_particles(center, Color(0.35, 0.78, 1.0))
	_spawn_floating_text(center + Vector2(0.0, -14.0), "Água cheia!", Color(0.55, 0.88, 1.0))


func _on_day_advanced(_new_day: int) -> void:
	for tile in _crops.keys():
		if soil_layer.get_cell_source_id(tile) == -1:
			continue
		if soil_layer.get_cell_atlas_coords(tile) != TILE_SOIL_WET:
			continue

		var crop_info: Dictionary = _crops[tile]
		var crop_id: String = str(crop_info["crop_id"])
		var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
		var row: int = int(crop_def.get("row", 0))

		var days_grown: int = int(crop_info["days_grown"]) + 1
		crop_info["days_grown"] = days_grown
		var stage: int = _compute_crop_stage(crop_id, days_grown)
		crop_info["stage"] = stage

		var spr: Sprite2D = crop_info.get("sprite")
		if is_instance_valid(spr):
			spr.frame_coords = Vector2i(stage, row)

	for cell in soil_layer.get_used_cells():
		if soil_layer.get_cell_atlas_coords(cell) == TILE_SOIL_WET:
			soil_layer.set_cell(cell, 0, TILE_SOIL_DRY)

	for animal in _animals:
		if is_instance_valid(animal) and animal.has_method("reset_daily"):
			animal.call("reset_daily")

	_update_day_night_tint()


func _on_day_changed(_day: int, _time_minutes: float) -> void:
	_update_day_night_tint()


func export_world_state() -> Dictionary:
	var tilled_dry: Array = []
	var tilled_wet: Array = []
	for cell in soil_layer.get_used_cells():
		var atlas: Vector2i = soil_layer.get_cell_atlas_coords(cell)
		if atlas == TILE_SOIL_WET:
			tilled_wet.append([cell.x, cell.y])
		elif atlas == TILE_SOIL_DRY:
			tilled_dry.append([cell.x, cell.y])

	var crops_arr: Array = []
	for tile_var in _crops.keys():
		var tile: Vector2i = tile_var as Vector2i
		var info: Dictionary = _crops[tile]
		crops_arr.append({
			"x": tile.x,
			"y": tile.y,
			"crop_id": str(info.get("crop_id", "")),
			"days_grown": int(info.get("days_grown", 0)),
		})

	var animals_collected: Array = []
	for animal in _animals:
		if is_instance_valid(animal):
			animals_collected.append(bool(animal.get("collected_today")))
		else:
			animals_collected.append(false)

	return {
		"tilled_dry": tilled_dry,
		"tilled_wet": tilled_wet,
		"crops": crops_arr,
		"animals_collected": animals_collected,
	}


func _restore_world_state(data: Dictionary) -> void:
	soil_layer.clear()
	for tile_var in _crops.keys():
		var spr: Variant = _crops[tile_var].get("sprite")
		if is_instance_valid(spr):
			(spr as Node).queue_free()
	_crops.clear()

	var dry_list: Variant = data.get("tilled_dry", [])
	if dry_list is Array:
		for pair in dry_list:
			if pair is Array and (pair as Array).size() >= 2:
				var cell := Vector2i(int(pair[0]), int(pair[1]))
				soil_layer.set_cell(cell, 0, TILE_SOIL_DRY)

	var wet_list: Variant = data.get("tilled_wet", [])
	if wet_list is Array:
		for pair in wet_list:
			if pair is Array and (pair as Array).size() >= 2:
				var cell := Vector2i(int(pair[0]), int(pair[1]))
				soil_layer.set_cell(cell, 0, TILE_SOIL_WET)

	var crop_list: Variant = data.get("crops", [])
	if crop_list is Array and _game_state != null:
		for entry in crop_list:
			if not (entry is Dictionary):
				continue
			var entry_dict := entry as Dictionary
			var tile := Vector2i(int(entry_dict.get("x", 0)), int(entry_dict.get("y", 0)))
			var crop_id: String = str(entry_dict.get("crop_id", ""))
			if crop_id.is_empty() or not _game_state.CROPS.has(crop_id):
				continue
			if soil_layer.get_cell_source_id(tile) == -1:
				soil_layer.set_cell(tile, 0, TILE_SOIL_DRY)
			var days_grown: int = maxi(int(entry_dict.get("days_grown", 0)), 0)
			var stage: int = _compute_crop_stage(crop_id, days_grown)
			var spr: Sprite2D = _create_crop_sprite(crop_id, stage, tile, false)
			_crops[tile] = {
				"crop_id": crop_id,
				"days_grown": days_grown,
				"stage": stage,
				"sprite": spr,
			}

	var collected_list: Variant = data.get("animals_collected", [])
	if collected_list is Array:
		var arr := collected_list as Array
		for i in range(mini(_animals.size(), arr.size())):
			var animal: CharacterBody2D = _animals[i]
			if is_instance_valid(animal):
				var val: bool = bool(arr[i])
				if animal.has_method("set_collected_today"):
					animal.call("set_collected_today", val)
				else:
					animal.set("collected_today", val)


func _update_day_night_tint() -> void:
	if day_night_modulate == null or _game_state == null:
		return
	var mins: float = float(_game_state.get("time_minutes"))
	var color := Color.WHITE
	if mins < 480.0:
		var t: float = clampf((mins - 360.0) / 120.0, 0.0, 1.0)
		color = Color(0.92, 0.90, 1.0).lerp(Color.WHITE, t)
	elif mins < 960.0:
		color = Color.WHITE
	elif mins < 1110.0:
		var t: float = clampf((mins - 960.0) / 150.0, 0.0, 1.0)
		color = Color.WHITE.lerp(Color(1.0, 0.78, 0.62), t)
	elif mins < 1260.0:
		var t: float = clampf((mins - 1110.0) / 150.0, 0.0, 1.0)
		color = Color(1.0, 0.78, 0.62).lerp(Color(0.56, 0.58, 0.84), t)
	else:
		var t: float = clampf((mins - 1260.0) / 180.0, 0.0, 1.0)
		color = Color(0.56, 0.58, 0.84).lerp(Color(0.42, 0.45, 0.72), t)
	day_night_modulate.color = color


func _update_target_cursor(shop_open: bool) -> void:
	if tile_cursor == null or player == null:
		return
	if shop_open:
		tile_cursor.visible = false
		return

	tile_cursor.visible = true
	_current_target_tile = _get_active_target_tile()
	_target_in_reach = _is_tile_in_reach(_current_target_tile)
	tile_cursor.global_position = Vector2(_current_target_tile.x * TILE_SIZE, _current_target_tile.y * TILE_SIZE)

	if _target_in_reach:
		tile_cursor.default_color = Color(1.0, 0.95, 0.4, 0.92)
		if _cursor_fill != null:
			_cursor_fill.color = Color(1.0, 0.96, 0.55, 0.14)
	else:
		tile_cursor.default_color = Color(1.0, 0.42, 0.42, 0.55)
		if _cursor_fill != null:
			_cursor_fill.color = Color(1.0, 0.35, 0.35, 0.08)


func _update_prompt_label(shop_open: bool) -> void:
	if _prompt_label == null or player == null:
		return
	if shop_open:
		_prompt_label.visible = false
		return

	var p_pos: Vector2 = player.global_position
	var hint: String = ""
	var anchor: Vector2 = p_pos + Vector2(0.0, -24.0)

	var nearby_animal: CharacterBody2D = _find_nearby_animal(p_pos, ANIMAL_INTERACT_REACH)

	if p_pos.distance_to(HOUSE_DOOR_POS) <= 28.0:
		hint = "[F] Dormir"
		anchor = HOUSE_DOOR_POS + Vector2(0.0, -24.0)
	elif p_pos.distance_to(_tile_center(SHIPPING_BIN_TILE)) <= 28.0:
		hint = "[F] Vender"
		anchor = _tile_center(SHIPPING_BIN_TILE) + Vector2(0.0, -20.0)
	elif p_pos.distance_to(_tile_center(SHOP_SIGN_TILE)) <= 28.0:
		hint = "[F] Loja"
		anchor = _tile_center(SHOP_SIGN_TILE) + Vector2(0.0, -20.0)
	elif p_pos.distance_to(_tile_center(WELL_TILE)) <= 28.0:
		hint = "[F] Encher Água"
		anchor = _tile_center(WELL_TILE) + Vector2(0.0, -20.0)
	elif nearby_animal != null:
		if nearby_animal.has_method("can_collect") and bool(nearby_animal.call("can_collect")):
			var a_type: String = str(nearby_animal.get("animal_type"))
			hint = "[F] Coletar Ovo" if a_type == "chicken" else "[F] Ordenhar Vaca"
		else:
			hint = "[F] Acariciar"
		anchor = nearby_animal.global_position + Vector2(0.0, -24.0)
	elif _crops.has(_current_target_tile) and int(_crops[_current_target_tile]["stage"]) == 4 and _target_in_reach:
		hint = "[E/F] Colher"
		anchor = _tile_center(_current_target_tile) + Vector2(0.0, -18.0)

	if hint.is_empty():
		_prompt_label.visible = false
	else:
		_prompt_label.visible = true
		_prompt_label.text = hint
		_prompt_label.reset_size()
		_prompt_label.global_position = anchor - Vector2(_prompt_label.size.x * 0.5, 0.0)


func _get_active_target_tile() -> Vector2i:
	if _mouse_active:
		var mouse_tile: Vector2i = _world_to_tile(get_global_mouse_position())
		if _is_tile_in_reach(mouse_tile):
			return mouse_tile
	return _get_keyboard_target_tile()


func _get_keyboard_target_tile() -> Vector2i:
	var player_tile: Vector2i = _world_to_tile(player.global_position)
	var dir_val: Variant = player.get("facing_dir")
	var facing: Vector2i = dir_val if dir_val is Vector2i else Vector2i(0, 1)
	var candidate: Vector2i = player_tile + facing
	return Vector2i(
		clampi(candidate.x, 0, MAP_WIDTH - 1),
		clampi(candidate.y, 0, MAP_HEIGHT - 1)
	)


func _is_tile_in_reach(tile: Vector2i) -> bool:
	if tile.x < 0 or tile.x >= MAP_WIDTH or tile.y < 0 or tile.y >= MAP_HEIGHT:
		return false
	var player_tile: Vector2i = _world_to_tile(player.global_position)
	var diff: Vector2i = tile - player_tile
	return absi(diff.x) <= REACH_TILES and absi(diff.y) <= REACH_TILES


func _is_near_water_source(world_pos: Vector2, target_tile: Vector2i) -> bool:
	if world_pos.distance_to(_tile_center(WELL_TILE)) <= 30.0:
		return true
	if target_tile == WELL_TILE:
		return true
	var player_tile: Vector2i = _world_to_tile(world_pos)
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var c: Vector2i = player_tile + Vector2i(dx, dy)
			if ground_layer.get_cell_source_id(c) != -1 and ground_layer.get_cell_atlas_coords(c) == TILE_WATER:
				return true
	return false


func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return ground_layer.local_to_map(ground_layer.to_local(world_pos))


func _tile_center(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * TILE_SIZE + TILE_SIZE * 0.5, tile.y * TILE_SIZE + TILE_SIZE * 0.5)


func _is_shop_open() -> bool:
	return hud != null and hud.has_method("is_shop_open") and bool(hud.call("is_shop_open"))


func _show_toast(msg: String) -> void:
	if _game_state != null and _game_state.has_method("emit_toast"):
		_game_state.call("emit_toast", msg)


func _play_sfx(method_name: String, args: Array = []) -> void:
	var audio: Node = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method(method_name):
		audio.callv(method_name, args)


func _spawn_floating_text(world_pos: Vector2, text: String, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.z_index = 30
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.04, 0.95))
	lbl.add_theme_constant_override("outline_size", 3)
	add_child(lbl)
	lbl.reset_size()
	lbl.global_position = world_pos - Vector2(lbl.size.x * 0.5, 0.0)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 14.0, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.85).set_delay(0.2)
	tw.chain().tween_callback(lbl.queue_free)


func _spawn_particles(world_pos: Vector2, color: Color) -> void:
	var p := CPUParticles2D.new()
	p.position = world_pos
	p.z_index = 15
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 7
	p.lifetime = 0.35
	p.direction = Vector2(0, -1)
	p.spread = 150.0
	p.gravity = Vector2(0, 90)
	p.initial_velocity_min = 18.0
	p.initial_velocity_max = 38.0
	p.scale_amount_min = 1.5
	p.scale_amount_max = 2.5
	p.color = color
	add_child(p)
	get_tree().create_timer(0.5).timeout.connect(p.queue_free)


# --- Demo IA / Auto-Farmer Mode (P) ---

func is_demo_active() -> bool:
	return demo_active


func set_demo_active(active: bool) -> void:
	if demo_active == active:
		return
	demo_active = active
	if demo_active:
		if _is_shop_open() and hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
		_mouse_active = false
		_reset_demo_ai_state()
		_show_toast("Modo Auto (Demo IA) ativado! (P para sair)")
	else:
		if player != null:
			player.set("external_input_dir", Vector2.ZERO)
		_reset_demo_ai_state()
	demo_mode_changed.emit(demo_active)


func toggle_demo_mode() -> bool:
	set_demo_active(not demo_active)
	return demo_active


func _reset_demo_ai_state() -> void:
	_demo_waypoints.clear()
	_demo_action = ""
	_demo_target_slot = -1
	_demo_target_animal = null
	_demo_pause_timer = 0.0
	_demo_stuck_timer = 0.0
	_demo_last_pos = player.global_position if player != null else Vector2.ZERO


func _tick_demo_ai(delta: float) -> void:
	if _demo_pause_timer > 0.0:
		_demo_pause_timer -= delta
		player.set("external_input_dir", Vector2.ZERO)
		return

	if _demo_action.is_empty():
		_plan_next_demo_task()
		if _demo_action.is_empty():
			player.set("external_input_dir", Vector2.ZERO)
			return

	if _demo_action == "animal":
		if not is_instance_valid(_demo_target_animal):
			_demo_waypoints.clear()
			_demo_action = ""
			return
		if _demo_waypoints.size() == 1:
			_demo_waypoints[0] = _demo_target_animal.global_position
			if player.global_position.distance_to(_demo_target_animal.global_position) <= 22.0:
				_demo_waypoints.clear()

	if not _demo_waypoints.is_empty():
		var wp: Vector2 = _demo_waypoints[0]
		var diff: Vector2 = wp - player.global_position
		if diff.length() <= 4.5:
			_demo_waypoints.remove_at(0)
		else:
			player.set("external_input_dir", diff.normalized())
			var moved: float = player.global_position.distance_to(_demo_last_pos)
			if moved < 15.0 * delta:
				_demo_stuck_timer += delta
				if _demo_stuck_timer >= 1.2:
					_reset_demo_ai_state()
					_demo_pause_timer = 0.12
			else:
				_demo_stuck_timer = 0.0
			_demo_last_pos = player.global_position
			if not _demo_waypoints.is_empty():
				return

	player.set("external_input_dir", Vector2.ZERO)
	_execute_demo_action()
	_demo_action = ""
	_demo_target_slot = -1
	_demo_target_animal = null
	_demo_stuck_timer = 0.0
	_demo_pause_timer = 0.22


func _plan_next_demo_task() -> void:
	if _game_state == null or player == null:
		return

	var p_pos: Vector2 = player.global_position
	var stamina: int = int(_game_state.get("stamina"))
	var water_level: int = int(_game_state.get("water_level"))
	var money: int = int(_game_state.get("money"))
	var seeds_dict: Dictionary = _game_state.get("seeds")

	# 1. Harvest mature crops (stage == 4)
	var mature_tile := _find_closest_crop_tile(p_pos, true, false)
	if mature_tile.x >= 0:
		_demo_action = "harvest"
		_demo_target_tile = mature_tile
		_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(mature_tile), "garden")
		return

	# Check if DEMO_PLOTS still has pending hoe/plant work before watering newly planted stage-0 seeds
	var pending_hoe_tile := _find_demo_plot_to_hoe(p_pos, stamina)
	var pending_plant: Dictionary = _find_demo_plot_to_plant(p_pos, seeds_dict)
	var has_pending_farm_setup: bool = (pending_hoe_tile.x >= 0) or (not pending_plant.is_empty())

	# 2. Water existing planted dry crops (older crops first, or all dry crops once setup finishes)
	var dry_crop_tile := _find_closest_crop_tile(p_pos, false, true, has_pending_farm_setup)
	if dry_crop_tile.x >= 0 and stamina >= 1:
		if water_level <= 2:
			_demo_action = "refill"
			_demo_target_tile = WELL_TILE
			_demo_target_slot = 1
			_demo_waypoints = _build_demo_path(p_pos, DEMO_WELL_WP, "outside")
			return
		_demo_action = "water"
		_demo_target_tile = dry_crop_tile
		_demo_target_slot = 1
		_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(dry_crop_tile), "garden")
		return

	# 3. Collect Ovo / Leite from ready animals
	var ready_animal := _find_closest_ready_animal(p_pos)
	if ready_animal != null:
		_demo_action = "animal"
		_demo_target_animal = ready_animal
		_demo_waypoints = _build_demo_path(p_pos, ready_animal.global_position, "pen")
		return

	# 4. Till & plant up to 6 starter plots in DEMO_PLOTS
	if stamina >= 10:
		if pending_hoe_tile.x >= 0:
			_demo_action = "hoe"
			_demo_target_tile = pending_hoe_tile
			_demo_target_slot = 0
			_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(pending_hoe_tile), "garden")
			return
		if not pending_plant.is_empty():
			var plant_tile: Vector2i = pending_plant["tile"]
			_demo_action = "plant"
			_demo_target_tile = plant_tile
			_demo_target_slot = int(pending_plant["slot"])
			_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(plant_tile), "garden")
			return

	# After setup finishes, catch any remaining dry crops (including newly planted stage-0)
	var remaining_dry := _find_closest_crop_tile(p_pos, false, true, false)
	if remaining_dry.x >= 0 and stamina >= 1:
		if water_level <= 2:
			_demo_action = "refill"
			_demo_target_tile = WELL_TILE
			_demo_target_slot = 1
			_demo_waypoints = _build_demo_path(p_pos, DEMO_WELL_WP, "outside")
			return
		_demo_action = "water"
		_demo_target_tile = remaining_dry
		_demo_target_slot = 1
		_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(remaining_dry), "garden")
		return

	# 5. Sell basket items at Shipping Bin
	if _game_state.has_method("get_total_basket_count") and int(_game_state.call("get_total_basket_count")) > 0:
		_demo_action = "sell"
		_demo_target_tile = SHIPPING_BIN_TILE
		_demo_waypoints = _build_demo_path(p_pos, DEMO_BIN_WP, "outside")
		return

	# 6. Buy missing seeds at Shop Sign if money >= 35
	if money >= 35 and _needs_any_seed(seeds_dict):
		_demo_action = "buy_seeds"
		_demo_target_tile = SHOP_SIGN_TILE
		_demo_waypoints = _build_demo_path(p_pos, DEMO_SIGN_WP, "outside")
		return

	# 7. Sleep at farmhouse door to advance to the next day
	_demo_action = "sleep"
	_demo_target_tile = Vector2i(8, 5)
	_demo_waypoints = _build_demo_path(p_pos, DEMO_DOOR_WP, "outside")


func _execute_demo_action() -> void:
	if _game_state == null or player == null:
		return

	if _demo_target_slot >= 0 and _game_state.has_method("select_slot"):
		_game_state.call("select_slot", _demo_target_slot)

	match _demo_action:
		"harvest":
			if _crops.has(_demo_target_tile) and int(_crops[_demo_target_tile]["stage"]) == 4:
				if player.has_method("set_facing_toward"):
					player.call("set_facing_toward", _tile_center(_demo_target_tile))
				_harvest_crop(_demo_target_tile)
		"hoe", "plant", "water":
			_handle_use_on_tile(_demo_target_tile)
		"refill":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", _tile_center(WELL_TILE))
			_refill_watering_can()
		"animal":
			if is_instance_valid(_demo_target_animal):
				_interact_with_animal(_demo_target_animal)
		"sell":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", _tile_center(SHIPPING_BIN_TILE))
			_sell_at_shipping_bin()
		"buy_seeds":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", _tile_center(SHOP_SIGN_TILE))
			_demo_buy_needed_seeds()
		"sleep":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", HOUSE_DOOR_POS)
			_game_state.call("advance_day")


func _demo_buy_needed_seeds() -> void:
	var seeds_dict: Dictionary = _game_state.get("seeds")
	for crop_id in ["strawberry", "carrot", "wheat"]:
		while int(seeds_dict.get(crop_id, 0)) < 2:
			var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
			var price: int = int(crop_def.get("seed_price", 10))
			if int(_game_state.get("money")) < price:
				break
			if not bool(_game_state.call("buy_seed", crop_id, 1)):
				break
			seeds_dict = _game_state.get("seeds")


func _needs_any_seed(seeds_dict: Dictionary) -> bool:
	for crop_id in ["wheat", "carrot", "strawberry"]:
		if int(seeds_dict.get(crop_id, 0)) < 2:
			return true
	return false


func _find_closest_crop_tile(from_pos: Vector2, want_mature: bool, want_dry: bool, only_older_than_today: bool = false) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_dist: float = INF
	for tile_var in _crops.keys():
		var tile: Vector2i = tile_var as Vector2i
		var info: Dictionary = _crops[tile]
		var stage: int = int(info.get("stage", 0))
		if want_mature and stage != 4:
			continue
		if want_dry:
			if stage == 4:
				continue
			if only_older_than_today and int(info.get("days_grown", 0)) <= 0:
				continue
			if soil_layer.get_cell_source_id(tile) == -1 or soil_layer.get_cell_atlas_coords(tile) != TILE_SOIL_DRY:
				continue
		var d: float = from_pos.distance_to(_tile_center(tile))
		if d < best_dist:
			best_dist = d
			best = tile
	return best


func _find_closest_ready_animal(from_pos: Vector2) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = INF
	for animal in _animals:
		if not is_instance_valid(animal):
			continue
		if animal.has_method("can_collect") and bool(animal.call("can_collect")):
			var d: float = from_pos.distance_to(animal.global_position)
			if d < best_dist:
				best_dist = d
				best = animal
	return best


func _find_demo_plot_to_hoe(from_pos: Vector2, stamina: int) -> Vector2i:
	if stamina < 10:
		return Vector2i(-1, -1)
	var best := Vector2i(-1, -1)
	var best_dist: float = INF
	for t in DEMO_PLOTS:
		if soil_layer.get_cell_source_id(t) == -1 and obstacle_layer.get_cell_source_id(t) == -1 and not _crops.has(t):
			var d: float = from_pos.distance_to(_tile_center(t))
			if d < best_dist:
				best_dist = d
				best = t
	return best


func _find_demo_plot_to_plant(from_pos: Vector2, seeds_dict: Dictionary) -> Dictionary:
	var seed_cycle: Array[Dictionary] = [
		{"crop_id": "wheat", "slot": 2},
		{"crop_id": "carrot", "slot": 3},
		{"crop_id": "strawberry", "slot": 4},
	]
	var best_tile := Vector2i(-1, -1)
	var best_idx: int = -1
	var best_dist: float = INF
	for i in range(DEMO_PLOTS.size()):
		var t: Vector2i = DEMO_PLOTS[i]
		if soil_layer.get_cell_source_id(t) != -1 and not _crops.has(t):
			var d: float = from_pos.distance_to(_tile_center(t))
			if d < best_dist:
				best_dist = d
				best_tile = t
				best_idx = i
	if best_idx < 0:
		return {}

	for offset in range(seed_cycle.size()):
		var entry: Dictionary = seed_cycle[(best_idx + offset) % seed_cycle.size()]
		if int(seeds_dict.get(entry["crop_id"], 0)) > 0:
			return {"tile": best_tile, "slot": int(entry["slot"])}
	return {}


func _garden_stand_pos(tile: Vector2i) -> Vector2:
	var stand_tile: Vector2i = tile + Vector2i(0, 1)
	if not ARABLE_RECT.has_point(stand_tile):
		stand_tile = tile + Vector2i(0, -1)
	return _tile_center(stand_tile)


func _get_demo_zone(pos: Vector2) -> String:
	if DEMO_GARDEN_BOUNDS_PX.has_point(pos):
		return "garden"
	if DEMO_PEN_BOUNDS_PX.has_point(pos):
		return "pen"
	return "outside"


func _build_demo_path(from_pos: Vector2, dest_pos: Vector2, dest_zone: String) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var from_zone: String = _get_demo_zone(from_pos)

	if from_zone == dest_zone and (from_zone == "garden" or from_zone == "pen"):
		path.append(dest_pos)
		return path

	if from_zone == "outside" and dest_zone == "outside" and absf(from_pos.y - DEMO_CORRIDOR_Y) <= 18.0:
		path.append(dest_pos)
		return path

	# Step 1: Exit current zone safely onto main dirt path corridor (y = 104)
	if from_zone == "garden":
		path.append(DEMO_GARDEN_ENTRY_WP)
		path.append(DEMO_GARDEN_CORRIDOR_WP)
	elif from_zone == "pen":
		path.append(DEMO_PEN_ENTRY_WP)
		path.append(DEMO_PEN_CORRIDOR_WP)
	else:
		if from_pos.x >= 272.0 and from_pos.x <= 304.0 and from_pos.y >= 120.0 and from_pos.y <= 146.0:
			path.append(DEMO_GARDEN_CORRIDOR_WP)
		elif from_pos.x >= 430.0 and from_pos.x <= 450.0 and from_pos.y >= 94.0 and from_pos.y <= 130.0:
			path.append(DEMO_PEN_CORRIDOR_WP)
		elif from_pos.y > 256.0:
			if from_pos.x <= 392.0:
				path.append(Vector2(280.0, 276.0))
				path.append(Vector2(280.0, 232.0))
				path.append(DEMO_GARDEN_ENTRY_WP)
				path.append(DEMO_GARDEN_CORRIDOR_WP)
			else:
				path.append(Vector2(408.0, 240.0))
				path.append(Vector2(408.0, DEMO_CORRIDOR_Y))
		elif from_pos.y > 120.0:
			if from_pos.x < 192.0:
				path.append(Vector2(152.0, DEMO_CORRIDOR_Y))
			else:
				path.append(Vector2(408.0, DEMO_CORRIDOR_Y))
		else:
			path.append(Vector2(clampf(from_pos.x, 128.0, 424.0), DEMO_CORRIDOR_Y))

	# Step 2: Enter destination zone from main corridor
	if dest_zone == "garden":
		path.append(DEMO_GARDEN_CORRIDOR_WP)
		path.append(DEMO_GARDEN_ENTRY_WP)
		path.append(dest_pos)
	elif dest_zone == "pen":
		path.append(DEMO_PEN_CORRIDOR_WP)
		path.append(DEMO_PEN_ENTRY_WP)
		path.append(dest_pos)
	else:
		path.append(dest_pos)

	return path
