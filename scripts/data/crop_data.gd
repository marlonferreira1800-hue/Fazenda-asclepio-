class_name CropData
extends Resource
## Definições de cultivos do projeto Fazendinha 2D.
## Cada linha (row) corresponde exatamente a res://assets/sprites/crops_sheet.png (5 cols x 6 rows de 16x16).

@export var id: String = ""
@export var crop_name: String = ""
@export var row: int = 0
@export var days_to_grow: int = 2
@export var seed_price: int = 10
@export var sell_price: int = 25

const DEFINITIONS: Dictionary = {
	"wheat": {
		"id": "wheat",
		"name": "Trigo",
		"row": 0,
		"days_to_grow": 2,
		"seed_price": 10,
		"sell_price": 25,
	},
	"carrot": {
		"id": "carrot",
		"name": "Cenoura",
		"row": 1,
		"days_to_grow": 3,
		"seed_price": 20,
		"sell_price": 55,
	},
	"strawberry": {
		"id": "strawberry",
		"name": "Morango",
		"row": 2,
		"days_to_grow": 4,
		"seed_price": 35,
		"sell_price": 110,
	},
	"corn": {
		"id": "corn",
		"name": "Milho",
		"row": 3,
		"days_to_grow": 3,
		"seed_price": 30,
		"sell_price": 90,
	},
	"tomato": {
		"id": "tomato",
		"name": "Tomate",
		"row": 4,
		"days_to_grow": 4,
		"seed_price": 45,
		"sell_price": 145,
	},
	"pumpkin": {
		"id": "pumpkin",
		"name": "Abóbora",
		"row": 5,
		"days_to_grow": 5,
		"seed_price": 65,
		"sell_price": 220,
	},
}


static func get_all_definitions() -> Dictionary:
	return DEFINITIONS.duplicate(true)


static func create_crop(crop_id: String):
	var crop = new()
	if not DEFINITIONS.has(crop_id):
		return crop
	var entry: Dictionary = DEFINITIONS[crop_id]
	crop.id = str(entry["id"])
	crop.crop_name = str(entry["name"])
	crop.row = int(entry["row"])
	crop.days_to_grow = int(entry["days_to_grow"])
	crop.seed_price = int(entry["seed_price"])
	crop.sell_price = int(entry["sell_price"])
	return crop


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": crop_name,
		"row": row,
		"days_to_grow": days_to_grow,
		"seed_price": seed_price,
		"sell_price": sell_price,
	}
