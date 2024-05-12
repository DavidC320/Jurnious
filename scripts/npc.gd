extends StaticBody3D

@export var menu:CanvasLayer

@onready var canvas_layer = $CanvasLayer


func activate():
	canvas_layer.visible = true


func _on_exit_pressed():
	canvas_layer.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event.is_action_pressed("menu"):
		canvas_layer.visible = false


func _on_island_pressed():
	get_tree().change_scene_to_file("res://scenes/maps/island.tscn")


func _on_canyon_pressed():
	get_tree().change_scene_to_file("res://scenes/maps/Plains.tscn")
