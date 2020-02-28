extends HBoxContainer

signal automate_clicked()
signal edit_automate_clicked()

var nom : String = "Nom de l'automate'"

func _ready():
	$Nom.text = nom

func _on_automate_clicked_pressed():
	emit_signal("automate_clicked")


func _on_edit_automate__pressed():
	emit_signal("edit_automate_clicked")
