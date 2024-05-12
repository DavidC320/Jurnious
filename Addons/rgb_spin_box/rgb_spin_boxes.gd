extends VBoxContainer
@export_color_no_alpha var color = Color.BLACK
@onready var red_spin_box := $HBoxContainer/Red
@onready var green_spin_box := $HBoxContainer2/Green
@onready var blue_spin_box := $HBoxContainer3/Blue


signal color_changed(new_color)


func _ready():
	red_spin_box.value =  round(color.r * 255)
	green_spin_box.value =  round(color.g * 255)
	blue_spin_box.value =  round(color.b * 255)
	for spin_box in [red_spin_box, green_spin_box, blue_spin_box]:
		spin_box.value_changed.connect(get_color)


func get_color(_value=0):
	var color = Color(
		red_spin_box.value / 255, 
		green_spin_box.value / 255, 
		blue_spin_box.value / 255)
	color_changed.emit(color)
	return color
