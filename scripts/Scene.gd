extends Control

@export var scene_name: String = "Scene"
@onready var scene_image = $SceneImage

@onready var scene_name_label = $SceneName


func _ready():
	update_ui()

func update_ui():
	if scene_name_label:
		scene_name_label.text = "%s" % [scene_name]
