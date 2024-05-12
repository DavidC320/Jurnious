extends MarginContainer

var item_holder:Item

@onready var sprite_2d = $VBoxContainer/HBoxContainer/MarginContainer/Sprite2D
@onready var name_label = $VBoxContainer/HBoxContainer/VBoxContainer/Name
@onready var count = $VBoxContainer/HBoxContainer/VBoxContainer/Count
@onready var value = $VBoxContainer/value


func init(item:Item):
	item_holder = item


# Called when the node enters the scene tree for the first time.
func _ready():
	name_label.text = "Name: %s" % item_holder.item_data.item_name
	count.text = "Count: %d" % item_holder.count
	update_labels(item_holder.count)
	item_holder.count_change.connect(update_labels)
	sprite_2d.modulate = item_holder.item_data.color
	if item_holder.item_data.pick_up_sprite:
		sprite_2d.texture = item_holder.item_data.pick_up_sprite

func update_labels(new_amount:int):
	count.text = "Count: %d" % new_amount
	value.text = "Value: %d(%d)" % [item_holder.get_value(), item_holder.item_data.coin_value]
