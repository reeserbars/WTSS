extends Node

var debug
var sensitivity : float =  .0005
var controller_sensitivity : float =  .010
var is_aiming : bool = true
var frames_per_second
var insanity : int = 0

func _process(delta: float) -> void:
	if debug:
		frames_per_second = "%.2f" %  (1.0/delta)
		debug.add_property("FPS",frames_per_second,1)
		debug.add_property("Insanity", Global.insanity, 4)


func is_mouse_inside_window():
	var mouse_pos = get_viewport().get_mouse_position()
	var window_size = get_viewport().get_visible_rect().size
	return mouse_pos.x >= 0 and mouse_pos.y >= 0 and mouse_pos.x <= window_size.x and mouse_pos.y <= window_size.y
