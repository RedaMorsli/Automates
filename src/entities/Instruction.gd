extends Node2D


var etat_debut
var mot_lu : String
var etat_fin


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
		$Line2D.set_point_position(0, etat_debut.position)
		$Line2D.set_point_position(1, etat_fin.position)

func set_etat_fin(etat):
	etat_fin = etat
	for i in range($Line2D.points.size()):
		if i == 0:
			continue
		else:
			$Line2D.remove_point(i)
	$Line2D.add_point(etat_fin.position)
	print(etat_debut.nom, etat_fin.nom)
