extends Node
class_name Item

@export var item_data:ItemResource
@export var count:int

signal count_change(new_amount)

func init(item:ItemResource, amount:int):
	item_data = item
	count = amount

func change_amount(amount:int):
	count = clamp(count + amount, 0, 99)
	count_change.emit(count)


func get_value():
	return count * item_data.coin_value


func is_empty():
	return true if count <= 0 else false

func save_item():
	var data = {
		"item resource" : item_data.resource_path,
		"count" : count
	}
	return data
