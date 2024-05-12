@tool
extends Resource
class_name  DropSlot

@export_category("Info")
@export var _item:ItemResource
@export_range(1, 100) var weight:int
@export var remove_when_selected :=  false
