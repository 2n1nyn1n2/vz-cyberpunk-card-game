extends Control

@export var scene_name: String = "Scene"
@export var scene_description: String = "Scene Description"
@onready var scene_image = $SceneImage

@onready var scene_name_label = $SceneNameContainer/SceneName

@onready var scene_desc_label = $SceneDescContainer/SceneDesc


func _ready():
	update_ui()

func update_ui():
	if scene_name_label:
		scene_name_label.text = "%s" % [scene_name]
		
		var min_size = scene_name_label.get_minimum_size()	
		scene_name_label.size = min_size
	if scene_desc_label:
		scene_desc_label.text = "%s" % [scene_description]
		
		var min_size = scene_desc_label.get_minimum_size()	
		scene_desc_label.size = min_size
