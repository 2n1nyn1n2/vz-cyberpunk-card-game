extends Control

signal toggled(choice_node)

@export var is_selectable = false

@export var choice_name: String = "Choice"
@export var choice_data: Dictionary = {"requirements": [], "costs": [], "rewards": []}

const CHOICE_SIZE = Vector2(256, 256)

var is_toggled = false
var is_hovering = false

const COLOR_OFF = Color.DARK_GRAY
const COLOR_ON = Color.LIGHT_GREEN
const COLOR_HOVER = Color.LIGHT_GRAY


func _ready():
	custom_minimum_size = CHOICE_SIZE


func get_possession_description(possession_data: Dictionary):
	if possession_data.has("description") && possession_data.get("description").length() > 0:
		var description = possession_data.get("description")
		var possession = possession_data.get("possession")
		var count = possession_data.get("count")
		return "%s\n\t(%s %s)" % [description, possession, count]
	else:
		var possession = possession_data.get("possession")
		var count = possession_data.get("count")
		return "%s %s" % [possession, count]


func update_costs(possessions_data: Dictionary):
	var costs: Array = choice_data.get("costs")
	for cost in costs:
		var cost_possession = cost.get("possession")
		var cost_count = cost.get("count")
		var deck_count = possessions_data.get(cost_possession, 0)
		deck_count -= cost_count
		possessions_data.set(cost_possession, deck_count)


func update_rewards(possessions_data: Dictionary):
	var rewards: Array = choice_data.get("rewards")
	for reward in rewards:
		var reward_possession = reward.get("possession")
		var reward_count = reward.get("count")
		var deck_count = possessions_data.get(reward_possession, 0)
		deck_count += reward_count
		possessions_data.set(reward_possession, deck_count)


func update_is_selectable(possessions_data: Dictionary):
	is_selectable = true
	var requirements: Array = choice_data.get("requirements")
	for requirement in requirements:
		var requirement_possession = requirement.get("possession")
		var requirement_count = requirement.get("count")
		var deck_count = possessions_data.get(requirement_possession, 0)
		if deck_count < requirement_count:
			is_selectable = false

	var costs: Array = choice_data.get("costs")
	for cost in costs:
		var cost_possession = cost.get("possession")
		var cost_count = cost.get("count")
		var deck_count = possessions_data.get(cost_possession, 0)
		if deck_count < cost_count:
			is_selectable = false


func update_ui():
	var choice_background_rect = $Background
	choice_background_rect.color = COLOR_OFF
	var choice_name_label = $ChoiceName
	var choice_desciption_label = $ChoiceDescription

	if choice_name_label:
		choice_name_label.text = "%s" % [choice_name]

	var choice_description = ""

	choice_description += "Requirements:\n"
	var requirements: Array = choice_data.get("requirements")
	for requirement in requirements:
		choice_description += get_possession_description(requirement)
		choice_description += "\n"

	choice_description += "Costs:\n"
	var costs: Array = choice_data.get("costs")
	for cost in costs:
		choice_description += get_possession_description(cost)
		choice_description += "\n"

	choice_description += "Rewards:\n"
	var rewards: Array = choice_data.get("rewards")
	for reward in rewards:
		choice_description += get_possession_description(reward)
		choice_description += "\n"

	print("Choice update_ui:", "choice_description:", choice_description)

	if choice_desciption_label:
		choice_desciption_label.text = "%s" % [choice_description]


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
	print("Choice Toggle State: ", is_toggled)
	emit_signal("toggled", self, is_toggled)


func update_visuals():
	var choice_background_rect = $Background
	if is_toggled:
		choice_background_rect.color = COLOR_ON
	elif is_hovering:
		choice_background_rect.color = COLOR_HOVER
	else:
		choice_background_rect.color = COLOR_OFF


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
