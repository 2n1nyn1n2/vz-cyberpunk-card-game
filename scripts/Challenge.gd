extends Control

@export var challenge_name: String = "Challenge"
@export var hp: int = 30
@export var attack: int = 6

@onready var hp_label = $HP
@onready var challenge_name_label = $ChallengeName
@onready var challenge_image = $ChallengeImage

const CHALLENGE_SIZE = Vector2(256, 256)

func _ready():
	challenge_image.custom_minimum_size = CHALLENGE_SIZE
	challenge_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	challenge_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	update_ui()

func update_ui():
	if hp_label:
		hp_label.text = "%s  HP: %d" % [name, hp]
	if challenge_name_label:
		challenge_name_label.text = "%s" % [challenge_name]

func take_damage(amount: int):
	hp -= amount
	if hp < 0:
		hp = 0
	update_ui()
	print("%s takes %d damage! HP: %d" % [name, amount, hp])
