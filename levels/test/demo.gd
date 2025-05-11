extends Node3D

@export var greenlight: Area3D
@onready var minigame : PackedScene = preload("res://levels/minigames/minigame_placeholder.tscn")
@onready var game_int: StaticBody3D = %GameInt

func _ready() -> void:
	StoryEventListener.goal_completed.connect(_on_goal_completed)

func _process(delta: float) -> void:
	Global.debug.add_property("is aiming", Global.is_aiming, 3)
	Global.debug.add_property("lamp lit up", StoryEventListener.goals["lamp_lit_up"], 3)

func start_minigame() -> void:
	game_int.add_child(minigame.instantiate())
	Dialogic.disconnect("timeline_ended", start_minigame)

func _on_goal_completed(goal_name: String) -> void:
	if goal_name == "lamp_lit_up":
		greenlight.show()
		game_int.interaction_complete = true


func _on_game_int_interacted() -> void:
	if !game_int.interaction_complete:
		Dialogic.connect("timeline_ended", start_minigame)
