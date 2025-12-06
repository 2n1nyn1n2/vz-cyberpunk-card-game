extends Node

@onready var scene = $Scene
@onready var hand = $Hand
@onready var select_character_button = $SelectCharacterContainer/SelectCharacter
@onready var scroll_hand_left_button = $ScrollHandLeftContainer/ScrollHandLeft
@onready var scroll_hand_right_button = $ScrollHandRightContainer/ScrollHandRight

const HAND_SIZE: int = 6
const PLAYER_HAND_PER_CARD_X_OFFSET:int = 320
const PLAYER_HAND_X_OFFSET:int = 96

var deck_players: Array = []
var hand_players: Array = []
var scene_data: Dictionary
var selected_player : Node
var hand_ix : int = 0

func _ready():
	load_scenes_from_json("res://data/scenes.json")
	load_players_from_json("res://data/players.json")
	draw_hand()
	update_ui()
	select_character_button.pressed.connect(_on_select_character_pressed)
	scroll_hand_left_button.pressed.connect(_on_scroll_hand_left_pressed)
	scroll_hand_right_button.pressed.connect(_on_scroll_hand_right_pressed)
	
func _on_player_toggled(state_owner:Node, state: bool):
	print("_on_player_toggled: state_owner:", state_owner,
		" is_toggled:", state, 
		" deck_players.size():", deck_players.size())
	
	selected_player = null
	select_character_button.disabled = true
	
	for i in range(deck_players.size()):
		var player = deck_players[i]
		#print("_on_player_toggled: player:", player, " is_toggled:", player.is_toggled)
		if state && state_owner == player:
			player.set_toggled_state(true)
			selected_player = player
		else:
			player.set_toggled_state(false)
	
	if selected_player == null:
		select_character_button.disabled = true
		print("_on_player_toggled: selected_player:", selected_player)
	else:
		print("_on_player_toggled: selected_player:", selected_player, " player_name:", selected_player.player_name)
		select_character_button.disabled = false

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
	#deck_players.shuffle()

func draw_hand():
	print("draw_hand:",
		" HAND_SIZE:", HAND_SIZE,
		" hand_players.size():", hand_players.size(),
		" deck_players.size():", deck_players.size())
	remove_all_hand_children();
	for i in range(HAND_SIZE):
		if deck_players.is_empty():
			break
		
		var deck_players_ix : int = (i+hand_ix+deck_players.size()) % deck_players.size();
		print("draw_hand:",
			" i:", i,
			" hand_ix:", hand_ix,
			" deck_players_ix:", deck_players_ix)
			
		var player = deck_players[deck_players_ix]
		hand.add_child(player)
		hand_players.append(player)
		
		player.update_ui();

	for i in range(hand_players.size()):
		var player = hand_players[i]
		var pos = player.position
		pos.x = PLAYER_HAND_X_OFFSET + (PLAYER_HAND_PER_CARD_X_OFFSET * i)
		player.position = pos
	
	scroll_hand_left_button.disabled = hand_ix == 0;
	scroll_hand_right_button.disabled = hand_ix == (deck_players.size()-HAND_SIZE);

func _on_select_character_pressed():
	TransferPlayerToScene.transfer_player(selected_player, "res://scenes/BattleManager.tscn")

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
	hand_players.clear()
