extends Node3D

@onready var map: Node3D = $Map
@onready var player: Entity = $Player
@onready var elevator: Node3D = $Elevator
@onready var timer: Timer = $Timer

func _ready() -> void:
	map.MAPSIZE += Vector3(Global.get_quota_count() * 2, Global.get_quota_count() / 2, Global.get_quota_count() * 2)
	map.generate()
	get_tree().call_group("enemies", "set_target", [player])

func _process(delta) -> void:
	elevator.set_label(str("Quota:\n$", Global.cash, " / $", Global.get_quota(), "\n", 2 - Global.level_count % 3, " Floors Left"))
	player.hud.update_time(timer.get_time_left() if timer.get_time_left() != 0 else timer.get_wait_time())

func _on_elevator_closed() -> void:
	var scene = "Systems/Generation/level" if Global.level_count % 3 < 2 else "Rooms/Permanent/shop"
	
	Global.next_scene = "res://" + scene + ".tscn"
	Global.player_1_data = player.get_data() if player.global_position.z < 0 else []
	Global.level_count += 1
	get_tree().change_scene_to_packed(Global.loading_scene)

func _on_timer_timeout() -> void:
	player.die()

func _on_elevator_opened() -> void:
	timer.start()
