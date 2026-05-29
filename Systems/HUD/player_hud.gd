extends Node2D

@onready var hp: Label = $Health/Panel/HP
@onready var clip: Label = $Ammo/Panel/Clip
@onready var reserve: Label = $Ammo/Panel/Reserve
@onready var cash = $Cash/Panel/Cash
@onready var time = $TimeLeft/Panel/Time
@onready var money_tool_tip = $MoneyToolTip

func _process(delta: float) -> void:
	cash.set_text("$" + str(Global.cash))

func update_health(value: int) -> void:
	hp.set_text(str(value))

func update_time(value: float) -> void:
	time.set_text(str(floor(value)))

func update_clip(value: int) -> void:
	clip.set_text(str(value))

func update_reserve(value: int) -> void:
	reserve.set_text(str(value))

func show_money_tip(value: bool) -> void:
	money_tool_tip.visible = value
