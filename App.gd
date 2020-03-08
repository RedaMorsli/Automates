extends Node

var current_scene = null

var save_path = "res://automates.cfg"
var config = ConfigFile.new()
var load_response = config.load(save_path)

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func save_automate(automate_scene):
	config.set_value("Automates", automate_scene.automate_name, automate_scene)
	config.save(save_path)

func open_automate(automate_name):
	goto_scene(config.get_value("Automates", automate_name))
	pass

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

func open_scene(scene):
	#call_deferred("open_scene", scene)
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)

func _deferred_open_scene(scene):
	current_scene.free()
	current_scene = scene
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
