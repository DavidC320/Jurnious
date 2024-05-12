extends Node3D
class_name Map

@export var monsters:Array[ActorResource]
@export var monster_max_count = 10
var timer:Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.wait_time = 5
	add_child(timer)
	timer.start()
	timer.timeout.connect(summon_monster)
	summon_monster()
	pass # Replace with function body.

func summon_monster():
	timer.start()
	print("hi")
	var monster_count = get_tree().get_nodes_in_group("Enemy").size()
	if monster_count < monster_max_count:
		var spawner = get_tree().get_nodes_in_group("Spawner").pick_random()
		if spawner.can_summon():
			spawner.summon(monsters)
			print("swaws")
