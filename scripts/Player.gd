extends Actor
class_name Player

const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.002
@onready var stats = $CanvasLayer/MarginContainer/VBoxContainer/Stats

@onready var equipment_meshes := {
	"armour" : {
		"mesh" : $player/Armature/Skeleton3D/Armour/Armour,
		"overide index" : 0
	},
	"right hand" : {
		"mesh" : $player/Armature/Skeleton3D/Icosphere_002/sword/Cube_002,
		"overide index" : 1
	},
	"left hand" : {
		"mesh" : $player/Armature/Skeleton3D/Icosphere_001/shield/Cube_001,
		"overide index" : 0
	}
}
@onready var equipment = $CanvasLayer/MarginContainer/VBoxContainer/Equipment

@onready var head := $Head
@onready var player := $player
@onready var camera := $Head/Camera3D

# Interaction
@onready var intract_label := $CanvasLayer/IntractLabel
@onready var interaction_range := $player/InteractionRange
@onready var attack_range = $player/AttackRange

# States
var left_state = "idle"
var right_state = "idle"
@onready var animation_tree = $player/AnimationTree

# limits
@onready var limit_vector:Vector4 = Vector4(
	get_tree().get_first_node_in_group("bottomleft").global_position.x,
	get_tree().get_first_node_in_group("topright").global_position.x,
	get_tree().get_first_node_in_group("topright").global_position.z,
	get_tree().get_first_node_in_group("bottomleft").global_position.z
)
@onready var sea_level:int = get_tree().get_first_node_in_group("waterpoint").global_position.y

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# sounds
@onready var hurt = $Hurt
@onready var hit = $Hit
@onready var block = $Block

@onready var respawn_point = global_position


signal equipment_changed()


func damage_health(damage:int):
	if "defend" in [left_state, right_state]:
		block.play()
		damage /= 2
	else:
		hurt.play()
	update_labels()
	super(damage)

func die():
	global_position = respawn_point
	health = max_health
	update_labels()


func _physics_process(delta):
	intract_label.visible = true if interaction_range.get_overlapping_bodies() else false
	# Add the gravity.
	var final_gravity = gravity
	if global_position.y < sea_level:
		final_gravity /= 3
	
	if not is_on_floor():
		velocity.y -= final_gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or global_position.y < sea_level):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var roation_axis = Input.get_axis("roll_right", "roll_left")
	head.rotate_y(roation_axis * 4 * delta)
	player.rotate_y(roation_axis * 4 * delta)
	
	
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var final_speed = _actor_resource.speed
	if Input.is_action_pressed("run"):
		final_speed *= 2
	if direction:
		velocity.x = direction.x * final_speed
		velocity.z = direction.z * final_speed
	else:
		velocity.x = move_toward(velocity.x, 0, final_speed)
		velocity.z = move_toward(velocity.z, 0, final_speed)

	move_and_slide()
	global_position.x = clamp(global_position.x, limit_vector.x, limit_vector.y)
	global_position.z = clamp(global_position.z, limit_vector.z, limit_vector.y)


func _ready():
	super()
	update_stats_on_equipment()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PlayerLoader.equipment_changed.connect(update_equipment)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		player.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -0.20, .40)


func _input(event):
	if event.is_action_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("intereact"):
		var list_of_interaction = interaction_range.get_overlapping_bodies()
		if list_of_interaction:
			var interaction = list_of_interaction[0]
			interaction.activate()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		left_state = slot_use(event, "left hand", PlayerLoader.left_hand, "left", left_state, right_state)
		right_state = slot_use(event, "right hand", PlayerLoader.right_hand, "right", right_state, left_state)


func _process(delta):
	defend_blend("left", left_state)
	defend_blend("right", right_state)


func defend_blend(side:String, state:String):
	var paramater_defend_path = "parameters/%s defend/blend_amount" % side
	var side_inital_blend = float(animation_tree[paramater_defend_path])
	var target_defend_blend = 1.0 if state == "defend" else 0.0
	animation_tree[paramater_defend_path] = lerp(side_inital_blend, target_defend_blend, .2)


func slot_use(event, input:String, item:ItemResource, side:String, previous_state:String, counter_state:String):
	if !item:
		return previous_state
	var combat_state = previous_state
	var item_type = item.item_type
	if event.is_action_pressed(input):
		combat_state = "attack" if item_type == "weapon" else "defend"
		if combat_state == "attack" and "defend" not in counter_state:
			animation_tree["parameters/"+ side +" attack/request"] = 1
			if attack_range.has_overlapping_bodies():
				if attack_range.get_overlapping_bodies().size() > 0:
					hit.play()
					var object:Actor = attack_range.get_overlapping_bodies()[0]
					object.damage_health(item.damage + attack)
	
	elif event.is_action_released(input):
		combat_state = "idle"
	return combat_state


func change_material(slot:String, item:ItemResource):
	if slot not in equipment_meshes.keys():
		print_debug(slot, " not in dict")
	
	var new_material = StandardMaterial3D.new()
	if item:
		new_material.albedo_color = item.color
	else:
		new_material.albedo_color = Color.WHITE
	var mesh:MeshInstance3D = equipment_meshes.get(slot).get("mesh")
	mesh.set_surface_override_material(equipment_meshes.get(slot).get("overide index"), new_material)


func update_equipment(slot:PlayerLoader.SLOTS):
	update_stats_on_equipment()
	match slot:
		PlayerLoader.SLOTS.LEFT_HAND : change_material("left hand", PlayerLoader.left_hand)
		PlayerLoader.SLOTS.RIGHT_HAND : change_material("right hand", PlayerLoader.right_hand)
		PlayerLoader.SLOTS.ARMOUR : change_material("armour", PlayerLoader.armour)


func update_stats_on_equipment():
	var new_health = _actor_resource.health
	var new_defense = _actor_resource.defense
	var new_speed = _actor_resource.speed
	
	for item in [PlayerLoader.left_hand, PlayerLoader.right_hand]:
		if !item:
			continue
		var equipment_item:ItemResource = item
		new_defense += equipment_item.defense
		new_health += equipment_item.health
		new_speed += equipment_item.speed
	
	health = new_health
	max_health = new_health
	defense = new_defense
	speed = new_speed
	update_labels()

func update_labels():
	var damage = attack
	stats.text = "HP: %d/%d\nSP: %d\nDF: %d\nAT: %d" % [
		health, max_health, speed, defense, damage
	]
	var text = "Equipment\n"
	if PlayerLoader.armour:
		change_material("armour", PlayerLoader.armour)
		text += "Armour(%d) - %s\n" % [PlayerLoader.armour.defense, PlayerLoader.armour.item_name]
	if PlayerLoader.right_hand:
		change_material("right hand", PlayerLoader.right_hand)
		text += "Right hand(%d)  - %s\n" % [
			PlayerLoader.right_hand.damage if PlayerLoader.right_hand.item_type == "weapon" else PlayerLoader.right_hand.defense, 
			PlayerLoader.right_hand.item_name]
	if PlayerLoader.left_hand:
		change_material("left hand", PlayerLoader.left_hand)
		text += "left hand(%d) - %s\n" % [
			PlayerLoader.left_hand.damage if PlayerLoader.left_hand.item_type == "weapon" else PlayerLoader.left_hand.defense, 
			PlayerLoader.left_hand.item_name]
	equipment.text = text
