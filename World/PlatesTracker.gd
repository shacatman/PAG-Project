extends Node2D

# Defines the PlatesTracker object which keeps track of the plates' states in the level

var platesGoal : int = 0
var platesPressed : int = 0
onready var barrier = $Barrier
#signal levelCompleted

# Called when the node enters the scene tree for the first time.
func _ready():
	#needed only if children are not all plates! otherwise use: platesGoal = get_child_count() 
	for child in get_children():
		if child is Area2D:
			platesGoal += 1
#	print("Goal:",platesGoal)

func platePressed():#called by Plate objects whenever plate is pressed
	platesPressed += 1
	if platesPressed == platesGoal:
		barrier.queue_free()
#		emit_signal("levelCompleted")

func plateUnPressed():#called by Plate objects whenever plate is unpressed
	platesPressed-=1

