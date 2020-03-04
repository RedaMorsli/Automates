extends Node2D

var Etat = preload("res://src/entities/Etat.tscn")
var Instruction = preload("res://src/entities/Instruction.tscn")

var etat_popup_opened = false
var last_right_click_position

var last_etat_right_clicked
var last_instruction_clicked : Node2D

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
		0:#edit etat
			pass
		1:#delete etat
			var etat = last_etat_right_clicked
			for child in $Instructions.get_children():
				if (child.etat_debut == etat) or (child.etat_fin == etat):
					child.queue_free()
			last_etat_right_clicked.queue_free()


func _on_NewLinkDialog_confirmed():
	var debut = $Popups/NewLinkDialog/VBoxContainer/HBoxContainer2/EtatDebut.selected
	var fin = $Popups/NewLinkDialog/VBoxContainer/HBoxContainer3/EtatFin.selected
	var mot = $Popups/NewLinkDialog/VBoxContainer/HBoxContainer4/Mot.text
	var etat_debut =  $Etats.get_child(debut)
	var etat_fin = $Etats.get_child(fin)
	
	var new_instruction = _ins_exists(etat_debut, etat_fin)
	if etat_debut == etat_fin:
		if new_instruction == null:
			new_instruction = Instruction.instance()
			new_instruction.mot_lu.append(mot)
			new_instruction.etat_debut = etat_debut
			new_instruction.etat_fin = etat_fin
			new_instruction.boucle = true
			etat_debut.show_boucle(new_instruction.mot_lu)
			new_instruction.connect("right_click_instruction", self, "_on_right_click_instruction")
			$Instructions.add_child(new_instruction)
		else:
			new_instruction.mot_lu.append(mot)
			etat_debut.show_boucle(new_instruction.mot_lu)
			print(new_instruction.mot_lu)
	else:
		if  new_instruction == null:
			new_instruction = Instruction.instance()
			new_instruction.etat_debut = etat_debut
			new_instruction.etat_fin = etat_fin
			new_instruction.connect("right_click_instruction", self, "_on_right_click_instruction")
			$Instructions.add_child(new_instruction)
	
		new_instruction.mot_lu.append(mot)

func _ins_exists(debut, fin):
	for	child in $Instructions.get_children():
		if (child.etat_debut == debut) and (child.etat_fin == fin):
			return child
	return null

func _on_right_click_instruction(instruction):
	etat_popup_opened = true
	last_instruction_clicked = instruction
	print(last_instruction_clicked.etat_debut.nom, last_instruction_clicked.etat_fin.nom)
	$Popups/PopupMenuInstruction.rect_position = get_global_mouse_position()
	$Popups/PopupMenuInstruction.popup()

func _on_right_click_boucle(etat):
	etat_popup_opened = true
	for child in $Instructions.get_children():
		if (child.etat_debut == etat) and (child.etat_fin == etat):
			last_instruction_clicked = child
	print(last_instruction_clicked.etat_debut.nom, last_instruction_clicked.etat_fin.nom)
	$Popups/PopupMenuInstruction.rect_position = get_global_mouse_position()
	$Popups/PopupMenuInstruction.popup()


func _on_PopupMenuInstruction_id_pressed(id):
	match id:
		0:#edit
			pass
		1:#delete
			if last_instruction_clicked.etat_debut == last_instruction_clicked.etat_fin:
				last_instruction_clicked.etat_debut.hide_boucle()
			last_instruction_clicked.queue_free()
