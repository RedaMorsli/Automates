extends Node

var current_scene = null

var save_path = ""

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	# Instance the new scene.
	current_scene = s.instance()
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

func enregistrer(etats : Array, instructions : Array):
	if save_path.empty():
		pass
	else:
		var save_game = File.new()
		save_game.open(save_path, File.WRITE)
		for etat in etats:
			var node_data = etat.call("save");
			save_game.store_line(to_json(node_data))
		for i in instructions:
			var node_data = i.call("save");
			save_game.store_line(to_json(node_data))
		save_game.close()

func enregistrer_sous(etats : Array, instructions : Array, path : String):
	var save_game = File.new()
	save_game.open(path, File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for etat in etats:
			var node_data = etat.call("save");
			save_game.store_line(to_json(node_data))
	for i in instructions:
			var node_data = i.call("save");
			save_game.store_line(to_json(node_data))
	save_game.close()
