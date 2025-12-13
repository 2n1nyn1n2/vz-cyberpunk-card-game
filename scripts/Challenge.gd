extends Control

signal toggled(challenge_node)

@export var challenge_name: String = "Challenge"
@export var challenge_description: String = "Challenge Description"
@export var challenge_image_texture: Resource
@export var is_selectable = false

const CHALLENGE_SIZE = Vector2(512, 512)

var is_toggled = false
var is_hovering = false

const COLOR_OFF = Color.DARK_GRAY
const COLOR_ON = Color.LIGHT_GREEN
const COLOR_HOVER = Color.LIGHT_GRAY


func _ready():
	custom_minimum_size = CHALLENGE_SIZE


func update_ui():
	var challenge_background_rect = $Background
	challenge_background_rect.color = COLOR_OFF

	var challenge_image = $ChallengeImage
	var challenge_name_label = $ChallengeName
	var challenge_description_label = $ChallengeDescription

	#print("Character:", challenge_image_texture, " challenge_image:", challenge_image)
	if challenge_image_texture:
		challenge_image.texture = challenge_image_texture
		challenge_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		challenge_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		challenge_image.custom_minimum_size = CHALLENGE_SIZE

	if challenge_name_label:
		challenge_name_label.text = "%s" % [challenge_name]
	if challenge_description_label:
		challenge_description_label.text = "%s" % [challenge_description]


func _gui_input(event):
	if !is_selectable:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle()
			# Consumes the event so other nodes don't receive it
			get_viewport().set_input_as_handled()


func set_toggled_state(state: bool):
	is_toggled = state
	update_visuals()


func toggle():
	is_toggled = !is_toggled
	print("Character Toggle State: ", is_toggled)
	emit_signal("toggled", self, is_toggled)


func update_visuals():
	var challenge_background_rect = $Background
	if is_toggled:
		challenge_background_rect.color = COLOR_ON
	elif is_hovering:
		challenge_background_rect.color = COLOR_HOVER
	else:
		challenge_background_rect.color = COLOR_OFF


func _mouse_entered():
	if !is_selectable:
		return
	is_hovering = true
	update_visuals()


func _mouse_exited():
	if !is_selectable:
		return
	is_hovering = false
	update_visuals()
