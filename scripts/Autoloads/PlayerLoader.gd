extends Node

enum SLOTS {
	LEFT_HAND,
	RIGHT_HAND,
	ARMOUR
}

var slot_filters:= [["weapon", "shield"], ["weapon", "shield"], ["equipment"]]

var player_name:String = ""
var skin_color:Color = Color.TAN
var cloth_color:Color = Color.WHITE

@onready var inventory:Inventory = Inventory.new()
var left_hand:ItemResource = load("res://resources/items/shield_wood.tres")
var right_hand:ItemResource = load("res://resources/items/sword_wood.tres")
var armour:ItemResource 

var coins:int

signal equipment_changed(slot)
signal coins_change()

func reset_game():
	player_name = ""
	skin_color = Color.TAN
	cloth_color = Color.WHITE

	inventory = Inventory.new()
	left_hand = null
	right_hand = null
	armour = null

	coins = 0


func get_list_of_saved_games():
	var dir = DirAccess.open("user://")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				print(file_name)
			file_name = dir.get_next()
	else:
		print("error")
	pass


func change_slot_item(slot:SLOTS, item:Item):
	var list_of_slots = [left_hand, right_hand, armour]
	var previous_item = list_of_slots[slot]

	var item_resource = item
	if item is Item:
		item_resource = item.item_data

	# if the item are the same
	if item_resource == previous_item:
		return

	if item_resource is ItemResource:
		# if the item doesn't match the filter
		if item_resource.item_type not in slot_filters[slot]:
			return
		inventory.change_item(item_resource, -1)
	
	# There is a previous item
	if previous_item:
		inventory.change_item(previous_item, 1)
	
	match slot:
		SLOTS.LEFT_HAND : left_hand = item_resource
		SLOTS.RIGHT_HAND : right_hand = item_resource
		SLOTS.ARMOUR : armour = item_resource
	equipment_changed.emit(slot)
	

func change_amount_of_coins(number:int):
	coins += number
	if coins < 0:
		coins = 0
	coins_change.emit()


#
# Save & Load
#
func get_save_data():
	var data = {
		"name" : player_name,
		"coins" : coins,
		"skin" : [skin_color.r, skin_color.g, skin_color.b],
		"cloth" : [cloth_color.r, cloth_color.g, cloth_color.b],
		"left hand" : left_hand,
		"right hand" : right_hand,
		"armour" : armour,
		"inventory" : inventory.save_inventory()
	}
	return data
	

func save_game():
	if player_name.strip_edges(true, true) == "":
		print("The player doesn't have a name.")
		return
	var path = "user://"+player_name+".SVE"
	if FileAccess.file_exists(path):
		print("%s exits" % path) 
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	var data = get_save_data()
	var json_data = JSON.stringify(data)
	save_file.store_line(json_data)


#
func set_save_data(data_string):
	var data = JSON.parse_string(data_string)
	player_name = data["name"]
	coins = data["coins"]
	skin_color = Color(data["skin"][0], data["skin"][1], data["skin"][2])
	cloth_color = Color(data["cloth"][0], data["cloth"][1], data["cloth"][2])
	
	left_hand = data["left hand"]
	right_hand = data["right hand"]
	armour = data["armour"]
	
	inventory.clear_inventory()
	inventory.load_items(data["inventory"])

func load_game(file_name):
	var path = "user://"+file_name
	if !FileAccess.file_exists(path):
		print("%s doesn't exits" % path)
		return
	set_save_data(FileAccess.open(path, FileAccess.READ).get_as_text())
#
# Save & Load
#
"""
Resources

https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
How to save game data
https://docs.godotengine.org/en/stable/classes/class_diraccess.html
How to get files in a directory
"""
