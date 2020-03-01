extends Node

var linking : bool = false
var editing_link

func _ready():
	pass

func link_with(etat):
	editing_link.set_etat_fin(etat)
	editing_link = null
	linking = false
