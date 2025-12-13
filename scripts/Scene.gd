extends Control

signal toggled(scene_node)

@export var scene_name: String = "Scene"
@export var scene_description: String = "Scene Description"
@export var scene_image_texture: Resource
@export var is_selectable = false

const SCENE_SIZE = Vector2(512, 512)

var is_toggled = false
var is_hovering = false

const COLOR_OFF = Color.DARK_GRAY
const COLOR_ON = Color.LIGHT_GREEN
const COLOR_HOVER = Color.LIGHT_GRAY


func _ready():
	custom_minimum_size = SCENE_SIZE
	var scene_background_rect = $Background
	scene_background_rect.color = COLOR_OFF


func update_ui():
	var scene_image = $SceneImage
	var scene_name_label = $SceneName
	var scene_description_label = $SceneDescription

	#print("scene:", scene_image_texture, " scene_image:", scene_image)
	if scene_image_texture:
		scene_image.texture = scene_image_texture
		scene_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		scene_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		scene_image.custom_minimum_size = SCENE_SIZE

	if scene_name_label:
		scene_name_label.text = "%s" % [scene_name]

	if scene_description:
		scene_description_label.text = "%s" % [scene_description]


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
	print("Scene Toggle State: ", is_toggled)
	emit_signal("toggled", self, is_toggled)


func update_visuals():
	var scene_background_rect = $Background
	if is_toggled:
		scene_background_rect.color = COLOR_ON
	elif is_hovering:
		scene_background_rect.color = COLOR_HOVER
	else:
		scene_background_rect.color = COLOR_OFF


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
