extends MarginContainer
class_name ItemWidget

@export var show_labels = true

@onready var sprite_2d = $Sprite2D
@onready var value = $Value
@onready var amount = $Amount
@onready var highlight = $Highlight
@onready var selected_rect = $SelectedRect
const EMPTY = preload("res://resources/textures/Empty.tres")
var item:Item

var selected = false
var highlighted = false

signal select_state_changed(widgit)


func _ready():
	highlight.visible = false
	value.visible = show_labels
	amount.visible = show_labels

func init_item(item_data:Item):
	item = item_data
	if !item.item_data:
		sprite_2d.modulate = Color.WHITE
		sprite_2d.texture = EMPTY
		tooltip_text = "Nothing here."
	else:
		item.count_change.connect(update_labels)
		sprite_2d.texture = item.item_data.pick_up_sprite
		sprite_2d.modulate = item.item_data.color
		tooltip_text = item.item_data.item_name
		update_labels(item.count)

func update_labels(new_count):
	value.text = "%d$" % item.get_value()
	amount.text = "%s" % new_count


func _unhandled_input(event):
	# var click_out = event.is_action_pressed("left hand") and !highlight.visible
	if !highlighted:
		return
	
	var double_click = event.is_action_pressed("left hand") and selected
	if double_click:
		change_selected(false, true)
	elif event.is_action_pressed("left hand"):
		change_selected(true, true)

func change_selected(is_selected:bool, emit:= false):
	selected_rect.visible = is_selected
	selected = is_selected
	if emit:
		select_state_changed.emit(self)

func change_highlighted(is_highlighted:bool):
	highlight.visible = is_highlighted
	highlighted = is_highlighted

func _on_mouse_detector_mouse_entered():
	change_highlighted(true)


func _on_mouse_detector_mouse_exited():
	change_highlighted(false)
