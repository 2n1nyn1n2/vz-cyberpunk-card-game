extends Control
class_name Action

@export var action_name: String = "Action"
@export var cost: int = 1
@export var damage: int = 0
@export var action_image_texture: Resource;

signal action_played(action)

# Node references
#@onready var texture_rect = $ActionImage
#@onready var play_button = $PlayButton
#@onready var anim = $AnimationPlayer

const ACTION_SIZE = Vector2(256, 256)

func _ready():
	# Set min size
	custom_minimum_size = ACTION_SIZE

func update_ui():
	var action_image = $ActionImage
	
	#print("Action:", action_image_texture, " action_image:", action_image)
	
	if action_image_texture:
		action_image.texture = action_image_texture
		action_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		action_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		#action_image.size = action_image_texture.get_size()
		action_image.custom_minimum_size = ACTION_SIZE

# Play button pressed
func on_play_pressed():
	emit_signal("action_played", self)
	var anim = $AnimationPlayer

	# Play animation safely
	if anim and anim.has_animation("play"):
		anim.play("play")
