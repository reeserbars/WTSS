extends CanvasLayer


func _on_draggable_detector_area_entered(area: Area2D) -> void:
	StoryEventListener.complete_goal("lamp_lit_up")
	queue_free()
