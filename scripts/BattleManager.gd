extends Node

@onready var scene = $Scene
@onready var hand = $Hand
@onready var possessions = $Possessions
@onready var challenge = $Challenge
@onready var player = $Player
@onready var energy_label = $EnergyLabel
@onready var end_turn_button = $EndTurnButton
@onready var win_status_label = $WinStatus

const HAND_SIZE:int = 5
const ACTION_HAND_X_OFFSET:int = 320
const POSSESSION_X_OFFSET:int = 96

var energy: int = 3
var max_energy: int = 3
var deck_actions: Array = []
var deck_possessions: Array = []
var disaction: Array = []
var hand_actions: Array = []
var challenge_data: Dictionary
var scene_data: Dictionary
var player_data: Dictionary

func _ready():
	load_scenes_from_json("res://data/scenes.json")
	load_actions_from_json("res://data/actions.json")
	load_possessions_from_json("res://data/possessions.json")
	load_challenges_from_json("res://data/challenges.json")
	load_players_from_json("res://data/players.json")
	draw_hand(HAND_SIZE)
	draw_possessions();
	update_ui()
	end_turn_button.pressed.connect(_on_end_turn_pressed)

func get_active_records(path: String):
	var data : Array = [];
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var raw_data = JSON.parse_string(file.get_as_text())
		if typeof(raw_data) == TYPE_ARRAY:
			#print("Raw Size:", raw_data.size())
			for i in range(raw_data.size()):
				var c = raw_data[i]
				#print("Raw Raw Index:", i, " Scene:", c)
				var active : bool = c.get("active", false)
				if active:
					data.append(c)
		
	#print("Data:", data)
	return data

func load_scenes_from_json(path: String):
	var data = get_active_records(path)
	#print("Scene Data:", data)
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
			scene_data = data.pick_random()
			scene.scene_name = scene_data.get("name", "Unknown")
			scene.scene_image.texture = load(scene_data.get("texture", ""))
			scene.update_ui()

func load_players_from_json(path: String):
	var data = get_active_records(path)
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		
#		verify possessions exist.
		var deck_possessions_exist = {}
		for possession in deck_possessions:
			deck_possessions_exist[possession.possession_name] = true;
			#print("Known possession Name: " + possession.possession_name)

		var deck_possessions_unknown = {}
		for players in data:
			var desired_possessions = players.desired_possessions
			if typeof(desired_possessions) == TYPE_ARRAY and desired_possessions.size() > 0:
				for possession_name in desired_possessions:
					if(!deck_possessions_exist.has(possession_name)):
						deck_possessions_unknown[possession_name] = true;

		var deck_possessions_unknown_names = deck_possessions_unknown.keys()
		deck_possessions_unknown_names.sort();
		var deck_possessions_unknown_template = []
		for possession_name in deck_possessions_unknown_names:
				deck_possessions_unknown_template.append({
					"name": possession_name,
					"texture": "res://assets/possessions/"+possession_name+".png",
					"active":true
				})

		print("Unknown possession Names: " + str(deck_possessions_unknown_names))
		print("Unknown possessions: " + JSON.stringify(deck_possessions_unknown_template, "\t"))

		player_data = data.pick_random()
		player.player_name = player_data.get("name", "Unknown")
		player.player_image.texture = load(player_data.get("texture", ""))
		player.update_ui()

func load_actions_from_json(path: String):
	var data = get_active_records(path)
	if typeof(data) == TYPE_ARRAY:
		for c in data:
			var action = preload("res://scenes/Action.tscn").instantiate()
			action.action_name = c.get("name", "Unknown")
			action.cost = c.get("cost", 1)
			action.damage = c.get("damage", 0)
			action.action_image_texture = load(c.get("texture", ""))
			action.set_meta("block", c.get("block", 0))
			action.action_played.connect(_on_action_played)
			
			var action_name = action.find_child("ActionName", true, true)
			action_name.text = action.action_name;
			
			var play_button = action.find_child("PlayButton", true, true)
			play_button.pressed.connect(action.on_play_pressed)
			deck_actions.append(action)
	
	deck_actions.shuffle()
	
	#print("Deck Size:", deck_actions.size())
	#for i in range(deck_actions.size()):
		#var action = deck_actions[i]
		#print("Deck Index:", i, " Action:", action.action_name)

func load_possessions_from_json(path: String):
	var data = get_active_records(path)
	if typeof(data) == TYPE_ARRAY:
		for c in data:
			var possession_name = c.get("name", "Unknown")
			var possession_image_texture_name = c.get("texture", "")
			var possession_image_texture = load(possession_image_texture_name)
			#print("Texture for:", str(c), possession_image_texture)
			if possession_image_texture == null:
				print("Missing Texture for:", possession_name)

			var possession = preload("res://scenes/Possession.tscn").instantiate()
			possession.possession_name = possession_name
			possession.possession_image_texture = possession_image_texture

			var possession_name_child = possession.find_child("PossessionName", true, true)
			possession_name_child.text = possession.possession_name;
			
			deck_possessions.append(possession)

	#print("Deck Size:", deck_possessions.size())
	#for i in range(deck_possessions.size()):
		#var possession = deck_possessions[i]
		#print("Deck Index:", i, " Possession:", possession.possession_name, possession.possession_image_texture)

func load_challenges_from_json(path: String):
	var data = get_active_records(path)
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		challenge_data = data.pick_random()
		challenge.challenge_name = challenge_data.get("name", "Unknown")
		challenge.hp = challenge_data.get("hp", 6)
		challenge.attack = challenge_data.get("attack", 6)
		challenge.challenge_image.texture = load(challenge_data.get("texture", ""))
		challenge.update_ui()

func draw_hand(n: int):
	for i in range(n):
		if deck_actions.is_empty():
			break
		var action = deck_actions.pop_back()
		hand.add_child(action)
		hand_actions.append(action)
		
		action.update_ui();

	for i in range(hand_actions.size()):
		var action = hand_actions[i]
		var pos = action.position
		pos.x = ACTION_HAND_X_OFFSET * i
		action.position = pos

	#print("Hand Size:", hand_actions.size())
	#for i in range(hand_actions.size()):
		#var action = hand_actions[i]
		#print("Hand Index:", i, " Action:", action.action_name)

func draw_possessions():
	for i in range(deck_possessions.size()):
		var possession = deck_possessions[i]
		possessions.add_child(possession)
		var pos = possession.position
		pos.x = POSSESSION_X_OFFSET * i
		possession.position = pos
		possession.update_ui();

	#print("Possessions Size:", deck_possessions.size())
	#for i in range(deck_possessions.size()):
		#var possession = deck_possessions[i]
		#print("Possession Index:", i, " Possession:", possession.possession_name)

func _on_action_played(action):
	if energy >= action.cost:
		energy -= action.cost
		var block = action.get_meta("block", 0)
		if block > 0:
			player.add_block(block)
		elif action.damage > 0:
			challenge.take_damage(action.damage)
		
		# Safely play the action's animation
		var anim = action.get_node_or_null("AnimationPlayer")
		if anim and anim.has_animation("play"):
			anim.play("play")
		# do NOT delete the action, since we reuse them.
		#action.queue_free()
		hand.remove_child(action)
		hand_actions.erase(action)
		disaction.append(action);
		update_ui()
	else:
		#print("Not enough energy!")
		energy_label.text = "Not enough energy!: %d/%d" % [energy, max_energy]

func _on_possession_played(possession):
	if energy >= possession.cost:
		energy_label.text = "Enough energy!: %d/%d" % [energy, max_energy]
	else:
		energy_label.text = "Not enough energy!: %d/%d" % [energy, max_energy]

func _on_end_turn_pressed():
	var attack_value = challenge_data.get("attack", 6)
	player.take_damage(attack_value)
	player.block = 0
	energy = max_energy
	
	if hand_actions.is_empty():
		#print("Disaction Size:", disaction.size())
		for i in range(disaction.size()):
			var action = disaction[i]
			#print("Disaction Index:", i, " Action:", action.action_name)
			deck_actions.append(action);
		disaction.clear();
		deck_actions.shuffle()
		draw_hand(5)
	else:
		draw_hand(1)
	update_ui()

func update_ui():
	energy_label.text = "Energy: %d/%d" % [energy, max_energy]
	#print("player.hp", player.hp, "challenge.hp", challenge.hp)
	if win_status_label:
		if player.hp == 0:
			win_status_label.text = "💀 Player defeated!";
		elif challenge.hp == 0:
			win_status_label.text = "Challenge defeated!";
		else:
			win_status_label.text = "In Progress";
