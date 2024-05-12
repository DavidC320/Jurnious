@tool
extends Resource
class_name ItemResource

@export_category("Information")
@export var item_name:String
@export_enum("collectable", "equipment", "weapon", "shield") var item_type = "collectable":
	set(value):
		item_type = value
		notify_property_list_changed()

@export_category("Statistics")
@export var coin_value := 10
## Equipment
@export var defense := 10
@export var speed := 2.0
@export var health := 10
## Weapons
@export var damage := 5

@export_category("Sprites")
@export_color_no_alpha var color = Color.WHITE
@export_file() var _model
@export var pick_up_sprite:Texture


func _validate_property(property):
	if property.name in ['defense', 'speed', 'health'] and item_type not in ["equipment", "shield"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ['damage'] and item_type != 'weapon':
		property.usage = PROPERTY_USAGE_NO_EDITOR
