extends Area3D

@export var focus_node: Node3D
@export var cam_manager: Node

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		focus_node.position = position
		cam_manager.call("update_camera_position")
