extends StaticBody3D

@export var mesh_instance_path: NodePath
@export var highlight_distance: float = 5.0

@onready var Prompt = $ButtonPrompt

var mesh_instance: MeshInstance3D

func _ready():
	mesh_instance = get_node(mesh_instance_path)
	if not mesh_instance.material_override:
		mesh_instance.material_override = mesh_instance.get_active_material(0).duplicate()

func _on_interaction_range_body_entered(body):
	if body.name == "CharacterBody3D":
		set_highlight(true)
		Prompt.show()

func _on_interaction_range_body_exited(body):
	if body.name == "CharacterBody3D":
		set_highlight(false)
		Prompt.hide()

func set_highlight(is_hovered: bool):
	var material = mesh_instance.material_override
	if material:
		material.set_shader_parameter("is_hovered", is_hovered)
