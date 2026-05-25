extends Entity

# 83 Hu = 24 m
class_name Player

@export var player_id: int = 1

@onready var camera: Camera3D = $Camera3D
@onready var modelAnimator: AnimationPlayer = $Bagman/AnimationPlayer
@onready var playerAnimator: AnimationPlayer = $AnimationPlayer
@onready var viewport_container: SubViewportContainer = $Camera3D/SubViewportContainer
@onready var viewport: SubViewport = $Camera3D/SubViewportContainer/SubViewport
@onready var view_model: Camera3D = $Camera3D/SubViewportContainer/SubViewport/ViewModel
@onready var hud: Node2D = $PlayerHUD
@onready var lupara_base: Gun = $LuparaBase
@onready var tommy_base: Gun = $TommyBase
@onready var colt_base: Gun = $ColtBase
@onready var gun: Gun
@onready var hitscan: Node3D
@onready var step_sound: AudioStreamPlayer3D = $StepSound
@onready var step_timer: Timer = $StepTimer
@onready var floor_cast: RayCast3D = $FloorCast

var air_jumps: int
var crouched: bool
var running: bool
var input_id: String = str(player_id)
var holstered_gun: Gun
enum Mult {
	HEALTH,
	SPEED,
	DAMAGE,
	CLIP,
	CAPPACITY
}
var mults: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]

var base_speed: float = 80.0
var speed: float
const STEP_FREQUENCY: float = 40.0
const BACKWARD_MULTIPLIER: float = 0.9
const POSTURE_MULTIPLIER: float = 0.6
const JUMP_VELOCITY: float = 85.0
const MAX_AIR_JUMPS: int = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	viewport.size = DisplayServer.window_get_size()
	
	speed = base_speed
	
	load_data(Global.player_1_data)
	
	apply_mults()
	
	hitscan.global_transform = camera.global_transform
	
	hud.update_health(health)
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())
	
	view_model.set_model(gun.get_view_model())

func apply_mults() -> void:
	health *= ceil(mults[Mult.HEALTH])
	speed = base_speed * mults[Mult.SPEED]
	gun.damage = gun.base_damage * mults[Mult.DAMAGE]
	gun.clip_size = gun.base_clip_size * ceil(mults[Mult.CLIP])
	gun.ammo_cappacity = gun.base_ammo_cappacity * ceil(mults[Mult.CAPPACITY])
	
	if holstered_gun:
		holstered_gun.damage = holstered_gun.base_damage * mults[Mult.DAMAGE]
		holstered_gun.clip_size = holstered_gun.base_clip_size * ceil(mults[Mult.CLIP])
		holstered_gun.ammo_cappacity = holstered_gun.base_ammo_cappacity * ceil(mults[Mult.CAPPACITY])

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_input(delta)
	handle_movement()
	handle_step_sound()
	view_model.global_transform = camera.global_transform

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func get_cash(money: int = 10):
	Global.cash += money

func give_item(item):
	if item is Gun:
		if not holstered_gun:
			holstered_gun = gun
		
		if item.name == "Lupara":
			gun = lupara_base.duplicate()
		elif item.name == "Tommy":
			gun = tommy_base.duplicate()
		else:
			gun = colt_base.duplicate()
		
		add_child(gun)
		
		gun.for_player(player_id)
		
		switch_to_current_gun()
	elif item is Modifier:
		call(item.get_modifier_function(), item.get_modifier_value())

func refill_ammo(proportion_filled: float) -> void:
	gun.clip = gun.clip_size
	gun.ammo = gun.ammo_cappacity
	
	if holstered_gun:
		holstered_gun.clip = holstered_gun.clip_size
		holstered_gun.ammo = holstered_gun.ammo_cappacity
	
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())

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
	
	view_model.play("Fire")
	gun.shoot()
	hud.update_clip(gun.get_clip())

func reload() -> void:
	view_model.play("Reload")

func handle_input(delta: float) -> void:
	handle_jump()
	handle_pause()
	handle_crouch()
	handle_sprint()
	handle_shoot()
	handle_reload()
	if Input.is_action_just_pressed("switch_" + input_id) and not view_model.is_busy() and holstered_gun:
		view_model.play("Holster")
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.01)
		
		camera.rotate_x(-event.relative.y*0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		view_model.sway(Vector2(-event.relative.x, event.relative.y))

func handle_jump() -> void:
	if is_on_floor():
		air_jumps = MAX_AIR_JUMPS
	if Input.is_action_just_pressed("jump_" + input_id): 
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif air_jumps > 0:
			air_jumps -= 1
			velocity.y = JUMP_VELOCITY

func handle_pause() -> void:
	if Input.is_action_just_pressed("pause_" + input_id):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func handle_crouch() -> void:
	if Input.is_action_just_pressed("crouch_" + input_id):
		crouched = true
		playerAnimator.play("Crouch")
	if Input.is_action_just_released("crouch_" + input_id):
		crouched = false
		playerAnimator.play("Uncrouch")

func handle_sprint() -> void:
	if Input.is_action_just_pressed("run_" + input_id):
		running = true
	if Input.is_action_just_released("run_" + input_id):
		running = false

func handle_shoot() -> void:
	if Input.is_action_pressed("attack_" + input_id) and not gun.clip_empty() and not view_model.is_busy():
		shoot()

func handle_reload() -> void:
	if Input.is_action_just_pressed("reload_" + input_id) and not gun.clip_full() and not gun.no_ammo() and not view_model.is_busy():
		reload()

#Override
func hurt(damage: float) -> void:
	super.hurt(damage)
	hud.update_health(health)

#Override
func die() -> void:
	Global.reset()
	Global.next_scene = "res://Systems/Menus/main.tscn"
	get_tree().change_scene_to_packed(Global.loading_scene)

func handle_movement() -> void:
	var input_dir: Vector2 = Input.get_vector("left_" + input_id, "right_" + input_id, "forward_" + input_id, "back_" + input_id)
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var move_speed: float = speed
	
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
		modelAnimator.play("ArmatureAction")
	else:
		modelAnimator.play("RESET")
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

func get_floor_position() -> Vector3:
	if not floor_cast.is_colliding():
		return global_position
	
	return floor_cast.get_collision_point()

func get_data() -> Array:
	return [global_position, rotation, velocity, air_jumps, gun.get_data(), null if not holstered_gun else holstered_gun.get_data(), mults]

func load_data(data: Array) -> void:
	if data.is_empty():
		give_item(colt_base)
		return
	
	global_position = data[0]
	rotation = data[1]
	velocity = data[2]
	air_jumps = data[3]
	give_item(data[4][0])
	gun.load_data(data[4])
	if data[5]:
		give_item(data[5][0])
		holstered_gun.load_data(data[5])
	mults = data[6]
	
	hud.update_health(health)
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())

func _on_view_model_reload_finished() -> void:
	gun.reload()
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())

func _on_step_timer_timeout() -> void:
	step_sound.play()

func _on_view_model_holstered() -> void:
	gun.visible = false
	
	var temp_gun = gun
	gun = holstered_gun
	holstered_gun = temp_gun
	
	switch_to_current_gun()

func switch_to_current_gun() -> void:
	hud.update_clip(gun.get_clip())
	hud.update_reserve(gun.get_ammo())
	
	hitscan = gun.get_hitscan()
	hitscan.global_transform = camera.global_transform
	
	gun.visible = true
	view_model.set_model(gun.get_view_model())
