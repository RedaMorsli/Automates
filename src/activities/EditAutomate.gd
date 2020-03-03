extends Node2D

var Etat = preload("res://src/entities/Etat.tscn")
var Instruction = preload("res://src/entities/Instruction.tscn")

var etat_popup_opened = false
var last_right_click_position

var last_etat_right_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_right_mouse") and (not etat_popup_opened):
		last_right_click_position = get_global_mouse_position()
		$Popups/PopupMenuVoid.rect_position = get_global_mouse_position()
		$Popups/PopupMenuVoid.popup()


func _on_Etat_right_click_etat(etat):
	etat_popup_opened = true
	last_etat_right_clicked = etat
	$Popups/PopupMenuEtat.rect_position = get_global_mouse_position()
	$Popups/PopupMenuEtat.popup()


func _on_PopupMenuEtat_popup_hide():
	etat_popup_opened = false


func _on_PopupMenuVoid_id_pressed(id):
	match id:
		0:#New état
			$Popups/NewEtatDialog.popup_centered_ratio(0.2)
		1:#New instruction
			$Popups/NewLinkDialog/VBoxContainer/HBoxContainer2/EtatDebut.clear()
			$Popups/NewLinkDialog/VBoxContainer/HBoxContainer3/EtatFin.clear()
			for etat in $Etats.get_children():
				$Popups/NewLinkDialog/VBoxContainer/HBoxContainer2/EtatDebut.add_item(etat.nom)
				$Popups/NewLinkDialog/VBoxContainer/HBoxContainer3/EtatFin.add_item(etat.nom)
			$Popups/NewLinkDialog.popup_centered_ratio(0.4)


func _on_NewEtatDialog_confirmed():
	var new_etat = Etat.instance()
	new_etat.nom = $Popups/NewEtatDialog/VBoxContainer/HBoxContainer/NewName.text
	new_etat.initial = $Popups/NewEtatDialog/VBoxContainer/HBoxContainer2/CheckInitial.pressed
	new_etat.final = $Popups/NewEtatDialog/VBoxContainer/HBoxContainer2/CheckFinal.pressed
	new_etat.position = last_right_click_position
	new_etat.connect("right_click_etat", self, "_on_Etat_right_click_etat")
	$Etats.add_child(new_etat)


func _on_PopupMenuEtat_id_pressed(id):
	match id:
		0:#ajouter instruction
			#var new_instruciton = Instruction.instance()
			#EditVars.editing_link = new_instruciton
			#new_instruciton.etat_debut = last_etat_right_clicked
			#$Instructions.add_child(new_instruciton)
			#EditVars.linking = true
			pass


func _on_NewLinkDialog_confirmed():
	var debut = $Popups/NewLinkDialog/VBoxContainer/HBoxContainer2/EtatDebut.selected
	var fin = $Popups/NewLinkDialog/VBoxContainer/HBoxContainer3/EtatFin.selected
	var mot = $Popups/NewLinkDialog/VBoxContainer/HBoxContainer4/Mot.text
	var etat_debut =  $Etats.get_child(debut)
	var etat_fin = $Etats.get_child(fin)
	
	var new_instruction = _ins_exists(etat_debut, etat_fin)
	if  new_instruction == null:
		new_instruction = Instruction.instance()
		new_instruction.etat_debut = etat_debut
		new_instruction.etat_fin = etat_fin
		$Instructions.add_child(new_instruction)
	
	new_instruction.mot_lu.append(mot)

func _ins_exists(debut, fin):
	for	child in $Instructions.get_children():
		if (child.etat_debut == debut) and (child.etat_fin == fin):
			return child
	return null
