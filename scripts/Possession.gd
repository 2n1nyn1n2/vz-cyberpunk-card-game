extends Control
class_name Possession

@export var possession_name: String = "Possession"
@export var possession_count: int = 0
@export var possession_image_texture: Resource;

# Node references
#@onready var texture_rect = $PossessionImage
#@onready var play_button = $PlayButton
#@onready var anim = $AnimationPlayer

const POSSESSION_SIZE = Vector2(64, 64)

func _ready():
	# Set min size
	custom_minimum_size = POSSESSION_SIZE

func update_ui():
	var possession_image = $PossessionImage
	var possession_count_label = $PossessionCount
	
	#print("Possession:", possession_image_texture, " possession_image:", possession_image)
	
	if possession_count_label:
		possession_count_label.text = "%s" % [possession_count]

	if possession_image_texture:
		possession_image.texture = possession_image_texture
		possession_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		possession_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		#possession_image.size = possession_image_texture.get_size()
		possession_image.custom_minimum_size = POSSESSION_SIZE
