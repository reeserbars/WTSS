extends Node3D

@onready var lightsourcestreetlamp_6: SpotLight3D = $Level/Lightsourcestreetlamp6
@onready var minigame : PackedScene = preload("res://levels/minigames/minigame_placeholder.tscn")
@onready var interactable_4: StaticBody3D = $Level/Interactable4

func _ready() -> void:
	MinigameLoader.connect("minigame_completed", _on_minigame_completed)

func _on_interactable_4_interacted() -> void:
	Dialogic.connect("timeline_ended", start_minigame)

func start_minigame() -> void:
	add_child(minigame.instantiate())

func _on_minigame_completed() -> void:
	print("Minigame Completed")
	lightsourcestreetlamp_6.show()
	interactable_4.interaction_complete = true
