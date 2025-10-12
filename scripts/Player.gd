extends Node2D

@export var max_hp: int = 50
var hp: int
var block: int = 0

@onready var hp_label = $HP

func _ready():
	hp = max_hp
	update_ui()

func update_ui():
	if hp_label:
		hp_label.text = "HP: %d  Block: %d" % [hp, block]

func add_block(amount: int):
	block += amount
	update_ui()

func take_damage(amount: int):
	var remaining = amount
	if block > 0:
		var absorbed = min(block, amount)
		block -= absorbed
		remaining -= absorbed
	hp -= remaining
	if hp < 0:
		hp = 0
	update_ui()
	print("Player takes %d damage (remaining HP: %d)" % [amount, hp])
	if hp == 0:
		print("💀 Player defeated!")
