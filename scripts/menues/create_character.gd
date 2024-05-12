extends Control

@onready var play_button = $HBoxContainer/VBoxContainer/VBoxContainer/PlayButton
@onready var skin_parts = [
	$HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera3D/player/Armature/Skeleton3D/Icosphere/Icosphere,
	$HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera3D/player/Armature/Skeleton3D/Icosphere_001/Icosphere_001,
	$HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera3D/player/Armature/Skeleton3D/Icosphere_002/Icosphere_002]
@onready var armour = $HBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera3D/player/Armature/Skeleton3D/Armour/Armour
@onready var skin_spin = $HBoxContainer/VBoxContainer/SkinSpin
@onready var armour_spin = $HBoxContainer/VBoxContainer/ArmourSpin
@onready var name_edit = $HBoxContainer/VBoxContainer/VBoxContainer/NameEdit

func _ready():
	PlayerLoader.save_game()
	skin_spin.color_changed.connect(update_skin)
	armour_spin.color_changed.connect(update_armour)
	update_skin(skin_spin.get_color())
	update_armour(armour_spin.get_color())

func update_skin(color:Color):
	for skin in skin_parts:
		var skin_var :MeshInstance3D = skin
		var new_material = StandardMaterial3D.new()
		new_material.albedo_color = color
		skin_var.set_surface_override_material(0, new_material)

func update_armour(color:Color):
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = color
	armour.set_surface_override_material(0, new_material)

func _on_play_button_pressed():
	pass # Replace with function body.
