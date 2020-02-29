extends ViewportContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ViewportContainer_mouse_entered():
	print("mouse entred")
	pass # Replace with function body.


func _on_ViewportContainer_focus_entered():
	print("focus entred")
	pass # Replace with function body.
