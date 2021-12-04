extends KinematicBody2D
class_name Pushable

#member variables
var SPEED=50



func push(direction):
	#move only on one (significant) axis
#	if abs(direction.x)>abs(direction.y):
#		direction.y=0
#	elif abs(direction.x)<abs(direction.y):
#		direction.x=0
	move_and_slide(direction.normalized()*SPEED)

