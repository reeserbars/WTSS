extends Node

var debug
var sensitivity : float =  .0005
var controller_sensitivity : float =  .010
var is_aiming : bool = false

func is_mouse_inside_window():
	var mouse_pos = get_viewport().get_mouse_position()
	var window_size = get_viewport().get_visible_rect().size
	return mouse_pos.x >= 0 and mouse_pos.y >= 0 and mouse_pos.x <= window_size.x and mouse_pos.y <= window_size.y
