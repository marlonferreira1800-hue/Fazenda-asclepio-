class_name CropData
extends Resource
## Definições de cultivos do projeto Fazendinha 2D.
## Culturas "base" correspondem a res://assets/sprites/crops_sheet.png (5x3 de 16x16).
## Culturas "extra" correspondem a res://assets/sprites/crops_extra_sheet.png (5x3 de 16x16).

@export var id: String = ""
@export var crop_name: String = ""
@export var row: int = 0
@export var days_to_grow: int = 2
@export var regrow_days: int = 0
@export var seed_price: int = 10
@export var sell_price: int = 25
@export var sheet_kind: String = "base"

const CROP_ORDER: Array[String] = [
	"wheat",
	"carrot",
	"strawberry",
	"corn",
	"tomato",
	"pumpkin",
]

const DEFINITIONS: Dictionary = {
	"wheat": {
		"id": "wheat",
		"name": "Trigo",
		"row": 0,
		"days_to_grow": 2,
		"regrow_days": 0,
		"seed_price": 10,
		"sell_price": 25,
		"sheet": "base",
		"icon_sheet": "base",
		"icon_col": 2,
	},
	"carrot": {
		"id": "carrot",
		"name": "Cenoura",
		"row": 1,
		"days_to_grow": 3,
		"regrow_days": 0,
		"seed_price": 20,
		"sell_price": 55,
		"sheet": "base",
		"icon_sheet": "base",
		"icon_col": 3,
	},
	"strawberry": {
		"id": "strawberry",
		"name": "Morango",
		"row": 2,
		"days_to_grow": 4,
		"regrow_days": 2,
		"seed_price": 35,
		"sell_price": 110,
		"sheet": "base",
		"icon_sheet": "base",
		"icon_col": 4,
	},
	"corn": {
		"id": "corn",
		"name": "Milho",
		"row": 0,
		"days_to_grow": 4,
		"regrow_days": 2,
		"seed_price": 40,
		"sell_price": 65,
		"sheet": "extra",
		"icon_sheet": "v13",
		"icon_col": 1,
	},
	"tomato": {
		"id": "tomato",
		"name": "Tomate",
		"row": 1,
		"days_to_grow": 3,
		"regrow_days": 2,
		"seed_price": 30,
		"sell_price": 50,
		"sheet": "extra",
		"icon_sheet": "v13",
		"icon_col": 2,
	},
	"pumpkin": {
		"id": "pumpkin",
		"name": "Abóbora",
		"row": 2,
		"days_to_grow": 5,
		"regrow_days": 0,
		"seed_price": 60,
		"sell_price": 190,
		"sheet": "extra",
		"icon_sheet": "v13",
		"icon_col": 3,
	},
}


static func get_all_definitions() -> Dictionary:
	return DEFINITIONS.duplicate(true)


static func get_crop_order() -> Array[String]:
	return CROP_ORDER.duplicate()


static func create_crop(crop_id: String):
	var crop = new()
	if not DEFINITIONS.has(crop_id):
		return crop
	var entry: Dictionary = DEFINITIONS[crop_id]
	crop.id = str(entry["id"])
	crop.crop_name = str(entry["name"])
	crop.row = int(entry["row"])
	crop.days_to_grow = int(entry["days_to_grow"])
	crop.regrow_days = int(entry.get("regrow_days", 0))
	crop.seed_price = int(entry["seed_price"])
	crop.sell_price = int(entry["sell_price"])
	crop.sheet_kind = str(entry.get("sheet", "base"))
	return crop


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": crop_name,
		"row": row,
		"days_to_grow": days_to_grow,
		"regrow_days": regrow_days,
		"seed_price": seed_price,
		"sell_price": sell_price,
		"sheet": sheet_kind,
	}
