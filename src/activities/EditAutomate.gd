extends Node2D

var etat_popup_opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_right_mouse") and (not etat_popup_opened):
		$EditCamera/PopupMenuVoid.rect_position = get_global_mouse_position()
		$EditCamera/PopupMenuVoid.popup()


func _on_Etat_right_click_etat():
	etat_popup_opened = true
	$EditCamera/PopupMenuEtat.rect_position = get_global_mouse_position()
	$EditCamera/PopupMenuEtat.popup()


func _on_PopupMenuEtat_popup_hide():
	etat_popup_opened = false


func _on_PopupMenuVoid_id_pressed(id):
	match id:
		0:#New état
			$EditCamera/NewEtatDialog.rect_position = $EditCamera.get_camera_screen_center()
			$EditCamera/NewEtatDialog.popup()
