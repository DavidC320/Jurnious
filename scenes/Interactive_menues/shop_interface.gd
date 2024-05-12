extends CanvasLayer

@onready var grid_container = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/ScrollContainer/GridContainer
@onready var label_2 = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label2
@onready var click_timer = $ClickTimer
@onready var error = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Error

const SWORD_STEEL = preload("res://resources/items/sword_steel.tres")
const ARMOUR_STEEL = preload("res://resources/items/armour_steel.tres")
const SHIELD_STEEL = preload("res://resources/items/shield_steel.tres")


const ITEM_INVENTORY_WIDGIT = preload("res://scenes/widgets/item_inventory_widgit.tscn")
var current_item:Item


func _ready():
	update_inventory()
	update_coin_label()
	PlayerLoader.coins_change.connect(update_coin_label)
	PlayerLoader.inventory.inventory_updated.connect(update_inventory)


func update_coin_label():
	label_2.text = "Coins - %d" % PlayerLoader.coins


func update_inventory():
	for child in grid_container.get_children(): child.queue_free()
	for item in PlayerLoader.inventory.get_items():
		if !item.is_empty():
			var item_widget:ItemWidget = ITEM_INVENTORY_WIDGIT.instantiate()
			# item_widget.selected_item.connect(item_select_change)
			grid_container.add_child(item_widget)
			item_widget.init_item(item)
			item_widget.select_state_changed.connect(click_widgit)


func click_widgit(widget:ItemWidget):
	if current_item == widget.item:
		PlayerLoader.change_amount_of_coins(current_item.item_data.coin_value)
		PlayerLoader.inventory.change_item(current_item.item_data, -1)
		update_inventory()
		click_timer.stop()
	else:
		click_timer.start()
		current_item = widget.item


func buy_item(item_resource:ItemResource, price):
	if PlayerLoader.coins >= price:
		error.text = "Thank you for purchase!"
		PlayerLoader.change_amount_of_coins(-price)
		PlayerLoader.inventory.change_item(item_resource, 1)
	else:
		error.text = "Sorry, need more money."

func _on_buy_shield_pressed():
	buy_item(SHIELD_STEEL, 40)


func _on_buy_armour_pressed():
	buy_item(ARMOUR_STEEL, 40)


func _on_buy_sword_pressed():
	buy_item(SWORD_STEEL, 40)


func _on_click_timer_timeout():
	current_item = null
	click_timer.stop()
	pass # Replace with function body.


func _on_button_pressed():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass # Replace with function body.
