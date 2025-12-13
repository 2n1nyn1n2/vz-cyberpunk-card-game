extends Node

@onready var background = $Background
@onready var hand = $Hand
@onready var possessions = $Possessions
@onready var challenge = $Challenge
@onready var character = $Character
@onready var select_choice_button = $SelectChoiceContainer/SelectChoice

@export var load_starting_possessions = true

const HAND_SIZE: int = 5
const CHOICE_HAND_X_OFFSET: int = 320
const POSSESSION_X_OFFSET: int = 192
const POSSESSION_Y_OFFSET: int = 256
const POSSESSION_X_MAX: int = 5

var deck_choices: Array = []
var deck_possessions: Array = []
var discarded_choices: Array = []
var hand_choices: Array = []
var challenge_data: Dictionary
var background_data: Dictionary
var character_data: Dictionary
var possessions_data: Dictionary
var selected_choice: Node


func _ready():
	load_characters()
	select_choice_button.pressed.connect(_on_select_choice_pressed)


func load_scene():
	load_background_from_json("res://data/scenes.json")


func load_characters():
	load_characters_from_json("res://data/characters.json")


func load_possessions():
	load_possessions_from_json("res://data/possessions.json")


func load_challenges():
	load_challenges_from_json("res://data/challenges.json")
	draw_hand(HAND_SIZE)
	draw_possessions()
	update_ui()


func load_background_from_json(path: String):
	var data = ActiveRecords.get_active_dictionary_records(path, "starting_location")
	#print("Background Data:", data)
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		background_data = data.pick_random()
		# if character was already selected, use it
		for background_element in data:
			if background.background_name == background_element.get("name", "Unknown"):
				background_data = background_element

		background.background_name = background_data.get("name", "Unknown")
		background.background_image.texture = load(background_data.get("texture", ""))
		background.update_ui()


func load_characters_from_json(path: String):
	var data = ActiveRecords.get_active_array_records(path)
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
#		verify possessions exist.
		var deck_possessions_exist = {}
		for possession in deck_possessions:
			deck_possessions_exist[possession.possession_name] = true
			#print("Known possession Name: " + possession.possession_name)

		var deck_possessions_unknown = {}
		for character_element in data:
			var desired_possessions = character_element.desired_possessions
			if typeof(desired_possessions) == TYPE_ARRAY and desired_possessions.size() > 0:
				for possession_name in desired_possessions:
					if !deck_possessions_exist.has(possession_name):
						deck_possessions_unknown[possession_name] = true

		var deck_possessions_unknown_names = deck_possessions_unknown.keys()
		deck_possessions_unknown_names.sort()
		var deck_possessions_unknown_template = []
		for possession_name in deck_possessions_unknown_names:
			deck_possessions_unknown_template.append(
				{
					"name": possession_name,
					"texture": "res://assets/possessions/" + possession_name + ".png",
					"active": true
				}
			)

		print("Unknown possession Names: " + str(deck_possessions_unknown_names))
		print("Unknown possessions: " + JSON.stringify(deck_possessions_unknown_template, "\t"))

		character_data = data.pick_random()

		# if character was already selected, use it
		for character_element in data:
			if character.character_name == character_element.get("name", "Unknown"):
				character_data = character_element

		character.character_description = character_data.get("description", "Unknown")
		character.character_name = character_data.get("name", "Unknown")
		character.character_image_texture = load(character_data.get("texture", ""))
		character.update_ui()


func load_possessions_from_json(path: String):
	var starting_possessions = character_data.get("starting_possessions")
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

			if load_starting_possessions:
				possession.possession_count = starting_possessions.get(possession_name, 0)
				possessions_data.set(possession.possession_name, possession.possession_count)
			else:
				possession.possession_count = possessions_data.get(possession.possession_name, 0)

			if possession.possession_count > 0:
				deck_possessions.append(possession)


func load_challenges_from_json(path: String):
	var raw_data = ActiveRecords.get_active_array_records(path)
	var data = []
	if typeof(raw_data) == TYPE_ARRAY and raw_data.size() > 0:
		for raw_data_ix in range(raw_data.size()):
			var raw_challenge_data = raw_data[raw_data_ix]
			if raw_challenge_data.has("json"):
				var details_path = raw_challenge_data.get("json")
				var details_data = ActiveRecords.get_dictionary_record(details_path)
				raw_challenge_data.description = details_data.get("description", "Unknown")
				raw_challenge_data.choices = []

				if details_data.has("choices"):
					var choices_data = details_data.get("choices")
					if typeof(choices_data) == TYPE_ARRAY:
						raw_challenge_data.choices = details_data.get("choices")

			data.append(raw_challenge_data)

	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		challenge_data = data.pick_random()
		# if challenge was already selected, use it
		for challenge_element in data:
			if challenge.challenge_name == challenge_element.get("name", "Unknown"):
				challenge_data = challenge_element

		print("challenge_data:", challenge_data)

		challenge.challenge_description = challenge_data.get("description", "Unknown")

		var choices_data = challenge_data.get("choices")
		if typeof(choices_data) == TYPE_ARRAY:
			for choice_ix in range(choices_data.size()):
				var choice_data = choices_data[choice_ix]
				if typeof(choice_data) == TYPE_DICTIONARY:
					var choice = preload("res://tscns/Choice.tscn").instantiate()
					choice.toggled.connect(_on_choice_toggled)
					choice.choice_name = choice_data.get("name", "Unknown")
					choice.choice_data = choice_data
					deck_choices.append(choice)
					print("Choice Index:", choice_ix, " choice.choice_name:", choice.choice_name)

		challenge.challenge_name = challenge_data.get("name", "Unknown")
		challenge.challenge_image_texture = load(challenge_data.get("texture", ""))
		challenge.update_ui()


func draw_hand(n: int):
	print("draw_hand n:", n)
	print("draw_hand deck_choices:", deck_choices)
	for i in range(n):
		var added_choice: bool = false
		while !added_choice:
			if deck_choices.is_empty():
				break
			var choice = deck_choices.pop_back()
			choice.update_is_selectable(possessions_data)
			if choice.is_selectable:
				added_choice = true
				hand.add_child(choice)
				hand_choices.append(choice)

	for i in range(hand_choices.size()):
		var choice = hand_choices[i]
		var pos = choice.position
		pos.x = CHOICE_HAND_X_OFFSET * i
		choice.position = pos
		print(
			"draw_hand Choice Index:",
			i,
			" choice.choice_name:",
			choice.choice_name,
			"choice.position",
			choice.position
		)
		choice.update_ui()


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


func _on_select_choice_pressed():
	var choice = selected_choice
	print("_on_select_choice_pressed: choice:", choice, "possessions_data:", possessions_data)
	choice.update_costs(possessions_data)
	choice.update_rewards(possessions_data)
	for i in range(deck_possessions.size()):
		var possession = deck_possessions[i]
		possession.possession_count = possessions_data.get(possession.possession_name, 0)

	hand.remove_child(choice)
	hand_choices.erase(choice)
	discarded_choices.append(choice)
	update_ui()
	print(
		"_on_select_choice_pressed: choice:",
		choice,
		"possessions_data:",
		possessions_data,
		"transfer starting"
	)
	TransferToScene.transfer_data(
		character.character_name,
		background.background_name,
		challenge.challenge_name,
		possessions_data,
		"res://tscns/SceneSelection.tscn"
	)
	print(
		"_on_select_choice_pressed: choice:",
		choice,
		"possessions_data:",
		possessions_data,
		"transfer finished"
	)


func _on_choice_toggled(state_owner: Node, state: bool):
	print(
		"_on_choice_toggled: state_owner:",
		state_owner,
		" is_toggled:",
		state,
		" hand_choices.size():",
		hand_choices.size()
	)

	selected_choice = null
	select_choice_button.disabled = true

	for i in range(hand_choices.size()):
		var choice = hand_choices[i]
		#print("_on_choice_toggled: choice:", choice, " is_toggled:", choice.is_toggled)
		if state && state_owner == choice:
			choice.set_toggled_state(true)
			selected_choice = choice
		else:
			choice.set_toggled_state(false)

	if selected_choice == null:
		select_choice_button.disabled = true
		print("_on_choice_toggled: selected_choice:", selected_choice)
	else:
		print(
			"_on_choice_toggled: selected_choice:",
			selected_choice,
			" choice_name:",
			selected_choice.choice_name
		)
		select_choice_button.disabled = false


func update_ui():
	pass
