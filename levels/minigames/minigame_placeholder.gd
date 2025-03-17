extends CanvasLayer


func _on_draggable_detector_area_entered(area: Area2D) -> void:
	MinigameLoader.emit_signal("minigame_completed")
	queue_free()
