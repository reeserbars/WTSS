extends CharacterBody3D

const SPEED = 5.5
const GRAVITY = -9.8

var sensitivity : float =  .005
var controller_sensitivity : float =  .010

var axis_vector : Vector2
var mouse_captured : bool = true
var aim_mode : bool = false

@onready var camera: Camera3D = $Pivot/Camera
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_flash: GPUParticles3D = $Pivot/Camera/pistol/GPUParticles3D
@onready var raycast: RayCast3D = $Pivot/Camera/RayCast3D
@onready var gunshot_sound: AudioStreamPlayer3D = %GunshotSound
@onready var player_sprite: Sprite3D = $Sprite3D
@onready var pivot: Marker3D = $Pivot

func _ready() -> void:
	camera.current = false

func _process(_delta: float) -> void:
	sensitivity = Global.sensitivity
	controller_sensitivity = Global.controller_sensitivity
	
	# Check if the aim button is pressed or released
	if Input.is_action_pressed("aim"):
		aim_mode = true
		update_aim_mode()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_released("aim"):
		aim_mode = false
		update_aim_mode()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if aim_mode:
		rotate_y(-axis_vector.x * controller_sensitivity)
		camera.rotate_x(-axis_vector.y * controller_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80),deg_to_rad(80))
		camera.rotation.y = clamp(camera.rotation.y, deg_to_rad(-180),deg_to_rad(-180))
		camera.rotation.z = clamp(camera.rotation.z, 0,0)
	

func _unhandled_input(event: InputEvent) -> void:
	axis_vector = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if event is InputEventMouseMotion and aim_mode:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(event.relative.y * sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80),deg_to_rad(80))
	
	
	if Input.is_action_just_pressed("shoot") \
		and anim_player.current_animation != "shoot" :
		play_shoot_effects.rpc()
		gunshot_sound.play()
		if raycast.is_colliding() && str(raycast.get_collider()).contains("CharacterBody3D") :
			var hit_player: Object = raycast.get_collider()
			hit_player.recieve_damage.rpc_id(hit_player.get_multiplayer_authority())


func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Get input direction
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var current_camera = get_viewport().get_camera_3d()
	if current_camera:
		var input_vector = Vector3(input_dir.x, 0, input_dir.y)
		var direction = (current_camera.global_transform.basis * input_vector).normalized()

		# Handle movement
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if not aim_mode:
		rotate_towards_mouse()

@rpc("call_local")
func play_shoot_effects() -> void:
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func update_aim_mode() -> void:
	if aim_mode:
		camera.current = true
		player_sprite.hide()
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	else:
		player_sprite.show()
		camera.current = false
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.rotation.x = 0

func rotate_towards_mouse():
	var current_camera = get_viewport().get_camera_3d()
	if not current_camera:
		return
	# Get mouse position in world space
	var mouse_pos = get_viewport().get_mouse_position()
	var from = current_camera.project_ray_origin(mouse_pos)
	var to = from + current_camera.project_ray_normal(mouse_pos) * 1000

	# Create and configure ray query
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result:
		var target_pos = result.position
		var direction = (target_pos - pivot.global_transform.origin).normalized()

		# Calculate the target rotation around the Y-axis
		var target_yaw = atan2(direction.x, direction.z)
		pivot.rotation.y = target_yaw

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		anim_player.play("idle")
