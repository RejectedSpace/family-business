extends Entity

enum {
	IDLE,
	AWAKE,
	SCREAM,
	CHASE,
	ATTACK,
	AWARE
}

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var animator: AnimationPlayer = $Infected/AnimationPlayer
@onready var ray_cast: RayCast3D = $RayCast3D
@onready var hitscan: RayCast3D = $HitScan
@onready var groan_sound: AudioStreamPlayer3D = $GroanSound
@onready var scream_sound: AudioStreamPlayer3D = $ScreamSound
@onready var chase_sound: AudioStreamPlayer3D = $ChaseSound
@onready var step_sound: AudioStreamPlayer3D = $StepSound
@onready var groan_timer: Timer = $GroanTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var step_timer: Timer = $StepTimer
@onready var aware_timer: Timer = $AwareTimer
@onready var attack_timer: Timer = $AttackTimer

var state: int = IDLE
var players: Array
var target: Entity

const SPEED: float = 60
const EPSILON: float = 0.75
const SIGHT_DISTANCE: float = 100.0
const FOV: float = 190.0
const SMOOTHING_FACTOR = 0.2

func _ready() -> void:
	step_sound.set_volume_db(15)
	
	agent.set_target_position(Vector3.ZERO)

func die() -> void:
	dead = true
	
	for x in range(0, target.reward):
		var cash = preload("res://Items/Consumable/cash.tscn").instantiate()
		cash.position = ray_cast.global_position
		cash.rotation = rotation
		var rand_vel = Vector3(randf_range(-25, 25), 25, randf_range(-25, 25))
		cash.linear_velocity = velocity + rand_vel
		get_parent().add_child(cash)
	
	queue_free()

func _physics_process(delta: float) -> void:
	if players:
		var closest_distance
		var closest_player
		for player in players:
			looking(player)
			if ray_cast.get_collider() == player:
				var distance = global_transform.origin.distance_squared_to(player.global_transform.origin)
				if not closest_distance or distance < closest_distance:
					closest_distance = distance
					closest_player = player
			
		if closest_player:
			update_target_location(closest_player)
	
	handle_state(delta)
	
	apply_gravity(delta)
	
	move_and_slide()
	
	if state == CHASE:
		animator.play("Run")
	elif state == IDLE or state == AWARE:
		animator.play("Idle")

func looking(player: Node3D) -> void:
	var to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var forward = global_transform.basis.x
	var angle_deg = rad_to_deg(acos(clamp(forward.dot(to_player), -1.0, 1.0)))
	var squared_distance = global_transform.origin.distance_squared_to(player.global_transform.origin)
	
	if angle_deg > FOV * 0.5 and squared_distance > 200 and state != AWARE:
		return
	ray_cast.look_at(ray_cast.global_transform.origin + to_player, Vector3.UP)

func in_hitscan(player: Node3D) -> bool:
	return hitscan.get_collider() == player

func handle_state(delta: float) -> void:
	if agent.get_target_position().is_zero_approx() or agent.is_target_reached():
		if not players or not is_target_current():
			idle(delta)
		elif players and players.any(in_hitscan):
			attack()
		else:
			chase(delta)
	else:
		if state == IDLE or state == AWARE:
			if agent.get_path_length() > 96 and randi() % 3 == 0:
				scream()
			else:
				awake()
		elif state == CHASE:
			if players and players.any(in_hitscan):
				attack()
			else:
				chase(delta)

func is_target_current() -> bool:
	for player in players:
		if agent.get_target_position().is_equal_approx(player.get_floor_position()):
			return true
	return false

func attack() -> void:
	if players and state != ATTACK:
		attack_timer.start()
		animator.play("Attack")
		end_chase()
	state = ATTACK
	
	agent.set_velocity(Vector3(0, velocity.y, 0))

func hit() -> void:
	if players:
		for player in players:
			if in_hitscan(player):
				player.hurt(10)

func hurt_from(damage: float, player: Node3D) -> void:
	update_target_location(player)
	hurt(damage)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func scream() -> void:
	state = SCREAM
	animator.play("ScreamStart")
	scream_sound.play()

func awake() -> void:
	state = AWAKE
	animator.play("Awake")
	chase_sound.play()

func chase(delta: float) -> void:
	
	var current_pos: Vector3 = global_transform.origin
	var next_pos: Vector3 = agent.get_next_path_position()
	var distance: Vector3 = next_pos - current_pos
	
	var desired_direction: Vector3 = distance.normalized()
	
	rotation.y = rotate_toward(rotation.y, Vector2(desired_direction.x, -desired_direction.z).angle(), 15 * delta)
	
	var new_velocity: Vector3 = Vector3(desired_direction.x * SPEED, velocity.y, desired_direction.z * SPEED)
	
	agent.set_velocity(new_velocity)

func start_chase() -> void:
	state = CHASE
	step_timer.start()
	randomize_timer(chase_timer)

func end_chase() -> void:
	if not step_timer.is_stopped():
		step_timer.timeout.emit()
		step_timer.stop()

func idle(delta: float) -> void:
	if state == AWAKE or state == SCREAM:
		state = IDLE
	elif state == CHASE or state == ATTACK:
		state = AWARE
		aware_timer.start()
		end_chase()
	
	agent.set_velocity(Vector3(0, velocity.y, 0))

func update_target_location(player: Node3D) -> void:
	if player:
		target = player
		agent.set_target_position(player.get_floor_position())

func set_target(targets: Array) -> void:
	players = targets

func randomize_timer(timer: Timer) -> void:
	var rand_val = randf() + 0.5
	timer.start(timer.get_wait_time() * rand_val)

func _on_groan_timer_timeout() -> void:
	if state == IDLE or state == AWARE:
		groan_sound.play()
	else:
		randomize_timer(groan_timer)

func _on_groan_sound_finished() -> void:
	randomize_timer(groan_timer)

func _on_chase_timer_timeout() -> void:
	if state == CHASE:
		chase_sound.play()
	else:
		randomize_timer(chase_timer)

func _on_chase_sound_finished() -> void:
	randomize_timer(chase_timer)

func _on_step_timer_timeout() -> void:
	step_sound.play()
	step_timer.start()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Awake" or anim_name == "ScreamEnd" or anim_name == "Attack":
		start_chase()

func _on_aware_timer_timeout() -> void:
	if state == AWARE:
		state = IDLE

func _on_scream_sound_finished() -> void:
	animator.play("ScreamEnd")

func _on_attack_timer_timeout() -> void:
	hit()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 100000 * 0.016)
