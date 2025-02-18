extends StaticBody3D

@export var mesh_instance_path: NodePath
@export var highlight_distance: float = 5.0
@export var is_character: bool
@export var dialogue_timeline : DialogicTimeline = preload("res://dialogue/placeholder_timeline.dtl")

var mesh_instance: MeshInstance3D
var interactable: bool = false

@onready var prompt = $ButtonPrompt
@onready var character_sprite: Sprite3D = $CharacterSprite


func _ready():
	mesh_instance = get_node(mesh_instance_path)
	if not mesh_instance.material_override:
		mesh_instance.material_override = mesh_instance.get_active_material(0).duplicate()
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _input(_event: InputEvent) -> void:
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return
	if Input.is_action_pressed("interact") and interactable:
		prompt.hide()
		Dialogic.start(dialogue_timeline)
		get_viewport().set_input_as_handled()
		interactable = false

func _process(_delta: float) -> void:
	if Global.is_aiming and is_character:
		character_sprite.show()
		mesh_instance.hide()
	else:
		character_sprite.hide()
		mesh_instance.show()
	
	

func set_highlight(highlight: bool):
	var material = mesh_instance.material_override.next_pass
	if highlight:
		if material:
			material.set_shader_parameter("outline_width", 1.0)
	else:
		if material:
			material.set_shader_parameter("outline_width", 0)

func _on_timeline_ended():
	pass

func _on_interaction_range_body_entered(body : Node3D):
	
	if body.name == "Player":
		set_highlight(true)
		prompt.show()
		interactable = true
		


func _on_interaction_range_body_exited(body : Node3D):
	if body.name == "Player":
		set_highlight(false)
		prompt.hide()
		interactable = false
