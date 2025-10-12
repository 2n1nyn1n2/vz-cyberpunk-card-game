extends Control
class_name Card

@export var card_name: String = "Card"
@export var cost: int = 1
@export var damage: int = 0
@export var face_texture: Texture2D

signal card_played(card)

# Node references
#@onready var texture_rect = $CardImage
#@onready var play_button = $PlayButton
#@onready var anim = $AnimationPlayer

const CARD_SIZE = Vector2(150, 150)

func _ready():
	# Set card size
	custom_minimum_size = CARD_SIZE

# Play button pressed
func on_play_pressed():
	emit_signal("card_played", self)
	var anim = $AnimationPlayer

	# Play animation safely
	if anim and anim.has_animation("play"):
		anim.play("play")
