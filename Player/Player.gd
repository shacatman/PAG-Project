extends KinematicBody2D
class_name Player

#variables
onready var MAX_SPEED=100
onready var ACCELERATION=600
onready var FRICTION=600
#onready var pushables={}
var velocity=Vector2.ZERO


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	#player moves,update velocity.
	if input_vector != Vector2.ZERO:
		velocity += input_vector * ACCELERATION * delta#v=v0+a*t
		velocity = velocity.clamped(MAX_SPEED)
	else:#stop the movement
		velocity = velocity.move_toward(Vector2.ZERO,delta*FRICTION)
	move_and_slide(velocity)
	if get_slide_count()>0:
		var pushable = get_slide_collision(0).collider as Pushable
		if pushable:
			pushable.push(-get_slide_collision(0).normal)#input_vector)

#	for pushable in pushables:
#		pushable.push(pushables[pushable])

#
#func _on_BoxInteraction_body_entered(box):
##	print("entered!!!")
#	var direction= box.global_position -global_position
#		#move only on one (significant) axis
#	if abs(direction.x)>abs(direction.y):
#		direction.y=0
#	elif abs(direction.x)<abs(direction.y):
#		direction.x=0
#	pushables[box]=direction.normalized()
##	box.push(direction.normalized())
#	pass # Replace with function body.
#
#
#func _on_BoxInteraction_body_exited(box):
#	pushables.erase(box)
#	pass # Replace with function body.
