extends Node2D


var etat_debut
var mot_lu : String
var etat_fin


# Called when the node enters the scene tree for the first time.
func _ready():
	$Line2D.add_point(etat_debut.position)
	$Line2D.add_point(etat_fin.position)

func _process(delta):
	pass
