extends CharacterBody3D

const SPEED = 5.5
const GRAVITY = -9.8

var sensitivity : float =  .005
var controller_sensitivity : float =  .010

var axis_vector : Vector2
var mouse_captured : bool = true
var uv : bool

@onready var camera: Camera3D = $Pivot/Camera
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_flash: GPUParticles3D = $Pivot/Camera/pistol/GPUParticles3D
@onready var raycast: RayCast3D = $Pivot/Camera/RayCast3D
@onready var gunshot_sound: AudioStreamPlayer3D = %GunshotSound
@onready var pivot: Marker3D = $Pivot
@onready var flashlight: SpotLight3D = $Pivot/Camera/Flashlight
@onready var playermodel: Node3D = $Playermodel



func _ready() -> void:
	camera.current = false

func _process(_delta: float) -> void:
	sensitivity = Global.sensitivity
	controller_sensitivity = Global.controller_sensitivity
	
	# Check if the aim button is pressed or released
	
	if Global.is_aiming:
		rotate_y(-axis_vector.x * controller_sensitivity)
		camera.rotate_x(-axis_vector.y * controller_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45),deg_to_rad(45))
		camera.rotation.y = clamp(camera.rotation.y, deg_to_rad(-45),deg_to_rad(45))
		camera.rotation.z = clamp(camera.rotation.z, 0,0)
	
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("aim"):
		Global.is_aiming = true
		update_aim_mode()
		
	elif Input.is_action_just_released("aim"):
		Global.is_aiming = false
		update_aim_mode()
	
	if event.is_action_pressed("flashlight"):
		flashlight.visible = not flashlight.visible
	
	if event.is_action_pressed("shoot"):
		flash_uv()
		flashlight.light_color = Color.hex(0xa600ffff)
	elif event.is_action_released("shoot"):
		flashlight.light_color = Color.hex(0xffffffff)
	
func _unhandled_input(event: InputEvent) -> void:
	
	
	axis_vector = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if event is InputEventMouseMotion and Global.is_aiming:
		camera.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
	
	



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

	if not Global.is_aiming:
		rotate_towards_mouse()

func flash_uv() -> void:
	
	
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func update_aim_mode() -> void:
	
	
	if Global.is_aiming:
		playermodel.hide()
		camera.current = true
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	else:
		playermodel.show()
		camera.current = false
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.rotation.x = 0
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func rotate_towards_mouse():
	var current_camera = get_viewport().get_camera_3d()
	if not current_camera:
		return
	# Get mouse position in world space
	var target_plane_mouse = Plane(Vector3(0,1,0), position.y)
	var mouse_pos = get_viewport().get_mouse_position()
	var from = current_camera.project_ray_origin(mouse_pos)
	var to = from + current_camera.project_ray_normal(mouse_pos) * 1000
	var cursor_position_on_plane = target_plane_mouse.intersects_ray(from, to)
	look_at(cursor_position_on_plane, Vector3.UP, 0)
	
	if Global.debug:
		Global.debug.add_property("MousePos", get_viewport().get_mouse_position(), 2)
		Global.debug.add_property("CursorOnPlane", cursor_position_on_plane, 2)
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		anim_player.play("idle")
