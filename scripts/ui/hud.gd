extends CanvasLayer
## Cozy pixel-art HUD, Tabbed Shop, Journal (Orders/Album), Menu/Options & Touch UI for Fazendinha 2D (640x360 viewport).

const CropDataScript := preload("res://scripts/data/crop_data.gd")
const FarmCatalogScript := preload("res://scripts/data/farm_catalog.gd")

const UI_ICONS_PATH := "res://assets/sprites/ui_icons.png"
const V13_ICONS_PATH := "res://assets/sprites/v13_icons.png"
const VERSION_DATA_PATH := "res://scripts/data/version_data.gd"

const FALLBACK_VERSION := "v1.4.0"
const FALLBACK_AUTHOR := "@marlonferreira1800-hue (Marlon Ferreira)"
const FALLBACK_RELEASES_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases"
const FALLBACK_ISSUES_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues"
const FALLBACK_CHANGELOG_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/blob/main/CHANGELOG.md"
const FALLBACK_HISTORY: Array[Dictionary] = [
	{
		"version": "v1.4.0",
		"title": "Rebrota, Fertilizante Ouro ★, Pesca, Máquinas, Carinho & Diário (J)",
		"date": "2026-11-20",
		"author": "@marlonferreira1800-hue",
		"highlights": [
			"Rebrota em Morango/Milho/Tomate + Fertilizante e qualidade Ouro ★ (1.5x)",
			"Minigame de Pesca (4 peixes), Carinho/Ovo Azul, Compra de animais, Máquinas e Diário (J)",
		],
	},
	{
		"version": "v1.3.0",
		"title": "Novos Cultivos, Upgrades, Clima, Música, Animais & Mobile",
		"date": "2026-11-19",
		"author": "@marlonferreira1800-hue",
		"highlights": [
			"Milho, Tomate e Abóbora (6 culturas), upgrades 3x1/3x3 e Aspersor 3x3",
			"Clima Sol/Chuva automático, BGM procedural em loop, Ovelha/Porco e Touch Mobile",
		],
	},
]

const DEFAULT_HOTBAR_SLOTS: Array[Dictionary] = [
	{"id": "hoe", "name": "Enxada", "type": "tool", "sheet": "base", "icon_col": 0, "key_hint": "1"},
	{"id": "watering_can", "name": "Regador", "type": "tool", "sheet": "base", "icon_col": 1, "key_hint": "2"},
	{"id": "fishing_rod", "name": "Vara de Pesca", "type": "tool", "sheet": "v13", "icon_col": 0, "key_hint": "3"},
	{"id": "wheat_seed", "name": "Sem. Trigo", "type": "seed", "crop_id": "wheat", "sheet": "base", "icon_col": 2, "key_hint": "4"},
	{"id": "carrot_seed", "name": "Sem. Cenoura", "type": "seed", "crop_id": "carrot", "sheet": "base", "icon_col": 3, "key_hint": "5"},
	{"id": "strawberry_seed", "name": "Sem. Morango", "type": "seed", "crop_id": "strawberry", "sheet": "base", "icon_col": 4, "key_hint": "6"},
	{"id": "corn_seed", "name": "Sem. Milho", "type": "seed", "crop_id": "corn", "sheet": "base", "icon_col": 8, "key_hint": "7"},
	{"id": "tomato_seed", "name": "Sem. Tomate", "type": "seed", "crop_id": "tomato", "sheet": "base", "icon_col": 9, "key_hint": "8"},
	{"id": "pumpkin_seed", "name": "Sem. Abóbora", "type": "seed", "crop_id": "pumpkin", "sheet": "base", "icon_col": 10, "key_hint": "9"},
	{"id": "fertilizer", "name": "Fertilizante", "type": "supply", "supply_id": "fertilizer", "sheet": "v13", "icon_col": 4, "key_hint": "0"},
	{"id": "sprinkler", "name": "Aspersor", "type": "supply", "supply_id": "sprinkler", "sheet": "base", "icon_col": 11, "key_hint": "-"},
]

const CROP_ORDER: Array[String] = ["wheat", "carrot", "strawberry", "corn", "tomato", "pumpkin"]

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
var _v13_icons_texture: Texture2D = null
var _v13_icons_cols: int = 0

var _shop_open: bool = false
var _shop_tab: String = "seeds" # "seeds" | "upgrades" | "farm"
var _journal_open: bool = false
var _journal_tab: int = 0 # 0: Pedidos, 1: Álbum, 2: Dicas & Vel.
var _changelog_open: bool = false
var _menu_open: bool = false
var _touch_seen: bool = false
var _toast_tween: Tween = null
var _open_external_links: bool = true

var _current_version: String = FALLBACK_VERSION
var _version_author: String = FALLBACK_AUTHOR
var _releases_url: String = FALLBACK_RELEASES_URL
var _issues_url: String = FALLBACK_ISSUES_URL
var _changelog_url: String = FALLBACK_CHANGELOG_URL
var _version_history: Array[Dictionary] = []

# UI references
var _ui_root: Control
var _day_time_label: Label
var _money_label: Label
var _version_button: Button
var _weather_today_icon: TextureRect
var _weather_today_label: Label
var _weather_next_icon: TextureRect
var _weather_next_label: Label
var _stamina_bar: ProgressBar
var _stamina_fill_style: StyleBoxFlat
var _stamina_value_label: Label
var _water_bar: ProgressBar
var _water_value_label: Label

var _harvest_label: Label
var _basket_extra_label: Label
var _egg_label: Label
var _blue_egg_label: Label
var _milk_label: Label
var _wool_label: Label
var _truffle_label: Label
var _sound_button: Button
var _auto_button: Button
var _journal_button: Button
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
var _shop_tab_seeds_btn: Button
var _shop_tab_upgrades_btn: Button
var _shop_tab_farm_btn: Button
var _shop_seeds_grid: GridContainer
var _shop_upgrades_vbox: VBoxContainer
var _shop_farm_scroll: ScrollContainer
var _shop_farm_vbox: VBoxContainer
var _shop_crop_info_labels: Dictionary = {}
var _shop_buy_buttons: Dictionary = {}
var _shop_upgrade_title_labels: Dictionary = {}
var _shop_upgrade_desc_labels: Dictionary = {}
var _shop_upgrade_buttons: Dictionary = {}
var _shop_fertilizer_desc_label: Label
var _shop_sprinkler_desc_label: Label

var _journal_backdrop: ColorRect
var _journal_panel: PanelContainer
var _journal_tab_buttons: Array[Button] = []
var _journal_content_vbox: VBoxContainer

var _changelog_backdrop: ColorRect
var _changelog_panel: PanelContainer
var _changelog_title_label: Label
var _changelog_author_label: Label

var _menu_backdrop: ColorRect
var _menu_panel: PanelContainer
var _menu_sfx_btn: Button
var _menu_music_btn: Button
var _menu_touch_btn: Button
var _menu_speed_btn: Button
var _menu_reset_btn: Button
var _menu_reset_confirm_box: PanelContainer

var _touch_layer: Control
var _touch_dir_active := Vector2.ZERO


func _ready() -> void:
	_load_version_metadata()

	_icons_texture = _load_texture_safe(UI_ICONS_PATH)
	if _icons_texture != null:
		_icons_cols = int(_icons_texture.get_width() / 16.0)

	_v13_icons_texture = _load_texture_safe(V13_ICONS_PATH)
	if _v13_icons_texture != null:
		_v13_icons_cols = int(_v13_icons_texture.get_width() / 16.0)

	_build_ui()
	_connect_signals()
	_sync_all_from_state()


func _load_texture_safe(res_path: String) -> Texture2D:
	var tex: Texture2D = null
	if ResourceLoader.exists(res_path):
		tex = load(res_path) as Texture2D
	if tex == null and FileAccess.file_exists(res_path):
		var img := Image.load_from_file(ProjectSettings.globalize_path(res_path))
		if img != null and not img.is_empty():
			tex = ImageTexture.create_from_image(img)
	return tex


func _input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch or event is InputEventScreenDrag) and not _touch_seen:
		_touch_seen = true
		_refresh_touch_controls()


func _unhandled_input(event: InputEvent) -> void:
	var parent := get_parent()
	if parent != null and parent.has_method("is_fishing_active") and bool(parent.call("is_fishing_active")):
		return

	var key_event := event as InputEventKey
	var key_pressed: bool = key_event != null and key_event.pressed and not key_event.echo
	var keycode: Key = key_event.keycode if key_pressed else KEY_NONE

	if (InputMap.has_action("toggle_changelog") and event.is_action_pressed("toggle_changelog")) or (key_pressed and keycode == KEY_V):
		_play_click()
		toggle_changelog()
		get_viewport().set_input_as_handled()
		return

	if (InputMap.has_action("ui_cancel") and event.is_action_pressed("ui_cancel")) or (key_pressed and keycode == KEY_ESCAPE):
		_play_click()
		if _changelog_open:
			_set_changelog_open(false)
		elif _journal_open:
			_set_journal_open(false)
		elif _menu_open:
			if _menu_reset_confirm_box != null and _menu_reset_confirm_box.visible:
				_menu_reset_confirm_box.visible = false
			else:
				_set_menu_open(false)
		elif _shop_open:
			_set_shop_open(false)
		else:
			_set_menu_open(true)
		get_viewport().set_input_as_handled()
		return

	if (_changelog_open or _menu_open or _journal_open) and (
		(InputMap.has_action("toggle_demo") and event.is_action_pressed("toggle_demo")) or (key_pressed and keycode == KEY_P)
	):
		close_all_modals()
		return

	if not is_shop_open():
		for i in range(9):
			var action_name := "slot_%d" % (i + 1)
			if InputMap.has_action(action_name) and event.is_action_pressed(action_name):
				_select_slot(i)
				get_viewport().set_input_as_handled()
				return

		if key_pressed:
			var matched_slot := -1
			match keycode:
				KEY_1, KEY_KP_1:
					matched_slot = 0
				KEY_2, KEY_KP_2:
					matched_slot = 1
				KEY_3, KEY_KP_3:
					matched_slot = 2
				KEY_4, KEY_KP_4:
					matched_slot = 3
				KEY_5, KEY_KP_5:
					matched_slot = 4
				KEY_6, KEY_KP_6:
					matched_slot = 5
				KEY_7, KEY_KP_7:
					matched_slot = 6
				KEY_8, KEY_KP_8:
					matched_slot = 7
				KEY_9, KEY_KP_9:
					matched_slot = 8
				KEY_0, KEY_KP_0:
					matched_slot = 9
				KEY_MINUS, KEY_KP_SUBTRACT:
					matched_slot = 10
			if matched_slot >= 0:
				_select_slot(matched_slot)
				get_viewport().set_input_as_handled()
				return

		if event is InputEventMouseButton and event.pressed:
			var mb := event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var slots := _get_hotbar_slots()
				if not slots.is_empty():
					var gs := _get_game_state()
					var cur: int = int(gs.selected_slot) if gs != null else 0
					var step: int = -1 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1
					var nxt: int = (cur + step + slots.size()) % slots.size()
					_select_slot(nxt)
					get_viewport().set_input_as_handled()


func toggle_shop() -> void:
	_set_shop_open(not _shop_open)


func toggle_journal(tab_idx: int = -1) -> void:
	var clamped_tab: int = clampi(tab_idx, 0, 2) if tab_idx >= 0 else _journal_tab
	if _journal_open and tab_idx >= 0 and _journal_tab != clamped_tab:
		_journal_tab = clamped_tab
		_refresh_journal()
		return
	if tab_idx >= 0:
		_journal_tab = clamped_tab
	_set_journal_open(not _journal_open)


func is_shop_open() -> bool:
	return _shop_open or _changelog_open or _menu_open or _journal_open


func close_all_modals() -> void:
	if _shop_open:
		_set_shop_open(false)
	if _journal_open:
		_set_journal_open(false)
	if _changelog_open:
		_set_changelog_open(false)
	if _menu_open:
		_set_menu_open(false)


func toggle_changelog() -> void:
	_set_changelog_open(not _changelog_open)


func is_changelog_open() -> bool:
	return _changelog_open


func toggle_menu() -> void:
	_set_menu_open(not _menu_open)


func _set_shop_open(open: bool) -> void:
	if open:
		if _changelog_open:
			_set_changelog_open(false)
		if _menu_open:
			_set_menu_open(false)
		if _journal_open:
			_set_journal_open(false)
	_shop_open = open
	if _shop_backdrop != null:
		_shop_backdrop.visible = _shop_open
	if _shop_panel != null:
		_shop_panel.visible = _shop_open
	if _shop_open:
		_refresh_shop()


func _set_journal_open(open: bool) -> void:
	if open:
		if _shop_open:
			_set_shop_open(false)
		if _changelog_open:
			_set_changelog_open(false)
		if _menu_open:
			_set_menu_open(false)
	_journal_open = open
	if _journal_backdrop != null:
		_journal_backdrop.visible = _journal_open
	if _journal_panel != null:
		_journal_panel.visible = _journal_open
	if _journal_open:
		_refresh_journal()


func _set_changelog_open(open: bool) -> void:
	if open:
		if _shop_open:
			_set_shop_open(false)
		if _journal_open:
			_set_journal_open(false)
		if _menu_open:
			_set_menu_open(false)
	_changelog_open = open
	if _changelog_backdrop != null:
		_changelog_backdrop.visible = _changelog_open
	if _changelog_panel != null:
		_changelog_panel.visible = _changelog_open


func _set_menu_open(open: bool) -> void:
	if open:
		if _shop_open:
			_set_shop_open(false)
		if _journal_open:
			_set_journal_open(false)
		if _changelog_open:
			_set_changelog_open(false)
	_menu_open = open
	if _menu_reset_confirm_box != null:
		_menu_reset_confirm_box.visible = false
	if _menu_backdrop != null:
		_menu_backdrop.visible = _menu_open
	if _menu_panel != null:
		_menu_panel.visible = _menu_open
	if _menu_open:
		_refresh_menu_buttons()


func _load_version_metadata() -> void:
	_version_history.clear()
	if ResourceLoader.exists(VERSION_DATA_PATH):
		var version_script := load(VERSION_DATA_PATH) as Script
		if version_script != null:
			var consts := version_script.get_script_constant_map()
			if not str(consts.get("CURRENT_VERSION", "")).is_empty():
				_current_version = str(consts["CURRENT_VERSION"])
			if not str(consts.get("AUTHOR", "")).is_empty():
				_version_author = str(consts["AUTHOR"])
			if not str(consts.get("RELEASES_URL", "")).is_empty():
				_releases_url = str(consts["RELEASES_URL"])
			if not str(consts.get("ISSUES_URL", "")).is_empty():
				_issues_url = str(consts["ISSUES_URL"])
			if not str(consts.get("CHANGELOG_URL", "")).is_empty():
				_changelog_url = str(consts["CHANGELOG_URL"])
			var raw_history: Variant = consts.get("HISTORY", [])
			if raw_history is Array:
				for item in raw_history:
					if item is Dictionary:
						_version_history.append((item as Dictionary).duplicate(true))

	if _version_history.is_empty():
		for item in FALLBACK_HISTORY:
			_version_history.append(item.duplicate(true))


func _emit_toast(text: String) -> void:
	var gs := _get_game_state()
	if gs != null and gs.has_method("emit_toast"):
		gs.call("emit_toast", text)
	else:
		_on_toast_message(text)


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
	return CropDataScript.get_all_definitions()


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
		if gs.has_signal("upgrades_changed"):
			gs.upgrades_changed.connect(_on_upgrades_changed)
		if gs.has_signal("weather_changed"):
			gs.weather_changed.connect(_on_weather_changed)
		if gs.has_signal("touch_mode_changed"):
			gs.touch_mode_changed.connect(_on_touch_mode_changed)
		if gs.has_signal("orders_changed"):
			gs.orders_changed.connect(_on_orders_or_album_changed)
		if gs.has_signal("album_changed"):
			gs.album_changed.connect(_on_orders_or_album_changed)
		if gs.has_signal("machines_changed"):
			gs.machines_changed.connect(_on_machines_changed)
		if gs.has_signal("animal_purchased"):
			gs.animal_purchased.connect(_on_animal_purchased)

	var audio := _get_audio_manager()
	if audio != null:
		if audio.has_signal("mute_changed"):
			audio.mute_changed.connect(_on_mute_changed)
		if audio.has_signal("music_mute_changed"):
			audio.music_mute_changed.connect(_on_music_mute_changed)

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
		_on_weather_changed("sunny", "sunny")
		_on_inventory_changed()
		_on_tool_changed(0)
	else:
		_on_day_changed(gs.day, gs.time_minutes)
		_on_money_changed(gs.money)
		_on_stamina_changed(gs.stamina, gs.max_stamina)
		_on_water_changed(gs.water_level, gs.max_water)
		_on_weather_changed(str(gs.get("weather")), str(gs.get("tomorrow_weather")))
		_on_inventory_changed()
		_on_tool_changed(gs.selected_slot)

	_refresh_sound_button()
	_refresh_auto_button()
	_refresh_journal_button()
	_refresh_menu_buttons()
	_refresh_touch_controls()


func _build_ui() -> void:
	_ui_root = Control.new()
	_ui_root.name = "UIRoot"
	_ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ui_root)

	_build_stats_panel()
	_build_basket_panel()
	_build_touch_controls()
	_build_hotbar_section()
	_build_controls_hint()
	_build_shop_modal()
	_build_journal_modal()
	_build_changelog_modal()
	_build_menu_modal()
	_build_toast_panel()


func _build_stats_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "StatsPanel"
	panel.position = Vector2(6, 6)
	panel.add_theme_stylebox_override("panel", _make_parchment_style(7, 4))
	_ui_root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	# Row 1: Day/Time + Money + Version badge
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 5)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(top_row)

	_day_time_label = _make_label("Dia 1 - 06:00", 9, COL_INK)
	_day_time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(_day_time_label)

	var money_row := HBoxContainer.new()
	money_row.add_theme_constant_override("separation", 2)
	money_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(money_row)

	money_row.add_child(_make_icon_rect("base", 5, Vector2(14, 14)))

	_money_label = _make_label("$100", 9, COL_GOLD_TEXT)
	money_row.add_child(_money_label)

	_version_button = _make_colored_button(
		"%s (V)" % _current_version,
		Vector2(46, 15),
		7,
		Color("#5a442d"),
		Color("#72583b"),
		Color("#453321"),
		COL_WOOD_BORDER,
		Color("#fff1cc")
	)
	_version_button.name = "VersionButton"
	_version_button.tooltip_text = "Histórico de versões e links (V)"
	_version_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_version_button.pressed.connect(_on_version_button_pressed)
	top_row.add_child(_version_button)

	# Row 2: Weather & Forecast
	var weather_row := HBoxContainer.new()
	weather_row.add_theme_constant_override("separation", 4)
	weather_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(weather_row)

	_weather_today_icon = _make_icon_rect("base", 14, Vector2(13, 13))
	weather_row.add_child(_weather_today_icon)
	_weather_today_label = _make_label("Hoje: Sol", 8, COL_INK)
	weather_row.add_child(_weather_today_label)

	weather_row.add_child(_make_label("|", 8, COL_INK_MUTED))

	_weather_next_icon = _make_icon_rect("base", 14, Vector2(13, 13))
	weather_row.add_child(_weather_next_icon)
	_weather_next_label = _make_label("Amanhã: Sol", 8, COL_INK_MUTED)
	weather_row.add_child(_weather_next_label)

	# Row 3: Stamina bar
	var stamina_row := HBoxContainer.new()
	stamina_row.add_theme_constant_override("separation", 4)
	stamina_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(stamina_row)

	var stamina_lbl := _make_label("Energia", 8, COL_INK)
	stamina_lbl.custom_minimum_size = Vector2(36, 0)
	stamina_row.add_child(stamina_lbl)

	_stamina_fill_style = _make_bar_fill_style(Color("#5ab549"))
	var stamina_built := _make_progress_bar(Vector2(114, 11), _stamina_fill_style)
	_stamina_bar = stamina_built["bar"]
	_stamina_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stamina_value_label = stamina_built["label"]
	stamina_row.add_child(_stamina_bar)

	# Row 4: Water bar
	var water_row := HBoxContainer.new()
	water_row.add_theme_constant_override("separation", 4)
	water_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(water_row)

	var water_lbl := _make_label("Água", 8, COL_INK)
	water_lbl.custom_minimum_size = Vector2(36, 0)
	water_row.add_child(water_lbl)

	var water_fill := _make_bar_fill_style(Color("#3a9be0"))
	var water_built := _make_progress_bar(Vector2(114, 11), water_fill)
	_water_bar = water_built["bar"]
	_water_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	panel.offset_left = -332
	panel.offset_top = 6
	panel.offset_right = -6
	panel.add_theme_stylebox_override("panel", _make_parchment_style(6, 4))
	_ui_root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	_harvest_label = _make_label("Tri:0 Cen:0 Mor:0 | Mil:0 Tom:0 Abo:0", 8, COL_INK)
	_harvest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(_harvest_label)

	var animal_row := HBoxContainer.new()
	animal_row.add_theme_constant_override("separation", 3)
	animal_row.alignment = BoxContainer.ALIGNMENT_END
	animal_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(animal_row)

	animal_row.add_child(_make_icon_rect("base", 6, Vector2(12, 12)))
	_egg_label = _make_label("0", 8, COL_INK)
	animal_row.add_child(_egg_label)

	animal_row.add_child(_make_icon_rect("v13", 9, Vector2(12, 12)))
	_blue_egg_label = _make_label("0", 8, COL_INK)
	animal_row.add_child(_blue_egg_label)

	animal_row.add_child(_make_icon_rect("base", 7, Vector2(12, 12)))
	_milk_label = _make_label("0", 8, COL_INK)
	animal_row.add_child(_milk_label)

	animal_row.add_child(_make_icon_rect("base", 12, Vector2(12, 12)))
	_wool_label = _make_label("0", 8, COL_INK)
	animal_row.add_child(_wool_label)

	animal_row.add_child(_make_icon_rect("base", 13, Vector2(12, 12)))
	_truffle_label = _make_label("0", 8, COL_INK)
	animal_row.add_child(_truffle_label)

	_basket_extra_label = _make_label("| Peixe:0 Art:0 ($0)", 8, COL_GOLD_TEXT)
	animal_row.add_child(_basket_extra_label)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 2)
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(btn_row)

	_auto_button = _make_wood_button("Auto (P)", Vector2(44, 17), 7)
	_auto_button.pressed.connect(_on_auto_button_pressed)
	btn_row.add_child(_auto_button)

	var save_btn := _make_wood_button("Salvar", Vector2(34, 17), 7)
	save_btn.pressed.connect(_on_save_button_pressed)
	btn_row.add_child(save_btn)

	_sound_button = _make_wood_button("Som: ON", Vector2(42, 17), 7)
	_sound_button.pressed.connect(_on_sound_button_pressed)
	btn_row.add_child(_sound_button)

	var shop_btn := _make_wood_button("Loja (B)", Vector2(42, 17), 7)
	shop_btn.pressed.connect(_on_shop_button_pressed)
	btn_row.add_child(shop_btn)

	_journal_button = _make_wood_button("Diário (J)", Vector2(48, 17), 7)
	_journal_button.pressed.connect(_on_journal_button_pressed)
	btn_row.add_child(_journal_button)

	var sleep_btn := _make_wood_button("Dormir (N)", Vector2(48, 17), 7)
	sleep_btn.pressed.connect(_on_sleep_button_pressed)
	btn_row.add_child(sleep_btn)

	var menu_btn := _make_wood_button("Menu", Vector2(32, 17), 7)
	menu_btn.name = "MenuButton"
	menu_btn.pressed.connect(_on_menu_button_pressed)
	btn_row.add_child(menu_btn)


func _build_hotbar_section() -> void:
	var container := VBoxContainer.new()
	container.name = "HotbarSection"
	container.anchor_left = 0.5
	container.anchor_right = 0.5
	container.anchor_top = 1.0
	container.anchor_bottom = 1.0
	container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	container.offset_bottom = -17
	container.add_theme_constant_override("separation", 2)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_root.add_child(container)

	_active_item_label = _make_outlined_label("Enxada", 9, Color(1.0, 0.97, 0.88))
	_active_item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(_active_item_label)

	var tray := PanelContainer.new()
	tray.name = "HotbarPanel"
	tray.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var tray_style := _make_flat_style(COL_WOOD_DARK, Color("#351b0c"), 2, 4, 3, 2)
	tray.add_theme_stylebox_override("panel", tray_style)
	container.add_child(tray)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 2)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.add_child(hbox)

	_slot_normal_style = _make_flat_style(Color("#dfca9d"), COL_WOOD_SOFT, 1, 2, 2, 1)
	_slot_active_style = _make_flat_style(Color("#fff4cf"), COL_GOLD_BORDER, 2, 2, 2, 1)

	var slots := _get_hotbar_slots()
	for i in range(slots.size()):
		var slot_data: Dictionary = slots[i]
		var slot_panel := PanelContainer.new()
		slot_panel.name = "Slot_%d" % i
		slot_panel.custom_minimum_size = Vector2(25, 25)
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

		var icon_sheet := str(slot_data.get("sheet", "base"))
		var icon_col := int(slot_data.get("icon_col", i))
		var icon_rect := _make_icon_rect(icon_sheet, icon_col, Vector2(15, 15))
		icon_center.add_child(icon_rect)

		var key_hint := str(slot_data.get("key_hint", str(i + 1)))
		var key_lbl := _make_label(key_hint, 7, COL_INK_MUTED)
		key_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		key_lbl.offset_left = 0
		key_lbl.offset_top = -2
		key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		key_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		inner.add_child(key_lbl)

		var s_type: String = str(slot_data.get("type", ""))
		var s_id: String = str(slot_data.get("id", ""))
		var count_lbl := _make_outlined_label("", 7, Color.WHITE)
		count_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		count_lbl.offset_right = 0
		count_lbl.offset_bottom = 2
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count_lbl.visible = (s_type == "seed" or s_type == "supply" or s_id == "hoe" or s_id == "watering_can")
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
	panel.offset_bottom = -1
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override(
		"panel",
		_make_flat_style(Color(0.11, 0.07, 0.04, 0.80), Color(0.42, 0.26, 0.13, 0.65), 1, 6, 1, 2)
	)
	_ui_root.add_child(panel)

	var lbl := _make_label(
		"WASD: Mover | Espaço: Usar | F: Interagir | 1-0,-: Slot | B: Loja | J: Diário | N: Dormir | P: Auto | Esc: Menu",
		7,
		Color(0.96, 0.93, 0.84)
	)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(lbl)


func _build_touch_controls() -> void:
	_touch_layer = Control.new()
	_touch_layer.name = "TouchControls"
	_touch_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_touch_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_touch_layer.visible = false
	_ui_root.add_child(_touch_layer)

	# Bottom-left D-Pad
	var dpad := Control.new()
	dpad.name = "TouchDPad"
	dpad.anchor_left = 0.0
	dpad.anchor_top = 1.0
	dpad.anchor_bottom = 1.0
	dpad.offset_left = 10
	dpad.offset_top = -94
	dpad.offset_right = 94
	dpad.offset_bottom = -10
	dpad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_touch_layer.add_child(dpad)

	var dir_specs := [
		{"text": "▲", "pos": Vector2(28, 0), "dir": Vector2(0, -1)},
		{"text": "▼", "pos": Vector2(28, 56), "dir": Vector2(0, 1)},
		{"text": "◀", "pos": Vector2(0, 28), "dir": Vector2(-1, 0)},
		{"text": "▶", "pos": Vector2(56, 28), "dir": Vector2(1, 0)},
	]
	for spec in dir_specs:
		var btn := _make_colored_button(
			str(spec["text"]),
			Vector2(26, 26),
			9,
			Color(0.24, 0.14, 0.08, 0.72),
			Color(0.35, 0.21, 0.12, 0.85),
			Color(0.55, 0.36, 0.18, 0.92),
			COL_GOLD_BORDER,
			Color(1.0, 0.96, 0.82)
		)
		btn.position = spec["pos"]
		btn.size = Vector2(26, 26)
		var dir_vec: Vector2 = spec["dir"]
		btn.button_down.connect(_on_touch_dir_down.bind(dir_vec))
		btn.button_up.connect(_on_touch_dir_up)
		btn.mouse_exited.connect(_on_touch_dir_up)
		dpad.add_child(btn)

	# Bottom-right Action buttons
	var actions_box := VBoxContainer.new()
	actions_box.name = "TouchActions"
	actions_box.anchor_left = 1.0
	actions_box.anchor_right = 1.0
	actions_box.anchor_top = 1.0
	actions_box.anchor_bottom = 1.0
	actions_box.offset_left = -88
	actions_box.offset_top = -80
	actions_box.offset_right = -10
	actions_box.offset_bottom = -14
	actions_box.add_theme_constant_override("separation", 5)
	actions_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_touch_layer.add_child(actions_box)

	var use_btn := _make_colored_button(
		"Usar",
		Vector2(76, 28),
		9,
		Color(0.28, 0.56, 0.24, 0.82),
		Color(0.35, 0.68, 0.30, 0.90),
		Color(0.22, 0.44, 0.19, 0.95),
		COL_GOLD_BORDER,
		Color.WHITE
	)
	use_btn.pressed.connect(_on_touch_use_pressed)
	actions_box.add_child(use_btn)

	var interact_btn := _make_colored_button(
		"Interagir",
		Vector2(76, 28),
		9,
		Color(0.24, 0.48, 0.68, 0.82),
		Color(0.30, 0.58, 0.80, 0.90),
		Color(0.18, 0.38, 0.54, 0.95),
		COL_GOLD_BORDER,
		Color.WHITE
	)
	interact_btn.pressed.connect(_on_touch_interact_pressed)
	actions_box.add_child(interact_btn)


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
	_shop_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_shop_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_shop_panel.offset_left = -222
	_shop_panel.offset_right = 222
	_shop_panel.offset_top = -132
	_shop_panel.offset_bottom = 112
	_shop_panel.visible = false
	_shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_shop_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT, COL_WOOD_BORDER, 3, 9, 6, 3))
	_shop_backdrop.add_child(_shop_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	main_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_panel.add_child(main_vbox)

	# Header with 3 tabs + money
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(header)

	var title := _make_label("Loja da Fazenda", 10, COL_WOOD_DARK)
	header.add_child(title)

	_shop_tab_seeds_btn = _make_wood_button("Sementes", Vector2(56, 17), 7)
	_shop_tab_seeds_btn.pressed.connect(_on_shop_tab_pressed.bind("seeds"))
	header.add_child(_shop_tab_seeds_btn)

	_shop_tab_upgrades_btn = _make_wood_button("Upgrades", Vector2(56, 17), 7)
	_shop_tab_upgrades_btn.pressed.connect(_on_shop_tab_pressed.bind("upgrades"))
	header.add_child(_shop_tab_upgrades_btn)

	_shop_tab_farm_btn = _make_wood_button("Animais & Máq.", Vector2(72, 17), 7)
	_shop_tab_farm_btn.pressed.connect(_on_shop_tab_pressed.bind("farm"))
	header.add_child(_shop_tab_farm_btn)

	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(header_spacer)

	var money_box := HBoxContainer.new()
	money_box.add_theme_constant_override("separation", 3)
	money_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(money_box)

	money_box.add_child(_make_icon_rect("base", 5, Vector2(14, 14)))
	_shop_money_label = _make_label("$100", 10, COL_GOLD_TEXT)
	money_box.add_child(_shop_money_label)

	main_vbox.add_child(_make_separator())

	# Tab 1: Seeds Grid (2 columns x 3 rows)
	_shop_seeds_grid = GridContainer.new()
	_shop_seeds_grid.name = "SeedsGrid"
	_shop_seeds_grid.columns = 2
	_shop_seeds_grid.add_theme_constant_override("h_separation", 6)
	_shop_seeds_grid.add_theme_constant_override("v_separation", 4)
	_shop_seeds_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(_shop_seeds_grid)

	var crops := _get_crops()
	for crop_id in CROP_ORDER:
		var crop: Dictionary = crops.get(crop_id, {})
		var row_panel := PanelContainer.new()
		row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#b89563"), 1, 5, 3, 2))
		_shop_seeds_grid.add_child(row_panel)

		var row_hbox := HBoxContainer.new()
		row_hbox.add_theme_constant_override("separation", 4)
		row_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_panel.add_child(row_hbox)

		var icon_sheet := str(crop.get("icon_sheet", "base"))
		var icon_col := int(crop.get("icon_col", 2))
		var icon_rect := _make_icon_rect(icon_sheet, icon_col, Vector2(16, 16))
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row_hbox.add_child(icon_rect)

		var info_vbox := VBoxContainer.new()
		info_vbox.add_theme_constant_override("separation", 0)
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_hbox.add_child(info_vbox)

		var crop_name := str(crop.get("name", crop_id.capitalize()))
		var regrow := int(crop.get("regrow_days", 0))
		var title_txt := "%s ★Reb" % crop_name if regrow > 0 else crop_name
		var title_lbl := _make_label(title_txt, 8, COL_INK)
		info_vbox.add_child(title_lbl)

		var days := int(crop.get("days_to_grow", 2))
		var sell_price := int(crop.get("sell_price", 25))
		var sub_lbl := _make_label("%dd | $%d | Est:0" % [days, sell_price], 7, COL_INK_MUTED)
		info_vbox.add_child(sub_lbl)
		_shop_crop_info_labels[crop_id] = sub_lbl

		var seed_price := int(crop.get("seed_price", 10))
		var buy_btn := _make_wood_button("1x $%d" % seed_price, Vector2(44, 19), 7)
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buy_btn.pressed.connect(_on_buy_seed_pressed.bind(crop_id, 1))
		row_hbox.add_child(buy_btn)
		_shop_buy_buttons[crop_id] = buy_btn

		var buy5_btn := _make_wood_button("+5", Vector2(22, 19), 7)
		buy5_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buy5_btn.pressed.connect(_on_buy_seed_pressed.bind(crop_id, 5))
		row_hbox.add_child(buy5_btn)

	# Tab 2: Upgrades & Supplies (Hoe, Can, Stamina, Fertilizer, Sprinkler)
	_shop_upgrades_vbox = VBoxContainer.new()
	_shop_upgrades_vbox.name = "UpgradesVBox"
	_shop_upgrades_vbox.add_theme_constant_override("separation", 3)
	_shop_upgrades_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_shop_upgrades_vbox.visible = false
	main_vbox.add_child(_shop_upgrades_vbox)

	var upgrade_specs := [
		{"id": "hoe", "title": "Enxada", "icon": 0},
		{"id": "can", "title": "Regador", "icon": 1},
		{"id": "stamina", "title": "Resistência", "icon": 5},
	]
	for u in upgrade_specs:
		var uid: String = str(u["id"])
		var row_p := PanelContainer.new()
		row_p.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#b89563"), 1, 6, 2, 2))
		_shop_upgrades_vbox.add_child(row_p)

		var row_h := HBoxContainer.new()
		row_h.add_theme_constant_override("separation", 6)
		row_p.add_child(row_h)

		var u_icon := _make_icon_rect("base", int(u["icon"]), Vector2(15, 15))
		u_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row_h.add_child(u_icon)

		var u_vbox := VBoxContainer.new()
		u_vbox.add_theme_constant_override("separation", 0)
		u_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_h.add_child(u_vbox)

		var u_title := _make_label("%s (Nv. 1/3)" % str(u["title"]), 8, COL_INK)
		u_vbox.add_child(u_title)
		_shop_upgrade_title_labels[uid] = u_title

		var u_desc := _make_label("", 7, COL_INK_MUTED)
		u_vbox.add_child(u_desc)
		_shop_upgrade_desc_labels[uid] = u_desc

		var u_btn := _make_wood_button("Melhorar ($150)", Vector2(88, 18), 7)
		u_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		u_btn.pressed.connect(_on_buy_upgrade_pressed.bind(uid))
		row_h.add_child(u_btn)
		_shop_upgrade_buttons[uid] = u_btn

	# Fertilizer row inside Upgrades tab
	var ft_panel := PanelContainer.new()
	ft_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#b89563"), 1, 6, 2, 2))
	_shop_upgrades_vbox.add_child(ft_panel)

	var ft_hbox := HBoxContainer.new()
	ft_hbox.add_theme_constant_override("separation", 6)
	ft_panel.add_child(ft_hbox)

	var ft_icon := _make_icon_rect("v13", 4, Vector2(15, 15))
	ft_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ft_hbox.add_child(ft_icon)

	var ft_vbox := VBoxContainer.new()
	ft_vbox.add_theme_constant_override("separation", 0)
	ft_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ft_hbox.add_child(ft_vbox)

	ft_vbox.add_child(_make_label("Fertilizante (Slot 0) — Ouro ★ 1.5x", 8, COL_INK))
	_shop_fertilizer_desc_label = _make_label("Aumenta chance de colheita ★ | Estoque: 2", 7, COL_INK_MUTED)
	ft_vbox.add_child(_shop_fertilizer_desc_label)

	var ft_btn := _make_wood_button("1x ($15)", Vector2(54, 18), 7)
	ft_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ft_btn.pressed.connect(_on_buy_supply_pressed.bind("fertilizer", 1))
	ft_hbox.add_child(ft_btn)

	var ft5_btn := _make_wood_button("+5", Vector2(26, 18), 7)
	ft5_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ft5_btn.pressed.connect(_on_buy_supply_pressed.bind("fertilizer", 5))
	ft_hbox.add_child(ft5_btn)

	# Sprinkler row inside Upgrades tab
	var sp_panel := PanelContainer.new()
	sp_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#b89563"), 1, 6, 2, 2))
	_shop_upgrades_vbox.add_child(sp_panel)

	var sp_hbox := HBoxContainer.new()
	sp_hbox.add_theme_constant_override("separation", 6)
	sp_panel.add_child(sp_hbox)

	var sp_icon := _make_icon_rect("base", 11, Vector2(15, 15))
	sp_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sp_hbox.add_child(sp_icon)

	var sp_vbox := VBoxContainer.new()
	sp_vbox.add_theme_constant_override("separation", 0)
	sp_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_hbox.add_child(sp_vbox)

	sp_vbox.add_child(_make_label("Aspersor Automático (Slot -)", 8, COL_INK))
	_shop_sprinkler_desc_label = _make_label("Rega 3x3 toda manhã | Estoque: 0", 7, COL_INK_MUTED)
	sp_vbox.add_child(_shop_sprinkler_desc_label)

	var sp_btn := _make_wood_button("Comprar ($180)", Vector2(88, 18), 7)
	sp_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sp_btn.pressed.connect(_on_buy_sprinkler_pressed)
	sp_hbox.add_child(sp_btn)

	# Tab 3: Animals & Artisanal Machines (ScrollContainer)
	_shop_farm_scroll = ScrollContainer.new()
	_shop_farm_scroll.name = "FarmShopScroll"
	_shop_farm_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_shop_farm_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_shop_farm_scroll.visible = false
	main_vbox.add_child(_shop_farm_scroll)

	_shop_farm_vbox = VBoxContainer.new()
	_shop_farm_vbox.add_theme_constant_override("separation", 4)
	_shop_farm_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shop_farm_scroll.add_child(_shop_farm_vbox)

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


func _build_journal_modal() -> void:
	_journal_backdrop = ColorRect.new()
	_journal_backdrop.name = "JournalBackdrop"
	_journal_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_journal_backdrop.color = Color(0.08, 0.05, 0.03, 0.55)
	_journal_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_journal_backdrop.visible = false
	_ui_root.add_child(_journal_backdrop)

	_journal_panel = PanelContainer.new()
	_journal_panel.name = "JournalPanel"
	_journal_panel.anchor_left = 0.5
	_journal_panel.anchor_right = 0.5
	_journal_panel.anchor_top = 0.5
	_journal_panel.anchor_bottom = 0.5
	_journal_panel.offset_left = -204
	_journal_panel.offset_right = 204
	_journal_panel.offset_top = -124
	_journal_panel.offset_bottom = 112
	_journal_panel.visible = false
	_journal_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_journal_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT, COL_WOOD_BORDER, 3, 9, 6, 3))
	_journal_backdrop.add_child(_journal_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	main_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_journal_panel.add_child(main_vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 5)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(header)

	var title := _make_label("Diário da Fazenda", 10, COL_WOOD_DARK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var tab_titles := ["Pedidos", "Álbum", "Dicas & Vel."]
	_journal_tab_buttons.clear()
	for i in range(tab_titles.size()):
		var t_btn := _make_wood_button(tab_titles[i], Vector2(58, 17), 7)
		t_btn.pressed.connect(_on_journal_tab_pressed.bind(i))
		header.add_child(t_btn)
		_journal_tab_buttons.append(t_btn)

	main_vbox.add_child(_make_separator())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 152)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	_journal_content_vbox = VBoxContainer.new()
	_journal_content_vbox.add_theme_constant_override("separation", 4)
	_journal_content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_journal_content_vbox)

	main_vbox.add_child(_make_separator())

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 6)
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(footer)

	var close_btn := _make_colored_button(
		"Fechar (J)",
		Vector2(66, 19),
		8,
		Color("#b84b3e"),
		Color("#cf5a4c"),
		Color("#94392e"),
		Color("#61231c"),
		Color.WHITE
	)
	close_btn.pressed.connect(func() -> void:
		_play_click()
		_set_journal_open(false)
	)
	footer.add_child(close_btn)


func _build_menu_modal() -> void:
	_menu_backdrop = ColorRect.new()
	_menu_backdrop.name = "MenuBackdrop"
	_menu_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu_backdrop.color = Color(0.08, 0.05, 0.03, 0.58)
	_menu_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_backdrop.visible = false
	_ui_root.add_child(_menu_backdrop)

	_menu_panel = PanelContainer.new()
	_menu_panel.name = "MenuPanel"
	_menu_panel.anchor_left = 0.5
	_menu_panel.anchor_right = 0.5
	_menu_panel.anchor_top = 0.5
	_menu_panel.anchor_bottom = 0.5
	_menu_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_menu_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_menu_panel.offset_left = -134
	_menu_panel.offset_right = 134
	_menu_panel.offset_top = -120
	_menu_panel.offset_bottom = 108
	_menu_panel.visible = false
	_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT, COL_WOOD_BORDER, 3, 10, 7, 3))
	_menu_backdrop.add_child(_menu_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	_menu_panel.add_child(vbox)

	var title := _make_label("Menu & Opções", 10, COL_WOOD_DARK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	vbox.add_child(_make_separator())

	_menu_sfx_btn = _make_wood_button("Efeitos Sonoros: ON", Vector2(0, 19), 8)
	_menu_sfx_btn.pressed.connect(_on_sound_button_pressed)
	vbox.add_child(_menu_sfx_btn)

	_menu_music_btn = _make_wood_button("Música de Fundo: ON", Vector2(0, 19), 8)
	_menu_music_btn.pressed.connect(_on_music_button_pressed)
	vbox.add_child(_menu_music_btn)

	_menu_touch_btn = _make_wood_button("Controles Touch: Auto", Vector2(0, 19), 8)
	_menu_touch_btn.pressed.connect(_on_touch_mode_button_pressed)
	vbox.add_child(_menu_touch_btn)

	_menu_speed_btn = _make_wood_button("Velocidade do Dia: 1x", Vector2(0, 19), 8)
	_menu_speed_btn.pressed.connect(_on_menu_speed_cycle_pressed)
	vbox.add_child(_menu_speed_btn)

	var ver_btn := _make_wood_button("Atualizações & Changelog (V)", Vector2(0, 19), 8)
	ver_btn.pressed.connect(_on_version_button_pressed)
	vbox.add_child(ver_btn)

	_menu_reset_btn = _make_colored_button(
		"Reiniciar Fazenda (Dia 1)",
		Vector2(0, 19),
		8,
		Color("#a84336"),
		Color("#c25244"),
		Color("#853126"),
		Color("#591d15"),
		Color.WHITE
	)
	_menu_reset_btn.pressed.connect(_on_menu_reset_pressed)
	vbox.add_child(_menu_reset_btn)

	_menu_reset_confirm_box = PanelContainer.new()
	_menu_reset_confirm_box.visible = false
	_menu_reset_confirm_box.add_theme_stylebox_override("panel", _make_flat_style(Color(0.95, 0.84, 0.72), Color("#9e382b"), 1, 6, 4, 2))
	vbox.add_child(_menu_reset_confirm_box)

	var confirm_vbox := VBoxContainer.new()
	confirm_vbox.add_theme_constant_override("separation", 3)
	_menu_reset_confirm_box.add_child(confirm_vbox)

	var warn_lbl := _make_label("Apagar o save e voltar ao Dia 1?", 8, Color("#731e15"))
	warn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirm_vbox.add_child(warn_lbl)

	var confirm_row := HBoxContainer.new()
	confirm_row.add_theme_constant_override("separation", 6)
	confirm_row.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_vbox.add_child(confirm_row)

	var cancel_rst := _make_wood_button("Cancelar", Vector2(70, 18), 8)
	cancel_rst.pressed.connect(_on_cancel_reset_pressed)
	confirm_row.add_child(cancel_rst)

	var do_rst := _make_colored_button(
		"Confirmar",
		Vector2(76, 18),
		8,
		Color("#b8392c"),
		Color("#d14739"),
		Color("#8f281e"),
		Color("#5e1912"),
		Color.WHITE
	)
	do_rst.pressed.connect(_on_confirm_reset_pressed)
	confirm_row.add_child(do_rst)

	var close_menu_btn := _make_colored_button(
		"Voltar ao Jogo (Esc)",
		Vector2(0, 19),
		8,
		Color("#5a9640"),
		Color("#6eb050"),
		Color("#487a32"),
		Color("#2e4f1e"),
		Color.WHITE
	)
	close_menu_btn.pressed.connect(_on_close_menu_pressed)
	vbox.add_child(close_menu_btn)


func _format_author_badge(author: String) -> String:
	var handle := author.strip_edges()
	var space_idx := handle.find(" ")
	if space_idx > 0:
		handle = handle.substr(0, space_idx)
	return "Autor: %s" % handle


func _build_changelog_modal() -> void:
	_changelog_backdrop = ColorRect.new()
	_changelog_backdrop.name = "ChangelogBackdrop"
	_changelog_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_changelog_backdrop.color = Color(0.08, 0.05, 0.03, 0.55)
	_changelog_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_changelog_backdrop.visible = false
	_ui_root.add_child(_changelog_backdrop)

	_changelog_panel = PanelContainer.new()
	_changelog_panel.name = "ChangelogPanel"
	_changelog_panel.anchor_left = 0.5
	_changelog_panel.anchor_right = 0.5
	_changelog_panel.anchor_top = 0.5
	_changelog_panel.anchor_bottom = 0.5
	_changelog_panel.offset_left = -196
	_changelog_panel.offset_right = 196
	_changelog_panel.offset_top = -110
	_changelog_panel.offset_bottom = 80
	_changelog_panel.visible = false
	_changelog_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_changelog_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT, COL_WOOD_BORDER, 3, 9, 6, 3))
	_changelog_backdrop.add_child(_changelog_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	main_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_changelog_panel.add_child(main_vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(header)

	_changelog_title_label = _make_label("Atualizações (%s)" % _current_version, 10, COL_WOOD_DARK)
	_changelog_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_changelog_title_label)

	var author_badge := PanelContainer.new()
	author_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	author_badge.add_theme_stylebox_override(
		"panel",
		_make_flat_style(Color(0.92, 0.85, 0.69, 0.96), Color("#b89563"), 1, 5, 1, 2)
	)
	header.add_child(author_badge)

	_changelog_author_label = _make_label(_format_author_badge(_version_author), 7, COL_GOLD_TEXT)
	author_badge.add_child(_changelog_author_label)

	main_vbox.add_child(_make_separator())

	# Scrollable release history list
	var scroll := ScrollContainer.new()
	scroll.name = "ChangelogScroll"
	scroll.custom_minimum_size = Vector2(0, 108)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.clip_contents = true
	main_vbox.add_child(scroll)

	var history_vbox := VBoxContainer.new()
	history_vbox.name = "ChangelogEntries"
	history_vbox.add_theme_constant_override("separation", 4)
	history_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	history_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(history_vbox)

	for entry in _version_history:
		var ver_str := str(entry.get("version", ""))
		var title_str := str(entry.get("title", ""))
		var date_str := str(entry.get("date", ""))
		var entry_author := str(entry.get("author", _version_author))
		var is_current := (ver_str == _current_version)

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_theme_stylebox_override(
			"panel",
			_make_flat_style(
				Color(0.95, 0.89, 0.75, 0.98) if is_current else COL_PARCHMENT_ALT,
				Color("#9c6c2e") if is_current else Color("#b89563"),
				1,
				6,
				4,
				2
			)
		)
		history_vbox.add_child(card)

		var card_vbox := VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 2)
		card_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(card_vbox)

		var card_top := HBoxContainer.new()
		card_top.add_theme_constant_override("separation", 6)
		card_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_vbox.add_child(card_top)

		var heading_text := "%s — %s" % [ver_str, title_str] if not title_str.is_empty() else ver_str
		var heading_lbl := _make_label(heading_text, 8, COL_WOOD_DARK)
		heading_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		heading_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_top.add_child(heading_lbl)

		var meta_text := "%s · %s" % [date_str, _format_author_badge(entry_author).replace("Autor: ", "")] if not date_str.is_empty() else entry_author
		var meta_lbl := _make_label(meta_text, 7, COL_INK_MUTED)
		meta_lbl.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		card_top.add_child(meta_lbl)

		var highlights: Variant = entry.get("highlights", [])
		if highlights is Array:
			for h in highlights:
				var bullet_lbl := _make_label("• %s" % str(h), 7, COL_INK)
				bullet_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				bullet_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				card_vbox.add_child(bullet_lbl)

	main_vbox.add_child(_make_separator())

	# Footer buttons
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 6)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(footer)

	var releases_btn := _make_colored_button(
		"Releases (GitHub)",
		Vector2(98, 20),
		8,
		Color("#466f8f"),
		Color("#5686ab"),
		Color("#375973"),
		Color("#233c4f"),
		Color.WHITE
	)
	releases_btn.name = "ReleasesButton"
	releases_btn.pressed.connect(_on_open_releases_pressed)
	footer.add_child(releases_btn)

	var issues_btn := _make_colored_button(
		"Issues / Bugs",
		Vector2(82, 20),
		8,
		Color("#8b5a2b"),
		Color("#a36b35"),
		Color("#704721"),
		Color("#4a2d13"),
		Color.WHITE
	)
	issues_btn.name = "IssuesButton"
	issues_btn.pressed.connect(_on_open_issues_pressed)
	footer.add_child(issues_btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(spacer)

	var close_btn := _make_colored_button(
		"Fechar (V)",
		Vector2(66, 20),
		8,
		Color("#b84b3e"),
		Color("#cf5a4c"),
		Color("#94392e"),
		Color("#61231c"),
		Color.WHITE
	)
	close_btn.name = "CloseChangelogButton"
	close_btn.pressed.connect(_on_close_changelog_pressed)
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
	_toast_panel.offset_bottom = -68
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
	if _shop_open:
		_refresh_shop()


func _on_day_changed(day: int, time_minutes: float) -> void:
	if _day_time_label == null:
		return
	var total_mins := int(floor(time_minutes))
	var hours := (total_mins / 60) % 24
	var mins := total_mins % 60
	_day_time_label.text = "Dia %d - %02d:%02d" % [day, hours, mins]


func _on_weather_changed(weather: String, tomorrow_weather: String) -> void:
	var today_rain := (weather == "rainy" or weather == "rain")
	var next_rain := (tomorrow_weather == "rainy" or tomorrow_weather == "rain")
	if _weather_today_icon != null:
		_weather_today_icon.texture = _make_icon_texture("base", 15 if today_rain else 14)
	if _weather_today_label != null:
		_weather_today_label.text = "Hoje: %s" % ("Chuva" if today_rain else "Sol")
	if _weather_next_icon != null:
		_weather_next_icon.texture = _make_icon_texture("base", 15 if next_rain else 14)
	if _weather_next_label != null:
		_weather_next_label.text = "Amanhã: %s" % ("Chuva" if next_rain else "Sol")


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


func _on_upgrades_changed() -> void:
	var gs := _get_game_state()
	var selected: int = int(gs.selected_slot) if gs != null else 0
	_update_active_item_label(selected)
	if _shop_open:
		_refresh_shop()


func _on_touch_mode_changed(_mode: String) -> void:
	_refresh_touch_controls()
	_refresh_menu_buttons()


func _on_orders_or_album_changed() -> void:
	_refresh_journal_button()
	if _journal_open:
		_refresh_journal()


func _on_machines_changed() -> void:
	if _shop_open:
		_refresh_shop()


func _on_animal_purchased(_animal_type: String) -> void:
	if _shop_open:
		_refresh_shop()


func _sum_dict(d: Dictionary) -> int:
	var s: int = 0
	for v in d.values():
		s += int(v)
	return s


func _on_inventory_changed() -> void:
	var gs := _get_game_state()
	var harvested: Dictionary = gs.get("harvested") if gs != null and gs.get("harvested") != null else {}
	var animal_products: Dictionary = gs.get("animal_products") if gs != null and gs.get("animal_products") != null else {}
	var fish_dict: Dictionary = gs.get("fish") if gs != null and gs.get("fish") != null else {}
	var artisan_dict: Dictionary = gs.get("artisan") if gs != null and gs.get("artisan") != null else {}
	var seeds: Dictionary = gs.get("seeds") if gs != null and gs.get("seeds") != null else {}
	var supplies: Dictionary = gs.get("supplies") if gs != null and gs.get("supplies") != null else {}
	var gold_items: Dictionary = gs.get("gold_items") if gs != null and gs.get("gold_items") != null else {}

	if _harvest_label != null:
		var w := int(harvested.get("wheat", 0))
		var c := int(harvested.get("carrot", 0))
		var s := int(harvested.get("strawberry", 0))
		var co := int(harvested.get("corn", 0))
		var t := int(harvested.get("tomato", 0))
		var p := int(harvested.get("pumpkin", 0))
		_harvest_label.text = "Tri:%d Cen:%d Mor:%d | Mil:%d Tom:%d Abo:%d" % [w, c, s, co, t, p]

	if _egg_label != null:
		_egg_label.text = str(int(animal_products.get("egg", 0)))
	if _blue_egg_label != null:
		_blue_egg_label.text = str(int(animal_products.get("blue_egg", 0)))
	if _milk_label != null:
		_milk_label.text = str(int(animal_products.get("milk", 0)))
	if _wool_label != null:
		_wool_label.text = str(int(animal_products.get("wool", 0)))
	if _truffle_label != null:
		_truffle_label.text = str(int(animal_products.get("truffle", 0)))

	if _basket_extra_label != null:
		var f_cnt := _sum_dict(fish_dict)
		var a_cnt := _sum_dict(artisan_dict)
		var gold_cnt := _sum_dict(gold_items)
		var basket_val := int(gs.call("get_total_basket_value")) if gs != null and gs.has_method("get_total_basket_value") else 0
		var star_part := " · %d★" % gold_cnt if gold_cnt > 0 else ""
		_basket_extra_label.text = "| P:%d A:%d ($%d)%s" % [f_cnt, a_cnt, basket_val, star_part]

	var slots := _get_hotbar_slots()
	for i in range(mini(slots.size(), _slot_counts.size())):
		var slot_data: Dictionary = slots[i]
		var s_type: String = str(slot_data.get("type", ""))
		var s_id: String = str(slot_data.get("id", ""))
		if s_type == "seed":
			var crop_id := str(slot_data.get("crop_id", ""))
			var qty := int(seeds.get(crop_id, 0))
			_slot_counts[i].visible = true
			_slot_counts[i].text = str(qty)
			_slot_counts[i].add_theme_color_override(
				"font_color",
				Color(1.0, 0.80, 0.76) if qty <= 0 else Color.WHITE
			)
			_slot_icons[i].modulate.a = 0.55 if qty <= 0 else 1.0
		elif s_type == "supply":
			var sup_id := str(slot_data.get("supply_id", ""))
			var qty_s := int(supplies.get(sup_id, 0))
			_slot_counts[i].visible = true
			_slot_counts[i].text = str(qty_s)
			_slot_counts[i].add_theme_color_override(
				"font_color",
				Color(1.0, 0.80, 0.76) if qty_s <= 0 else Color.WHITE
			)
			_slot_icons[i].modulate.a = 0.55 if qty_s <= 0 else 1.0
		elif s_id == "hoe" and gs != null:
			var lvl_h := int(gs.get("hoe_level"))
			_slot_counts[i].visible = lvl_h > 1
			_slot_counts[i].text = "N%d" % lvl_h
			_slot_counts[i].add_theme_color_override("font_color", COL_GOLD_BORDER)
			_slot_icons[i].modulate.a = 1.0
		elif s_id == "watering_can" and gs != null:
			var lvl_c := int(gs.get("can_level"))
			_slot_counts[i].visible = lvl_c > 1
			_slot_counts[i].text = "N%d" % lvl_c
			_slot_counts[i].add_theme_color_override("font_color", COL_GOLD_BORDER)
			_slot_icons[i].modulate.a = 1.0
		else:
			_slot_counts[i].visible = false
			_slot_icons[i].modulate.a = 1.0

	var selected: int = int(gs.selected_slot) if gs != null else 0
	_update_active_item_label(selected)
	_refresh_journal_button()
	if _shop_open:
		_refresh_shop()
	if _journal_open:
		_refresh_journal()


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
	_refresh_menu_buttons()


func _on_music_button_pressed() -> void:
	var audio := _get_audio_manager()
	if audio != null and audio.has_method("toggle_music_mute"):
		audio.call("toggle_music_mute")
	_refresh_menu_buttons()


func _on_touch_mode_button_pressed() -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("set_touch_mode"):
		var cur: String = str(gs.get("touch_mode"))
		var nxt: String = "on" if cur == "auto" else ("off" if cur == "on" else "auto")
		gs.call("set_touch_mode", nxt)


func _on_menu_speed_cycle_pressed() -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("set_time_speed_multiplier"):
		var cur: float = float(gs.get("time_speed_multiplier"))
		var nxt: float = 1.0 if cur < 0.8 else (1.5 if cur < 1.25 else 0.5)
		gs.call("set_time_speed_multiplier", nxt)
	_refresh_menu_buttons()
	if _journal_open:
		_refresh_journal()


func _on_mute_changed(_is_muted: bool) -> void:
	_refresh_sound_button()
	_refresh_menu_buttons()


func _on_music_mute_changed(_is_muted: bool) -> void:
	_refresh_menu_buttons()


func _on_auto_button_pressed() -> void:
	_play_click()
	var parent := get_parent()
	if parent != null and parent.has_method("toggle_demo_mode"):
		parent.call("toggle_demo_mode")
	_refresh_auto_button()


func _on_demo_mode_changed(active: bool) -> void:
	if active:
		close_all_modals()
	_apply_auto_button_state(active)


func _on_shop_button_pressed() -> void:
	_play_click()
	toggle_shop()


func _on_journal_button_pressed() -> void:
	_play_click()
	toggle_journal()


func _on_shop_tab_pressed(tab_id: String) -> void:
	_play_click()
	_shop_tab = tab_id
	_refresh_shop()


func _on_journal_tab_pressed(tab_idx: int) -> void:
	_play_click()
	_journal_tab = tab_idx
	_refresh_journal()


func _on_close_shop_pressed() -> void:
	_play_click()
	_set_shop_open(false)


func _on_menu_button_pressed() -> void:
	_play_click()
	toggle_menu()


func _on_close_menu_pressed() -> void:
	_play_click()
	_set_menu_open(false)


func _on_menu_reset_pressed() -> void:
	_play_click()
	if _menu_reset_confirm_box != null:
		_menu_reset_confirm_box.visible = not _menu_reset_confirm_box.visible


func _on_cancel_reset_pressed() -> void:
	_play_click()
	if _menu_reset_confirm_box != null:
		_menu_reset_confirm_box.visible = false


func _on_confirm_reset_pressed() -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("reset_save"):
		gs.call("reset_save")
	_set_menu_open(false)


func _on_version_button_pressed() -> void:
	_play_click()
	toggle_changelog()


func _on_close_changelog_pressed() -> void:
	_play_click()
	_set_changelog_open(false)


func _open_external_url(url: String, toast_text: String) -> void:
	_play_click()
	_emit_toast(toast_text)
	if _open_external_links and not url.is_empty():
		OS.shell_open(url)


func _on_open_releases_pressed() -> void:
	_open_external_url(_releases_url, "Abrindo Releases no GitHub...")


func _on_open_issues_pressed() -> void:
	_open_external_url(_issues_url, "Abrindo Issues no GitHub...")


func _on_sleep_button_pressed() -> void:
	_play_click()
	close_all_modals()
	var gs := _get_game_state()
	if gs != null:
		gs.advance_day()


func _on_buy_seed_pressed(crop_id: String, qty: int) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null:
		gs.buy_seed(crop_id, qty)


func _on_buy_upgrade_pressed(upgrade_id: String) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("buy_upgrade"):
		gs.call("buy_upgrade", upgrade_id)


func _on_buy_supply_pressed(supply_id: String, qty: int) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("buy_supply"):
		gs.call("buy_supply", supply_id, qty)


func _on_buy_sprinkler_pressed() -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("buy_sprinkler"):
		gs.call("buy_sprinkler", 1)


func _on_buy_animal_pressed(animal_type: String) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("buy_animal"):
		gs.call("buy_animal", animal_type)


func _on_buy_machine_pressed(machine_id: String) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("buy_machine"):
		gs.call("buy_machine", machine_id)


func _on_deliver_order_pressed(order_idx: int) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("deliver_order"):
		gs.call("deliver_order", order_idx)


func _on_speed_pressed(speed_val: float) -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null and gs.has_method("set_time_speed_multiplier"):
		gs.call("set_time_speed_multiplier", speed_val)
	_refresh_journal()
	_refresh_menu_buttons()


func _on_sell_all_pressed() -> void:
	_play_click()
	var gs := _get_game_state()
	if gs != null:
		gs.sell_all_harvested()


func _on_touch_dir_down(dir: Vector2) -> void:
	_touch_dir_active = dir
	var parent := get_parent()
	if parent != null and parent.has_method("set_touch_move_dir"):
		parent.call("set_touch_move_dir", dir)


func _on_touch_dir_up() -> void:
	if _touch_dir_active == Vector2.ZERO:
		return
	_touch_dir_active = Vector2.ZERO
	var parent := get_parent()
	if parent != null and parent.has_method("set_touch_move_dir"):
		parent.call("set_touch_move_dir", Vector2.ZERO)


func _on_touch_use_pressed() -> void:
	var parent := get_parent()
	if parent != null and parent.has_method("trigger_touch_use"):
		parent.call("trigger_touch_use")


func _on_touch_interact_pressed() -> void:
	var parent := get_parent()
	if parent != null and parent.has_method("trigger_touch_interact"):
		parent.call("trigger_touch_interact")


# --- Refresh helpers ---

func _refresh_sound_button() -> void:
	if _sound_button == null:
		return
	var audio := _get_audio_manager()
	var is_muted: bool = bool(audio.get("muted")) if audio != null and audio.get("muted") != null else false
	_sound_button.text = "Som: OFF" if is_muted else "Som: ON"


func _refresh_menu_buttons() -> void:
	var audio := _get_audio_manager()
	var is_muted: bool = bool(audio.get("muted")) if audio != null and audio.get("muted") != null else false
	var is_bgm_muted: bool = bool(audio.get("music_muted")) if audio != null and audio.get("music_muted") != null else false
	if _menu_sfx_btn != null:
		_menu_sfx_btn.text = "Efeitos Sonoros (SFX): %s" % ("OFF" if is_muted else "ON")
	if _menu_music_btn != null:
		_menu_music_btn.text = "Música de Fundo: %s" % ("OFF" if is_bgm_muted else "ON")

	var gs := _get_game_state()
	var t_mode: String = str(gs.get("touch_mode")) if gs != null and gs.get("touch_mode") != null else "auto"
	if _menu_touch_btn != null:
		var lbl := "Auto" if t_mode == "auto" else ("Sempre ON" if t_mode == "on" else "OFF")
		_menu_touch_btn.text = "Controles Touch: %s" % lbl

	if _menu_speed_btn != null:
		var spd: float = float(gs.get("time_speed_multiplier")) if gs != null and gs.get("time_speed_multiplier") != null else 1.0
		var spd_lbl := "Lento (0.5x)" if spd < 0.8 else ("Rápido (1.5x)" if spd > 1.25 else "Normal (1x)")
		_menu_speed_btn.text = "Velocidade do Dia: %s" % spd_lbl


func _refresh_touch_controls() -> void:
	if _touch_layer == null:
		return
	var gs := _get_game_state()
	var t_mode: String = str(gs.get("touch_mode")) if gs != null and gs.get("touch_mode") != null else "auto"
	if t_mode == "on":
		_touch_layer.visible = true
	elif t_mode == "off":
		_touch_layer.visible = false
		_on_touch_dir_up()
	else:
		_touch_layer.visible = DisplayServer.is_touchscreen_available() or _touch_seen


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


func _refresh_journal_button() -> void:
	if _journal_button == null:
		return
	var gs := _get_game_state()
	var has_ready: bool = gs != null and gs.has_method("has_deliverable_order") and bool(gs.call("has_deliverable_order"))
	if has_ready:
		_journal_button.text = "Diário !"
		_apply_button_theme(_journal_button, Color("#e8b848"), Color("#ffd066"), Color("#c99932"), COL_GOLD_BORDER, COL_INK)
	else:
		_journal_button.text = "Diário (J)"
		_apply_button_theme(_journal_button, Color("#d8b982"), Color("#ebd09d"), Color("#bd9b63"), COL_WOOD_BORDER, COL_INK)


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
	var s_type: String = str(slot_data.get("type", ""))
	var s_id: String = str(slot_data.get("id", ""))
	var gs := _get_game_state()
	if s_type == "seed" and gs != null:
		var crop_id := str(slot_data.get("crop_id", ""))
		var qty := int(gs.seeds.get(crop_id, 0))
		_active_item_label.text = "%s (%d)" % [item_name, qty]
	elif s_type == "supply" and gs != null:
		var sup_id := str(slot_data.get("supply_id", ""))
		var qty_s := int(gs.supplies.get(sup_id, 0))
		_active_item_label.text = "%s (%d)" % [item_name, qty_s]
	elif s_id == "hoe" and gs != null:
		var lvl := int(gs.get("hoe_level"))
		var mode := str(gs.call("get_tool_reach_mode", "hoe"))
		_active_item_label.text = "%s (Nv.%d · %s)" % [item_name, lvl, mode]
	elif s_id == "watering_can" and gs != null:
		var lvl := int(gs.get("can_level"))
		var mode := str(gs.call("get_tool_reach_mode", "watering_can"))
		_active_item_label.text = "%s (Nv.%d · %s)" % [item_name, lvl, mode]
	else:
		_active_item_label.text = item_name


func _clear_children(container: Node) -> void:
	if container == null:
		return
	for child in container.get_children():
		child.queue_free()


func _style_tab_buttons(buttons: Array[Button], active_idx: int) -> void:
	for i in range(buttons.size()):
		if i == active_idx:
			_apply_button_theme(buttons[i], Color("#5a9640"), Color("#6eb050"), Color("#487a32"), COL_GOLD_BORDER, Color.WHITE)
		else:
			_apply_button_theme(buttons[i], Color("#d8b982"), Color("#ebd09d"), Color("#bd9b63"), COL_WOOD_BORDER, COL_INK)


func _refresh_shop() -> void:
	if _shop_panel == null:
		return
	var gs := _get_game_state()
	var crops := _get_crops()
	var seeds: Dictionary = gs.get("seeds") if gs != null and gs.get("seeds") != null else {}
	var supplies: Dictionary = gs.get("supplies") if gs != null and gs.get("supplies") != null else {}
	var money: int = int(gs.get("money")) if gs != null and gs.get("money") != null else 100

	if _shop_money_label != null:
		_shop_money_label.text = "$%d" % money

	if _shop_seeds_grid != null:
		_shop_seeds_grid.visible = (_shop_tab == "seeds")
	if _shop_upgrades_vbox != null:
		_shop_upgrades_vbox.visible = (_shop_tab == "upgrades")
	if _shop_farm_scroll != null:
		_shop_farm_scroll.visible = (_shop_tab == "farm")

	if _shop_tab_seeds_btn != null:
		_apply_tab_style(_shop_tab_seeds_btn, _shop_tab == "seeds")
	if _shop_tab_upgrades_btn != null:
		_apply_tab_style(_shop_tab_upgrades_btn, _shop_tab == "upgrades")
	if _shop_tab_farm_btn != null:
		_apply_tab_style(_shop_tab_farm_btn, _shop_tab == "farm")

	for crop_id in CROP_ORDER:
		var crop: Dictionary = crops.get(crop_id, {})
		var days := int(crop.get("days_to_grow", 2))
		var regrow := int(crop.get("regrow_days", 0))
		var sell_price := int(crop.get("sell_price", 25))
		var seed_price := int(crop.get("seed_price", 10))
		var owned := int(seeds.get(crop_id, 0))

		if _shop_crop_info_labels.has(crop_id):
			var info_lbl: Label = _shop_crop_info_labels[crop_id]
			var reb_txt := " Reb%dd" % regrow if regrow > 0 else ""
			info_lbl.text = "%dd%s | $%d | Est:%d" % [days, reb_txt, sell_price, owned]

		if _shop_buy_buttons.has(crop_id):
			var btn: Button = _shop_buy_buttons[crop_id]
			btn.text = "1x $%d" % seed_price

	# Refresh Upgrades tab
	if gs != null and gs.has_method("get_upgrade_level") and gs.has_method("get_upgrade_cost"):
		var defs: Dictionary = gs.UPGRADE_DEFS
		for uid in ["hoe", "can", "stamina"]:
			var def: Dictionary = defs.get(uid, {})
			var lvl: int = int(gs.call("get_upgrade_level", uid))
			var max_lvl: int = int(def.get("max_level", 3))
			var cost: int = int(gs.call("get_upgrade_cost", uid))
			var descs: Array = def.get("descriptions", [])
			var cur_desc: String = str(descs[clampi(lvl - 1, 0, descs.size() - 1)]) if not descs.is_empty() else ""
			var nxt_desc: String = str(descs[clampi(lvl, 0, descs.size() - 1)]) if lvl < max_lvl and not descs.is_empty() else "Nível Máximo"

			if _shop_upgrade_title_labels.has(uid):
				(_shop_upgrade_title_labels[uid] as Label).text = "%s (Nv. %d/%d)" % [str(def.get("name", uid)), lvl, max_lvl]
			if _shop_upgrade_desc_labels.has(uid):
				var desc_text := "%s → Próx: %s" % [cur_desc, nxt_desc] if lvl < max_lvl else "%s (MAX)" % cur_desc
				(_shop_upgrade_desc_labels[uid] as Label).text = desc_text
			if _shop_upgrade_buttons.has(uid):
				var u_btn: Button = _shop_upgrade_buttons[uid]
				if cost < 0:
					u_btn.text = "MAX"
					u_btn.disabled = true
				else:
					u_btn.text = "Melhorar ($%d)" % cost
					u_btn.disabled = false

	var fert_owned: int = int(supplies.get("fertilizer", 0))
	if _shop_fertilizer_desc_label != null:
		_shop_fertilizer_desc_label.text = "Aumenta chance de colheita ★ | Estoque: %d" % fert_owned

	var sp_owned: int = int(supplies.get("sprinkler", 0))
	if _shop_sprinkler_desc_label != null:
		_shop_sprinkler_desc_label.text = "Rega 3x3 toda manhã | Estoque: %d" % sp_owned

	# Refresh Farm tab (Animals + Machines)
	if _shop_tab == "farm" and _shop_farm_vbox != null:
		_clear_children(_shop_farm_vbox)
		var cur_animals: int = int(gs.get("animal_count")) if gs != null else 5
		_shop_farm_vbox.add_child(_make_label("Animais do Cercado (%d/%d)" % [cur_animals, FarmCatalogScript.MAX_FARM_ANIMALS], 8, COL_WOOD_DARK))
		for a_type in FarmCatalogScript.ANIMAL_SHOP_ORDER:
			var a_def: Dictionary = FarmCatalogScript.ANIMAL_SHOP[a_type]
			var full := cur_animals >= FarmCatalogScript.MAX_FARM_ANIMALS
			_add_shop_farm_row(
				str(a_def["icon_sheet"]),
				int(a_def["icon_col"]),
				str(a_def["name"]),
				str(a_def["desc"]),
				"Lotado" if full else "Comprar ($%d)" % int(a_def["buy_price"]),
				full,
				Callable(self, "_on_buy_animal_pressed").bind(a_type)
			)

		_shop_farm_vbox.add_child(_make_separator())
		_shop_farm_vbox.add_child(_make_label("Máquinas Artesanais", 8, COL_WOOD_DARK))
		var owned_m: Dictionary = gs.get("owned_machines") if gs != null else {}
		for m_id in FarmCatalogScript.MACHINE_ORDER:
			var m_def: Dictionary = FarmCatalogScript.MACHINES[m_id]
			var has_it := bool(owned_m.get(m_id, false))
			_add_shop_farm_row(
				str(m_def["icon_sheet"]),
				int(m_def["icon_col"]),
				str(m_def["name"]),
				str(m_def["desc"]),
				"Instalada ✓" if has_it else "Instalar ($%d)" % int(m_def["buy_price"]),
				has_it,
				Callable(self, "_on_buy_machine_pressed").bind(m_id)
			)

	if _shop_harvest_label != null:
		var total_items := 0
		var total_value := 0
		if gs != null and gs.has_method("get_total_basket_count") and gs.has_method("get_total_basket_value"):
			total_items = int(gs.call("get_total_basket_count"))
			total_value = int(gs.call("get_total_basket_value"))
		var gold_dict: Dictionary = gs.get("gold_items") if gs != null and gs.get("gold_items") is Dictionary else {}
		var gold_cnt := _sum_dict(gold_dict)
		var star_part := " · %d★" % gold_cnt if gold_cnt > 0 else ""
		_shop_harvest_label.text = "Cesta: %d itens ($%d)%s" % [total_items, total_value, star_part]


func _add_shop_farm_row(
	icon_sheet: String,
	icon_col: int,
	title_txt: String,
	sub_txt: String,
	btn_txt: String,
	disabled: bool,
	on_press: Callable
) -> void:
	var row_panel := PanelContainer.new()
	row_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#b89563"), 1, 6, 3, 2))
	_shop_farm_vbox.add_child(row_panel)

	var row_hbox := HBoxContainer.new()
	row_hbox.add_theme_constant_override("separation", 6)
	row_panel.add_child(row_hbox)

	var icon_rect := _make_icon_rect(icon_sheet, icon_col, Vector2(16, 16))
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row_hbox.add_child(icon_rect)

	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 0)
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_hbox.add_child(info_vbox)

	info_vbox.add_child(_make_label(title_txt, 8, COL_INK))
	info_vbox.add_child(_make_label(sub_txt, 7, COL_INK_MUTED))

	var btn := _make_wood_button(btn_txt, Vector2(88, 19), 7)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.disabled = disabled
	if not disabled and on_press.is_valid():
		btn.pressed.connect(on_press)
	row_hbox.add_child(btn)


func _refresh_journal() -> void:
	if _journal_panel == null or _journal_content_vbox == null:
		return
	_style_tab_buttons(_journal_tab_buttons, _journal_tab)
	_clear_children(_journal_content_vbox)

	var gs := _get_game_state()
	if gs == null:
		return

	if _journal_tab == 0:
		var orders: Array = gs.get("daily_orders")
		if orders.is_empty():
			_journal_content_vbox.add_child(_make_label("Sem encomendas hoje.", 8, COL_INK))
			return
		for i in range(orders.size()):
			var ord: Dictionary = orders[i]
			var item_id := str(ord.get("item_id", ""))
			var qty := int(ord.get("qty", 1))
			var reward := int(ord.get("reward", 50))
			var done := bool(ord.get("completed", false))
			var owned := int(gs.call("get_item_count", item_id))
			var info := FarmCatalogScript.get_item_info(item_id, gs.CROPS)
			var can_deliver := bool(gs.call("can_deliver_order", i))

			var row_panel := PanelContainer.new()
			row_panel.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#b89563"), 1, 6, 4, 2))
			_journal_content_vbox.add_child(row_panel)

			var hbox := HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 6)
			row_panel.add_child(hbox)

			hbox.add_child(_make_icon_rect(str(info.get("icon_sheet", "base")), int(info.get("icon_col", 2)), Vector2(16, 16)))

			var txt_vbox := VBoxContainer.new()
			txt_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			txt_vbox.add_theme_constant_override("separation", 1)
			hbox.add_child(txt_vbox)
			txt_vbox.add_child(_make_label("%dx %s -> Recompensa: $%d" % [qty, str(ord.get("name", item_id)), reward], 8, COL_INK))
			txt_vbox.add_child(_make_label("No estoque: %d / %d" % [owned, qty], 7, COL_GOLD_TEXT if can_deliver else COL_INK_MUTED))

			var btn_txt := "Entregue ✓" if done else "Entregar"
			var d_btn := _make_colored_button(
				btn_txt,
				Vector2(66, 19),
				7,
				Color("#5a9640") if can_deliver else Color("#b9a888"),
				Color("#6eb050") if can_deliver else Color("#b9a888"),
				Color("#487a32") if can_deliver else Color("#b9a888"),
				Color("#2e4f1e") if can_deliver else Color("#8f7c5c"),
				Color.WHITE if can_deliver else Color("#5c4f3d")
			)
			d_btn.disabled = not can_deliver
			if can_deliver:
				d_btn.pressed.connect(Callable(self, "_on_deliver_order_pressed").bind(i))
			hbox.add_child(d_btn)
	elif _journal_tab == 1:
		var prog: Dictionary = gs.call("get_album_progress")
		_journal_content_vbox.add_child(_make_label("Descobertos: %d / %d itens da Fazenda" % [int(prog["found"]), int(prog["total"])], 8, COL_WOOD_DARK))

		var discovered: Dictionary = gs.get("album_discovered")
		for group_id in ["crops", "fish", "artisan"]:
			var grp: Dictionary = FarmCatalogScript.ALBUM_GROUPS[group_id]
			var unlocked := bool(gs.call("has_album_bonus", group_id))
			var card := PanelContainer.new()
			card.add_theme_stylebox_override("panel", _make_flat_style(COL_PARCHMENT_ALT, Color("#9c6c2e") if unlocked else Color("#b89563"), 1, 5, 3, 2))
			_journal_content_vbox.add_child(card)

			var g_vbox := VBoxContainer.new()
			g_vbox.add_theme_constant_override("separation", 3)
			card.add_child(g_vbox)

			var status_txt := "ATIVO ✓" if unlocked else "Em progresso"
			var grp_lbl := _make_label("%s — %s (%s)" % [str(grp["title"]), str(grp["bonus_desc"]), status_txt], 7, COL_GOLD_TEXT if unlocked else COL_INK)
			grp_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			grp_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			g_vbox.add_child(grp_lbl)

			var items_row := HBoxContainer.new()
			items_row.add_theme_constant_override("separation", 4)
			g_vbox.add_child(items_row)

			for item_id_var in grp["items"]:
				var item_id := str(item_id_var)
				var is_found := bool(discovered.get(item_id, false))
				var info := FarmCatalogScript.get_item_info(item_id, gs.CROPS)
				var chip := PanelContainer.new()
				chip.custom_minimum_size = Vector2(22, 22)
				chip.tooltip_text = str(info.get("name", item_id)) if is_found else "???"
				chip.add_theme_stylebox_override("panel", _make_flat_style(Color("#fff4cf") if is_found else Color("#cfc1a3"), COL_WOOD_SOFT, 1, 2, 2, 1))
				var ic := _make_icon_rect(str(info.get("icon_sheet", "base")), int(info.get("icon_col", 2)), Vector2(16, 16))
				if not is_found:
					ic.modulate = Color(0.25, 0.20, 0.16, 0.35)
				chip.add_child(ic)
				items_row.add_child(chip)
	else:
		_journal_content_vbox.add_child(_make_label("Velocidade do Relógio do Dia", 8, COL_WOOD_DARK))
		var speed_row := HBoxContainer.new()
		speed_row.add_theme_constant_override("separation", 5)
		_journal_content_vbox.add_child(speed_row)

		var cur_speed: float = float(gs.get("time_speed_multiplier"))
		for spec in [{"lbl": "Lento (0.5x)", "val": 0.5}, {"lbl": "Normal (1x)", "val": 1.0}, {"lbl": "Rápido (1.5x)", "val": 1.5}]:
			var val: float = float(spec["val"])
			var is_cur := absf(cur_speed - val) < 0.05
			var s_btn := _make_wood_button(str(spec["lbl"]), Vector2(82, 19), 7)
			if is_cur:
				_apply_button_theme(s_btn, Color("#5a9640"), Color("#6eb050"), Color("#487a32"), COL_GOLD_BORDER, Color.WHITE)
			s_btn.pressed.connect(Callable(self, "_on_speed_pressed").bind(val))
			speed_row.add_child(s_btn)

		_journal_content_vbox.add_child(_make_separator())
		_journal_content_vbox.add_child(_make_label("Dicas rápidas da v1.4.0:", 8, COL_WOOD_DARK))
		for tip_txt in [
			"• Morango, Milho e Tomate rebrotam após a colheita sem gastar semente!",
			"• Use Fertilizante (slot 0) para aumentar chance de colheita Ouro ★ (1.5x).",
			"• Use a Vara de Pesca (slot 3) na beira do lago para pescar 4 espécies.",
			"• Carinho diário nos animais aumenta chance de Ovo Azul e itens Ouro ★.",
		]:
			var tip_lbl := _make_label(tip_txt, 7, COL_INK)
			tip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			tip_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_journal_content_vbox.add_child(tip_lbl)


func _apply_tab_style(btn: Button, active: bool) -> void:
	if active:
		_apply_button_theme(btn, Color("#5a9640"), Color("#6eb050"), Color("#487a32"), COL_GOLD_BORDER, Color.WHITE)
	else:
		_apply_button_theme(btn, Color("#d8b982"), Color("#ebd09d"), Color("#bd9b63"), COL_WOOD_BORDER, COL_INK)


# --- Style & widget factory helpers ---

func _make_icon_texture(sheet_name: String, col: int) -> Texture2D:
	var tex := _v13_icons_texture if sheet_name == "v13" else _icons_texture
	var max_cols := _v13_icons_cols if sheet_name == "v13" else _icons_cols
	if tex == null or col < 0 or col >= max_cols:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(col * 16, 0, 16, 16)
	return atlas


func _make_icon_rect(sheet_name: String, col: int, min_size: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = min_size
	rect.texture = _make_icon_texture(sheet_name, col)
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
	btn.add_theme_color_override("font_disabled_color", Color(0.32, 0.25, 0.18, 0.85))
	btn.add_theme_stylebox_override("normal", _make_flat_style(normal_col, border_col, 1, 3, 2, 2))
	btn.add_theme_stylebox_override("hover", _make_flat_style(hover_col, border_col, 1, 3, 2, 2))
	btn.add_theme_stylebox_override("pressed", _make_flat_style(pressed_col, border_col, 1, 3, 2, 2))
	btn.add_theme_stylebox_override("disabled", _make_flat_style(Color(0.76, 0.70, 0.56, 0.85), Color("#8c7352"), 1, 3, 2, 2))


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line := StyleBoxLine.new()
	line.color = Color("#b89563")
	line.thickness = 1
	sep.add_theme_stylebox_override("separator", line)
	return sep
