extends StaticBody3D

@export var mesh_instance_path: NodePath
@export var highlight_distance: float = 5.0

var mesh_instance: MeshInstance3D
var interactable: bool = false
@onready var prompt = $ButtonPrompt



func _ready():
	mesh_instance = get_node(mesh_instance_path)
	if not mesh_instance.material_override:
		mesh_instance.material_override = mesh_instance.get_active_material(0).duplicate()

func _input(_event: InputEvent) -> void:
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return
	if Input.is_action_pressed("interact") and interactable:
		Dialogic.start('placeholder_timeline')
		get_viewport().set_input_as_handled()


func _on_interaction_range_body_entered(body : Node3D):
	print(body.name)
	if body.name == "Player":
		set_highlight(true)
		prompt.show()
		interactable = true

func _on_interaction_range_body_exited(body : Node3D):
	if body.name == "Player":
		set_highlight(false)
		prompt.hide()
		interactable = false


func set_highlight(is_hovered: bool):
	var material = mesh_instance.material_override.next_pass
	if is_hovered:
		if material:
			material.set_shader_parameter("outline_width", 1.0)
	else:
		if material:
			material.set_shader_parameter("outline_width", 0)
