extends StaticBody3D

@onready var spot_down_left: SpotLight3D = $SpotDownL
@onready var spot_up_left: SpotLight3D = $SpotUpL
@onready var spot_down_right: SpotLight3D = $SpotDownR
@onready var spot_up_right: SpotLight3D = $SpotUpR

func _ready() -> void:
	var ramdom: int = randi() % 16
	if ramdom < 2:
		visible = false
	else:
		visible = true
		var left_visible: bool = ramdom % 4 != 0
		spot_down_left.visible = left_visible
		spot_up_left.visible = left_visible
		
		var right_visible: bool = ramdom / 2 % 4 != 0
		spot_down_right.visible = right_visible
		spot_up_right.visible = right_visible
