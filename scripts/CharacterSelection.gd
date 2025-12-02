extends Node

@onready var scene = $Scene
@onready var hand = $Hand
@onready var select_character_button = $SelectCharacterContainer/SelectCharacter

const HAND_SIZE:int = 6
const PLAYER_HAND_PER_CARD_X_OFFSET:int = 320
const PLAYER_HAND_X_OFFSET:int = 96

var deck_players: Array = []
var hand_players: Array = []
var scene_data: Dictionary

func _ready():
	load_scenes_from_json("res://data/scenes.json")
	load_players_from_json("res://data/players.json")
	draw_hand(HAND_SIZE)
	update_ui()
	select_character_button.pressed.connect(_on_select_character_pressed)
	
func _on_player_toggled(state_owner:Node, state: bool):
	print("_on_player_toggled: state_owner:", state_owner,
		" is_toggled:", state, 
		" deck_players.size():", deck_players.size())
	
	for i in range(deck_players.size()):
		var player = deck_players[i]
		print("_on_player_toggled: player:", player, " is_toggled:", player.is_toggled)
		if state:
			player.set_toggled_state(state_owner == player)
		else:
			player.set_toggled_state(false)

func load_scenes_from_json(path: String):
	var data = ActiveRecords.get_active_dictionary_records(path, "character_selection")
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
			scene_data = data.pick_random()
			scene.scene_name = scene_data.get("name", "Unknown")
			scene.scene_description = scene_data.get("description", "Unknown")
			scene.scene_image.texture = load(scene_data.get("texture", ""))
			scene.update_ui()

func load_players_from_json(path: String):
	var data = ActiveRecords.get_active_array_records(path)
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		for c in data:
			var player = preload("res://scenes/Player.tscn").instantiate()
			player.player_name = c.get("name", "Unknown")
			player.player_image_texture = load(c.get("texture", ""))
			player.update_ui()
			player.toggled.connect(_on_player_toggled)
			deck_players.append(player)
	deck_players.shuffle()

func draw_hand(n: int):
	for i in range(n):
		if deck_players.is_empty():
			break
		var player = deck_players[i]
		hand.add_child(player)
		hand_players.append(player)
		
		player.update_ui();

	for i in range(hand_players.size()):
		var player = hand_players[i]
		var pos = player.position
		pos.x = PLAYER_HAND_X_OFFSET + (PLAYER_HAND_PER_CARD_X_OFFSET * i)
		player.position = pos

func _on_select_character_pressed():
	pass

func update_ui():
	pass
