extends Popup

signal create_pressed()

func _ready():
	pass

func _on_TopBar_add_clicked():
	popup_centered()
	pass


func _on_Confirm_pressed():
	emit_signal("create_pressed")
	pass


func _on_Cancel_pressed():
	hide()
	pass
