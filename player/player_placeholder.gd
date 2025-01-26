extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var flash_pivot = $FlashPivot
@onready var anim_tree = $AnimationTree["parameters/playback"]

func _ready() -> void:
	anim_tree.travel("Walk")

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle movement
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Update animation blend amount
	anim_tree.set("parameters/Walk/blend_amount", input_dir)
	
	# Rotate FlashPivot towards the mouse
	rotate_flash_pivot_towards_mouse()

func rotate_flash_pivot_towards_mouse():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Get mouse position in world space
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	# Create and configure ray query
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result:
		var target_pos = result.position
		var direction = (target_pos - flash_pivot.global_transform.origin).normalized()
		
		# Calculate the target rotation around the Y-axis
		var target_yaw = atan2(direction.x, direction.z)
		flash_pivot.rotation.y = target_yaw
