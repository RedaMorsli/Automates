extends RigidBody2D


var nom : String
var final : bool = false
var initial : bool = false

func _ready():
	$Nom.text = nom
	if not final:
		$SpriteFinal.hide()
	if not initial:
		$SpriteInitial.hide()


func _on_Etat_input_event(viewport, event, shape_idx):
	print("input!")
