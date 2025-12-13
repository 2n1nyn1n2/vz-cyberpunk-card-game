extends Control

signal toggled(character_node)

@export var character_name: String = "Character"
@export var character_description: String = "Character Description"
@export var character_image_texture: Resource
@export var is_selectable = false

const PLAYER_SIZE = Vector2(512, 512)

var is_toggled = false
var is_hovering = false

const COLOR_OFF = Color.DARK_GRAY
const COLOR_ON = Color.LIGHT_GREEN
const COLOR_HOVER = Color.LIGHT_GRAY


func _ready():
	custom_minimum_size = PLAYER_SIZE


func update_ui():
	var character_background_rect = $Background
	character_background_rect.color = COLOR_OFF

	var character_image = $CharacterImage
	var character_name_label = $CharacterName
	var character_description_label = $CharacterDescription

	#print("Character:", character_image_texture, " character_image:", character_image)
	if character_image_texture:
		character_image.texture = character_image_texture
		character_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		character_image.custom_minimum_size = PLAYER_SIZE

	if character_name_label:
		character_name_label.text = "%s" % [character_name]

	if character_description_label:
		character_description_label.text = "%s" % [character_description]


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
	var character_background_rect = $Background
	if is_toggled:
		character_background_rect.color = COLOR_ON
	elif is_hovering:
		character_background_rect.color = COLOR_HOVER
	else:
		character_background_rect.color = COLOR_OFF


func _mouse_entered():
	if !is_selectable:
		return
	is_hovering = true
	update_visuals()


# Called when the mouse pointer leaves the control node's area
func _mouse_exited():
	if !is_selectable:
		return
	is_hovering = false
	update_visuals()
