extends Node

@onready var background = $Background
@onready var hand = $Hand
@onready var select_challenge_button = $SelectChallengeContainer/SelectChallenge
@onready var scroll_hand_left_button = $ScrollHandLeftContainer/ScrollHandLeft
@onready var scroll_hand_right_button = $ScrollHandRightContainer/ScrollHandRight
@onready var selected_character = $Character

@export var load_starting_possessions = true

const HAND_SIZE: int = 3
const PLAYER_HAND_PER_CARD_X_OFFSET: int = 640
const PLAYER_HAND_X_OFFSET: int = 96

var deck_challenges: Array = []
var hand_challenges: Array = []
var background_data: Dictionary
var selected_challenge: Node
var hand_ix: int = 0
var possessions_data: Dictionary


func _ready():
	select_challenge_button.pressed.connect(_on_select_challenge_pressed)
	scroll_hand_left_button.pressed.connect(_on_scroll_hand_left_pressed)
	scroll_hand_right_button.pressed.connect(_on_scroll_hand_right_pressed)


func load_scene():
	load_background_from_json("res://data/scenes.json")
	load_challenges_from_json("res://data/challenges.json")
	draw_hand()
	update_ui()


func load_possessions():
	pass


func load_characters():
	pass


func _on_challenge_toggled(state_owner: Node, state: bool):
	print(
		"_on_challenge_toggled: state_owner:",
		state_owner,
		" is_toggled:",
		state,
		" deck_challenges.size():",
		deck_challenges.size()
	)

	selected_challenge = null
	select_challenge_button.disabled = true

	for i in range(deck_challenges.size()):
		var challenge = deck_challenges[i]
		#print("_on_challenge_toggled: challenge:", challenge, " is_toggled:", challenge.is_toggled)
		if state && state_owner == challenge:
			challenge.set_toggled_state(true)
			selected_challenge = challenge
		else:
			challenge.set_toggled_state(false)

	if selected_challenge == null:
		select_challenge_button.disabled = true
		print("_on_challenge_toggled: selected_challenge:", selected_challenge)
	else:
		print(
			"_on_challenge_toggled: selected_challenge:",
			selected_challenge,
			" challenge_name:",
			selected_challenge.challenge_name
		)
		select_challenge_button.disabled = false


func load_background_from_json(path: String):
	var data = ActiveRecords.get_active_dictionary_records(path, "starting_location")
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		background_data = data.pick_random()
		# if challenge was already selected, use it
		for background_element in data:
			if background.background_name == background_element.get("name", "Unknown"):
				background_data = background_element

		background.background_name = background_data.get("name", "Unknown")
		background.background_description = background_data.get("description", "Unknown")
		background.background_image.texture = load(background_data.get("texture", ""))
		background.update_ui()


func load_challenges_from_json(path: String):
	var data = ActiveRecords.get_active_array_records(path)
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		for c in data:
			var challenge_name = c.get("name", "Unknown")
			if background_data.challenges.has(challenge_name):
				var challenge = preload("res://tscns/Challenge.tscn").instantiate()
				challenge.is_selectable = true
				challenge.challenge_name = challenge_name
				challenge.challenge_description = c.get("description", "Unknown")
				challenge.challenge_image_texture = load(c.get("texture", ""))
				challenge.update_ui()
				challenge.toggled.connect(_on_challenge_toggled)
				deck_challenges.append(challenge)
	#deck_challenges.shuffle()


func draw_hand():
	print(
		"ChallengeSelection:",
		"draw_hand:",
		" HAND_SIZE:",
		HAND_SIZE,
		" hand_challenges.size():",
		hand_challenges.size(),
		" deck_challenges.size():",
		deck_challenges.size()
	)
	remove_all_hand_children()
	var hand_size = min(HAND_SIZE, deck_challenges.size())
	for i in range(hand_size):
		if deck_challenges.is_empty():
			break

		var deck_challenges_ix: int = (
			(i + hand_ix + deck_challenges.size()) % deck_challenges.size()
		)
		print(
			"ChallengeSelection:",
			"draw_hand:",
			" i:",
			i,
			" hand_ix:",
			hand_ix,
			" deck_challenges_ix:",
			deck_challenges_ix
		)

		var challenge = deck_challenges[deck_challenges_ix]
		hand.add_child(challenge)
		hand_challenges.append(challenge)

		challenge.update_ui()

	for i in range(hand_challenges.size()):
		var challenge = hand_challenges[i]
		var pos = challenge.position
		pos.x = PLAYER_HAND_X_OFFSET + (PLAYER_HAND_PER_CARD_X_OFFSET * i)
		challenge.position = pos

	scroll_hand_left_button.disabled = hand_ix == 0
	scroll_hand_right_button.disabled = hand_ix == (deck_challenges.size() - hand_size)


func _on_select_challenge_pressed():
	TransferToScene.transfer_data(
		selected_character.character_name,
		background.background_name,
		selected_challenge.challenge_name,
		possessions_data,
		"res://tscns/BattleManager.tscn"
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
	hand_challenges.clear()
