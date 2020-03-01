extends Node2D

var Etat = preload("res://src/entities/Etat.tscn")

var etat_popup_opened = false
var last_right_click_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_right_mouse") and (not etat_popup_opened):
		last_right_click_position = get_global_mouse_position()
		$EditCamera/PopupMenuVoid.rect_position = get_global_mouse_position()
		$EditCamera/PopupMenuVoid.popup()


func _on_Etat_right_click_etat():
	etat_popup_opened = true
	$EditCamera/PopupMenuEtat.rect_position = get_global_mouse_position()
	$EditCamera/PopupMenuEtat.popup()


func _on_PopupMenuEtat_popup_hide():
	etat_popup_opened = false


func _on_PopupMenuVoid_id_pressed(id):
	match id:
		0:#New état
			$EditCamera/NewEtatDialog.popup_centered_ratio(0.2)


func _on_NewEtatDialog_confirmed():
	var new_etat = Etat.instance()
	new_etat.nom = $EditCamera/NewEtatDialog/VBoxContainer/HBoxContainer/NewName.text
	new_etat.initial = $EditCamera/NewEtatDialog/VBoxContainer/HBoxContainer2/CheckInitial.pressed
	new_etat.final = $EditCamera/NewEtatDialog/VBoxContainer/HBoxContainer2/CheckFinal.pressed
	new_etat.position = last_right_click_position
	$Etats.add_child(new_etat)
