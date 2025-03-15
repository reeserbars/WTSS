extends CharacterBody2D

const GRAVITY = 200
var _dragging = false
var draggable = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var current_position : Vector2 = global_position
	var mouse_position : Vector2 = get_global_mouse_position()
	
	var distance : float = current_position.distance_to(mouse_position)
	var direction : Vector2 = current_position.direction_to(mouse_position)
	var speed = distance / delta
	
	draggable = distance < $CollisionShape2D.shape.size.x/2
	if _dragging and draggable:
		velocity = direction * speed
		move_and_slide()
	else:
		velocity.y += GRAVITY * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and draggable:
		_dragging = event.is_action_pressed("shoot")
		
