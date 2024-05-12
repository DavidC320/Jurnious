@tool
extends Resource
class_name DropTable

@export_category("Info")
@export_range(0, 10) var roll_count := 1
@export var drop_table:Array[DropSlot]
var total:int
var weighted_slots:Array

func _init():
	var counted_total = 0
	for slot in drop_table:
		counted_total += slot.weight
		weighted_slots.append([counted_total, slot._item])
	total = counted_total


func generate_item(random_number:int):
	var previous_start:int
	for slot in weighted_slots:
		var item:ItemResource = slot[1]
		var weight = slot[0]
		var above_less = (random_number > previous_start)
		var below_greater = (random_number <= weight)
		if !slot[1] or (!above_less or !below_greater):
			previous_start = weight
			continue
		
		if random_number > previous_start and random_number <= slot[0]:
			return item
	return null

func generate_drops():
	_init()
	var items:Inventory = Inventory.new()
	for _number in range(roll_count):
		var random_choice = randi_range(0, total)
		var item = generate_item(random_choice)
		if item:
			items.change_item(item, 1)
	return items
		

