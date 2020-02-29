extends Node2D


var nom : String
var final : bool = false
var initial : bool = false

func _ready():
	$Area2D/Nom.text = nom
	if not final:
		$Area2D/SpriteFinal.hide()
	if not initial:
		$Area2D/SpriteInitial.hide()


func _process(delta):
	if Input.is_action_pressed("click"):
		print("clicked:")


func _on_etat_input_event(viewport, event, shape_idx):
	print("input")


func _on_Area2D_mouse_entered():
	print("entred")
