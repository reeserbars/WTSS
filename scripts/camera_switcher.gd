extends Node

@export var position_markers: Array[Marker3D]

var current_camera_index = 0

@onready var camera: Camera3D = $"../../Camera"

func _unhandled_input(event):
	if event.is_action_pressed("next_camera"):
		current_camera_index = (current_camera_index + 1) % position_markers.size()
		update_camera_position()

func update_camera_position():
	var new_position = position_markers[current_camera_index].global_position
	var new_quaternion = position_markers[current_camera_index].quaternion
	var tween = create_tween()
	tween.parallel().tween_property(camera, "position", new_position, 0.5)
	tween.parallel().tween_property(camera, "quaternion", new_quaternion, 0.25)
