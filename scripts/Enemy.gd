extends Node2D

#@export var name: String = "Enemy"
@export var hp: int = 30
@export var attack: int = 6

@onready var sprite = $Sprite2D
@onready var hp_label = $HP

func _ready():
	update_ui()

func update_ui():
	if hp_label:
		hp_label.text = "%s  HP: %d" % [name, hp]

func take_damage(amount: int):
	hp -= amount
	if hp < 0:
		hp = 0
	update_ui()
	print("%s takes %d damage! HP: %d" % [name, amount, hp])
