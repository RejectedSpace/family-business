extends CharacterBody3D

# 83 Hu = 24 m

const SPEED = 120
const BACKWARD_MULTIPLIER = 0.9
const POSTURE_MULTIPLIER = 0.6
const JUMP_VELOCITY = 85
const MAX_AIR_JUMPS = 1
var air_jumps: int
var crouched: bool
var running: bool
@onready var camera = $Camera3D
@onready var playerAnimator = $Bagman/AnimationPlayer

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_input(delta)
	handle_movement()

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_input(delta: float) -> void:
	handle_jump()
	handle_pause()
	handle_crouch()
	handle_sprint()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.01)
		
		camera.rotate_x(-event.relative.y*0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

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

func handle_movement() -> void:
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var move_speed = SPEED
	
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
