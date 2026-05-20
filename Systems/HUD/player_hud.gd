extends Node2D

@onready var hp: Label = $Health/Panel/HP
@onready var clip: Label = $Ammo/Panel/Clip
@onready var reserve: Label = $Ammo/Panel/Reserve
@onready var enemies = $Enemies/Panel/Enemies

func _process(delta: float) -> void:
	enemies.set_text(str(Global.enemies))

func update_health(value: int) -> void:
	hp.set_text(str(value))

func update_clip(value: int) -> void:
	clip.set_text(str(value))

func update_reserve(value: int) -> void:
	reserve.set_text(str(value))
