extends Control

@export var player_name: String = "Player"
@export var max_hp: int = 50
var hp: int
var block: int = 0

@onready var hp_label = $HP
@onready var player_image = $PlayerImage
@onready var player_name_label = $PlayerName

const PLAYER_SIZE = Vector2(256, 256)

func _ready():
	hp = max_hp
	player_image.custom_minimum_size = PLAYER_SIZE
	player_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	player_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	update_ui()

func update_ui():
	if hp_label:
		hp_label.text = "HP: %d  Block: %d" % [hp, block]
	if player_name_label:
		player_name_label.text = "%s" % [player_name]
		
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
		
	print("Player takes %d damage (remaining HP: %d)" % [amount, hp])
	if hp == 0:
		print("💀 Player defeated!")
		
	update_ui()
