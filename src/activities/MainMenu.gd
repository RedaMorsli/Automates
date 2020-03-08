extends Control

var Automate = preload("res://src/activities/EditAutomate.tscn")

func _on_Paramtres_create_pressed():
	App.goto_scene("res://src/activities/EditAutomate.tscn")
	pass


func _on_NewDialog_create_pressed(automate_name):
	var new_automate = Automate.instance()
	new_automate.automate_name = automate_name
	App.save_automate(new_automate)
	App.open_scene(new_automate)
