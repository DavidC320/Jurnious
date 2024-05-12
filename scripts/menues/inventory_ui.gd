extends MarginContainer

enum {
	NULL = 0,
	ITEM = 1,
	LEFT_SLOT = 2,
	RIGHT_SLOT = 3,
	ARMOUR_SLOT = 4,
}


const ITEM_INVENTORY_WIDGIT = preload("res://scenes/widgets/item_inventory_widgit.tscn")
@onready var grid_container = $VBoxContainer/MarginContainer/ScrollContainer/GridContainer
@onready var scroll_container = $VBoxContainer/MarginContainer/ScrollContainer

@onready var left = $VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/Left
@onready var armour = $VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/Armour
@onready var right = $VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/Right
@onready var add_to_iventory_button = $VBoxContainer/MarginContainer/AddToIventoryButton


var current_widget:ItemWidget
var current_mode:int

# Called when the node enters the scene tree for the first time.
func _ready():
	update_slot_widgets()
	update_inventory()
	PlayerLoader.inventory.inventory_updated.connect(update_inventory)

func update_inventory():
	for child in grid_container.get_children(): child.queue_free()
	for item in PlayerLoader.inventory._items:
		if !item.is_empty():
			var item_widget:ItemWidget = ITEM_INVENTORY_WIDGIT.instantiate()
			# item_widget.selected_item.connect(item_select_change)
			grid_container.add_child(item_widget)
			item_widget.init_item(item)
			item_widget.select_state_changed.connect(func(value): button_pressed(value, ITEM))

func update_slot_widgets(connect_widgets := true):
	set_up_charcter_slots(PlayerLoader.left_hand, left, LEFT_SLOT, connect_widgets)
	set_up_charcter_slots(PlayerLoader.right_hand, right, RIGHT_SLOT, connect_widgets)
	set_up_charcter_slots(PlayerLoader.armour, armour, ARMOUR_SLOT, connect_widgets)

func button_pressed(widget:ItemWidget, slot:int):
	var previous_mode = current_mode
	current_mode = slot
	var previous_widget:ItemWidget = current_widget
	current_widget = widget
	add_to_iventory_button.visible = false
	
	if previous_widget != current_widget and previous_widget:
		previous_widget.change_selected(false)
	
	if current_widget == previous_widget:
		current_widget = null
		current_mode = NULL
		return
	
	# item modes
	if current_mode in [LEFT_SLOT, RIGHT_SLOT, ARMOUR_SLOT] and previous_mode != ITEM and current_widget.item.item_data:  # place in inventory
		add_to_iventory_button.visible = true
	
	elif previous_mode == ITEM and current_mode in [LEFT_SLOT, RIGHT_SLOT, ARMOUR_SLOT]:  # equip
		var item:Item = previous_widget.item
		equip_item(item, current_mode)
		current_mode = NULL
	# print("Previous: ", previous_mode, " ", previous_widget, "\nCurrent:", current_mode, " ", current_widget)


func set_up_charcter_slots(item:ItemResource, widget:ItemWidget, slot:int, connect_widgets:= true):
	var new_item = Item.new()
	new_item.init(item, 1)
	
	widget.init_item(new_item)
	if connect_widgets:
		print("set")
		widget.select_state_changed.connect(func(value): button_pressed(value, slot))


func _on_button_pressed():
	scroll_container.visible = !scroll_container.visible


func _on_add_to_iventory_button_pressed():
	equip_item(null, current_mode)
	add_to_iventory_button.visible = false

func equip_item(item:Item, mode:int):
	match mode:
		LEFT_SLOT:
			PlayerLoader.change_slot_item(PlayerLoader.SLOTS.LEFT_HAND, item)
		RIGHT_SLOT:
			PlayerLoader.change_slot_item(PlayerLoader.SLOTS.RIGHT_HAND, item)
		ARMOUR_SLOT:
			PlayerLoader.change_slot_item(PlayerLoader.SLOTS.ARMOUR, item)
	reset_states()

func reset_states():
	update_inventory()
	current_widget.change_selected(false)
	update_slot_widgets(false)
	change_current(null, NULL)
	
func change_current(widget:ItemWidget, mode:int):
	current_widget = widget
	current_mode = mode
