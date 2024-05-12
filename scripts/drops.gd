extends RigidBody3D


var inventory:Inventory
@onready var canvas_layer = $CanvasLayer
@onready var grid_container = $CanvasLayer/VBoxContainer/MarginContainer/ScrollContainer/GridContainer
@onready var click_timer = $ClickTimer

const ITEM_INVENTORY_WIDGIT = preload("res://scenes/widgets/item_inventory_widgit.tscn")
var current_item:Item

func _ready():
	update_inventory()


func update_inventory():
	if inventory.get_items().size() == 0:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		queue_free()
	for child in grid_container.get_children(): child.queue_free()
	for item in inventory.get_items():
		if !item.is_empty():
			var item_widget:ItemWidget = ITEM_INVENTORY_WIDGIT.instantiate()
			# item_widget.selected_item.connect(item_select_change)
			grid_container.add_child(item_widget)
			item_widget.init_item(item)
			item_widget.select_state_changed.connect(click_widgit)


func click_widgit(widget:ItemWidget):
	if current_item == widget.item:
		PlayerLoader.inventory.change_item(current_item.item_data, current_item.count)
		inventory.change_item(current_item.item_data, -current_item.count)
		update_inventory()
		click_timer.stop()
	else:
		click_timer.start()
		current_item = widget.item


func activate():
	canvas_layer.visible = true


func _on_exit_pressed():
	canvas_layer.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event.is_action_pressed("menu"):
		canvas_layer.visible = false


func _on_click_timer_timeout():
	current_item = null
	click_timer.stop()


func _on_life_timer_timeout():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()


func _on_button_pressed():
	for item in inventory.get_items():
		PlayerLoader.inventory.change_item(item.item_data, item.count)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
