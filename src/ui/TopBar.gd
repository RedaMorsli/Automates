extends Control

signal add_clicked()
signal settings_clicked()

func _on_Settings_pressed():
	emit_signal("settings_clicked")

func _on_AddAutomate_pressed():
	emit_signal("add_clicked")
