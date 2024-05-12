extends Node
class_name Inventory

@export var _items:Array[Item]= []

signal inventory_updated()

func change_item(item:ItemResource, amount:int):
	var index:= 0
	if item not in get_item_resources_in_item_holder():
		var new_item = Item.new()
		new_item.init(item, amount)
		_items.append(new_item)
		index = _items.size() - 1
	else:
		index = get_item_resources_in_item_holder().find(item)
		var item_holder:Item = _items[index]
		item_holder.change_amount(amount)
		if item_holder.is_empty():
			_items.pop_at(index)
	inventory_updated.emit()

func get_item_resources_in_item_holder() -> Array:
	var list_of_resource = []
	for item in _items:
		list_of_resource.append(item.item_data)
	return list_of_resource

func get_item(index:int):
	if index >= _items.size():
		return null
	return _items[index]

func get_items():
	return _items

func save_inventory():
	var list_of_items:Array[Dictionary]
	for item in _items:
		list_of_items.append(item.save_item())
	return list_of_items


func clear_inventory():
	_items.clear()

func load_items(list_of_items):
	for item in list_of_items:
		change_item(load(item["item resource"]), item["count"])
