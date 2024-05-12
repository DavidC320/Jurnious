extends Resource
class_name ActorResource

@export_category("Information")
@export var name: String
@export var drop_table:DropTable
@export_category("Statistics")
@export var health := 100
@export var defense := 5
@export var speed := 4.0
@export var attack := 5
@export var jump_height := -600
@export var acenstion_time := .5
@export var decension_time := .5
@export_category("model")
@export_file("*.glb") var model

