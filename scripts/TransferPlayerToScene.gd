extends Node

func transfer_player(player_node: Node, scene_path : String):
	var player_name_to_transfer = player_node.player_name
	var current_scene_root = get_tree().current_scene 

	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		print("Error changing scene: ", error)
		return
		
	# Wait for the next frame to ensure the new scene is loaded
	await get_tree().tree_changed

	var new_scene_root = get_tree().current_scene
	if new_scene_root == null:
		print("Null current_scene error when changing scene to: ", scene_path)
		return
	
	var placeholder_player = new_scene_root.find_child("Player", true) 
	
	if placeholder_player and is_instance_valid(placeholder_player):
		placeholder_player.player_name = player_name_to_transfer		
		print("Successfully transferred name '", player_name_to_transfer, "' to placeholder.")
	else:
		print("ERROR: Could not find placeholder player node named 'Player' in the new scene.")
