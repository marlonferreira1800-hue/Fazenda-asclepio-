extends Node
## Autoload global de estado de jogo, inventário, economia, persistência e relógio diário.

const CropDataScript := preload("res://scripts/data/crop_data.gd")

signal money_changed(new_money: int)
signal day_changed(day: int, time_minutes: float)
signal inventory_changed()
signal tool_changed(slot_index: int)
signal stamina_changed(stamina: int, max_stamina: int)
signal water_changed(water: int, max_water: int)
signal toast_message(text: String)
signal day_advanced(new_day: int)
signal upgrades_changed()
signal weather_changed(weather: String, tomorrow_weather: String)
signal touch_mode_changed(mode: String)
signal game_reset()

const SAVE_PATH := "user://savegame.json"
const MINUTES_PER_DAY: float = 1440.0
const START_OF_DAY_MINUTES: float = 360.0
const TIME_SCALE_MINUTES_PER_SECOND: float = 4.0

const WEATHER_SUNNY := "sunny"
const WEATHER_RAINY := "rainy"
const SPRINKLER_PRICE: int = 180

const HOTBAR_SLOTS: Array[Dictionary] = [
	{"id": "hoe", "name": "Enxada", "type": "tool", "icon_col": 0},
	{"id": "watering_can", "name": "Regador", "type": "tool", "icon_col": 1},
	{"id": "wheat_seed", "name": "Sem. Trigo", "type": "seed", "crop_id": "wheat", "icon_col": 2},
	{"id": "carrot_seed", "name": "Sem. Cenoura", "type": "seed", "crop_id": "carrot", "icon_col": 3},
	{"id": "strawberry_seed", "name": "Sem. Morango", "type": "seed", "crop_id": "strawberry", "icon_col": 4},
	{"id": "corn_seed", "name": "Sem. Milho", "type": "seed", "crop_id": "corn", "icon_col": 8},
	{"id": "tomato_seed", "name": "Sem. Tomate", "type": "seed", "crop_id": "tomato", "icon_col": 9},
	{"id": "pumpkin_seed", "name": "Sem. Abóbora", "type": "seed", "crop_id": "pumpkin", "icon_col": 10},
	{"id": "sprinkler", "name": "Aspersor", "type": "placeable", "icon_col": 11},
]

const ANIMAL_PRODUCTS: Dictionary = {
	"egg": {"name": "Ovo", "sell_price": 30},
	"milk": {"name": "Leite", "sell_price": 45},
	"wool": {"name": "Lã", "sell_price": 60},
	"truffle": {"name": "Trufa", "sell_price": 80},
}

const UPGRADE_DEFS: Dictionary = {
	"hoe": {
		"name": "Enxada",
		"max_level": 3,
		"costs": [150, 350],
		"descriptions": ["Ara 1x1", "Ara 3x1 em linha", "Ara 3x3 em área"],
	},
	"can": {
		"name": "Regador",
		"max_level": 3,
		"costs": [150, 350],
		"descriptions": ["20 água (1x1)", "40 água (3x1)", "60 água (3x3)"],
	},
	"stamina": {
		"name": "Resistência",
		"max_level": 3,
		"costs": [120, 280],
		"descriptions": ["100 Energia", "140 Energia", "180 Energia"],
	},
}

var CROPS: Dictionary = CropDataScript.get_all_definitions()

var money: int = 100
var day: int = 1
var time_minutes: float = START_OF_DAY_MINUTES
var time_paused: bool = false
var stamina: int = 100
var max_stamina: int = 100
var water_level: int = 20
var max_water: int = 20
var selected_slot: int = 0

var hoe_level: int = 1
var can_level: int = 1
var stamina_level: int = 1
var sprinklers_owned: int = 0

var weather: String = WEATHER_SUNNY
var tomorrow_weather: String = WEATHER_SUNNY
var touch_mode: String = "auto"

var seeds: Dictionary = {
	"wheat": 6,
	"carrot": 4,
	"strawberry": 2,
	"corn": 0,
	"tomato": 0,
	"pumpkin": 0,
}
var harvested: Dictionary = {
	"wheat": 0,
	"carrot": 0,
	"strawberry": 0,
	"corn": 0,
	"tomato": 0,
	"pumpkin": 0,
}
var animal_products: Dictionary = {
	"egg": 0,
	"milk": 0,
	"wool": 0,
	"truffle": 0,
}

var auto_save_enabled: bool = true

var _last_emitted_minute: int = int(START_OF_DAY_MINUTES)
var _world_state_provider: Callable = Callable()
var _pending_world_save: Dictionary = {}
var _weather_rng := RandomNumberGenerator.new()


func _ready() -> void:
	_weather_rng.randomize()
	load_game()


func _process(delta: float) -> void:
	tick_time(delta)


func _get_audio() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/AudioManager")


func _sync_caps_from_levels() -> void:
	var stamina_caps := [100, 140, 180]
	var water_caps := [20, 40, 60]
	max_stamina = stamina_caps[clampi(stamina_level - 1, 0, stamina_caps.size() - 1)]
	max_water = water_caps[clampi(can_level - 1, 0, water_caps.size() - 1)]


func tick_time(delta: float) -> void:
	if time_paused or delta <= 0.0:
		return
	time_minutes += delta * TIME_SCALE_MINUTES_PER_SECOND
	if time_minutes >= MINUTES_PER_DAY:
		advance_day()
		return
	var current_minute: int = int(floor(time_minutes))
	if current_minute != _last_emitted_minute:
		_last_emitted_minute = current_minute
		day_changed.emit(day, time_minutes)


func select_slot(idx: int) -> void:
	if idx < 0 or idx >= HOTBAR_SLOTS.size():
		return
	selected_slot = idx
	tool_changed.emit(selected_slot)


func get_selected_slot() -> Dictionary:
	if selected_slot >= 0 and selected_slot < HOTBAR_SLOTS.size():
		return HOTBAR_SLOTS[selected_slot]
	return HOTBAR_SLOTS[0]


func buy_seed(crop_id: String, qty: int = 1) -> bool:
	if qty <= 0 or not CROPS.has(crop_id):
		return false
	var crop: Dictionary = CROPS[crop_id]
	var cost: int = int(crop["seed_price"]) * qty
	var audio := _get_audio()
	if money < cost:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Moedas insuficientes! Precisa de $%d." % cost)
		return false
	money -= cost
	seeds[crop_id] = int(seeds.get(crop_id, 0)) + qty
	money_changed.emit(money)
	inventory_changed.emit()
	if audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	emit_toast("Comprou %dx Semente de %s (-$%d)" % [qty, str(crop["name"]), cost])
	if auto_save_enabled:
		save_game(false)
	return true


func get_upgrade_level(upgrade_id: String) -> int:
	match upgrade_id:
		"hoe":
			return hoe_level
		"can":
			return can_level
		"stamina":
			return stamina_level
	return 1


func get_upgrade_cost(upgrade_id: String) -> int:
	if not UPGRADE_DEFS.has(upgrade_id):
		return -1
	var def: Dictionary = UPGRADE_DEFS[upgrade_id]
	var lvl: int = get_upgrade_level(upgrade_id)
	var max_lvl: int = int(def["max_level"])
	if lvl >= max_lvl:
		return -1
	var costs: Array = def["costs"]
	var idx: int = lvl - 1
	if idx < 0 or idx >= costs.size():
		return -1
	return int(costs[idx])


func buy_upgrade(upgrade_id: String) -> bool:
	if not UPGRADE_DEFS.has(upgrade_id):
		return false
	var cost: int = get_upgrade_cost(upgrade_id)
	var audio := _get_audio()
	if cost < 0:
		emit_toast("Upgrade já está no nível máximo!")
		return false
	if money < cost:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Moedas insuficientes! Precisa de $%d." % cost)
		return false

	money -= cost
	match upgrade_id:
		"hoe":
			hoe_level = mini(3, hoe_level + 1)
		"can":
			can_level = mini(3, can_level + 1)
			_sync_caps_from_levels()
			water_level = max_water
			water_changed.emit(water_level, max_water)
		"stamina":
			stamina_level = mini(3, stamina_level + 1)
			_sync_caps_from_levels()
			stamina = max_stamina
			stamina_changed.emit(stamina, max_stamina)

	_sync_caps_from_levels()
	money_changed.emit(money)
	upgrades_changed.emit()
	if audio != null and audio.has_method("play_upgrade"):
		audio.play_upgrade()
	elif audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	var def: Dictionary = UPGRADE_DEFS[upgrade_id]
	var new_lvl: int = get_upgrade_level(upgrade_id)
	emit_toast("%s evoluída para Nv.%d! (-$%d)" % [str(def["name"]), new_lvl, cost])
	if auto_save_enabled:
		save_game(false)
	return true


func buy_sprinkler(qty: int = 1) -> bool:
	if qty <= 0:
		return false
	var cost: int = SPRINKLER_PRICE * qty
	var audio := _get_audio()
	if money < cost:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Moedas insuficientes! Precisa de $%d." % cost)
		return false
	money -= cost
	sprinklers_owned += qty
	money_changed.emit(money)
	inventory_changed.emit()
	if audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	emit_toast("Comprou %dx Aspersor (-$%d)! Selecione o slot 9." % [qty, cost])
	if auto_save_enabled:
		save_game(false)
	return true


func add_sprinkler(qty: int = 1) -> void:
	if qty <= 0:
		return
	sprinklers_owned += qty
	inventory_changed.emit()


func consume_sprinkler_item() -> bool:
	if sprinklers_owned <= 0:
		return false
	sprinklers_owned -= 1
	inventory_changed.emit()
	return true


func add_harvested(crop_id: String, qty: int = 1) -> void:
	if qty <= 0 or not CROPS.has(crop_id):
		return
	harvested[crop_id] = int(harvested.get(crop_id, 0)) + qty
	inventory_changed.emit()


func add_animal_product(product_id: String, qty: int = 1) -> void:
	if qty <= 0 or not ANIMAL_PRODUCTS.has(product_id):
		return
	animal_products[product_id] = int(animal_products.get(product_id, 0)) + qty
	inventory_changed.emit()


func sell_all_harvested() -> int:
	var total_profit: int = 0
	var total_items: int = 0
	for crop_id_var in harvested.keys():
		var crop_id: String = str(crop_id_var)
		var qty: int = int(harvested.get(crop_id, 0))
		if qty > 0 and CROPS.has(crop_id):
			total_profit += qty * int(CROPS[crop_id]["sell_price"])
			total_items += qty
		harvested[crop_id] = 0

	for prod_id_var in animal_products.keys():
		var prod_id: String = str(prod_id_var)
		var qty: int = int(animal_products.get(prod_id, 0))
		if qty > 0 and ANIMAL_PRODUCTS.has(prod_id):
			total_profit += qty * int(ANIMAL_PRODUCTS[prod_id]["sell_price"])
			total_items += qty
		animal_products[prod_id] = 0

	var audio := _get_audio()
	if total_items <= 0:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Cesta vazia! Nada para vender.")
		return 0

	money += total_profit
	money_changed.emit(money)
	inventory_changed.emit()
	if audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	emit_toast("Vendeu %d item(ns) por +$%d!" % [total_items, total_profit])
	if auto_save_enabled:
		save_game(false)
	return total_profit


func refill_water() -> void:
	water_level = max_water
	water_changed.emit(water_level, max_water)
	var audio := _get_audio()
	if audio != null and audio.has_method("play_water"):
		audio.play_water()
	emit_toast("Regador reabastecido! (%d/%d)" % [water_level, max_water])


func consume_stamina(amount: int) -> bool:
	if amount <= 0:
		return true
	if stamina < amount:
		var audio := _get_audio()
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Sem energia! Durma na casinha ou aperte N.")
		return false
	stamina -= amount
	stamina_changed.emit(stamina, max_stamina)
	return true


func use_water(amount: int = 1) -> bool:
	if amount <= 0:
		return true
	if water_level < amount:
		var audio := _get_audio()
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Regador vazio! Encha no lago ou no poço.")
		return false
	water_level -= amount
	water_changed.emit(water_level, max_water)
	return true


func set_weather(today_w: String, next_w: String = "") -> void:
	weather = WEATHER_RAINY if today_w == WEATHER_RAINY else WEATHER_SUNNY
	if not next_w.is_empty():
		tomorrow_weather = WEATHER_RAINY if next_w == WEATHER_RAINY else WEATHER_SUNNY
	weather_changed.emit(weather, tomorrow_weather)


func get_weather_label(w: String = weather) -> String:
	return "Chuva" if w == WEATHER_RAINY else "Sol"


func set_touch_mode(mode: String) -> void:
	if mode not in ["auto", "on", "off"]:
		return
	if touch_mode == mode:
		return
	touch_mode = mode
	touch_mode_changed.emit(touch_mode)
	if auto_save_enabled:
		save_game(false)


func advance_day() -> void:
	day += 1
	time_minutes = START_OF_DAY_MINUTES
	_last_emitted_minute = int(time_minutes)
	stamina = max_stamina

	weather = tomorrow_weather
	var rain_chance: float = 0.14 if weather == WEATHER_RAINY else 0.30
	tomorrow_weather = WEATHER_RAINY if _weather_rng.randf() < rain_chance else WEATHER_SUNNY

	weather_changed.emit(weather, tomorrow_weather)
	day_advanced.emit(day)
	day_changed.emit(day, time_minutes)
	stamina_changed.emit(stamina, max_stamina)
	var audio := _get_audio()
	if audio != null and audio.has_method("play_sleep"):
		audio.play_sleep()
	if weather == WEATHER_RAINY:
		emit_toast("Dia %d começou com chuva! Canteiros regados automaticamente." % day)
	else:
		emit_toast("Bom dia! Dia %d começou — energia restaurada." % day)
	if auto_save_enabled:
		save_game(false)


func emit_toast(msg: String) -> void:
	toast_message.emit(msg)


func get_formatted_time() -> String:
	var total_mins: int = clampi(int(floor(time_minutes)), 0, 1439)
	var hours: int = total_mins / 60
	var mins: int = total_mins % 60
	return "%02d:%02d" % [hours, mins]


func get_total_harvested() -> int:
	var total: int = 0
	for qty_var in harvested.values():
		total += int(qty_var)
	return total


func get_total_basket_count() -> int:
	var total: int = get_total_harvested()
	for qty_var in animal_products.values():
		total += int(qty_var)
	return total


func get_total_basket_value() -> int:
	var total: int = 0
	for crop_id_var in harvested.keys():
		var crop_id: String = str(crop_id_var)
		var qty: int = int(harvested.get(crop_id, 0))
		if qty > 0 and CROPS.has(crop_id):
			total += qty * int(CROPS[crop_id]["sell_price"])
	for prod_id_var in animal_products.keys():
		var prod_id: String = str(prod_id_var)
		var qty: int = int(animal_products.get(prod_id, 0))
		if qty > 0 and ANIMAL_PRODUCTS.has(prod_id):
			total += qty * int(ANIMAL_PRODUCTS[prod_id]["sell_price"])
	return total


func register_world_provider(provider: Callable) -> void:
	_world_state_provider = provider


func consume_pending_world_save() -> Dictionary:
	var copy: Dictionary = _pending_world_save.duplicate(true)
	_pending_world_save.clear()
	return copy


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(show_toast: bool = true) -> bool:
	var world_data: Dictionary = {}
	if _world_state_provider.is_valid():
		var provided = _world_state_provider.call()
		if provided is Dictionary:
			world_data = provided

	var audio := _get_audio()
	var sfx_muted: bool = bool(audio.get("muted")) if audio != null and audio.get("muted") != null else false
	var bgm_muted: bool = bool(audio.get("music_muted")) if audio != null and audio.get("music_muted") != null else false

	var payload: Dictionary = {
		"version": 2,
		"money": money,
		"day": day,
		"time_minutes": time_minutes,
		"stamina": stamina,
		"water_level": water_level,
		"selected_slot": selected_slot,
		"hoe_level": hoe_level,
		"can_level": can_level,
		"stamina_level": stamina_level,
		"sprinklers_owned": sprinklers_owned,
		"weather": weather,
		"tomorrow_weather": tomorrow_weather,
		"touch_mode": touch_mode,
		"muted": sfx_muted,
		"music_muted": bgm_muted,
		"seeds": seeds.duplicate(true),
		"harvested": harvested.duplicate(true),
		"animal_products": animal_products.duplicate(true),
		"world": world_data,
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		if show_toast:
			emit_toast("Erro ao salvar o jogo.")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()

	if show_toast:
		emit_toast("Jogo salvo! (Dia %d)" % day)
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return false
	var data: Dictionary = parsed

	money = maxi(0, int(data.get("money", 100)))
	day = maxi(1, int(data.get("day", 1)))
	time_minutes = clampf(float(data.get("time_minutes", START_OF_DAY_MINUTES)), 0.0, MINUTES_PER_DAY - 1.0)
	_last_emitted_minute = int(floor(time_minutes))

	hoe_level = clampi(int(data.get("hoe_level", 1)), 1, 3)
	can_level = clampi(int(data.get("can_level", 1)), 1, 3)
	stamina_level = clampi(int(data.get("stamina_level", 1)), 1, 3)
	sprinklers_owned = maxi(0, int(data.get("sprinklers_owned", 0)))
	_sync_caps_from_levels()

	stamina = clampi(int(data.get("stamina", max_stamina)), 0, max_stamina)
	water_level = clampi(int(data.get("water_level", max_water)), 0, max_water)
	selected_slot = clampi(int(data.get("selected_slot", 0)), 0, HOTBAR_SLOTS.size() - 1)

	var loaded_weather: String = str(data.get("weather", WEATHER_SUNNY))
	weather = WEATHER_RAINY if loaded_weather == WEATHER_RAINY else WEATHER_SUNNY
	var loaded_tomorrow: String = str(data.get("tomorrow_weather", WEATHER_SUNNY))
	tomorrow_weather = WEATHER_RAINY if loaded_tomorrow == WEATHER_RAINY else WEATHER_SUNNY

	var loaded_touch: String = str(data.get("touch_mode", "auto"))
	if loaded_touch in ["auto", "on", "off"]:
		touch_mode = loaded_touch

	var audio := _get_audio()
	if audio != null:
		if data.has("muted") and audio.has_method("set_muted"):
			audio.call("set_muted", bool(data["muted"]))
		if data.has("music_muted") and audio.has_method("set_music_muted"):
			audio.call("set_music_muted", bool(data["music_muted"]))

	var loaded_seeds = data.get("seeds", {})
	if loaded_seeds is Dictionary:
		for crop_id_var in seeds.keys():
			var crop_id: String = str(crop_id_var)
			if loaded_seeds.has(crop_id):
				seeds[crop_id] = maxi(0, int(loaded_seeds[crop_id]))

	var loaded_harvested = data.get("harvested", {})
	if loaded_harvested is Dictionary:
		for crop_id_var in harvested.keys():
			var crop_id: String = str(crop_id_var)
			if loaded_harvested.has(crop_id):
				harvested[crop_id] = maxi(0, int(loaded_harvested[crop_id]))

	var loaded_animals = data.get("animal_products", {})
	if loaded_animals is Dictionary:
		for prod_id_var in animal_products.keys():
			var prod_id: String = str(prod_id_var)
			if loaded_animals.has(prod_id):
				animal_products[prod_id] = maxi(0, int(loaded_animals[prod_id]))

	var world_dict = data.get("world", {})
	if world_dict is Dictionary:
		_pending_world_save = world_dict.duplicate(true)
	else:
		_pending_world_save = {}

	money_changed.emit(money)
	day_changed.emit(day, time_minutes)
	stamina_changed.emit(stamina, max_stamina)
	water_changed.emit(water_level, max_water)
	tool_changed.emit(selected_slot)
	upgrades_changed.emit()
	weather_changed.emit(weather, tomorrow_weather)
	touch_mode_changed.emit(touch_mode)
	inventory_changed.emit()
	return true


func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	money = 100
	day = 1
	time_minutes = START_OF_DAY_MINUTES
	_last_emitted_minute = int(START_OF_DAY_MINUTES)
	hoe_level = 1
	can_level = 1
	stamina_level = 1
	sprinklers_owned = 0
	_sync_caps_from_levels()
	stamina = max_stamina
	water_level = max_water
	selected_slot = 0
	weather = WEATHER_SUNNY
	tomorrow_weather = WEATHER_SUNNY
	seeds = {
		"wheat": 6,
		"carrot": 4,
		"strawberry": 2,
		"corn": 0,
		"tomato": 0,
		"pumpkin": 0,
	}
	harvested = {
		"wheat": 0,
		"carrot": 0,
		"strawberry": 0,
		"corn": 0,
		"tomato": 0,
		"pumpkin": 0,
	}
	animal_products = {
		"egg": 0,
		"milk": 0,
		"wool": 0,
		"truffle": 0,
	}
	_pending_world_save.clear()

	money_changed.emit(money)
	day_changed.emit(day, time_minutes)
	stamina_changed.emit(stamina, max_stamina)
	water_changed.emit(water_level, max_water)
	tool_changed.emit(selected_slot)
	upgrades_changed.emit()
	weather_changed.emit(weather, tomorrow_weather)
	inventory_changed.emit()
	game_reset.emit()
	emit_toast("Fazenda reiniciada para o Dia 1!")
