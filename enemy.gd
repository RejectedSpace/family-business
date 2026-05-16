extends Entity

enum {
	IDLE,
	ACTIVE
}

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var animator: AnimationPlayer = $Infected/AnimationPlayer
@onready var attack_timer: Timer = $AttackTimer

var state: int = IDLE
var player: Node3D

const SPEED: float = 60
const EPSILON: float = 0.75

func _ready() -> void:
	Global.enemies += 1

func die() -> void:
	Global.enemies -= 1
	dead = true
	queue_free()

func _physics_process(delta: float) -> void:
	
	update_target_location()
	
	var current_pos: Vector3 = global_transform.origin
	var next_pos: Vector3 = agent.get_next_path_position()
	var distance: Vector3 = next_pos - current_pos
	
	if agent.is_target_reached() and state == ACTIVE:
		attack()
	
	if not attack_timer.is_stopped() or agent.get_final_position().is_equal_approx(global_transform.origin):
		state = IDLE
	else:
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

func attack() -> void:
	if player:
		player.hurt(10)
		print(player.health)
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

func update_target(target: Node3D) -> void:
	player = target
	agent.set_target_position(target.global_transform.origin)
