extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func get_active_array_records(path: String):
	var data: Array = []
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var raw_data = JSON.parse_string(file.get_as_text())
		if typeof(raw_data) == TYPE_ARRAY:
			#print("Raw Size:", raw_data.size())
			for i in range(raw_data.size()):
				var c = raw_data[i]
				#print("Raw Raw Index:", i, " Scene:", c)
				var active: bool = c.get("active", false)
				if active:
					data.append(c)

	#print("Data:", data)
	return data


func get_active_dictionary_records(path: String, key: String):
	var data: Array = []
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var raw_data: Dictionary = JSON.parse_string(file.get_as_text())
		if typeof(raw_data) == TYPE_DICTIONARY:
			var key_data: Array = raw_data.get(key, [])
			#print("Raw Size:", raw_data.size())
			for i in range(key_data.size()):
				var c = key_data[i]
				#print("Raw Raw Index:", i, " Scene:", c)
				var active: bool = c.get("active", false)
				if active:
					data.append(c)

	#print("Data:", data)
	return data


func get_dictionary_record(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var raw_data: Dictionary = JSON.parse_string(file.get_as_text())
		if typeof(raw_data) == TYPE_DICTIONARY:
			return raw_data

	return Dictionary()
