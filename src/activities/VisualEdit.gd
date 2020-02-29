extends Node2D

var Etat = preload("res://src/entities/Etat.tscn")
var Instruction = preload("res://src/entities/Instruction.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var etat1 = Etat.instance()
	etat1.position = Vector2(200, 200)
	etat1.nom = "S1"
	var etat2 = Etat.instance()
	etat2.position = Vector2(500, 800)
	etat2.nom = "S2"
	$Etats.add_child(etat1)
	$Etats.add_child(etat2)
	var instruction = Instruction.instance()
	instruction.etat_debut = etat1
	instruction.etat_fin = etat2
	$Instructions.add_child(instruction)
	pass # Replace with function body.

