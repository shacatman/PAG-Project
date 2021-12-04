extends KinematicBody2D
class_name Pushable

#member variables
onready var SPEED=50



func push(direction):
	#move only on one (significant) axis
#	if abs(direction.x)>abs(direction.y):
#		direction.y=0
#	elif abs(direction.x)<abs(direction.y):
#		direction.x=0
	move_and_slide(direction.normalized()*SPEED)


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
