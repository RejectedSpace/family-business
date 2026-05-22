extends Entity

enum {
	IDLE,
	ACTIVE
}

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var animator: AnimationPlayer = $Infected/AnimationPlayer
@onready var ray_cast: RayCast3D = $RayCast3D
@onready var groan_sound: AudioStreamPlayer3D = $GroanSound
@onready var scream_sound: AudioStreamPlayer3D = $ScreamSound
@onready var chase_sound: AudioStreamPlayer3D = $ChaseSound
@onready var step_sound: AudioStreamPlayer3D = $StepSound
@onready var groan_timer: Timer = $GroanTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var step_timer: Timer = $StepTimer
@onready var hunt_timer: Timer = $HuntTimer

var state: int = IDLE
var player: Node3D

const SPEED: float = 60
const EPSILON: float = 0.75
const SIGHT_DISTANCE: float = 100.0
const FOV: float = 190.0
const SMOOTHING_FACTOR = 0.2

func _ready() -> void:
	Global.enemies += 1
	
	step_sound.set_volume_db(5)

func die() -> void:
	Global.enemies -= 1
	dead = true
	queue_free()

func _physics_process(delta: float) -> void:
	if player:
		looking()
	
	if ray_cast.get_collider() == player:
		update_target_location()
	
	var current_pos: Vector3 = global_transform.origin
	var next_pos: Vector3 = agent.get_next_path_position()
	var distance: Vector3 = next_pos - current_pos
	
	if agent.is_target_reached() and state == ACTIVE and global_position.distance_to(player.global_position) <= 5:
		attack()
	
	if not attack_timer.is_stopped() or agent.get_target_position().is_zero_approx() or agent.is_target_reached():
		if not step_timer.is_stopped():
			step_timer.timeout.emit()
			step_timer.stop()
		state = IDLE
	else:
		if state == IDLE:
			chase_sound.play()
			step_timer.start()
			randomize_timer(chase_timer)
		state = ACTIVE
	
	if state == ACTIVE:
		hunt(distance, delta)
	else:
		idle(delta)
	
	handle_gravity(delta)
	
	move_and_slide()
	
	
	if state == ACTIVE:
		animator.play("ArmatureAction")
	else:
		animator.play("ArmatureAction_001")

func looking() -> void:
	if not player:
		return
 
	var to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var forward = global_transform.basis.x
	var angle_deg = rad_to_deg(acos(clamp(forward.dot(to_player), -1.0, 1.0)))
	var squared_distance = global_transform.origin.distance_squared_to(player.global_transform.origin)
	if angle_deg > FOV * 0.5 and squared_distance > 200 and hunt_timer.is_stopped():
		return
	ray_cast.look_at(ray_cast.global_transform.origin + to_player, Vector3.UP)

func attack() -> void:
	if player:
		player.hurt(10)
	attack_timer.start()

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func hunt(distance: Vector3, delta: float) -> void:
	
	var desired_direction: Vector3 = distance.normalized()
	
	rotation.y = rotate_toward(rotation.y, Vector2(desired_direction.x, -desired_direction.z).angle(), 15 * delta)
	
	var new_velocity: Vector3 = Vector3(desired_direction.x * SPEED, velocity.y, desired_direction.z * SPEED)
	
	velocity = velocity.move_toward(new_velocity, 100000 * delta)

func idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 100000 * delta)
	velocity.z = move_toward(velocity.z, 0, 100000 * delta)

func update_target_location() -> void:
	if player:
		agent.set_target_position(player.global_transform.origin)
		print('gotcha')
		hunt_timer.start()

func update_target(target: Node3D) -> void:
	player = target

func randomize_timer(timer: Timer) -> void:
	var rand_val = randf() + 0.5
	timer.start(timer.get_wait_time() * rand_val)

func _on_groan_timer_timeout() -> void:
	if state == IDLE:
		groan_sound.play()
	else:
		randomize_timer(groan_timer)

func _on_groan_sound_finished() -> void:
	randomize_timer(groan_timer)

func _on_chase_timer_timeout() -> void:
	if state == ACTIVE:
		chase_sound.play()
	else:
		randomize_timer(chase_timer)

func _on_chase_sound_finished() -> void:
	randomize_timer(chase_timer)

func _on_step_timer_timeout() -> void:
	step_sound.play()
	step_timer.start()
