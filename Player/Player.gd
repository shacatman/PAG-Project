class_name Player
extends KinematicBody2D

# Defines the Player class: movement and interaction with the enviroment

#variables
var velocity : = Vector2.ZERO
onready var MAX_SPEED : = 100
onready var ACCELERATION : = 600
onready var FRICTION : = 600
onready var collisionShape:CollisionShape2D=$CollisionShape2D


# Called every physics frame. Deals with physics logic.
func _physics_process(delta):
	var input_vector : = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	#player moves, update velocity.
	if input_vector != Vector2.ZERO:
		velocity += input_vector * ACCELERATION * delta#v=v0+a*t
		velocity = velocity.clamped(MAX_SPEED)
	else:#stop the movement
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
	move_and_slide(velocity)#apply the velocity on the player
	
	if get_slide_count() > 0:#collision check
		var pushable : = get_slide_collision(0).collider as Pushable
		if pushable:
			pushable.push(-get_slide_collision(0).normal)

