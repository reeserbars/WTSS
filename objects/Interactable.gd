extends StaticBody3D
signal interacted

@export var mesh_instance: MeshInstance3D
@export var is_character: bool
@export var dialogue_timeline : DialogicTimeline = preload("res://dialogue/placeholder_timeline.dtl")

var shader_material : ShaderMaterial
var interactable: bool = false
var interaction_complete : bool = false

@onready var prompt: Label = $UI/Prompt
@onready var character_sprite: Sprite3D = $CharacterSprite
@onready var ui: Control = $UI


func _ready():
	if mesh_instance:
		shader_material = ShaderMaterial.new()
		shader_material.shader = preload("res://shaders/EdgeHighlight.gdshader")
		shader_material.render_priority = 1
		shader_material.set_shader_parameter("outline_width", 0)
		shader_material.set_shader_parameter("outline_color", Color(1.0, 1.0, 1.0))
		mesh_instance.material_overlay = shader_material
		ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
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
		interacted.emit()

func _process(_delta: float) -> void:
	if Global.is_aiming and is_character and mesh_instance:
		character_sprite.show()
		mesh_instance.hide()
	else:
		character_sprite.hide()
		mesh_instance.show()

func set_highlight(highlight: bool):
	var material = mesh_instance.material_overlay
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
		if not interaction_complete:
			interactable = true
		

func _on_interaction_range_body_exited(body : Node3D):
	if body.name == "Player":
		set_highlight(false)
		prompt.hide()
		interactable = false
