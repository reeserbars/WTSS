extends Area3D

# Define a new signal
signal focus_area_entered(body: Node3D)

func _on_body_entered(body: Node3D) -> void:
	emit_signal("focus_area_entered", body)
