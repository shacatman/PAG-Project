class_name Player
extends KinematicBody2D

# Defines the Player class: movement and interaction with the enviroment

signal speak
#variables
var velocity : = Vector2.ZERO
onready var MAX_SPEED : = 100
onready var ACCELERATION : = 600
onready var FRICTION : = 600
onready var collisionShape:CollisionShape2D = $CollisionShape2D
onready var sprite : = $Sprite

func _ready():#stops player input during dialog sections
	Dialog.connect("dialogStarted", self, "set_physics_process", [false])
	Dialog.connect("dialogEnded", self, "set_physics_process", [true])

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
		#sprite frame:	
		if abs(velocity.y) >abs(velocity.x):
			if velocity.y > 0:#going down
				sprite.set_frame(0)
			elif velocity.y < 0:
				sprite.set_frame(2)
		else:
			if velocity.x > 0:#going right
				sprite.set_frame(1)
			elif velocity.x < 0:
				sprite.set_frame(3)
	else:#stop the movement
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
	move_and_slide(velocity)#apply the velocity on the player
	
	if get_slide_count() > 0:#collision check
		var pushable : = get_slide_collision(0).collider as Pushable
		if pushable:
			pushable.push(-get_slide_collision(0).normal)
	
	if Input.is_key_pressed(KEY_E) and !Dialog.talking:#dialog checking
		emit_signal("speak")#npcs connect to the signal
		

func getSaveData():#Persistent_Static
	return {"PlayerPos": [global_position.x,global_position.y], "PlayerFrame" : sprite.frame}
	
func loadData(data:Dictionary):#Persistent_Static
	global_position.x = float(data["PlayerPos"][0])
	global_position.y = float(data["PlayerPos"][1])
	sprite.set_frame(int(data["PlayerFrame"]))
