extends Control

func _ready():
	pass


func _on_Automate_pressed():
	$PopupAutomate.popup()


func _on_Operations_pressed():
	$PopupOperations.popup()


func _on_Aide_pressed():
	$PopupAide.popup()
