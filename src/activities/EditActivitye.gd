extends Node

var Etat = preload("res://src/entities/Etat.tscn")
var Instruction = preload("res://src/entities/Instruction.tscn")
var rejected = []

func _ready():
	pass

func _process(delta):
	pass

func is_accessible(etat):
	return _is_etat_accessible(_get_etat_initial(), etat)

func is_coaccessible(etat):
	return _is_etat_coaccessible(etat, etat)

func smiplifier():
	var instructions = $Automate/Instructions.get_children()
	for ins in instructions:
		if decomposer(ins):
			delete_instruction(ins)

func decomposer(instrcution):
	var delete_ins = true
	var index_deleted = []
	var index = 0
	for word in instrcution.mot_lu:
		if word.length() > 1:
			index_deleted.append(index)
			var new_etats = []
			var new_ins = []
			for i in range(word.length()):
				var c = word[i]
				var inc = Instruction.instance()
				inc.mot_lu = c
				if i == 0:
					inc.etat_debut = instrcution.etat_debut
				if i == (word.length() - 1):
					inc.etat_fin = instrcution.etat_fin
				new_ins.append(inc)
			for i in range(word.length() - 1):
				var etat = Etat.instance()
				etat.nom = word[i] + word[i+1]
				new_etats.append(etat)
			var i = 0
			for ins in new_ins:
				if ins.etat_debut == null:
					ins.etat_debut = new_etats[i]
					if ins.etat_fin == null:
						ins.etat_fin = new_etats[i+1]
				else:
					ins.etat_fin = new_etats[i]
			#debug
			for etat in new_etats:
				print(etat.nom)
			for ins in new_ins:
				print(ins.etat_debut, ins.mot_lu, ins.etat_fin)
		else:
			delete_ins = false
		index += 1
	if not delete_ins:
		for id in index_deleted:
			instrcution.mot_lu.remove(id)
		if instrcution.etat_debut == instrcution.etat_fin:
			instrcution.etat_debut.show_boucle(instrcution.mot_lu)
	return delete_ins

func _is_etat_accessible(etat_initial, etat):
	if etat.initial:
		return true
	var current_etat = etat_initial
	if current_etat == _get_etat_initial():
		rejected.clear()
	if current_etat == etat:
		return false
	rejected.append(current_etat)
	for suc in _get_successeur(current_etat):
		if suc in rejected:
			continue
		if suc == etat:
			return true
		else:
			rejected.append(suc)
			if _is_etat_accessible(suc, etat):
				return true
	if etat_initial == _get_etat_initial(): 
		return false

func _is_etat_coaccessible(etat, etat_root):
	if etat.final:
		return true
	if etat == etat_root:
		rejected.clear()
	rejected.append(etat)
	for suc in _get_successeur(etat):
		if suc.final:
			return true
		if suc in rejected:
			continue
		else:
			rejected.append(suc)
	for suc in _get_successeur(etat):
		if _is_etat_coaccessible(suc, etat_root):
			return true
	if etat == etat_root:
		return false

func _get_etat_initial():
	for etat in $Automate/Etats.get_children():
		if etat.initial:
			return etat

func _get_successeur(etat):
	var instructions = $Automate/Instructions.get_children()
	var sucs = []
	for ins in instructions:
		if ins.etat_debut == etat:
			sucs.append(ins.etat_fin)
	return sucs

func _get_predecesseur(etat):
	pass

func delete(etat):
	for child in $Automate/Instructions.get_children():
		if (child.etat_debut == etat) or (child.etat_fin == etat):
			child.queue_free()
		etat.queue_free()

func delete_instruction(instruction):
	if instruction.etat_debut == instruction.etat_fin:
		instruction.etat_debut.hide_boucle()
	instruction.queue_free()


func _on_ReductionDialog_confirmed():
	for etat in $Automate/Etats.get_children():
		if (not is_accessible(etat)) or (not is_coaccessible(etat)):
			delete(etat)


func _on_PopupOperations_id_pressed(id):
	match id:
		1:#Réduction
			$GUI/ReductionDialog/MarginContainer/Tree.clear()
			var root = $GUI/ReductionDialog/MarginContainer/Tree.create_item()
			root.set_text(0, "Etats")
			var etats = $GUI/ReductionDialog/MarginContainer/Tree.create_item(root)
			etats.set_text(0, "Etats accessibles et co-accessibles")
			for etat in $Automate/Etats.get_children():
				if is_accessible(etat) and is_coaccessible(etat):
					var child = $GUI/ReductionDialog/MarginContainer/Tree.create_item(etats)
					child.set_text(0, etat.nom)
			var etats_non_acc = $GUI/ReductionDialog/MarginContainer/Tree.create_item(root)
			etats_non_acc.set_text(0, "Etats non accessibles")
			for etat in $Automate/Etats.get_children():
				if not is_accessible(etat):
					var child = $GUI/ReductionDialog/MarginContainer/Tree.create_item(etats_non_acc)
					child.set_text(0, etat.nom)
			var etats_non_coacc = $GUI/ReductionDialog/MarginContainer/Tree.create_item(root)
			etats_non_coacc.set_text(0, "Etats non co-accessibles")
			for etat in $Automate/Etats.get_children():
				if not is_coaccessible(etat):
					var child = $GUI/ReductionDialog/MarginContainer/Tree.create_item(etats_non_coacc)
					child.set_text(0, etat.nom)
			$GUI/ReductionDialog.popup_centered_ratio(0.4)
		2:#simplifier
			smiplifier()
