extends Entity

# 83 Hu = 24 m
class_name Player

@export var player_id: int = 1

@onready var camera: Camera3D = $Camera3D
@onready var bagman: Node3D = $Bagman
@onready var modelAnimator: AnimationPlayer = $Bagman/AnimationPlayer
@onready var playerAnimator: AnimationPlayer = $AnimationPlayer
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
@onready var money_sound: AudioStreamPlayer3D = $MoneySound

var blood = preload("res://Particles/blood.tscn")
var air_jumps: int
var crouched: bool
var running: bool
var input_id: String
var holstered_gun: Gun
enum Mult {
	HEALTH,
	SPEED,
	DAMAGE,
	MAG,
	RESERVE,
	CASH
}
var mults: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

var max_air_jumps: int = 0
var base_speed: float = 75.0
var max_health = base_health
var speed: float
var reward: int = 1
const STEP_FREQUENCY: float = 40.0
const BACKWARD_MULTIPLIER: float = 0.9
const POSTURE_MULTIPLIER: float = 0.6
const JUMP_VELOCITY: float = 85.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input_id = str(player_id)
	camera.set_cull_mask_value(player_id * 2 + 4, false)
	view_model.set_cull_mask_value(player_id * 2 + 5, true)
	view_model.player_id = player_id
	adjust_model_layer()
	
	load_data(Global.get_player_data(player_id))
	
	speed = base_speed
	
	apply_mults()
	regen()
	
	hitscan.global_transform = camera.global_transform
	
	hud.update_health(health)
	hud.update_mag(gun.get_mag())
	hud.update_reserve(gun.get_reserve())
	
	view_model.set_model(gun.get_view_model())

func adjust_model_layer() -> void:
	var all_descendants = bagman.find_children("*", "MeshInstance3D", true, false)
	for descendant in all_descendants:
		descendant.set_layer_mask(0)
		descendant.set_layer_mask_value(player_id * 2 + 4, true)

func apply_mults() -> void:
	max_health = ceil(base_health * mults[Mult.HEALTH])
	speed = base_speed * mults[Mult.SPEED]
	gun.damage = gun.base_damage * mults[Mult.DAMAGE]
	gun.mag_size = ceil(gun.base_mag_size * mults[Mult.MAG])
	gun.reserve_size = ceil(gun.base_reserve_size * mults[Mult.RESERVE])

	if holstered_gun:
		holstered_gun.damage = holstered_gun.base_damage * mults[Mult.DAMAGE]
		holstered_gun.mag_size = ceil(holstered_gun.base_mag_size * mults[Mult.MAG])
		holstered_gun.reserve_size = ceil(holstered_gun.base_reserve_size * mults[Mult.RESERVE])

func regen() -> void:
	health = min(health + ceil(max_health * .5), max_health)
	
	gun.reserve = min(gun.reserve + ceil(gun.reserve_size * .25), gun.reserve_size)
	
	if holstered_gun:
		holstered_gun.reserve = min(holstered_gun.reserve + ceil(holstered_gun.reserve_size * .25), holstered_gun.reserve_size)

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
	Global.cash += ceil(money * mults[Mult.CASH])
	money_sound.play()

func give_item(item: Item):
	var arg
	if item is Gun:
		arg = item
	elif item is Modifier:
		arg = item.get_modification_value()
	else:
		assert(false, "Given item of invalid type")
	
	call(item.get_function_name(), arg)

func equip_gun(new_gun: Gun):
	if not holstered_gun:
		holstered_gun = gun
		
	if new_gun.item_name == &"Lupara":
		gun = lupara_base.duplicate()
	elif new_gun.item_name == &"Tommy":
		gun = tommy_base.duplicate()
	elif new_gun.item_name == &"Colt":
		gun = colt_base.duplicate()
	else:
		assert(false, str("Equipped gun with invalid name (Name: ", new_gun.get_item_name(), ")"))
	
	add_child(gun)
	
	gun.for_player(player_id)
	
	switch_to_current_gun()

func refill_ammo(proportion_filled: float) -> void:
	gun.mag = gun.mag_size
	gun.reserve = gun.reserve_size
	
	if holstered_gun:
		holstered_gun.mag = holstered_gun.mag_size
		holstered_gun.reserve = holstered_gun.reserve_size
	
	hud.update_mag(gun.get_mag())
	hud.update_reserve(gun.get_reserve())

func heal_health(proportion_filled: float) -> void:
	health = max_health
	
	hud.update_health(health)

func increase_reserve(value: float) -> void:
	mults[Mult.RESERVE] += value
	
	var missing = gun.reserve_size - gun.reserve
	gun.reserve_size = ceil(gun.base_reserve_size * mults[Mult.RESERVE])
	gun.reserve = gun.reserve_size - missing
	
	if holstered_gun:
		missing = holstered_gun.reserve_size - holstered_gun.reserve
		holstered_gun.reserve_size = ceil(holstered_gun.base_reserve_size * mults[Mult.RESERVE])
		holstered_gun.reserve = holstered_gun.reserve_size - missing
	
	hud.update_reserve(gun.get_reserve())

func increase_mag(value: float) -> void:
	mults[Mult.MAG] += value
	
	var missing = gun.mag_size - gun.mag
	gun.mag_size = ceil(gun.base_mag_size * mults[Mult.MAG])
	gun.mag = gun.mag_size - missing
	
	if holstered_gun:
		missing = holstered_gun.mag_size - holstered_gun.mag
		holstered_gun.mag_size = ceil(holstered_gun.base_mag_size * mults[Mult.MAG])
		holstered_gun.mag = holstered_gun.mag_size - missing
	
	hud.update_mag(gun.get_mag())

func increase_health(value: float) -> void:
	mults[Mult.HEALTH] += value
	
	var missing = max_health - health
	max_health = ceil(base_health * mults[Mult.HEALTH])
	health = max_health - missing
	
	hud.update_health(health)

func increase_damage(value: float) -> void:
	mults[Mult.DAMAGE] += value
	
	gun.damage = ceil(gun.base_damage * mults[Mult.DAMAGE])
	
	if holstered_gun:
		holstered_gun.damage = ceil(holstered_gun.base_damage * mults[Mult.DAMAGE])

func increase_jumps(value: float) -> void:
	max_air_jumps += ceil(value)
	
	air_jumps = max_air_jumps

func increase_speed(value: float) -> void:
	mults[Mult.SPEED] += value
	
	speed = ceil(base_speed * mults[Mult.SPEED])

func increase_cash(value: float) -> void:
	mults[Mult.CASH] += value

func increase_reward(value: float) -> void:
	reward += ceil(value)

func shoot() -> void:
	var hitscan_dupe = gun.get_hitscan().duplicate()
	add_child(hitscan_dupe)
	hitscan_dupe.global_transform = camera.global_transform
	
	for ray: RayCast3D in hitscan_dupe.get_children():
		ray.force_raycast_update()
		var hit = ray.get_collider()
		if hit is Entity:
			hit.hurt_from(gun.get_damage(), self)
			spawn_blood(ray.get_collision_point())
	
	remove_child(hitscan_dupe)
	
	view_model.play("Fire")
	gun.shoot()
	hud.update_mag(gun.get_mag())

func spawn_blood(point: Vector3) -> void:
	var new_blood: GPUParticles3D = blood.instantiate()
	get_parent().add_child(new_blood)
	new_blood.global_position = point
	new_blood.restart()

func reload() -> void:
	view_model.play("Reload")

func handle_input(delta: float) -> void:
	handle_look()
	handle_jump()
	handle_pause()
	handle_crouch()
	handle_sprint()
	handle_shoot()
	handle_reload()
	handle_switch()

func handle_look() -> void:
	var look_vec = Input.get_vector("look_left_" + input_id, "look_right_" + input_id, "look_up_" + input_id, "look_down_" + input_id)
	
	rotate_y(-look_vec.x * Global.get_sensitivity(player_id))
	
	camera.rotate_x(-look_vec.y * Global.get_sensitivity(player_id))
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	view_model.sway(Vector2(-look_vec.x * Global.get_sensitivity(player_id) * 100, look_vec.y * Global.get_sensitivity(player_id) * 100))

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
		air_jumps = max_air_jumps
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
	if Input.is_action_pressed("attack_" + input_id) and not gun.mag_empty() and not view_model.is_busy():
		shoot()

func handle_reload() -> void:
	if Input.is_action_just_pressed("reload_" + input_id) and not gun.mag_full() and not gun.reserve_empty() and not view_model.is_busy():
		reload()

func handle_switch() -> void:
	if Input.is_action_just_pressed("switch_" + input_id) and not view_model.is_busy() and holstered_gun:
		view_model.play("Holster")

#Override
func hurt(damage: float) -> void:
	super.hurt(damage)
	hud.update_health(health)

#Override
func die() -> void:
	Global.next_scene = "res://Systems/Menus/game_over.tscn"
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
	
	var suffix = "Colt" if gun.rarity == 1 else ""
	if direction:
		modelAnimator.play("Run" + suffix)
	else:
		modelAnimator.play("Idle" + suffix)
	move_and_slide()

func handle_step_sound() -> void:
	if not is_on_floor():
		step_timer.stop()
		return
	var step_speed = get_real_velocity().length()
	if is_zero_approx(step_speed):
		if not step_timer.is_stopped():
			step_timer.timeout.emit()
		step_timer.stop()
		return
	var time_to_step = STEP_FREQUENCY / step_speed
	step_sound.set_volume_db(2 / time_to_step)
	if step_timer.is_stopped() or time_to_step < step_timer.get_time_left():
		step_timer.start(time_to_step)

func get_floor_position() -> Vector3:
	if not floor_cast.is_colliding():
		return global_position
	
	return floor_cast.get_collision_point()

func get_data() -> Array:
	return [global_position, rotation, velocity, air_jumps, max_air_jumps, gun.get_data(), [] if not holstered_gun else holstered_gun.get_data(), mults, health, reward]

func load_data(data: Array) -> void:
	if data.is_empty():
		give_item(colt_base)
		return
	
	global_position = data[0]
	rotation = data[1]
	velocity = data[2]
	air_jumps = data[3]
	max_air_jumps = data[4]
	
	if not data[6].is_empty():
		give_item(data[6][0])
		gun.load_data(data[6])
	
	give_item(data[5][0])
	gun.load_data(data[5])
	
	mults = data[7]
	health = data[8]
	reward = data[9]
	
	hud.update_health(health)
	hud.update_mag(gun.get_mag())
	hud.update_reserve(gun.get_reserve())

func _on_view_model_reload_finished() -> void:
	gun.reload()
	hud.update_mag(gun.get_mag())
	hud.update_reserve(gun.get_reserve())

func _on_step_timer_timeout() -> void:
	step_sound.play()

func _on_view_model_holstered() -> void:
	gun.visible = false
	
	var temp_gun = gun
	gun = holstered_gun
	holstered_gun = temp_gun
	
	switch_to_current_gun()

func switch_to_current_gun() -> void:
	hud.update_mag(gun.get_mag())
	hud.update_reserve(gun.get_reserve())
	
	hitscan = gun.get_hitscan()
	hitscan.global_transform = camera.global_transform
	
	view_model.set_model(gun.get_view_model())
