extends Node

@onready var hand_node = $Hand
@onready var enemy_node = $Enemy
@onready var player = $Player
@onready var energy_label = $EnergyLabel
@onready var end_turn_button = $EndTurnButton

var energy: int = 3
var max_energy: int = 3
var deck: Array = []
var discard: Array = []
var hand_cards: Array = []
var enemy_data: Dictionary

func _ready():
	load_cards_from_json("res://data/cards.json")
	load_enemy_from_json("res://data/enemies.json")
	draw_hand(5)
	update_ui()
	end_turn_button.pressed.connect(_on_end_turn_pressed)

func load_cards_from_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_ARRAY:
			for c in data:
				var card = preload("res://scenes/Card.tscn").instantiate()
				card.card_name = c.get("name", "Unknown")
				card.cost = c.get("cost", 1)
				card.damage = c.get("damage", 0)
				card.face_texture = load(c.get("texture", ""))
				card.set_meta("block", c.get("block", 0))
				card.card_played.connect(_on_card_played)
				
				var card_name = card.find_child("CardName", true, true)
				card_name.text = card.card_name;
				
				var play_button = card.find_child("PlayButton", true, true)
				play_button.pressed.connect(card.on_play_pressed)
				deck.append(card)
				
	deck.shuffle()
	
	print("Deck Size:", deck.size())
	for i in range(deck.size()):
		var card = deck[i]
		print("Deck Index:", i, " Card:", card.card_name)

func load_enemy_from_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_ARRAY and data.size() > 0:
				enemy_data = data.pick_random()
				enemy_node.hp = enemy_data.get("hp", 6)
				enemy_node.attack = enemy_data.get("attack", 6)
				enemy_node.update_ui()

func draw_hand(n: int):
	for i in range(n):
		if deck.is_empty():
			break
		var card = deck.pop_back()
		hand_node.add_child(card)
		hand_cards.append(card)

	for i in range(hand_cards.size()):
		var card = hand_cards[i]
		var pos = card.position
		pos.x = 250 * i
		card.position = pos

	print("Hand Size:", hand_cards.size())
	for i in range(hand_cards.size()):
		var card = hand_cards[i]
		print("Hand Index:", i, " Card:", card.card_name)

func _on_card_played(card):
	if energy >= card.cost:
		energy -= card.cost
		var block = card.get_meta("block", 0)
		if block > 0:
			player.add_block(block)
		elif card.damage > 0:
			enemy_node.take_damage(card.damage)
		
		# Safely play the card's animation
		var anim = card.get_node_or_null("AnimationPlayer")
		if anim and anim.has_animation("play"):
			anim.play("play")
		# do NOT delete the card, since we reuse them.
		#card.queue_free()
		hand_node.remove_child(card)
		hand_cards.erase(card)
		discard.append(card);
		update_ui()
	else:
		#print("Not enough energy!")
		energy_label.text = "Not enough energy!: %d/%d" % [energy, max_energy]

func _on_end_turn_pressed():
	var attack_value = enemy_data.get("attack", 6)
	player.take_damage(attack_value)
	player.block = 0
	energy = max_energy
	
	if hand_cards.is_empty():
		print("Discard Size:", discard.size())
		for i in range(discard.size()):
			var card = discard[i]
			print("Discard Index:", i, " Card:", card.card_name)
			deck.append(card);
		discard.clear();
		deck.shuffle()
		draw_hand(5)
	else:
		draw_hand(1)
	update_ui()

func update_ui():
	energy_label.text = "Energy: %d/%d" % [energy, max_energy]
