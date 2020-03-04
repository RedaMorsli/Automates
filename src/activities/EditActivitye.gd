extends Node

var rejected = []

func _ready():
	pass

func _process(delta):
	pass

func is_accessible(etat):
	return _is_etat_accessible(_get_etat_initial(), etat)

func is_coaccessible(etat):
	return _is_etat_coaccessible(etat, etat)

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
