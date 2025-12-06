extends Control

signal toggled(player_node)

@export var player_name: String = "Player"
@export var max_hp: int = 50
@export var player_image_texture: Resource;

var hp: int
var block: int = 0

@onready var hp_label = $HP
@onready var player_name_label = $PlayerName

const PLAYER_SIZE = Vector2(256, 256)

var is_toggled = false
var is_hovering = false

const COLOR_OFF = Color.DARK_GRAY
const COLOR_ON = Color.LIGHT_GREEN
const COLOR_HOVER = Color.LIGHT_GRAY

func _ready():
	hp = max_hp	
	custom_minimum_size = PLAYER_SIZE
	var player_background_rect = $Background
	player_background_rect.color = COLOR_OFF
	
func update_ui():
	var player_image = $PlayerImage
	
	#print("Player:", player_image_texture, " player_image:", player_image)
	if player_image_texture:
		player_image.texture = player_image_texture
		player_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		player_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		player_image.custom_minimum_size = PLAYER_SIZE
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

# This function detects mouse movement and button clicks inside the control node
func _gui_input(event):
	# --- 1. Detect Mouse Click ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle()
			get_viewport().set_input_as_handled() # Consumes the event so other nodes don't receive it
	
	# --- 2. Detect Mouse Enter/Exit (Hover) ---
	# This is handled separately using built-in signals/functions, see below.

# --- Custom Logic Functions ---

func set_toggled_state(state: bool):
	is_toggled = state
	update_visuals()
	
func toggle():
	is_toggled = !is_toggled
	print("Toggle State: ", is_toggled)
	
	# Update the visual appearance
	#update_visuals()
	
	# Emit a signal so other nodes can react (Good practice!)
	emit_signal("toggled", self, is_toggled)

func update_visuals():
	var player_background_rect = $Background
	if is_toggled:
		player_background_rect.color = COLOR_ON
	elif is_hovering:
		player_background_rect.color = COLOR_HOVER
	else:
		player_background_rect.color = COLOR_OFF

# --- Virtual Input Event Functions ---

# Called when the mouse pointer enters the control node's area
func _mouse_entered():
	is_hovering = true
	update_visuals()

# Called when the mouse pointer leaves the control node's area
func _mouse_exited():
	is_hovering = false
	update_visuals()
