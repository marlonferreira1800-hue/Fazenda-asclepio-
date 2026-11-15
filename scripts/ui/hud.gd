extends CanvasLayer
## Cozy pixel-art HUD & Shop UI for Fazendinha 2D (640x360 viewport).

const UI_ICONS_PATH := "res://assets/sprites/ui_icons.png"

const DEFAULT_HOTBAR_SLOTS: Array[Dictionary] = [
	{"id": "hoe", "name": "Enxada", "type": "tool", "icon_col": 0},
	{"id": "watering_can", "name": "Regador", "type": "tool", "icon_col": 1},
	{"id": "wheat_seed", "name": "Sem. Trigo", "type": "seed", "crop_id": "wheat", "icon_col": 2},
	{"id": "carrot_seed", "name": "Sem. Cenoura", "type": "seed", "crop_id": "carrot", "icon_col": 3},
	{"id": "strawberry_seed", "name": "Sem. Morango", "type": "seed", "crop_id": "strawberry", "icon_col": 4},
]

const DEFAULT_CROPS: Dictionary = {
	"wheat": {"name": "Trigo", "row": 0, "days_to_grow": 2, "seed_price": 10, "sell_price": 25},
	"carrot": {"name": "Cenoura", "row": 1, "days_to_grow": 3, "seed_price": 20, "sell_price": 55},
	"strawberry": {"name": "Morango", "row": 2, "days_to_grow": 4, "seed_price": 35, "sell_price": 110},
}

const CROP_ORDER: Array[String] = ["wheat", "carrot", "strawberry"]
const CROP_ICON_COLS: Dictionary = {
	"wheat": 2,
	"carrot": 3,
	"strawberry": 4,
}

# Cozy wood & parchment palette
const COL_WOOD_DARK := Color("#4e2c17")
const COL_WOOD_BORDER := Color("#6a3d1e")
const COL_WOOD_SOFT := Color("#8a5a32")
const COL_PARCHMENT := Color(0.96, 0.91, 0.78, 0.95)
const COL_PARCHMENT_ALT := Color(0.92, 0.85, 0.69, 0.96)
const COL_INK := Color("#3b2110")
const COL_INK_MUTED := Color("#5c3a20")
const COL_GOLD_TEXT := Color("#8f4f00")
const COL_GOLD_BORDER := Color("#ffd23f")
const COL_OUTLINE_DARK := Color(0.08, 0.05, 0.03, 0.95)
const COL_SHADOW_DARK := Color(0.05, 0.03, 0.02, 0.85)

var _icons_texture: Texture2D = null
var _icons_cols: int = 0
var _shop_open: bool = false
var _toast_tween: Tween = null

# UI references
var _ui_root: Control
var _day_time_label: Label
var _money_label: Label
var _stamina_bar: ProgressBar
var _stamina_fill_style: StyleBoxFlat
var _stamina_value_label: Label
var _water_bar: ProgressBar
var _water_value_label: Label
var _harvest_label: Label
var _animal_label: Label
var _egg_icon: TextureRect
var _milk_icon: TextureRect
var _egg_label: Label
var _milk_label: Label
var _sound_button: Button
var _auto_button: Button
var _active_item_label: Label

var _slot_panels: Array[PanelContainer] = []
var _slot_icons: Array[TextureRect] = []
var _slot_counts: Array[Label] = []
var _slot_normal_style: StyleBoxFlat
var _slot_active_style: StyleBoxFlat

var _toast_panel: PanelContainer
var _toast_label: Label

var _shop_backdrop: ColorRect
var _shop_panel: PanelContainer
var _shop_money_label: Label
var _shop_harvest_label: Label
var _shop_crop_info_labels: Dictionary = {}
var _shop_buy_buttons: Dictionary = {}


func _ready() -> void:
	if ResourceLoader.exists(UI_ICONS_PATH):
		_icons_texture = load(UI_ICONS_PATH) as Texture2D
	if _icons_texture == null and FileAccess.file_exists(UI_ICONS_PATH):
		var img := Image.load_from_file(ProjectSettings.globalize_path(UI_ICONS_PATH))
		if img != null and not img.is_empty():
			_icons_texture = ImageTexture.create_from_image(img)
	if _icons_texture != null:
		_icons_cols = int(_icons_texture.get_width() / 16.0)

	_build_ui()
	_connect_signals()
	_sync_all_from_state()


func _unhandled_input(event: InputEvent) -> void:
	for i in range(5):
		var action_name := "slot_%d" % (i + 1)
		if InputMap.has_action(action_name) and event.is_action_pressed(action_name):
			_select_slot(i)
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		match key_event.keycode:
			KEY_1, KEY_KP_1:
				_select_slot(0)
				get_viewport().set_input_as_handled()
			KEY_2, KEY_KP_2:
				_select_slot(1)
				get_viewport().set_input_as_handled()
			KEY_3, KEY_KP_3:
				_select_slot(2)
				get_viewport().set_input_as_handled()
			KEY_4, KEY_KP_4:
				_select_slot(3)
				get_viewport().set_input_as_handled()
			KEY_5, KEY_KP_5:
				_select_slot(4)
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				if _shop_open:
					toggle_shop()
					get_viewport().set_input_as_handled()


func toggle_shop() -> void:
	_shop_open = not _shop_open
	if _shop_backdrop != null:
		_shop_backdrop.visible = _shop_open
	if _shop_panel != null:
		_shop_panel.visible = _shop_open
	if _shop_open:
		_refresh_shop()


func is_shop_open() -> bool:
	return _shop_open


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _get_audio_manager() -> Node:
	return get_node_or_null("/root/AudioManager")


func _play_click() -> void:
	var audio := _get_audio_manager()
	if audio != null and audio.has_method("play_click"):
		audio.call("play_click")


func _get_hotbar_slots() -> Array:
	var gs := _get_game_state()
	if gs != null:
		return gs.HOTBAR_SLOTS
	return DEFAULT_HOTBAR_SLOTS


func _get_crops() -> Dictionary:
	var gs := _get_game_state()
	if gs != null and not gs.CROPS.is_empty():
		return gs.CROPS
	return DEFAULT_CROPS


func _select_slot(idx: int) -> void:
	var gs := _get_game_state()
	if gs != null:
		gs.select_slot(idx)
	else:
		_update_hotbar_selection(idx)


func _connect_signals() -> void:
	var gs := _get_game_state()
	if gs != null:
		if gs.has_signal("money_changed"):
			gs.money_changed.connect(_on_money_changed)
		if gs.has_signal("day_changed"):
			gs.day_changed.connect(_on_day_changed)
		if gs.has_signal("inventory_changed"):
			gs.inventory_changed.connect(_on_inventory_changed)
		if gs.has_signal("tool_changed"):
			gs.tool_changed.connect(_on_tool_changed)
		if gs.has_signal("stamina_changed"):
			gs.stamina_changed.connect(_on_stamina_changed)
		if gs.has_signal("water_changed"):
			gs.water_changed.connect(_on_water_changed)
		if gs.has_signal("toast_message"):
			gs.toast_message.connect(_on_toast_message)

	var audio := _get_audio_manager()
	if audio != null and audio.has_signal("mute_changed"):
		audio.mute_changed.connect(_on_mute_changed)

	var parent := get_parent()
	if parent != null and parent.has_signal("demo_mode_changed"):
		parent.connect("demo_mode_changed", _on_demo_mode_changed)


func _sync_all_from_state() -> void:
	var gs := _get_game_state()
	if gs == null:
		_on_day_changed(1, 360.0)
		_on_money_changed(100)
		_on_stamina_changed(100, 100)
		_on_water_changed(20, 20)
		_on_inventory_changed()
		_on_tool_changed(0)
	else:
		_on_day_changed(gs.day, gs.time_minutes)
		_on_money_changed(gs.money)
		_on_stamina_changed(gs.stamina, gs.max_stamina)
		_on_water_changed(gs.water_level, gs.max_water)
		_on_inventory_changed()
		_on_tool_changed(gs.selected_slot)

	_refresh_sound_button()
	_refresh_auto_button()


func _build_ui() -> void:
	_ui_root = Control.new()
	_ui_root.name = "UIRoot"
	_ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ui_root)

	_build_stats_panel()
	_build_basket_panel()
	_build_hotbar_section()
	_build_controls_hint()
	_build_shop_modal()
	_build_toast_panel()


func _build_stats_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "StatsPanel"
	panel.position = Vector2(6, 6)
	panel.add_theme_stylebox_override("panel", _make_parchment_style(7, 5))
	_ui_root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	# Row 1: Day/Time + Money
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(top_row)

	_day_time_label = _make_label("Dia 1 - 06:00", 9, COL_INK)
	_day_time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(_day_time_label)

	var money_row := HBoxContainer.new()
	money_row.add_theme_constant_override("separation", 3)
	money_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(money_row)

	var coin_rect := _make_icon_rect(5, Vector2(16, 16))
	money_row.add_child(coin_rect)

	_money_label = _make_label("$100", 9, COL_GOLD_TEXT)
	money_row.add_child(_money_label)

	# Row 2: Stamina bar
	var stamina_row := HBoxContainer.new()
	stamina_row.add_theme_constant_override("separation", 4)
	stamina_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(stamina_row)

	var stamina_lbl := _make_label("Energia", 8, COL_INK)
	stamina_lbl.custom_minimum_size = Vector2(36, 0)
	stamina_row.add_child(stamina_lbl)

	_stamina_fill_style = _make_bar_fill_style(Color("#5ab549"))
	var stamina_built := _make_progress_bar(Vector2(108, 12), _stamina_fill_style)
	_stamina_bar = stamina_built["bar"]
	_stamina_value_label = stamina_built["label"]
	stamina_row.add_child(_stamina_bar)

	# Row 3: Water bar
	var water_row := HBoxContainer.new()
	water_row.add_theme_constant_override("separation", 4)
	water_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(water_row)

	var water_lbl := _make_label("Água", 8, COL_INK)
	water_lbl.custom_minimum_size = Vector2(36, 0)
	water_row.add_child(water_lbl)

	var water_fill := _make_bar_fill_style(Color("#3a9be0"))
	var water_built := _make_progress_bar(Vector2(108, 12), water_fill)
	_water_bar = water_built["bar"]
	_water_value_label = water_built["label"]
	water_row.add_child(_water_bar)


func _build_basket_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "BasketPanel"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.offset_left = -236
	panel.offset_top = 6
	panel.offset_right = -6
	panel.add_theme_stylebox_override("panel", _make_parchment_style(7, 4))
	_ui_root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	_harvest_label = _make_label("Trigo: 0 | Cenoura: 0 | Morango: 0", 9, COL_INK)
	_harvest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(_harvest_label)

	var animal_row := HBoxContainer.new()
	animal_row.add_theme_constant_override("separation", 4)
	animal_row.alignment = BoxContainer.ALIGNMENT_END
	animal_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(animal_row)

	if _icons_cols >= 8:
		_egg_icon = _make_icon_rect(6, Vector2(16, 16))
		animal_row.add_child(_egg_icon)
		_egg_label = _make_label("Ovo: 0", 8, COL_INK)
		animal_row.add_child(_egg_label)

		var sep_lbl := _make_label("|", 8, COL_INK_MUTED)
		animal_row.add_child(sep_lbl)

		_milk_icon = _make_icon_rect(7, Vector2(16, 16))
		animal_row.add_child(_milk_icon)
		_milk_label = _make_label("Leite: 0", 8, COL_INK)
		animal_row.add_child(_milk_label)
	else:
		_animal_label = _make_label("Ovo: 0 | Leite: 0", 8, COL_INK)
		_animal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		animal_row.add_child(_animal_label)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 3)
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(btn_row)

	_auto_button = _make_wood_button("Auto (P)", Vector2(50, 17), 8)
	_auto_button.pressed.connect(_on_auto_button_pressed)
	btn_row.add_child(_auto_button)

	var save_btn := _make_wood_button("Salvar", Vector2(40, 17), 8)
	save_btn.pressed.connect(_on_save_button_pressed)
	btn_row.add_child(save_btn)

	_sound_button = _make_wood_button("Som: ON", Vector2(50, 17), 8)
	_sound_button.pressed.connect(_on_sound_button_pressed)
	btn_row.add_child(_sound_button)

	var shop_btn := _make_wood_button("Loja (B)", Vector2(52, 17), 8)
	shop_btn.pressed.connect(_on_shop_button_pressed)
	btn_row.add_child(shop_btn)

	var sleep_btn := _make_wood_button("Dormir (N)", Vector2(58, 17), 8)
	sleep_btn.pressed.connect(_on_sleep_button_pressed)
	btn_row.add_child(sleep_btn)


func _build_hotbar_section() -> void:
	var container := VBoxContainer.new()
	container.name = "HotbarSection"
	container.anchor_left = 0.5
	container.anchor_right = 0.5
	container.anchor_top = 1.0
	container.anchor_bottom = 1.0
	container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	container.offset_bottom = -18
	container.add_theme_constant_override("separation", 2)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_root.add_child(container)

	_active_item_label = _make_outlined_label("Enxada", 9, Color(1.0, 0.97, 0.88))
	_active_item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(_active_item_label)

	var tray := PanelContainer.new()
	tray.name = "HotbarPanel"
	tray.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var tray_style := _make_flat_style(COL_WOOD_DARK, Color("#351b0c"), 2, 4, 4, 2)
	tray.add_theme_stylebox_override("panel", tray_style)
	container.add_child(tray)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.add_child(hbox)

	_slot_normal_style = _make_flat_style(Color("#dfca9d"), COL_WOOD_SOFT, 1, 3, 3, 1)
	_slot_active_style = _make_flat_style(Color("#fff4cf"), COL_GOLD_BORDER, 2, 3, 3, 1)

	var slots := _get_hotbar_slots()
	for i in range(slots.size()):
		var slot_data: Dictionary = slots[i]
		var slot_panel := PanelContainer.new()
		slot_panel.name = "Slot_%d" % i
		slot_panel.custom_minimum_size = Vector2(30, 30)
		slot_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		slot_panel.tooltip_text = str(slot_data.get("name", ""))
		slot_panel.add_theme_stylebox_override("panel", _slot_normal_style)
		slot_panel.gui_input.connect(_on_slot_gui_input.bind(i))
		hbox.add_child(slot_panel)

		var inner := Control.new()
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_panel.add_child(inner)

		var icon_center := CenterContainer.new()
		icon_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(icon_center)

		var icon_col := int(slot_data.get("icon_col", i))
		var icon_rect := _make_icon_rect(icon_col, Vector2(16, 16))
		icon_center.add_child(icon_rect)

		var key_lbl := _make_label(str(i + 1), 7, COL_INK_MUTED)
		key_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		key_lbl.offset_left = 0
		key_lbl.offset_top = -2
		key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		key_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		inner.add_child(key_lbl)

		var count_lbl := _make_outlined_label("", 8, Color.WHITE)
		count_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		count_lbl.offset_right = 0
		count_lbl.offset_bottom = 2
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count_lbl.visible = slot_data.get("type", "") == "seed"
		inner.add_child(count_lbl)

		_slot_panels.append(slot_panel)
		_slot_icons.append(icon_rect)
		_slot_counts.append(count_lbl)


func _build_controls_hint() -> void:
	var panel := PanelContainer.new()
	panel.name = "ControlsHint"
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.offset_bottom = -2
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override(
		"panel",
		_make_flat_style(Color(0.11, 0.07, 0.04, 0.80), Color(0.42, 0.26, 0.13, 0.65), 1, 7, 1, 2)
	)
	_ui_root.add_child(panel)

	var lbl := _make_label(
		"WASD: Mover | Espaço/Clique: Usar | F: Interagir | 1-5: Slot | B: Loja | N: Dormir | P: Auto",
		8,
		Color(0.96, 0.93, 0.84)
	)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(lbl)


func _build_shop_modal() -> void:
	_shop_backdrop = ColorRect.new()
	_shop_backdrop.name = "ShopBackdrop"
	_shop_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shop_backdrop.color = Color(0.08, 0.05, 0.03, 0.55)
	_shop_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_shop_backdrop.visible = false
	_ui_root.add_child(_shop_backdrop)

	_shop_panel = PanelContainer.new()
	_shop_panel.name = "ShopPanel"
	_shop_panel.anchor_left = 0.5
	_shop_panel.anchor_right = 0.5
	_shop_panel.anchor_top = 0.5
	_shop_panel.anchor_bottom = 0.5
	_shop_panel.offset_left = -160
	_shop_panel.offset_right = 160
	_shop_panel.offset_top = -108
	_shop_panel.offset_bottom = 70
	_shop_panel.visible = false
	_shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_shop_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT, COL_WOOD_BORDER, 3, 9, 6, 3))
	_shop_backdrop.add_child(_shop_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	main_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_panel.add_child(main_vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(header)

	var title := _make_label("Loja de Sementes", 10, COL_WOOD_DARK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var money_box := HBoxContainer.new()
	money_box.add_theme_constant_override("separation", 3)
	money_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(money_box)

	money_box.add_child(_make_icon_rect(5, Vector2(16, 16)))
	_shop_money_label = _make_label("$100", 10, COL_GOLD_TEXT)
	money_box.add_child(_shop_money_label)

	main_vbox.add_child(_make_separator())

	# Seed purchase rows
	var crops := _get_crops()
	for crop_id in CROP_ORDER:
		var crop: Dictionary = crops.get(crop_id, DEFAULT_CROPS.get(crop_id, {}))
		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#b89563"), 1, 6, 3, 2))
		main_vbox.add_child(row_panel)

		var row_hbox := HBoxContainer.new()
		row_hbox.add_theme_constant_override("separation", 6)
		row_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_panel.add_child(row_hbox)

		var icon_col := int(CROP_ICON_COLS.get(crop_id, 2))
		var icon_rect := _make_icon_rect(icon_col, Vector2(16, 16))
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row_hbox.add_child(icon_rect)

		var info_vbox := VBoxContainer.new()
		info_vbox.add_theme_constant_override("separation", 0)
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_hbox.add_child(info_vbox)

		var crop_name := str(crop.get("name", crop_id.capitalize()))
		var title_lbl := _make_label("Semente de %s" % crop_name, 9, COL_INK)
		info_vbox.add_child(title_lbl)

		var days := int(crop.get("days_to_grow", 2))
		var sell_price := int(crop.get("sell_price", 25))
		var sub_lbl := _make_label("Cresce: %dd | Venda: $%d | Estoque: 0" % [days, sell_price], 8, COL_INK_MUTED)
		info_vbox.add_child(sub_lbl)
		_shop_crop_info_labels[crop_id] = sub_lbl

		var seed_price := int(crop.get("seed_price", 10))
		var buy_btn := _make_wood_button("Comprar ($%d)" % seed_price, Vector2(82, 20), 8)
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buy_btn.pressed.connect(_on_buy_seed_pressed.bind(crop_id))
		row_hbox.add_child(buy_btn)
		_shop_buy_buttons[crop_id] = buy_btn

	main_vbox.add_child(_make_separator())

	# Sell all + Close footer
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 6)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(footer)

	_shop_harvest_label = _make_label("Cesta: 0 itens ($0)", 8, COL_INK)
	_shop_harvest_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shop_harvest_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(_shop_harvest_label)

	var sell_btn := _make_colored_button(
		"Vender Tudo",
		Vector2(74, 20),
		8,
		Color("#5a9640"),
		Color("#6eb050"),
		Color("#487a32"),
		Color("#2e4f1e"),
		Color.WHITE
	)
	sell_btn.pressed.connect(_on_sell_all_pressed)
	footer.add_child(sell_btn)

	var close_btn := _make_colored_button(
		"Fechar (B)",
		Vector2(64, 20),
		8,
		Color("#b84b3e"),
		Color("#cf5a4c"),
		Color("#94392e"),
		Color("#61231c"),
		Color.WHITE
	)
	close_btn.pressed.connect(_on_close_shop_pressed)
	footer.add_child(close_btn)


func _build_toast_panel() -> void:
	_toast_panel = PanelContainer.new()
	_toast_panel.name = "ToastPanel"
	_toast_panel.anchor_left = 0.5
	_toast_panel.anchor_right = 0.5
	_toast_panel.anchor_top = 1.0
	_toast_panel.anchor_bottom = 1.0
	_toast_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_toast_panel.offset_bottom = -74
	_toast_panel.visible = false
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.add_theme_stylebox_override(
		"panel",
		_make_flat_style(Color(0.18, 0.10, 0.05, 0.94), COL_GOLD_BORDER, 1, 10, 4, 2)
	)
	_ui_root.add_child(_toast_panel)

	_toast_label = _make_label("", 9, Color("#fff8e2"))
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_panel.add_child(_toast_label)


# --- Signal callbacks ---

func _on_money_changed(new_money: int) -> void:
	if _money_label != null:
		_money_label.text = "$%d" % new_money
	if _shop_money_label != null:
		_shop_money_label.text = "$%d" % new_money
	_refresh_shop()


func _on_day_changed(day: int, time_minutes: float) -> void:
	if _day_time_label == null:
		return
	var total_mins := int(floor(time_minutes))
	var hours := (total_mins / 60) % 24
	var mins := total_mins % 60
	_day_time_label.text = "Dia %d - %02d:%02d" % [day, hours, mins]


func _on_stamina_changed(stamina: int, max_stamina: int) -> void:
	if _stamina_bar == null:
		return
	_stamina_bar.max_value = max(1, max_stamina)
	_stamina_bar.value = clampi(stamina, 0, max_stamina)
	_stamina_value_label.text = "%d/%d" % [stamina, max_stamina]

	var ratio := float(stamina) / float(max(1, max_stamina))
	if ratio <= 0.25:
		_stamina_fill_style.bg_color = Color("#d94f3d")
	elif ratio <= 0.50:
		_stamina_fill_style.bg_color = Color("#df9e2e")
	else:
		_stamina_fill_style.bg_color = Color("#5ab549")


func _on_water_changed(water: int, max_water: int) -> void:
	if _water_bar == null:
		return
	_water_bar.max_value = max(1, max_water)
	_water_bar.value = clampi(water, 0, max_water)
	_water_value_label.text = "%d/%d" % [water, max_water]


func _on_inventory_changed() -> void:
	var gs := _get_game_state()
	var harvested: Dictionary = gs.get("harvested") if gs != null and gs.get("harvested") != null else {"wheat": 0, "carrot": 0, "strawberry": 0}
	var animal_products: Dictionary = gs.get("animal_products") if gs != null and gs.get("animal_products") != null else {"egg": 0, "milk": 0}
	var seeds: Dictionary = gs.get("seeds") if gs != null and gs.get("seeds") != null else {"wheat": 6, "carrot": 4, "strawberry": 2}

	if _harvest_label != null:
		var w := int(harvested.get("wheat", 0))
		var c := int(harvested.get("carrot", 0))
		var s := int(harvested.get("strawberry", 0))
		_harvest_label.text = "Trigo: %d | Cenoura: %d | Morango: %d" % [w, c, s]

	var egg_qty := int(animal_products.get("egg", 0))
	var milk_qty := int(animal_products.get("milk", 0))
	if _egg_label != null and _milk_label != null:
		_egg_label.text = "Ovo: %d" % egg_qty
		_milk_label.text = "Leite: %d" % milk_qty
	elif _animal_label != null:
		_animal_label.text = "Ovo: %d | Leite: %d" % [egg_qty, milk_qty]

	var slots := _get_hotbar_slots()
	for i in range(mini(slots.size(), _slot_counts.size())):
		var slot_data: Dictionary = slots[i]
		if slot_data.get("type", "") == "seed":
			var crop_id := str(slot_data.get("crop_id", ""))
			var qty := int(seeds.get(crop_id, 0))
			_slot_counts[i].text = str(qty)
			_slot_counts[i].add_theme_color_override(
				"font_color",
				Color(1.0, 0.80, 0.76) if qty <= 0 else Color.WHITE
			)
			_slot_icons[i].modulate.a = 0.55 if qty <= 0 else 1.0

	var selected: int = int(gs.selected_slot) if gs != null else 0
	_update_active_item_label(selected)
	_refresh_shop()


func _on_tool_changed(slot_index: int) -> void:
	_update_hotbar_selection(slot_index)


func _on_toast_message(text: String) -> void:
	if _toast_panel == null or text.is_empty():
		return
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()

	_toast_label.text = text
	_toast_panel.visible = true
	_toast_panel.modulate.a = 0.0

	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast_panel, "modulate:a", 1.0, 0.15)
	_toast_tween.tween_interval(1.70)
	_toast_tween.tween_property(_toast_panel, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(func() -> void: _toast_panel.visible = false)


# --- UI action callbacks ---

func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_play_click()
			_select_slot(index)
			if index >= 0 and index < _slot_panels.size():
				_slot_panels[index].accept_event()


func _on_save_button_pressed() -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("save_game"):
		gs.call("save_game", true)


func _on_sound_button_pressed() -> void:
	var audio := _get_audio_manager()
	if audio != null and audio.has_method("toggle_mute"):
		audio.call("toggle_mute")
	_refresh_sound_button()


func _on_mute_changed(_is_muted: bool) -> void:
	_refresh_sound_button()


func _on_auto_button_pressed() -> void:
	_play_click()
	var parent := get_parent()
	if parent != null and parent.has_method("toggle_demo_mode"):
		parent.call("toggle_demo_mode")
	_refresh_auto_button()


func _on_demo_mode_changed(active: bool) -> void:
	_apply_auto_button_state(active)


func _on_shop_button_pressed() -> void:
	_play_click()
	toggle_shop()


func _on_close_shop_pressed() -> void:
	_play_click()
	toggle_shop()


func _on_sleep_button_pressed() -> void:
	_play_click()
	if _shop_open:
		toggle_shop()
	var gs := _get_game_state()
	if gs != null:
		gs.advance_day()


func _on_buy_seed_pressed(crop_id: String) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null:
		gs.buy_seed(crop_id, 1)


func _on_sell_all_pressed() -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null:
		gs.sell_all_harvested()


# --- Refresh helpers ---

func _refresh_sound_button() -> void:
	if _sound_button == null:
		return
	var audio := _get_audio_manager()
	var is_muted: bool = bool(audio.get("muted")) if audio != null and audio.get("muted") != null else false
	_sound_button.text = "Som: OFF" if is_muted else "Som: ON"


func _refresh_auto_button() -> void:
	if _auto_button == null:
		return
	var parent := get_parent()
	var is_active: bool = false
	if parent != null and parent.has_method("is_demo_active"):
		is_active = bool(parent.call("is_demo_active"))
	_apply_auto_button_state(is_active)


func _apply_auto_button_state(active: bool) -> void:
	if _auto_button == null:
		return
	if active:
		_auto_button.text = "Auto: ON"
		_apply_button_theme(
			_auto_button,
			Color("#4d9938"),
			Color("#61b54a"),
			Color("#3b782a"),
			COL_GOLD_BORDER,
			Color(1.0, 0.99, 0.90)
		)
	else:
		_auto_button.text = "Auto (P)"
		_apply_button_theme(
			_auto_button,
			Color("#d8b982"),
			Color("#ebd09d"),
			Color("#bd9b63"),
			COL_WOOD_BORDER,
			COL_INK
		)


func _update_hotbar_selection(slot_index: int) -> void:
	for i in range(_slot_panels.size()):
		var is_selected := (i == slot_index)
		_slot_panels[i].add_theme_stylebox_override(
			"panel",
			_slot_active_style if is_selected else _slot_normal_style
		)
	_update_active_item_label(slot_index)


func _update_active_item_label(slot_index: int) -> void:
	if _active_item_label == null:
		return
	var slots := _get_hotbar_slots()
	if slot_index < 0 or slot_index >= slots.size():
		return
	var slot_data: Dictionary = slots[slot_index]
	var item_name := str(slot_data.get("name", ""))
	if slot_data.get("type", "") == "seed":
		var gs := _get_game_state()
		var crop_id := str(slot_data.get("crop_id", ""))
		var qty := int(gs.seeds.get(crop_id, 0)) if gs != null else 0
		_active_item_label.text = "%s (%d)" % [item_name, qty]
	else:
		_active_item_label.text = item_name


func _refresh_shop() -> void:
	if _shop_panel == null:
		return
	var gs := _get_game_state()
	var crops := _get_crops()
	var seeds: Dictionary = gs.get("seeds") if gs != null and gs.get("seeds") != null else {}
	var harvested: Dictionary = gs.get("harvested") if gs != null and gs.get("harvested") != null else {}
	var animal_products: Dictionary = gs.get("animal_products") if gs != null and gs.get("animal_products") != null else {}
	var money: int = int(gs.get("money")) if gs != null and gs.get("money") != null else 100

	if _shop_money_label != null:
		_shop_money_label.text = "$%d" % money

	for crop_id in CROP_ORDER:
		var crop: Dictionary = crops.get(crop_id, DEFAULT_CROPS.get(crop_id, {}))
		var days := int(crop.get("days_to_grow", 2))
		var sell_price := int(crop.get("sell_price", 25))
		var seed_price := int(crop.get("seed_price", 10))
		var owned := int(seeds.get(crop_id, 0))

		if _shop_crop_info_labels.has(crop_id):
			var info_lbl: Label = _shop_crop_info_labels[crop_id]
			info_lbl.text = "Cresce: %dd | Venda: $%d | Estoque: %d" % [days, sell_price, owned]

		if _shop_buy_buttons.has(crop_id):
			var btn: Button = _shop_buy_buttons[crop_id]
			btn.text = "Comprar ($%d)" % seed_price

	if _shop_harvest_label != null:
		var total_items := 0
		var total_value := 0
		if gs != null and gs.has_method("get_total_basket_count") and gs.has_method("get_total_basket_value"):
			total_items = int(gs.call("get_total_basket_count"))
			total_value = int(gs.call("get_total_basket_value"))
		else:
			for crop_id in CROP_ORDER:
				var count := int(harvested.get(crop_id, 0))
				var crop: Dictionary = crops.get(crop_id, DEFAULT_CROPS.get(crop_id, {}))
				total_items += count
				total_value += count * int(crop.get("sell_price", 0))
			total_items += int(animal_products.get("egg", 0)) + int(animal_products.get("milk", 0))
			total_value += int(animal_products.get("egg", 0)) * 30 + int(animal_products.get("milk", 0)) * 45
		_shop_harvest_label.text = "Cesta: %d itens ($%d)" % [total_items, total_value]


# --- Style & widget factory helpers ---

func _make_icon_texture(col: int) -> Texture2D:
	if _icons_texture == null or col < 0 or col >= _icons_cols:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = _icons_texture
	atlas.region = Rect2(col * 16, 0, 16, 16)
	return atlas


func _make_icon_rect(col: int, min_size: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = min_size
	rect.texture = _make_icon_texture(col)
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl


func _make_outlined_label(text: String, font_size: int, color: Color) -> Label:
	var lbl := _make_label(text, font_size, color)
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.add_theme_color_override("font_outline_color", COL_OUTLINE_DARK)
	lbl.add_theme_color_override("font_shadow_color", COL_SHADOW_DARK)
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	return lbl


func _make_progress_bar(min_size: Vector2, fill_style: StyleBoxFlat) -> Dictionary:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = min_size
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", _make_flat_style(Color("#2a170c"), COL_WOOD_BORDER, 1, 0, 0, 1))
	bar.add_theme_stylebox_override("fill", fill_style)

	var val_lbl := _make_outlined_label("0/0", 8, Color(0.99, 0.98, 0.94))
	val_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	val_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(val_lbl)

	return {"bar": bar, "label": val_lbl}


func _make_bar_fill_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(1)
	style.anti_aliasing = false
	return style


func _make_parchment_style(pad_x: int, pad_y: int) -> StyleBoxFlat:
	return _make_flat_style(COL_PARCHMENT, COL_WOOD_BORDER, 2, pad_x, pad_y, 2)


func _make_flat_style(
	bg_color: Color,
	border_color: Color,
	border_width: int,
	pad_x: int,
	pad_y: int,
	corner_radius: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = pad_x
	style.content_margin_right = pad_x
	style.content_margin_top = pad_y
	style.content_margin_bottom = pad_y
	style.anti_aliasing = false
	return style


func _make_wood_button(text: String, min_size: Vector2, font_size: int) -> Button:
	return _make_colored_button(
		text,
		min_size,
		font_size,
		Color("#d8b982"),
		Color("#ebd09d"),
		Color("#bd9b63"),
		COL_WOOD_BORDER,
		COL_INK
	)


func _make_colored_button(
	text: String,
	min_size: Vector2,
	font_size: int,
	normal_col: Color,
	hover_col: Color,
	pressed_col: Color,
	border_col: Color,
	font_col: Color
) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = min_size
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", font_size)
	_apply_button_theme(btn, normal_col, hover_col, pressed_col, border_col, font_col)
	return btn


func _apply_button_theme(
	btn: Button,
	normal_col: Color,
	hover_col: Color,
	pressed_col: Color,
	border_col: Color,
	font_col: Color
) -> void:
	btn.add_theme_color_override("font_color", font_col)
	btn.add_theme_color_override("font_hover_color", font_col)
	btn.add_theme_color_override("font_pressed_color", font_col)
	btn.add_theme_stylebox_override("normal", _make_flat_style(normal_col, border_col, 1, 4, 2, 2))
	btn.add_theme_stylebox_override("hover", _make_flat_style(hover_col, border_col, 1, 4, 2, 2))
	btn.add_theme_stylebox_override("pressed", _make_flat_style(pressed_col, border_col, 1, 4, 2, 2))


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line := StyleBoxLine.new()
	line.color = Color("#b89563")
	line.thickness = 1
	sep.add_theme_stylebox_override("separator", line)
	return sep
