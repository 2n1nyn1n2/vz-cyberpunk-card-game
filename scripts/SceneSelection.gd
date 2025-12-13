extends Node

@onready var background = $Background
@onready var hand = $Hand
@onready var possessions = $Possessions
@onready var select_scene_button = $SelectSceneContainer/SelectScene
@onready var scroll_hand_left_button = $ScrollHandLeftContainer/ScrollHandLeft
@onready var scroll_hand_right_button = $ScrollHandRightContainer/ScrollHandRight

@export var load_starting_possessions = true

const HAND_SIZE: int = 3
const SCENE_HAND_PER_CARD_X_OFFSET: int = 640
const SCENE_HAND_X_OFFSET: int = 96
const POSSESSION_X_OFFSET: int = 192
const POSSESSION_Y_OFFSET: int = 256
const POSSESSION_X_MAX: int = 5

var deck_possessions: Array = []
var deck_scenes: Array = []
var hand_scenes: Array = []
var selected_scene: Node
var hand_ix: int = 0
var possessions_data: Dictionary


func _ready():
	load_background_from_json("res://data/scenes.json")
	load_scenes_from_json("res://data/scenes.json")
	draw_hand()
	update_ui()
	select_scene_button.pressed.connect(_on_select_scene_pressed)
	scroll_hand_left_button.pressed.connect(_on_scroll_hand_left_pressed)
	scroll_hand_right_button.pressed.connect(_on_scroll_hand_right_pressed)


func load_scene():
	pass


func load_possessions():
	load_possessions_from_json("res://data/possessions.json")
	draw_possessions()


func _on_scene_toggled(state_owner: Node, state: bool):
	print(
		"_on_scene_toggled: state_owner:",
		state_owner,
		" is_toggled:",
		state,
		" deck_scenes.size():",
		deck_scenes.size()
	)

	selected_scene = null
	select_scene_button.disabled = true

	for i in range(deck_scenes.size()):
		var scene = deck_scenes[i]
		#print("_on_scene_toggled: character:", character, " is_toggled:", character.is_toggled)
		if state && state_owner == scene:
			scene.set_toggled_state(true)
			selected_scene = scene
		else:
			scene.set_toggled_state(false)

	if selected_scene == null:
		select_scene_button.disabled = true
		print("_on_scene_toggled: selected_scene:", selected_scene)
	else:
		print(
			"_on_scene_toggled: selected_scene:",
			selected_scene,
			" scene_name:",
			selected_scene.scene_name
		)
		select_scene_button.disabled = false


func load_background_from_json(path: String):
	var data = ActiveRecords.get_active_dictionary_records(path, "scene_selection")
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		var background_data: Dictionary = data.pick_random()
		background.background_name = background_data.get("name", "Unknown")
		background.background_description = background_data.get("description", "Unknown")
		background.background_image.texture = load(background_data.get("texture", ""))
		background.update_ui()


func load_scenes_from_json(path: String):
	var data = ActiveRecords.get_active_dictionary_records(path, "starting_location")
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		for c in data:
			var scene = preload("res://tscns/Scene.tscn").instantiate()
			scene.is_selectable = true
			scene.scene_name = c.get("name", "Unknown")
			scene.scene_description = c.get("description", "Unknown")
			scene.scene_image_texture = load(c.get("texture", ""))
			scene.update_ui()
			scene.toggled.connect(_on_scene_toggled)
			deck_scenes.append(scene)


func load_possessions_from_json(path: String):
	var data = ActiveRecords.get_active_array_records(path)
	if typeof(data) == TYPE_ARRAY:
		for c in data:
			var possession_name = c.get("name", "Unknown")
			var possession_image_texture_name = c.get("texture", "")
			var possession_image_texture = load(possession_image_texture_name)
			#print("Texture for:", str(c), possession_image_texture)
			if possession_image_texture == null:
				print("Missing Texture for:", possession_name)

			var possession = preload("res://tscns/Possession.tscn").instantiate()
			possession.possession_name = possession_name
			possession.possession_image_texture = possession_image_texture
			var possession_name_child = possession.find_child("PossessionName", true, true)
			possession_name_child.text = possession.possession_name

			possession.possession_count = possessions_data.get(possession.possession_name, 0)

			if possession.possession_count > 0:
				deck_possessions.append(possession)


func draw_possessions():
	for i in range(deck_possessions.size()):
		var possession = deck_possessions[i]
		possessions.add_child(possession)
		var pos = possession.position
		pos.x = POSSESSION_X_OFFSET * (i % POSSESSION_X_MAX)
		@warning_ignore("integer_division")
		pos.y = POSSESSION_Y_OFFSET * (i / POSSESSION_X_MAX)
		possession.position = pos
		possession.update_ui()


func draw_hand():
	print(
		"SceneSelection:",
		"draw_hand:",
		" HAND_SIZE:",
		HAND_SIZE,
		" hand_scenes.size():",
		hand_scenes.size(),
		" deck_scenes.size():",
		deck_scenes.size()
	)
	remove_all_hand_children()
	for i in range(HAND_SIZE):
		if deck_scenes.is_empty():
			break

		var deck_characters_ix: int = (i + hand_ix + deck_scenes.size()) % deck_scenes.size()
		print(
			"SceneSelection:",
			"draw_hand:",
			" i:",
			i,
			" hand_ix:",
			hand_ix,
			" deck_characters_ix:",
			deck_characters_ix
		)

		var scene = deck_scenes[deck_characters_ix]
		hand.add_child(scene)
		hand_scenes.append(scene)

		scene.update_ui()

	for i in range(hand_scenes.size()):
		var scene = hand_scenes[i]
		var pos = scene.position
		pos.x = SCENE_HAND_X_OFFSET + (SCENE_HAND_PER_CARD_X_OFFSET * i)
		scene.position = pos

	scroll_hand_left_button.disabled = hand_ix == 0
	scroll_hand_right_button.disabled = hand_ix == (deck_scenes.size() - HAND_SIZE)


func _on_select_scene_pressed():
	TransferToScene.transfer_data(
		"", selected_scene.scene_name, "", possessions_data, "res://tscns/CharacterSelection.tscn"
	)


func _on_scroll_hand_left_pressed():
	hand_ix -= 1
	draw_hand()


func _on_scroll_hand_right_pressed():
	hand_ix += 1
	draw_hand()


func update_ui():
	pass


func remove_all_hand_children():
	var children = hand.get_children()

	for child in children:
		if is_instance_valid(child):
			hand.remove_child(child)
	hand_scenes.clear()
