extends Node2D

#Colors
const white = Color(1, 1, 1, 1)
const blue = Color(0, 0, 1, 1)

var etat_debut : KinematicBody2D
var mot_lu = []
var etat_fin : KinematicBody2D

func _draw():
	var center = (etat_debut.position + etat_fin.position) / 2
	var start = etat_debut.position
	var end = etat_fin.position
	var start_angle = atan2(start.y - center.y, start.x - center.x)
	var end_angle = atan2(end.y - center.y, end.x - center.x)
	var radius = etat_debut.position.distance_to(center)
	#draw link
	draw_line(etat_debut.position, etat_fin.position, Color(1, 1, 1, 1), 10)
	#draw_arc(center, radius, start_angle, end_angle, 32, Color(1, 1, 1, 1), 10)
	
	#rotate arrow
	$Arrow.position = center
	var angle = end.angle_to_point(start)
	$Arrow.rotation_degrees = rad2deg(angle)
	
	#draw  word
	var word = String(mot_lu)
	draw_string(load("res://assets/fonts/font_button.tres"), Vector2(center.x, center.y - 50), word)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
		#$Line2D.set_point_position(0, etat_debut.position)
		#$Line2D.set_point_position(1, etat_fin.position)
		update()

func set_etat_fin(etat):
	etat_fin = etat
	for i in range($Line2D.points.size()):
		if i == 0:
			continue
		else:
			$Line2D.remove_point(i)
	$Line2D.add_point(etat_fin.position)
	print(etat_debut.nom, etat_fin.nom)

func draw_circle_arc( center, radius, angle_from, angle_to, color ):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
		var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
		points_arc.push_back( point )
		
	for indexPoint in range(nb_points):
		draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)
