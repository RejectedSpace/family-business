extends Node3D

func _ready() -> void:
	$LongFourWay/DoorPoints/s1.set_enabled(true)
	$LongFourWay2/DoorPoints/s1.set_enabled(true)
	$LongFourWay2/DoorPoints/s3.set_enabled(true)
	$LongFourWay3/DoorPoints/s3.set_enabled(true)
	$Enemy.update_target($Player)
