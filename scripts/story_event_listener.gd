extends Node

signal goal_completed(goal_name)

var goals : Dictionary = {
	"orange_box_interacted" : false,
	"lamp_lit_up" : false
}

func complete_goal(goal_name: String) -> void:
	if goal_name in goals and not goals[goal_name]:
		goals[goal_name] = true
		goal_completed.emit(goal_name)  # Notify the game
