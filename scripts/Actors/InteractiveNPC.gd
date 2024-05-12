extends StaticBody3D
class_name InteractiveNPC

@export var menu:CanvasLayer


func activate():
	menu.visible = true


func _input(event):
	if event.is_action_pressed("menu"):
		menu.visible = false
