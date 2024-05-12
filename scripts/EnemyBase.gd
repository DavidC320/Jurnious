extends Actor

const JUMP_VELOCITY = 4.5
@onready var agent := $NavigationAgent3D
var target:Node3D
var move_to_target = false
var wandering = true
@onready var mesh_instance_3d = $MeshInstance3D
@onready var area_3d = $MeshInstance3D/Area3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var update_count = 0
var update_max = 10
var can_attack = true
@onready var attack_speed = $AttackSpeed

@onready var mesh_holder = $MeshInstance3D/MeshHolder
@onready var drop = preload("res://scenes/drops.tscn")

func _ready():
	super()
	if _actor_resource.model:
		if mesh_holder.get_child_count() > 0:
			mesh_holder.get_child(0).queue_free()
		var model = load(_actor_resource.model)
		var full_model = model.instantiate()
		mesh_holder.add_child(full_model)


func _on_area_3d_body_exited(body):
	move_to_target = false
	target = null
	velocity = Vector3.ZERO
	pass # Replace with function body.


func _on_attack_speed_timeout():
	can_attack = true
	pass # Replace with function body.


func _physics_process(delta):
	# Add the gravity.
	update_count += 1
	if update_count == update_max and move_to_target:
		find_position(target)
	update_count %= update_max
	
	if area_3d.has_overlapping_bodies() and can_attack:
		attack_target()

	elif !area_3d.has_overlapping_bodies() and target:
		move_to_target = true
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if target:
		increment_to_target(delta)
	move_and_slide()

func attack_target():
	move_to_target = false
	var player:Actor = area_3d.get_overlapping_bodies()[0]
	print("punch ", player)
	player.damage_health(attack)
	can_attack = false
	attack_speed.start()


func increment_to_target(delta):
	if position.distance_to(target.global_position) > .5 and move_to_target:
		var current:Vector3 = global_transform.origin
		var next:Vector3 = agent.get_next_path_position()
		var direction:Vector3 = (next - current).normalized()
		mesh_instance_3d.look_at(next)
		mesh_instance_3d.rotation.x = 0
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		move_to_target = false
		velocity = Vector3.ZERO


func find_position(t):
	target = t
	agent.target_position = t.global_position


func _on_area_3d_body_entered(body):
	find_position(body)
	move_to_target = true
	pass # Replace with function body.

func die():
	super()
	if _actor_resource.drop_table:
		var items:Inventory = _actor_resource.drop_table.generate_drops()
		var new_drop_object = drop.instantiate()
		new_drop_object.inventory = items
		var pos = global_position
		pos.y += 1
		get_parent().add_child(new_drop_object)
		new_drop_object.global_position = pos
	queue_free()
