extends Control

@export var background_name: String = "Background"
@export var background_description: String = "Background Description"
@onready var background_image = $BackgroundImage

@onready var background_name_label = $BackgroundNameContainer/BackgroundName

@onready var background_desc_label = $BackgroundDescContainer/BackgroundDesc


func _ready():
	update_ui()


func update_ui():
	if background_name_label:
		background_name_label.text = "%s" % [background_name]

		var min_size = background_name_label.get_minimum_size()
		background_name_label.size = min_size
	if background_desc_label:
		background_desc_label.text = "%s" % [background_description]

		var min_size = background_desc_label.get_minimum_size()
		background_desc_label.size = min_size
