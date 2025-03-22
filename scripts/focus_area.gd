extends Area3D

@export var pcam : PhantomCamera3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		pcam.set_priority(1)

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		pcam.set_priority(0)
