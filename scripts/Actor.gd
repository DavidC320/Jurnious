extends CharacterBody3D
class_name Actor

@export var _actor_resource:ActorResource
var health:int :
	set(value):
		health = value
		health_changed.emit()
var max_health:int
var defense:int
var speed:int
var attack:int

signal health_changed()

func _ready():
	health = _actor_resource.health
	max_health = _actor_resource.health
	defense = _actor_resource.defense
	speed = _actor_resource.speed
	attack = _actor_resource.attack


func damage_health(damage:int):
	var calcualte_damage = damage / (_actor_resource.defense + 100 / 100)
	health = clamp(health - calcualte_damage, 0, max_health)
	if dead():
		die()

func change_health(health_change:int):
	health = clamp(health + health_change, 0, max_health)
	if dead():
		die()


func dead():
	return true if health == 0 else false

func die():
	print(dead)
