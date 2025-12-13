extends Node


func transfer_data(
	character_name_to_transfer: String,
	scene_name_to_transfer: String,
	challenge_name_to_transfer: String,
	possessions_data_to_transfer: Dictionary,
	scene_path: String
):
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		print("Error changing scene: ", scene_path, " ", error)
		return
	else:
		print("Successfully changed to scene: ", scene_path)

	# Wait for the next frame to ensure the new scene is loaded
	await get_tree().tree_changed

	var new_scene_root = get_tree().current_scene
	if new_scene_root == null:
		print("Null current_scene error when changing scene to: ", scene_path)
		return

	if !possessions_data_to_transfer.is_empty():
		new_scene_root.possessions_data = possessions_data_to_transfer
		new_scene_root.load_starting_possessions = false
		new_scene_root.load_possessions()
		print(
			"Successfully transferred possessions '",
			possessions_data_to_transfer,
			"' to new scene."
		)
	else:
		new_scene_root.load_possessions()
		print("Skipped transferring possessions '", possessions_data_to_transfer, "' to new scene.")

	if scene_name_to_transfer != "":
		var placeholder_background = new_scene_root.find_child("Background", true)

		if placeholder_background and is_instance_valid(placeholder_background):
			placeholder_background.background_name = scene_name_to_transfer
			new_scene_root.load_scene()
			print(
				"Successfully transferred scene name '", scene_name_to_transfer, "' to new scene."
			)
		else:
			print(
				"ERROR: Could not find placeholder character node named 'Background' in the new scene."
			)
	else:
		print("Skipped transferring scene name '", scene_name_to_transfer, "' to new scene.")

	if challenge_name_to_transfer != "":
		var placeholder_challenge = new_scene_root.find_child("Challenge", true)
		print("Successfully found placeholder_challenge ", placeholder_challenge, scene_path)

		if placeholder_challenge and is_instance_valid(placeholder_challenge):
			placeholder_challenge.challenge_name = challenge_name_to_transfer
			new_scene_root.load_challenges()
			print(
				"Successfully transferred challenge name '",
				challenge_name_to_transfer,
				"' to new scene."
			)
		else:
			print(
				"ERROR: Could not find placeholder challenge node named 'Challenge' in the new scene."
			)
	else:
		print(
			"Skipped transferring challenge name '", challenge_name_to_transfer, "' to new scene."
		)

	if character_name_to_transfer != "":
		var placeholder_character = new_scene_root.find_child("Character", true)
		print("Successfully found placeholder_character ", placeholder_character, scene_path)

		if placeholder_character and is_instance_valid(placeholder_character):
			placeholder_character.character_name = character_name_to_transfer
			new_scene_root.load_characters()
			print(
				"Successfully transferred character name '",
				character_name_to_transfer,
				"' to new scene."
			)
		else:
			print(
				"ERROR: Could not find placeholder character node named 'Character' in the new scene."
			)
	else:
		print(
			"Skipped transferring character name '", character_name_to_transfer, "' to new scene."
		)
