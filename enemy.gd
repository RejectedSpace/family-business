extends CharacterBody3D

@onready var agent = $NavigationAgent3D

const SPEED = 90
const EPSILON = 0.75
enum {
	IDLE,
	ACTIVE
}
var state = ACTIVE


func _physics_process(delta: float) -> void:
	
	if state == ACTIVE:
		hunt(delta)
	else:
		idle(delta)
	
	handle_gravity(delta)
	
	move_and_slide()
	
	
	if not agent.is_target_reached() and (abs(velocity.x) > 0 or abs(velocity.z) > 0):
		$Infected/AnimationPlayer.play("ArmatureAction")
	else:
		$Infected/AnimationPlayer.play("ArmatureAction_001")

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func hunt(delta: float) -> void:
	var current_pos = global_transform.origin
	var next_pos = agent.get_next_path_position()
	var distance = next_pos - current_pos
	
	if distance.length() < EPSILON:
		velocity.x = move_toward(velocity.x, 0, 100000 * delta)
		velocity.z = move_toward(velocity.z, 0, 100000 * delta)
		return
	
	var desired_direction = distance.normalized()
	
	rotation.y = rotate_toward(rotation.y, Vector2(desired_direction.x, -desired_direction.z).angle(), 15 * delta)
	
	var new_velocity = desired_direction * SPEED
	
	velocity = velocity.move_toward(new_velocity, 100000 * delta)

func idle(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0

func update_target_location(target_pos) -> void:
	agent.set_target_position(target_pos)
