extends Node2D

@onready var hp: Label = $Control/Health
@onready var mag: Label = $Control/Mag
@onready var reserve: Label = $Control/Reserve
@onready var cash = $Control/Cash
@onready var time = $Control/Time
@onready var money_tool_tip = $Control/MoneyToolTip

func _process(delta: float) -> void:
	cash.set_text("$" + str(Global.cash))

func update_health(value: int) -> void:
	hp.set_text(str(value, " HP"))

func update_time(value: float) -> void:
	var sec: int = int(value)
	time.set_text(str(sec / 60, ":", "%02d" % (sec % 60)))

func update_mag(value: int) -> void:
	mag.set_text(str(value))

func update_reserve(value: int) -> void:
	reserve.set_text(str(value))

func show_money_tip(value: bool) -> void:
	money_tool_tip.visible = value
