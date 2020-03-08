extends Node

var automate_name

#Colors
const WHITE = Color(1, 1, 1, 1)
const RED = Color(1, 0, 0, 1)
const GREEN = Color(0, 1, 0, 1)
const BLUE = Color(0, 0, 1, 1)

var Etat = preload("res://src/entities/Etat.tscn")
var Instruction = preload("res://src/entities/Instruction.tscn")

var rejected = []

func _ready():
	pass

func complementaire():
	for etat in $Automate/Etats.get_children():
		etat.set_final(!etat.final)
	var alphabet = get_alphabet()
	var p = Etat.instance()
	p.nom = "P"
	p.final = true
	p.initial = false
	p.position = Vector2(1700, 1000)
	p.connect("right_click_etat", $Automate, "_on_Etat_right_click_etat")
	p.connect("right_click_boucle", $Automate, "_on_right_click_boucle")
	var p_ins = Instruction.instance()
	p_ins.mot_lu = alphabet
	p_ins.etat_debut = p
	p_ins.etat_fin = p
	p.show_boucle(p_ins.mot_lu)
	var instructions = []
	for etat in $Automate/Etats.get_children():
		for x in alphabet:
			var ins = _get_ins(etat, x)
			if ins.size() == 0:
				var new_ins = Instruction.instance()
				new_ins.etat_debut = etat
				new_ins.etat_fin = p
				new_ins.mot_lu.append(x)
				new_ins.connect("right_click_instruction", $Automate, "_on_right_click_instruction")
				instructions.append(new_ins)
				#$Automate/Instructions.add_child(new_ins)
				
	if !instructions.empty():
		$Automate/Etats.add_child(p)
		$Automate/Instructions.add_child(p_ins)
		for i in instructions:
			$Automate/Instructions.add_child(i)

func miroir():
	for ins in $Automate/Instructions.get_children():
		var etat = ins.etat_debut
		ins.etat_debut = ins.etat_fin
		ins.etat_fin = etat
		var reverse = []
		for word in ins.mot_lu:
			reverse.append(string_reverse(word))
		ins.mot_lu = reverse
		if ins.etat_debut == ins.etat_fin:
			ins.etat_debut.show_boucle(ins.mot_lu)
	for etat in $Automate/Etats.get_children():
		if etat.final and etat.initial:
			continue
		if etat.final:
			etat.set_final(false)
			etat.set_initial(true)
			continue
		if etat.initial:
			etat.set_final(true)
			etat.set_initial(false)
			continue

func string_reverse(a):
	var b
	var c = []
	var d = []
	for b in a:
		c.append(b)
	while c.size() > 0:
		d.append(c.back())
		c.pop_back()
		a = ""
	for b in d:
		a = a + str(b)
	return(a)

func read_word(word : String):
	for ins in $Automate/Instructions.get_children():
			ins.color = WHITE
	var etats_parcouru = []
	var ins_parcouru = []
	match is_word_readable(word, etats_parcouru, ins_parcouru):
		true:
			for ins in ins_parcouru:
				ins.color = GREEN
		false:
			$GUI/LireDialog/MarginContainer2/VBoxContainer/HBoxContainer3/ResultatText.text = "n'appartient pas à L(A)"
			for ins in ins_parcouru:
				ins.color = RED
		"nope":
			$GUI/LireDialog/MarginContainer2/VBoxContainer/HBoxContainer3/ResultatText.text = "automate non déterminisé"
			$GUI/DeterminateDialog.popup_centered()

func is_word_readable(word : String, etats_parcouru : Array, ins_parcouru : Array):
	var current_etat = _get_etat_initial()
	for i in word.length():
		var ins = _get_ins(current_etat, word[i])
		if ins.size() > 1: #non déterministe
			return "nope"
		elif ins.size() == 0: #n'appartient pas au L(A)
			return false
		else: # ins.size() == 1
			if not (ins[0].etat_debut in etats_parcouru):
				etats_parcouru.append(ins[0].etat_debut)
			if not (ins[0].etat_fin in etats_parcouru):
				etats_parcouru.append(ins[0].etat_fin)
			if not (ins[0] in ins_parcouru):
				ins_parcouru.append(ins[0])
			current_etat = ins[0].etat_fin
	if current_etat.final:
		$GUI/LireDialog/MarginContainer2/VBoxContainer/HBoxContainer3/ResultatText.text = "appartient à L(A)"
	return current_etat.final

func _get_ins(etat_debut, x):
	var t = []
	for ins in $Automate/Instructions.get_children():
		if (etat_debut == ins.etat_debut) and (x in ins.mot_lu):
			t.append(ins)
	return t

func is_simple():
	for ins in $Automate/Instructions.get_children():
		if "€" in ins.mot_lu:
			return false
		for word in ins.mot_lu:
			if word.length() > 1:
				return false
	return true

func is_deterministe():
	var alphabet = get_alphabet()
	for etat in $Automate/Etats.get_children():
		for x in alphabet:
			var ins =  _get_ins(etat, x)
			if ins.size() > 1:
				return false
	return true

func determiniser():
	var alphabet = get_alphabet()
	var new_etats = []
	var new_names = []
	var not_treated_etats = []
	var new_ins = []
	
	var current_etat = _get_etat_initial()
	var s0 = Etat.instance()
	s0.nom = "S0"
	s0.initial = true
	s0.final = current_etat.final
	new_names.append(s0)
	
	current_etat = [current_etat]
	new_etats.append(current_etat)
	
	var name_id = 0
	var stop = false
	
	while(!stop):
		for c in alphabet:
			var etat = get_states_when_read_x(current_etat, c)
			if etat.empty():
				continue
			var exist = false
			var etat_if_exist
			for state in new_etats:
				if states_equal(state, etat):
					exist = true
					etat_if_exist = new_names[new_etats.find(state)]
					break
			if not exist: 
				new_etats.append(etat)
				not_treated_etats.append(etat)
				name_id += 1
				#create etat instance
				var s = Etat.instance()
				s.nom = "S" + String(name_id)
				s.initial = false
				s.final = false
				for state in etat:
					if state.final:
						s.final = true
						break
				new_names.append(s)
				#create instruction instance
				var ins = Instruction.instance()
				ins.mot_lu.append(c)
				ins.etat_debut = new_names[new_etats.find(current_etat)]
				ins.etat_fin = s
				new_ins.append(ins)
			else: #etat exists
				var ins = Instruction.instance()
				ins.mot_lu.append(c)
				ins.etat_debut = new_names[new_etats.find(current_etat)]
				ins.etat_fin = etat_if_exist
				new_ins.append(ins)
				pass
		not_treated_etats.erase(current_etat)
		if not_treated_etats.empty():
			stop = true
		else:
			current_etat = not_treated_etats[0]
	
	display_states_and_ins(new_names, new_ins)

func display_states_and_ins(states, ins):
	for etat in $Automate/Etats.get_children():
		etat.queue_free()
	for i in $Automate/Instructions.get_children():
		i.queue_free()
	for etat in states:
		etat.connect("right_click_etat", $Automate, "_on_Etat_right_click_etat")
		etat.connect("right_click_boucle", $Automate, "_on_right_click_boucle")
		$Automate/Etats.add_child(etat)
	for i in ins:
		if i.etat_debut == i.etat_fin:
			i.etat_debut.show_boucle(i.mot_lu)
		i.connect("right_click_instruction", $Automate, "_on_right_click_instruction")
		$Automate/Instructions.add_child(i)
	reorganize_positions()

func get_states_when_read_x(states, x):
	var etats = []
	for s in states:
		for e in _get_successeur_mot(s, x):
			if not (e in etats):
				etats.append(e)
	return etats

func states_equal(etat1, etat2):
	var equal = true
	for etat in etat1:
		if etat in etat2:
			continue
		else:
			equal = false
			break
	if equal:
		for etat in etat2:
			if etat in etat1:
				continue
			else:
				equal = false
				break
	return equal

func get_alphabet():
	var alphabet = []
	for ins in $Automate/Instructions.get_children():
		for word in ins.mot_lu:
			for i in range(word.length()):
				if not (word[i] in alphabet):
					alphabet.append(word[i])
	return alphabet

func is_accessible(etat):
	return _is_etat_accessible(_get_etat_initial(), etat)

func is_coaccessible(etat):
	rejected.clear()
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
			#create
			for i in range(word.length()):
				var c = word[i]
				var inc = Instruction.instance()
				inc.connect("right_click_instruction", $Automate, "_on_right_click_instruction")
				inc.mot_lu.append(c)
				if i == 0:
					inc.etat_debut = instrcution.etat_debut
				if i == (word.length() - 1):
					inc.etat_fin = instrcution.etat_fin
				new_ins.append(inc)
			for i in range(word.length() - 1):
				var etat = Etat.instance()
				etat.connect("right_click_etat", $Automate, "_on_Etat_right_click_etat")
				etat.connect("right_click_boucle", $Automate, "_on_right_click_boucle")
				etat.nom = word[i] + word[i+1]
				new_etats.append(etat)
			var i = 0
			#link
			for etat in new_etats:
				if i == 0:
					new_ins[i].etat_debut = instrcution.etat_debut
					new_ins[i].etat_fin = etat
					if new_etats.size() == 1:
						new_ins[i+1].etat_debut = etat
						new_ins[i+1].etat_fin = instrcution.etat_fin
				elif i == new_etats.size() - 1:
					new_ins[i].etat_debut = new_etats[i-1]
					new_ins[i].etat_fin = etat
					new_ins[i+1].etat_debut = etat
					new_ins[i+1].etat_fin = instrcution.etat_fin
				else:
					new_ins[i].etat_debut = new_etats[i-1]
					new_ins[i].etat_fin = etat
				i += 1
			#display
			for etat in new_etats:
				etat.position = _get_nearest_position(instrcution.etat_debut.position)
				$Automate/Etats.add_child(etat)
			for ins in new_ins:
				$Automate/Instructions.add_child(ins)
		else:
			delete_ins = false
		index += 1
	if not delete_ins:
		for id in index_deleted:
			instrcution.mot_lu.remove(id)
		if instrcution.etat_debut == instrcution.etat_fin:
			instrcution.etat_debut.show_boucle(instrcution.mot_lu)
	return delete_ins

func delete_epsilons():
	for etat_epsilon in _get_etats_epsilon():
		rejected.clear()
		for clos in _get_epsilon_clos(etat_epsilon):
			if clos.final:
				etat_epsilon.set_final(true)
			for trans in _get_transitions(clos):
				rejected.clear()
				for etat in _get_epsilon_clos_trans(trans.etat_fin):
					for c in trans.mot_lu:
						#if c != "€":
						add_trans(etat_epsilon, etat, c)
	
	for ins in $Automate/Instructions.get_children():
		if _delete_char(ins.mot_lu, "€"):
			if ins.etat_debut == ins.etat_fin:
				ins.etat_debut.hide_boucle()
			ins.queue_free()

func _get_etats_epsilon():
	return $Automate/Etats.get_children()

func _get_epsilon_clos(etat_epsilon): #rejected.clear() before call
	var clos = []
	if not(etat_epsilon in rejected):
		clos.append(etat_epsilon)
		rejected.append(etat_epsilon)
		for suc in _get_successeur_mot(etat_epsilon, "€"):
			var suc_clos = _get_epsilon_clos(suc)
			if suc_clos.size() != 0:
				for c in suc_clos:
					clos.append(c)
		return clos
	else:
		return clos

func _get_transitions(epsilon_clos):
	return _get_instruction_without_mot(epsilon_clos, "€")

func _get_epsilon_clos_trans(transition):
	return _get_epsilon_clos(transition)

func add_trans(etat_debut, etat_fin, mot):
	var new_ins = _trans_exist(etat_debut, etat_fin, mot)
	if new_ins != null:
		if new_ins.etat_debut == null:
			new_ins.etat_debut = etat_debut
			new_ins.etat_fin = etat_fin
			new_ins.mot_lu.append(mot)
			new_ins.connect("right_click_instruction", $Automate, "_on_right_click_instruction")
			if new_ins.etat_debut == new_ins.etat_fin:
				new_ins.etat_debut.show_boucle(new_ins.mot_lu)
			else:
				$Automate/Instructions.add_child(new_ins)
		else:
			new_ins.mot_lu.append(mot)
			if new_ins.etat_debut == new_ins.etat_fin:
				new_ins.etat_debut.show_boucle(new_ins.mot_lu)

func _trans_exist(etat_debut, etat_fin, mot):
	for ins in $Automate/Instructions.get_children():
		if (etat_debut == ins.etat_debut) and (etat_fin == ins.etat_fin) and (mot in ins.mot_lu):
			return null
		elif (etat_debut == ins.etat_debut) and (etat_fin == ins.etat_fin):
			return ins
	return Instruction.instance()

func _delete_char(variable, mot):
	variable.erase(mot)
	if variable.size() == 0:
		return true
	return false

func _get_nearest_position(from_pos : Vector2):
	var position = from_pos
	var etats = $Automate/Etats.get_children()
	var instrcutions = $Automate/Instructions.get_children()
	var taken = []
	for etat in etats:
		taken.append(etat.position)
	for ins in instrcutions:
		taken.append(ins.get_position())
	while(_is_colliding(position, taken)):
		position += Vector2(40, 40)
	return position

func _is_colliding(point : Vector2, points):
	for p in points:
		if not (point.distance_to(p) >= 120):
			return true
	return false

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
	#if etat == etat_root:
		#rejected.clear()
	rejected.append(etat)
	for suc in _get_successeur(etat):
		var nom = suc.nom
		if suc in rejected:
			continue
		if suc.final:
			return true
		else:
			rejected.append(suc)
			if _is_etat_coaccessible(suc, etat_root):
				return true
	#for suc in _get_successeur(etat):
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

func _get_successeur_mot(etat, mot):
	var instructions = $Automate/Instructions.get_children()
	var sucs = []
	for ins in instructions:
		if (ins.etat_debut == etat) and (mot in ins.mot_lu):
			sucs.append(ins.etat_fin)
	return sucs

func _get_instruction_without_mot(etat_debut, mot):
	var instructions = $Automate/Instructions.get_children()
	var sucs = []
	for ins in instructions:
		if (ins.etat_debut == etat_debut):
			if (mot in ins.mot_lu):
				if ins.mot_lu.size() >= 1:
					sucs.append(ins)
			else:
				sucs.append(ins)
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

func reorganize_positions():
	var PosEtats = $Automate/Positions/PosEtats.get_children()
	var PosInstructions = $Automate/Positions/PosInstructions.get_children()
	var i = 0
	for etat in $Automate/Etats.get_children():
		etat.position = PosEtats[i].position
		i += 1
	i = 0
	for ins in $Automate/Instructions.get_children():
		ins.set_arrow_positoin(PosInstructions[i].position)
		i += 1

func _on_ReductionDialog_confirmed():
	for etat in $Automate/Etats.get_children():
		if (not is_accessible(etat)) or (not is_coaccessible(etat)):
			delete(etat)

func _on_PopupOperations_id_pressed(id):
	match id:
		0: #Read word
			if (not is_simple()) or (not is_deterministe()):
				$GUI/LireDialog/MarginContainer2/VBoxContainer/HBoxContainer3/ResultatText.text = "automate non déterminisé"
				$GUI/DeterminateDialog.popup_centered()
			else:
				$GUI/LireDialog.popup_centered()
				$GUI/LireDialog/MarginContainer2/VBoxContainer/HBoxContainer3/ResultatText.text = ""
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
			$GUI/SimplifyDialog.popup_centered()
		3:#determiniser
			$GUI/DeterminateDialog.popup_centered()
		4:#miroir
			$GUI/MiroirDialog.popup_centered()
		5:#complémentaire
			$GUI/ComplementaireDialog.popup_centered()

func _on_PopupAutomate_id_pressed(id):
	match id:
		0: #reorganizer
			reorganize_positions()
		3:#delete all
			$GUI/DeleteAllDialog.popup_centered()
		7:#Quitter
			$GUI/QuitDialog.popup_centered()

func _on_SimplifyDialog_confirmed():
	smiplifier()
	delete_epsilons()

func _on_DeterminateDialog_confirmed():
	smiplifier()
	delete_epsilons()
	determiniser()

func _on_LireButton_pressed():
	read_word($GUI/LireDialog/MarginContainer2/VBoxContainer/HBoxContainer2/LireText.text)


func _on_LireDialog_popup_hide():
	for ins in $Automate/Instructions.get_children():
			ins.color = WHITE


func _on_MiroirDialog_confirmed():
	miroir()


func _on_ComplementaireDialog_confirmed():
	complementaire()


func _on_DeleteAllDialog_confirmed():
	for ins in $Automate/Instructions.get_children():
		ins.queue_free()
	for etat in $Automate/Etats.get_children():
		etat.queue_free()


func _on_QuitDialog_confirmed():
	get_tree().quit()
