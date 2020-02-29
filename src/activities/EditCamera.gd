extends Camera2D

var is_camera_control_enabeled : bool = true
var start_drag_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	enable_camera_control()
	pass

func _input(event):
	if not is_camera_control_enabeled:
		return
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				if (self.zoom.x >= 0.3) and (self.zoom.y >= 0.3):
					self.zoom -= Vector2(0.1, 0.1)
					for node in self.get_children():
						node.rect_scale -= Vector2(0.1, 0.1)
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				self.zoom += Vector2(0.1, 0.1)
				for node in self.get_children():
						node.rect_scale += Vector2(0.1, 0.1)
				

func enable_camera_control():
	if Input.is_action_just_pressed("ui_middle_mouse"):
		start_drag_position = get_global_mouse_position()
	if Input.is_action_pressed("ui_middle_mouse"):
		self.position += start_drag_position - get_global_mouse_position()
