extends CharacterBody3D

const SPEED = 2.5
const JUMP_VELOCITY = 4.5

var input_dir = Vector2.ZERO

@onready var flash_pivot = $FlashPivot
@onready var anim_tree = $AnimationTree

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle movement
	var new_input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_dir = new_input_dir
	# Convert input to 3D direction
	var direction = Vector3.ZERO
	direction.x = input_dir.x
	direction.z = input_dir.y
	direction = direction.normalized()
	direction = transform.basis * direction
	# Apply movement
	var target_velocity = direction * SPEED
	velocity.x = lerpf(velocity.x, target_velocity.x, 10.0 * delta)
	velocity.z = lerpf(velocity.z, target_velocity.z, 10.0 * delta)

	if direction != Vector3.ZERO:
		anim_tree.get("parameters/playback").travel("Walk")
		anim_tree.set("parameters/Idle/BlendSpace2D/blend_position", input_dir)
		anim_tree.set("parameters/Walk/BlendSpace2D/blend_position", input_dir)
	else:
		anim_tree.get("parameters/playback").travel("Idle")
	move_and_slide()
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
