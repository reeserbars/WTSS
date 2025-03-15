extends Node2D

var selected = false
var mouse_offset = Vector2(0,0)

func _process(delta: float) -> void:
	if selected:
		follow_mouse()

func follow_mouse():
	position = get_global_mouse_position() + mouse_offset

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			mouse_offset = position - get_global_mouse_position()
			selected = true
		else:
			selected = false
