extends StaticBody3D

@onready var area_3d = $Area3D
const ENEMY_BASE = preload("res://scenes/actors/enemy_base.tscn")
@onready var marker_3d = $Marker3D

func can_summon():
	return !area_3d.has_overlapping_bodies()

func summon(monsters):
	var monster_data = monsters.pick_random()
	var monseter = ENEMY_BASE.instantiate()
	monseter._actor_resource = monster_data
	monseter.top_level = true
	get_parent().add_child(monseter)
	monseter.global_position = marker_3d.global_position
