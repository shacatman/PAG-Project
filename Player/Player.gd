extends KinematicBody2D


#variables
onready var MAX_SPEED=100
onready var ACCELERATION=600
onready var FRICTION=600
var velocity=Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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

