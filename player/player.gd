extends CharacterBody3D

const SPEED = 5.5
const GRAVITY = -9.8

var sensitivity : float =  10
var controller_sensitivity : float =  .010
var in_lit_area: bool = true
var axis_vector : Vector2
var mouse_captured : bool = true
var uv : bool

@onready var camera: Camera3D 
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle_flash: GPUParticles3D = $Pivot/pistol/GPUParticles3D
@onready var gunshot_sound: AudioStreamPlayer3D = %GunshotSound
@onready var pivot: Marker3D = $Pivot
@onready var flashlight: SpotLight3D = $Pivot/Flashlight
@onready var playermodel: Node3D = $Playermodel
@onready var player_phantom_cam: PhantomCamera3D = $Pivot/PlayerPhantomCam

func _ready() -> void:
	camera = owner.get_node("%MainCamera")


func _process(_delta: float) -> void:
	sensitivity = Global.sensitivity
	controller_sensitivity = Global.controller_sensitivity
	
	
	if Global.debug:
		Global.debug.add_property("in_lit_area", in_lit_area, 4)
		Global.debug.add_property("mousemode", Input.mouse_mode, 4)
	# Check if the aim button is pressed or released
	
	update_aim_mode()
	if Global.is_aiming:
		rotate_y(-axis_vector.x * controller_sensitivity)
		pivot.rotate_x(-axis_vector.y * controller_sensitivity)
		
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-45),deg_to_rad(45))
		pivot.rotation.y = clamp(pivot.rotation.y, deg_to_rad(-45),deg_to_rad(45))
		pivot.rotation.z = clamp(pivot.rotation.z, 0,0)
	

func _input(event: InputEvent) -> void:
	
	
	if event.is_action_pressed("flashlight") and !StoryEventListener.flash_is_out:
		flashlight.visible = not flashlight.visible
	
	if event.is_action_pressed("shoot"):
		shoot()
		flashlight.light_color = Color.hex(0xa600ffff)
	elif event.is_action_released("shoot"):
		flashlight.light_color = Color.hex(0xffffffff)
	
func _unhandled_input(event: InputEvent) -> void:
	
	axis_vector = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if event is InputEventMouseMotion and Global.is_aiming:
		pivot.rotate_y(-event.relative.x * sensitivity)
		pivot.rotate_x(-event.relative.y * sensitivity)


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
	if !Global.is_aiming:
		rotate_towards_mouse()

func shoot() -> void:
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func update_aim_mode() -> void:
	
	if Global.is_aiming:
		playermodel.hide()
		player_phantom_cam.set_priority(2)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	else:
		playermodel.show()
		pivot.rotation = Vector3.ZERO
		player_phantom_cam.set_priority(0)
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
	
	if cursor_position_on_plane:
		look_at(cursor_position_on_plane, Vector3.UP, 0)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		anim_player.play("idle")


func _on_sanity_timer_timeout() -> void:
	if in_lit_area:
		Global.insanity -= 2
	elif flashlight.visible:
		Global.insanity -= 1
	else:
		Global.insanity += 1
	Global.insanity = clamp(Global.insanity, 0, 100)
