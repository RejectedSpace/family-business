extends Entity

# 83 Hu = 24 m

@onready var camera: Camera3D = $Camera3D
@onready var playerAnimator: AnimationPlayer = $Bagman/AnimationPlayer
@onready var viewport: SubViewport = $Camera3D/SubViewportContainer/SubViewport
@onready var view_model_camera: Camera3D = $Camera3D/SubViewportContainer/SubViewport/ViewModel
@onready var hud: Node2D = $PlayerHUD
@onready var gun: Gun = $Lupara
@onready var hitscan: Node3D = gun.get_hitscan()
@onready var step_sound: AudioStreamPlayer3D = $StepSound
@onready var step_timer: Timer = $StepTimer

var air_jumps: int
var crouched: bool
var running: bool

const SPEED: float = 120.0
const STEP_FREQUENCY: float = 40.0
const BACKWARD_MULTIPLIER: float = 0.9
const POSTURE_MULTIPLIER: float = 0.6
const JUMP_VELOCITY: float = 85.0
const MAX_AIR_JUMPS: int = 1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	viewport.size = DisplayServer.window_get_size()
	
	hitscan.global_transform = camera.global_transform
	
	load_data(Global.player_data)
	
	hud.update_health(health)
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_input(delta)
	handle_movement()
	handle_step_sound()
	view_model_camera.global_transform = camera.global_transform

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func shoot() -> void:
	var hitscan_dupe = gun.get_hitscan().duplicate()
	add_child(hitscan_dupe)
	hitscan_dupe.global_transform = camera.global_transform
	
	for ray: RayCast3D in hitscan_dupe.get_children():
		ray.force_raycast_update()
		var hit = ray.get_collider()
		if hit is Entity:
			hit.hurt(gun.get_damage())
	
	remove_child(hitscan_dupe)
	
	view_model_camera.play("Fire")
	gun.shoot()
	hud.update_clip(gun.get_clip())

func reload() -> void:
	view_model_camera.play("Reload")

func handle_input(delta: float) -> void:
	handle_jump()
	handle_pause()
	handle_crouch()
	handle_sprint()
	handle_shoot()
	handle_reload()
	if Input.is_action_just_pressed("ctrl"):
		view_model_camera.play("Holster")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.01)
		
		camera.rotate_x(-event.relative.y*0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		view_model_camera.sway(Vector2(-event.relative.x, event.relative.y))

func handle_jump() -> void:
	if is_on_floor():
		air_jumps = MAX_AIR_JUMPS
	if Input.is_action_just_pressed("ui_accept"): 
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif air_jumps > 0:
			air_jumps -= 1
			velocity.y = JUMP_VELOCITY

func handle_pause() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func handle_crouch() -> void:
	if Input.is_action_just_pressed("ctrl"):
		crouched = true
		#playerAnimator.play("Crouch")
	if Input.is_action_just_released("ctrl"):
		crouched = false
		#playerAnimator.play("Uncrouch")

func handle_sprint() -> void:
	if Input.is_action_just_pressed("shift"):
		running = true
	if Input.is_action_just_released("shift"):
		running = false

func handle_shoot() -> void:
	if Input.is_action_pressed("mb1") and not gun.clip_empty() and not view_model_camera.is_busy():
		shoot()

func handle_reload() -> void:
	if Input.is_action_just_pressed("r") and not gun.clip_full() and not gun.no_ammo() and not view_model_camera.is_busy():
		reload()

#Override
func hurt(damage: float) -> void:
	super.hurt(damage)
	hud.update_health(health)

#Override
func die() -> void:
	get_tree().quit()

func handle_movement() -> void:
	var input_dir: Vector2 = Input.get_vector("a", "d", "w", "s")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var move_speed: float = SPEED
	
	if input_dir.y >= 0:
		move_speed *= BACKWARD_MULTIPLIER
	if crouched:
		move_speed *= POSTURE_MULTIPLIER
	if not running:
		move_speed *= POSTURE_MULTIPLIER
	
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	
	if(direction):
		playerAnimator.play("ArmatureAction")
	else:
		playerAnimator.play("RESET")
	move_and_slide()

func handle_step_sound() -> void:
	if not is_on_floor():
		step_timer.stop()
		return
	var speed = get_real_velocity().length()
	if is_zero_approx(speed):
		if not step_timer.is_stopped():
			step_timer.timeout.emit()
		step_timer.stop()
		return
	var time_to_step = STEP_FREQUENCY / speed
	step_sound.set_volume_db(2 / time_to_step)
	if step_timer.is_stopped() or time_to_step < step_timer.get_time_left():
		step_timer.start(time_to_step)

func get_data() -> Array:
	return [global_position, rotation, velocity, air_jumps, gun.get_clip(), gun.get_ammo()]

func load_data(data: Array) -> void:
	if data.is_empty():
		return
	
	global_position = data[0]
	rotation = data[1]
	velocity = data[2]
	air_jumps = data[3]
	gun.clip = data[4]
	gun.ammo = data[5]
	
	hud.update_health(health)
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())


func _on_view_model_reload_finished() -> void:
	gun.reload()
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())


func _on_step_timer_timeout() -> void:
	step_sound.play()
