extends Node

var rejected = []

func _ready():
	pass

func _process(delta):
	print(_is_etat_coaccessible($Automate/Etats/Etat2, $Automate/Etats/Etat2))
	pass

func _is_etat_accessible(etat_initial, etat):
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
			return _is_etat_accessible(suc, etat)
	return false

func _is_etat_coaccessible(etat, etat_root):
	if etat.final:
		return true
	if etat == etat_root:
		rejected.clear()
	rejected.append(etat)
	for suc in _get_successeur(etat):
		if suc in rejected:
			continue
		if suc.final:
			return true
		else:
			rejected.append(suc)
			return _is_etat_coaccessible(suc, etat_root)
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
